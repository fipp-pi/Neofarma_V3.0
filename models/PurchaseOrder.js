const { pool } = require('../config/database');
const InventoryBatch = require('./InventoryBatch');

async function findAll(filters = {}) {
  let sql = `SELECT po.*, s.trade_name AS supplier_name, s.corporate_name AS supplier_corporate
             FROM purchase_orders po
             INNER JOIN suppliers s ON s.id = po.supplier_id
             WHERE 1=1`;
  const params = [];
  if (filters.status) {
    sql += ' AND po.status = ?';
    params.push(filters.status);
  }
  sql += ' ORDER BY po.order_date DESC, po.id DESC';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function findById(id, connection = pool) {
  const [rows] = await connection.execute(
    `SELECT po.*,
            s.trade_name AS supplier_name,
            s.corporate_name AS supplier_corporate,
            s.cnpj AS supplier_cnpj,
            s.email AS supplier_email,
            s.phone AS supplier_phone,
            u.full_name AS employee_name
     FROM purchase_orders po
     INNER JOIN suppliers s ON s.id = po.supplier_id
     LEFT JOIN employees e ON e.id = po.employee_id
     LEFT JOIN users u ON u.id = e.user_id
     WHERE po.id = ? LIMIT 1`,
    [id]
  );
  return rows[0] || null;
}

async function findItemsByOrderId(orderId, connection = pool) {
  const [rows] = await connection.execute(
    `SELECT poi.*,
            p.name AS product_name,
            p.sku,
            ib.mfg_date AS batch_mfg_date,
            ib.quantity AS batch_current_qty
     FROM purchase_order_items poi
     INNER JOIN products p ON p.id = poi.product_id
     LEFT JOIN inventory_batches ib ON ib.id = poi.batch_id
     WHERE poi.purchase_order_id = ?
     ORDER BY poi.id ASC`,
    [orderId]
  );
  return rows;
}

async function createDraft(data, items, connection = pool) {
  const total = items.reduce((acc, it) => acc + Number(it.quantity) * Number(it.unit_cost), 0);
  const [result] = await connection.execute(
    `INSERT INTO purchase_orders (supplier_id, employee_id, status, payment_status, payment_method, total_amount, notes, expected_date)
     VALUES (?, ?, 'DRAFT', 'PENDING', ?, ?, ?, ?)`,
    [
      data.supplier_id,
      data.employee_id || null,
      data.payment_method || null,
      Number(total.toFixed(2)),
      data.notes || null,
      data.expected_date || null,
    ]
  );
  const orderId = result.insertId;
  for (const it of items) {
    const qty = Number(it.quantity);
    const cost = Number(it.unit_cost);
    await connection.execute(
      `INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, unit_cost, total_cost)
       VALUES (?, ?, ?, ?, ?)`,
      [orderId, it.product_id, qty, cost, Number((qty * cost).toFixed(2))]
    );
  }
  return orderId;
}

async function confirmPayment(orderId, connection = pool) {
  const [result] = await connection.execute(
    `UPDATE purchase_orders
     SET status = 'AWAITING_DELIVERY', payment_status = 'PAID', updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status = 'DRAFT' AND payment_status = 'PENDING'`,
    [orderId]
  );
  return result.affectedRows > 0;
}

async function receiveDelivery(orderId, lines, connection = pool) {
  const order = await findById(orderId, connection);
  if (!order || order.status !== 'AWAITING_DELIVERY') {
    return { ok: false, code: 'INVALID_STATUS', message: 'Compra não está aguardando entrega.' };
  }

  const items = await findItemsByOrderId(orderId, connection);
  const lineMap = new Map(lines.map((l) => [Number(l.item_id), l]));

  for (const item of items) {
    const input = lineMap.get(Number(item.id));
    if (!input) continue;
    const qtyRecv = Number(input.quantity_received);
    if (qtyRecv <= 0) continue;
    if (qtyRecv > Number(item.quantity)) {
      return { ok: false, code: 'QTY_INVALID', message: `Quantidade recebida maior que pedida (${item.product_name}).` };
    }
    const batchCode = String(input.batch_code || '').trim();
    const expiry = input.expiry_date;
    const mfgDate = input.mfg_date ? String(input.mfg_date).trim() : null;
    if (!batchCode || !expiry) {
      return { ok: false, code: 'BATCH_REQUIRED', message: `Informe lote e validade para ${item.product_name}.` };
    }
    if (mfgDate && mfgDate > expiry) {
      return { ok: false, code: 'DATE_INVALID', message: `Data de fabricação posterior à validade (${item.product_name}).` };
    }

    const batchId = await InventoryBatch.create(
      {
        product_id: item.product_id,
        batch_code: batchCode,
        mfg_date: mfgDate || null,
        expiry_date: expiry,
        quantity: qtyRecv,
      },
      connection
    );

    await connection.execute(
      `UPDATE purchase_order_items
       SET quantity_received = ?, batch_id = ?, batch_code = ?, expiry_date = ?
       WHERE id = ?`,
      [qtyRecv, batchId, batchCode, expiry, item.id]
    );
  }

  await connection.execute(
    `UPDATE purchase_orders SET status = 'RECEIVED', updated_at = CURRENT_TIMESTAMP WHERE id = ?`,
    [orderId]
  );
  return { ok: true };
}

async function cancelById(orderId, connection = pool) {
  const [result] = await connection.execute(
    `UPDATE purchase_orders SET status = 'CANCELLED', payment_status = 'FAILED', updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status IN ('DRAFT','AWAITING_DELIVERY')`,
    [orderId]
  );
  return result.affectedRows > 0;
}

module.exports = {
  findAll,
  findById,
  findItemsByOrderId,
  createDraft,
  confirmPayment,
  receiveDelivery,
  cancelById,
};
