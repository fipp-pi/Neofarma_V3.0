/**
 * Expedição de pedidos da loja (MVP operacional).
 * Filas, despacho (SHIPPED) e confirmação de entrega (DELIVERED).
 */
const { pool } = require('../config/database');

let columnsReady = false;

async function ensureColumns() {
  if (columnsReady) return;
  const alters = [
    'ALTER TABLE orders ADD COLUMN tracking_code VARCHAR(80) NULL AFTER shipping_deadline_days',
    'ALTER TABLE orders ADD COLUMN shipped_at DATETIME NULL AFTER tracking_code',
    'ALTER TABLE orders ADD COLUMN delivered_at DATETIME NULL AFTER shipped_at',
    'ALTER TABLE orders ADD COLUMN delivered_by BIGINT UNSIGNED NULL AFTER delivered_at',
  ];
  for (const sql of alters) {
    try {
      await pool.execute(sql);
    } catch (err) {
      if (err && err.code !== 'ER_DUP_FIELDNAME') throw err;
    }
  }
  try {
    await pool.execute(
      `ALTER TABLE orders
       ADD CONSTRAINT fk_orders_delivered_by
       FOREIGN KEY (delivered_by) REFERENCES users(id)
       ON UPDATE CASCADE ON DELETE SET NULL`
    );
  } catch (err) {
    if (err && err.code !== 'ER_DUP_KEYNAME' && err.code !== 'ER_CANT_CREATE_TABLE' && err.code !== 'ER_FK_DUP_NAME') {
      // FK opcional — ignora se já existir ou se users incompatível em ambientes legados.
    }
  }
  columnsReady = true;
}

function buildQueueCaseSql() {
  return `
    CASE
      WHEN o.status = 'DELIVERED' THEN 'DELIVERED'
      WHEN o.status = 'SHIPPED' THEN 'SHIPPED'
      WHEN o.status = 'PROCESSING' AND COALESCE(oi.items_count, 0) > 0 THEN 'READY_TO_SHIP'
      WHEN o.status = 'PROCESSING' AND COALESCE(opi.pending_count, 0) > 0 THEN 'STOCK_PENDING'
      WHEN o.status = 'PROCESSING' THEN 'READY_TO_SHIP'
      ELSE 'OTHER'
    END`;
}

/**
 * @param {{ queue?: string, search?: string, page?: number, pageSize?: number }} [options]
 */
async function listOrders(options = {}) {
  await ensureColumns();
  const queue = String(options.queue || 'ALL').toUpperCase();
  const search = options.search ? String(options.search).trim() : '';
  const page = Math.max(1, parseInt(options.page, 10) || 1);
  const pageSize = Math.min(100, Math.max(10, parseInt(options.pageSize, 10) || 20));
  const offset = (page - 1) * pageSize;

  const whereParts = ["o.payment_status = 'PAID'", "o.status <> 'CANCELLED'"];
  const params = [];

  const queueCase = buildQueueCaseSql();
  if (queue !== 'ALL') {
    whereParts.push(`(${queueCase}) = ?`);
    params.push(queue);
  }

  if (search) {
    whereParts.push('(u.full_name LIKE ? OR u.email LIKE ? OR o.id = ? OR o.tracking_code LIKE ?)');
    const term = `%${search}%`;
    params.push(term, term, Number(search) || -1, term);
  }

  const where = `WHERE ${whereParts.join(' AND ')}`;

  const [rows] = await pool.execute(
    `SELECT
      o.id,
      o.created_at,
      o.status AS order_status,
      o.payment_status,
      o.payment_method,
      o.total,
      o.shipping_service,
      o.shipping_zip,
      o.tracking_code,
      o.shipped_at,
      o.delivered_at,
      u.full_name,
      u.email,
      COALESCE(oi.items_count, 0) AS items_lines,
      COALESCE(oi.items_qty, 0) AS items_qty,
      COALESCE(opi.pending_count, 0) AS pending_lines,
      oi.items_preview,
      ${queueCase} AS fulfillment_queue
     FROM orders o
     INNER JOIN customers c ON c.id = o.customer_id
     INNER JOIN users u ON u.id = c.user_id
     LEFT JOIN (
       SELECT oi.order_id,
              COUNT(*) AS items_count,
              SUM(oi.quantity) AS items_qty,
              SUBSTRING_INDEX(GROUP_CONCAT(p.name ORDER BY oi.id SEPARATOR ' · '), ' · ', 2) AS items_preview
       FROM order_items oi
       INNER JOIN products p ON p.id = oi.product_id
       GROUP BY oi.order_id
     ) oi ON oi.order_id = o.id
     LEFT JOIN (
       SELECT order_id, COUNT(*) AS pending_count
       FROM order_pending_items
       GROUP BY order_id
     ) opi ON opi.order_id = o.id
     ${where}
     ORDER BY
       CASE ${queueCase}
         WHEN 'STOCK_PENDING' THEN 1
         WHEN 'READY_TO_SHIP' THEN 2
         WHEN 'SHIPPED' THEN 3
         WHEN 'DELIVERED' THEN 4
         ELSE 5
       END,
       o.created_at DESC,
       o.id DESC
     LIMIT ${pageSize} OFFSET ${offset}`,
    params
  );

  const [countRows] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM orders o
     INNER JOIN customers c ON c.id = o.customer_id
     INNER JOIN users u ON u.id = c.user_id
     LEFT JOIN (SELECT order_id, COUNT(*) AS items_count FROM order_items GROUP BY order_id) oi ON oi.order_id = o.id
     LEFT JOIN (SELECT order_id, COUNT(*) AS pending_count FROM order_pending_items GROUP BY order_id) opi ON opi.order_id = o.id
     ${where}`,
    params
  );

  const total = Number(countRows[0]?.total || 0);
  return {
    orders: rows || [],
    total,
    page,
    pageSize,
    totalPages: Math.max(1, Math.ceil(total / pageSize)),
  };
}

async function getQueueStats() {
  await ensureColumns();
  const queueCase = buildQueueCaseSql();
  const [rows] = await pool.execute(
    `SELECT q.fulfillment_queue, COUNT(*) AS c
     FROM (
       SELECT o.id, ${queueCase} AS fulfillment_queue
       FROM orders o
       LEFT JOIN (SELECT order_id, COUNT(*) AS items_count FROM order_items GROUP BY order_id) oi ON oi.order_id = o.id
       LEFT JOIN (SELECT order_id, COUNT(*) AS pending_count FROM order_pending_items GROUP BY order_id) opi ON opi.order_id = o.id
       WHERE o.payment_status = 'PAID' AND o.status <> 'CANCELLED'
     ) q
     GROUP BY q.fulfillment_queue`
  );
  const stats = {
    stock_pending: 0,
    ready_to_ship: 0,
    shipped: 0,
    delivered: 0,
    total_active: 0,
  };
  (rows || []).forEach((r) => {
    const c = Number(r.c || 0);
    stats.total_active += c;
    if (r.fulfillment_queue === 'STOCK_PENDING') stats.stock_pending = c;
    if (r.fulfillment_queue === 'READY_TO_SHIP') stats.ready_to_ship = c;
    if (r.fulfillment_queue === 'SHIPPED') stats.shipped = c;
    if (r.fulfillment_queue === 'DELIVERED') stats.delivered = c;
  });
  return stats;
}

async function markShipped(orderId, { tracking_code }, adminUserId) {
  await ensureColumns();
  const id = Number(orderId);
  const code = String(tracking_code || '').trim();
  if (!code) {
    const err = new Error('Informe o código de rastreio.');
    err.code = 'TRACKING_REQUIRED';
    throw err;
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute(
      `SELECT o.id, o.status, o.payment_status,
              (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) AS items_count,
              (SELECT COUNT(*) FROM order_pending_items WHERE order_id = o.id) AS pending_count
       FROM orders o WHERE o.id = ? FOR UPDATE`,
      [id]
    );
    const order = rows[0];
    if (!order) {
      const err = new Error('Pedido não encontrado.');
      err.code = 'NOT_FOUND';
      throw err;
    }
    if (String(order.payment_status) !== 'PAID') {
      const err = new Error('Só é possível despachar pedidos pagos.');
      err.code = 'INVALID_PAYMENT';
      throw err;
    }
    if (String(order.status) === 'SHIPPED' || String(order.status) === 'DELIVERED') {
      const err = new Error('Este pedido já foi despachado ou entregue.');
      err.code = 'INVALID_STATUS';
      throw err;
    }
    if (Number(order.pending_count) > 0 && Number(order.items_count) === 0) {
      const err = new Error('Aguardando separação de estoque. Confirme o pagamento ou aguarde a baixa dos itens.');
      err.code = 'STOCK_PENDING';
      throw err;
    }
    if (String(order.status) !== 'PROCESSING') {
      const err = new Error('Pedido não está pronto para expedição.');
      err.code = 'INVALID_STATUS';
      throw err;
    }

    await connection.execute(
      `UPDATE orders
       SET status = 'SHIPPED', tracking_code = ?, shipped_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [code, id]
    );
    await connection.commit();
    return { ok: true, message: 'Pedido marcado como enviado.' };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

async function markDelivered(orderId, adminUserId) {
  await ensureColumns();
  const id = Number(orderId);

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute(
      'SELECT id, status, payment_status FROM orders WHERE id = ? FOR UPDATE',
      [id]
    );
    const order = rows[0];
    if (!order) {
      const err = new Error('Pedido não encontrado.');
      err.code = 'NOT_FOUND';
      throw err;
    }
    if (String(order.payment_status) !== 'PAID') {
      const err = new Error('Só é possível confirmar entrega de pedidos pagos.');
      err.code = 'INVALID_PAYMENT';
      throw err;
    }
    if (String(order.status) !== 'SHIPPED') {
      const err = new Error('Confirme o despacho antes de marcar como entregue.');
      err.code = 'INVALID_STATUS';
      throw err;
    }

    await connection.execute(
      `UPDATE orders
       SET status = 'DELIVERED',
           delivered_at = CURRENT_TIMESTAMP,
           delivered_by = ?,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [adminUserId || null, id]
    );
    await connection.commit();
    return { ok: true, message: 'Entrega confirmada com sucesso.' };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

module.exports = {
  ensureColumns,
  listOrders,
  getQueueStats,
  markShipped,
  markDelivered,
};
