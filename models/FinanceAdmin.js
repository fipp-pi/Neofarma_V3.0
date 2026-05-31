/**
 * Funções do financeiro para dashboard e relatórios do admin.
 * Conversa com pedidos, pagamentos e agendamentos de serviço.
 */
const { pool } = require('../config/database');
const { fulfillOrderStock } = require('../services/orderFulfillmentService');

/**
 * Normaliza datas vindas de query string / formulário para uso seguro em SQL.
 *
 * @param {unknown} v
 * @returns {string|null}
 */
function toDateOrNull(v) {
  if (!v) return null;
  const s = String(v).trim();
  if (!s) return null;
  // Espera YYYY-MM-DD (ex.: input type="date").
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  return null;
}

/**
 * Monta trecho de filtro por período para reaproveitar nas consultas.
 */
function buildPeriodWhere(alias, options = {}) {
  const days = options.days != null ? Number(options.days) : 30;
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  const whereParts = [];
  const params = [];
  if (from && to) {
    whereParts.push(`${alias}.created_at >= ? AND ${alias}.created_at <= DATE_ADD(?, INTERVAL 1 DAY)`);
    params.push(from, to);
  } else if (days && Number.isFinite(days)) {
    whereParts.push(`${alias}.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)`);
    params.push(days);
  }
  return { where: whereParts.length ? `WHERE ${whereParts.join(' AND ')}` : '', params };
}

/**
 * Totais do dashboard: receita paga, contagens por payment_status e pedidos cancelados.
 *
 * @param {{ days?: number, from?: string, to?: string }} [options]
 * @returns {Promise<{ revenue_paid: number, pending_count: number, failed_count: number, cancelled_count: number, total_orders: number }>}
 */
async function getFinanceSummary(options = {}) {
  const orderPeriod = buildPeriodWhere('o', options);
  const servicePeriod = buildPeriodWhere('sa', options);

  const [orderRows] = await pool.execute(
    `SELECT
      SUM(CASE WHEN o.payment_status = 'PAID' THEN o.total ELSE 0 END) AS revenue_paid,
      SUM(CASE WHEN o.payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_count,
      SUM(CASE WHEN o.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_count,
      SUM(CASE WHEN o.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_count,
      COUNT(*) AS total_orders
    FROM orders o
    ${orderPeriod.where}`,
    orderPeriod.params
  );

  const [serviceRows] = await pool.execute(
    `SELECT
      SUM(CASE WHEN sa.payment_status = 'PAID' THEN sa.total_amount ELSE 0 END) AS revenue_paid_services,
      SUM(CASE WHEN sa.payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_services,
      SUM(CASE WHEN sa.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_services,
      SUM(CASE WHEN sa.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_services,
      COUNT(*) AS total_services
    FROM service_appointments sa
    ${servicePeriod.where}`,
    servicePeriod.params
  );

  const row = orderRows && Array.isArray(orderRows) && orderRows[0] ? orderRows[0] : {};
  const sRow = serviceRows && Array.isArray(serviceRows) && serviceRows[0] ? serviceRows[0] : {};
  const revenueOrders = Number(row && row.revenue_paid ? row.revenue_paid : 0);
  const revenueServices = Number(sRow && sRow.revenue_paid_services ? sRow.revenue_paid_services : 0);
  return {
    revenue_paid: revenueOrders + revenueServices,
    revenue_paid_orders: revenueOrders,
    revenue_paid_services: revenueServices,
    pending_count: Number(row && row.pending_count ? row.pending_count : 0) + Number(sRow && sRow.pending_services ? sRow.pending_services : 0),
    failed_count: Number(row && row.failed_count ? row.failed_count : 0) + Number(sRow && sRow.failed_services ? sRow.failed_services : 0),
    cancelled_count: Number(row && row.cancelled_count ? row.cancelled_count : 0) + Number(sRow && sRow.cancelled_services ? sRow.cancelled_services : 0),
    total_orders: Number(row && row.total_orders ? row.total_orders : 0),
    total_services: Number(sRow && sRow.total_services ? sRow.total_services : 0),
    total_transactions: Number(row && row.total_orders ? row.total_orders : 0) + Number(sRow && sRow.total_services ? sRow.total_services : 0),
  };
}

/**
 * Soma de `orders.total` por método, apenas com `payment_status = PAID`.
 *
 * @param {{ from?: string, to?: string, days?: number }} [options]
 * @returns {Promise<{ PIX: number, BOLETO: number, CREDIT_CARD: number }>}
 */
async function getRevenueByPaymentMethod(options = {}) {
  const orderPeriod = buildPeriodWhere('o', options);
  const servicePeriod = buildPeriodWhere('sa', options);

  const [orderRows] = await pool.execute(
    `SELECT
      o.payment_method,
      SUM(o.total) AS revenue
     FROM orders o
     ${orderPeriod.where}
     AND o.payment_status = 'PAID'
     GROUP BY o.payment_method`,
    orderPeriod.params
  );

  const [serviceRows] = await pool.execute(
    `SELECT
      sa.payment_method,
      SUM(sa.total_amount) AS revenue
     FROM service_appointments sa
     ${servicePeriod.where}
     AND sa.payment_status = 'PAID'
     GROUP BY sa.payment_method`,
    servicePeriod.params
  );

  const out = { PIX: 0, BOLETO: 0, CREDIT_CARD: 0, DEBIT_CARD: 0, CASH: 0 };
  (orderRows || []).forEach((r) => {
    out[r.payment_method] = Number(out[r.payment_method] || 0) + Number(r.revenue || 0);
  });
  (serviceRows || []).forEach((r) => {
    out[r.payment_method] = Number(out[r.payment_method] || 0) + Number(r.revenue || 0);
  });
  return out;
}

/**
 * Lista paginada para o admin com cliente (users) e último registro de payment.
 * `LIMIT`/`OFFSET` embutidos por compatibilidade com prepared statements do driver.
 *
 * @param {{ payment_status?: string, from?: string, to?: string, search?: string, page?: number, pageSize?: number }} [options]
 * @returns {Promise<{ orders: object[], total: number, page: number, pageSize: number, totalPages: number }>}
 */
async function listOrdersFinance(options = {}) {
  const paymentStatus = options.payment_status ? String(options.payment_status).toUpperCase() : 'ALL';
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  const search = options.search ? String(options.search).trim() : '';
  const page = Math.max(1, parseInt(options.page, 10) || 1);
  const pageSize = Math.min(200, Math.max(10, parseInt(options.pageSize, 10) || 25));
  const offset = (page - 1) * pageSize;

  const whereParts = [];
  const params = [];

  if (paymentStatus !== 'ALL') {
    whereParts.push('o.payment_status = ?');
    params.push(paymentStatus);
  }

  if (from && to) {
    whereParts.push('o.created_at >= ? AND o.created_at <= DATE_ADD(?, INTERVAL 1 DAY)');
    params.push(from, to);
  }

  if (search) {
    whereParts.push('(u.full_name LIKE ? OR u.email LIKE ? OR o.id = ?)');
    const term = `%${search}%`;
    params.push(term, term, Number(search) || -1);
  }

  const where = whereParts.length ? `WHERE ${whereParts.join(' AND ')}` : '';

  const [rows] = await pool.execute(
    `SELECT
      o.id,
      o.created_at,
      o.status AS order_status,
      o.payment_method,
      o.payment_status,
      o.total,
      u.full_name,
      u.email,
      p.pix_copy_paste,
      p.boleto_barcode,
      p.pix_qr_code,
      COALESCE(fi.qty_fulfilled, 0) + COALESCE(pi.qty_pending, 0) AS items_qty,
      COALESCE(fi.lines_fulfilled, 0) + COALESCE(pi.lines_pending, 0) AS items_lines,
      COALESCE(NULLIF(fi.items_preview, ''), pi.items_preview) AS items_preview
    FROM orders o
    INNER JOIN customers c ON c.id = o.customer_id
    INNER JOIN users u ON u.id = c.user_id
    LEFT JOIN payments p ON p.order_id = o.id
    LEFT JOIN (
      SELECT oi.order_id,
             SUM(oi.quantity) AS qty_fulfilled,
             COUNT(*) AS lines_fulfilled,
             SUBSTRING_INDEX(GROUP_CONCAT(p.name ORDER BY oi.id SEPARATOR ' · '), ' · ', 2) AS items_preview
      FROM order_items oi
      INNER JOIN products p ON p.id = oi.product_id
      GROUP BY oi.order_id
    ) fi ON fi.order_id = o.id
    LEFT JOIN (
      SELECT opi.order_id,
             SUM(opi.quantity) AS qty_pending,
             COUNT(*) AS lines_pending,
             SUBSTRING_INDEX(GROUP_CONCAT(p.name ORDER BY opi.id SEPARATOR ' · '), ' · ', 2) AS items_preview
      FROM order_pending_items opi
      INNER JOIN products p ON p.id = opi.product_id
      GROUP BY opi.order_id
    ) pi ON pi.order_id = o.id
    ${where}
    ORDER BY o.created_at DESC, o.id DESC
    LIMIT ${pageSize} OFFSET ${offset}`,
    params
  );

  // total count (para paginação)
  const [countRows] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM orders o
     INNER JOIN customers c ON c.id = o.customer_id
     INNER JOIN users u ON u.id = c.user_id
     LEFT JOIN payments p ON p.order_id = o.id
     ${where}`,
    params
  );

  const total = Number(countRows && countRows[0] && countRows[0].total ? countRows[0].total : 0);
  return { orders: rows || [], total, page, pageSize, totalPages: Math.max(1, Math.ceil(total / pageSize)) };
}

/**
 * Detalhe completo do pedido para o admin financeiro (cliente, entrega, pagamento e itens).
 *
 * @param {number|string} orderId
 * @returns {Promise<{ order: object, items: object[], pending_items: object[], summary: object }|null>}
 */
async function getOrderFinanceDetail(orderId) {
  const id = Number(orderId);
  if (!Number.isFinite(id) || id <= 0) return null;

  const [orderRows] = await pool.execute(
    `SELECT
      o.id,
      o.customer_id,
      o.address_id,
      o.status AS order_status,
      o.subtotal,
      o.shipping_cost,
      o.total,
      o.payment_method,
      o.payment_status,
      o.shipping_zip,
      o.shipping_service,
      o.shipping_deadline_days,
      o.tracking_code,
      o.shipped_at,
      o.delivered_at,
      o.delivered_by,
      o.created_at,
      o.updated_at,
      u.full_name,
      u.email,
      u.phone,
      a.street,
      a.number,
      a.complement,
      a.district,
      a.city,
      a.state,
      a.zip_code,
      pay.amount AS payment_amount,
      pay.status AS payment_record_status,
      pay.pix_copy_paste,
      pay.boleto_barcode,
      pay.boleto_due_date,
      pay.card_brand,
      pay.card_last4,
      pay.installments,
      du.full_name AS delivered_by_name
     FROM orders o
     INNER JOIN customers c ON c.id = o.customer_id
     INNER JOIN users u ON u.id = c.user_id
     INNER JOIN addresses a ON a.id = o.address_id
     LEFT JOIN payments pay ON pay.order_id = o.id
     LEFT JOIN users du ON du.id = o.delivered_by
     WHERE o.id = ?
     LIMIT 1`,
    [id]
  );
  const order = orderRows[0];
  if (!order) return null;

  const [itemRows] = await pool.execute(
    `SELECT
      oi.id,
      oi.product_id,
      oi.batch_id,
      oi.quantity,
      oi.unit_price,
      oi.line_total,
      p.name AS product_name,
      p.sku,
      l.name AS lab_name,
      ib.batch_code,
      ib.expiry_date
     FROM order_items oi
     INNER JOIN products p ON p.id = oi.product_id
     LEFT JOIN labs l ON l.id = p.lab_id
     LEFT JOIN inventory_batches ib ON ib.id = oi.batch_id
     WHERE oi.order_id = ?
     ORDER BY oi.id ASC`,
    [id]
  );

  const [pendingRows] = await pool.execute(
    `SELECT
      opi.id,
      opi.product_id,
      opi.quantity,
      opi.unit_price,
      opi.line_total,
      p.name AS product_name,
      p.sku
     FROM order_pending_items opi
     INNER JOIN products p ON p.id = opi.product_id
     WHERE opi.order_id = ?
     ORDER BY opi.id ASC`,
    [id]
  );

  const fulfilledQty = itemRows.reduce((acc, row) => acc + Number(row.quantity || 0), 0);
  const pendingQty = pendingRows.reduce((acc, row) => acc + Number(row.quantity || 0), 0);

  return {
    order,
    items: itemRows,
    pending_items: pendingRows,
    summary: {
      lines_fulfilled: itemRows.length,
      lines_pending: pendingRows.length,
      qty_fulfilled: fulfilledQty,
      qty_pending: pendingQty,
      qty_total: fulfilledQty + pendingQty,
      subtotal: Number(order.subtotal || 0),
      shipping: Number(order.shipping_cost || 0),
      total: Number(order.total || 0),
    },
  };
}

/**
 * Ranking por quantidade vendida em pedidos pagos (agrega `order_items`).
 *
 * @param {{ limit?: number, from?: string, to?: string, days?: number }} [options]
 */
async function getMostSoldProducts(options = {}) {
  const limit = Math.min(50, Math.max(3, parseInt(options.limit, 10) || 10));
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  const days = options.days != null ? Number(options.days) : 30;

  const whereParts = [];
  const params = [];
  whereParts.push("o.payment_status = 'PAID'");
  if (from && to) {
    whereParts.push('o.created_at >= ? AND o.created_at <= DATE_ADD(?, INTERVAL 1 DAY)');
    params.push(from, to);
  } else {
    whereParts.push('o.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)');
    params.push(days);
  }

  const where = `WHERE ${whereParts.join(' AND ')}`;

  const [rows] = await pool.execute(
    `SELECT
      oi.product_id,
      p.name AS product_name,
      p.sku,
      SUM(oi.quantity) AS qty_sold,
      SUM(oi.line_total) AS revenue
     FROM order_items oi
     INNER JOIN orders o ON o.id = oi.order_id
     INNER JOIN products p ON p.id = oi.product_id
     ${where}
     GROUP BY oi.product_id, p.name, p.sku
     ORDER BY qty_sold DESC, revenue DESC
     LIMIT ${limit}`,
    params
  );

  return rows || [];
}

/**
 * Série diária de receita em pedidos pagos (últimos N dias distintos, conforme `limitDays`).
 *
 * @param {{ from?: string, to?: string, days?: number, limitDays?: number }} [options]
 */
async function getRevenueByDay(options = {}) {
  const limitDays = Math.min(90, Math.max(7, parseInt(options.limitDays, 10) || 14));
  const orderPeriod = buildPeriodWhere('o', options);
  const servicePeriod = buildPeriodWhere('sa', options);

  const [rows] = await pool.execute(
    `SELECT
      day,
      SUM(revenue) AS revenue,
      COUNT(*) AS orders_count
     FROM (
      SELECT DATE(o.created_at) AS day, o.total AS revenue
      FROM orders o
      ${orderPeriod.where}
      AND o.payment_status = 'PAID'
      UNION ALL
      SELECT DATE(sa.created_at) AS day, sa.total_amount AS revenue
      FROM service_appointments sa
      ${servicePeriod.where}
      AND sa.payment_status = 'PAID'
     ) t
     GROUP BY day
     ORDER BY day DESC
     LIMIT ${limitDays}`,
    [...orderPeriod.params, ...servicePeriod.params]
  );

  return rows || [];
}

/**
 * Últimos pedidos pagos com dados para “recibo” (cliente + trechos de pagamento simulado).
 *
 * @param {{ limit?: number, from?: string, to?: string, days?: number }} [options]
 */
async function listRecentReceipts(options = {}) {
  const limit = Math.min(100, Math.max(5, parseInt(options.limit, 10) || 20));
  const orderPeriod = buildPeriodWhere('o', options);
  const servicePeriod = buildPeriodWhere('sa', options);

  const [rows] = await pool.execute(
    `SELECT *
     FROM (
      SELECT
        'ORDER' AS source_type,
        o.id AS ref_id,
        o.created_at,
        u.full_name,
        u.email,
        o.payment_method,
        o.total AS total,
        NULL AS refund_amount,
        p.status AS payment_record_status,
        p.pix_copy_paste,
        p.boleto_barcode
      FROM orders o
      INNER JOIN customers c ON c.id = o.customer_id
      INNER JOIN users u ON u.id = c.user_id
      LEFT JOIN payments p ON p.order_id = o.id
      ${orderPeriod.where}
      AND o.payment_status IN ('PAID', 'REFUNDED_PARTIAL')
      UNION ALL
      SELECT
        'SERVICE' AS source_type,
        sa.id AS ref_id,
        sa.created_at,
        sa.customer_name AS full_name,
        sa.customer_email AS email,
        sa.payment_method,
        sa.total_amount AS total,
        sa.refund_amount,
        sa.payment_status AS payment_record_status,
        NULL AS pix_copy_paste,
        NULL AS boleto_barcode
      FROM service_appointments sa
      ${servicePeriod.where}
      AND sa.payment_status IN ('PAID', 'REFUNDED_PARTIAL')
     ) r
     ORDER BY r.created_at DESC, r.ref_id DESC
     LIMIT ${limit}`,
    [...orderPeriod.params, ...servicePeriod.params]
  );

  return rows || [];
}

/**
 * Atualização transacional do status de pagamento (testes / operação manual).
 * Alinha `orders.payment_status`, `orders.status` e `payments.status`.
 *
 * @param {number|string} orderId
 * @param {string} paymentStatus - `PAID` ou `FAILED`
 * @returns {Promise<{ ok: boolean }>}
 * @throws {Error & { code?: string }} NOT_FOUND, INVALID_PAYMENT_STATUS
 */
async function markPaymentForOrderAdmin(orderId, paymentStatus) {
  const newPaymentStatus = String(paymentStatus || '').toUpperCase();
  if (!['PAID', 'FAILED'].includes(newPaymentStatus)) {
    const err = new Error('payment_status inválido. Use PAID ou FAILED.');
    err.code = 'INVALID_PAYMENT_STATUS';
    throw err;
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [orderRows] = await connection.execute(
      'SELECT id, payment_status, status FROM orders WHERE id = ? FOR UPDATE',
      [orderId]
    );
    const order = orderRows && orderRows[0] ? orderRows[0] : null;
    if (!order) {
      await connection.rollback();
      const err = new Error('Pedido não encontrado.');
      err.code = 'NOT_FOUND';
      throw err;
    }

    const nextOrderStatus = newPaymentStatus === 'PAID' ? 'PROCESSING' : 'CANCELLED';

    if (newPaymentStatus === 'PAID') {
      const fulfill = await fulfillOrderStock(orderId, connection);
      if (!fulfill.ok && fulfill.code !== 'NO_PENDING_ITEMS') {
        await connection.rollback();
        const err = new Error(fulfill.message || 'Não foi possível baixar estoque para o pedido.');
        err.code = fulfill.code || 'FULFILL_FAILED';
        throw err;
      }
    }

    await connection.execute('UPDATE payments SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_id = ?', [
      newPaymentStatus,
      orderId,
    ]);

    await connection.execute(
      'UPDATE orders SET payment_status = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [newPaymentStatus, nextOrderStatus, orderId]
    );

    await connection.commit();
    return { ok: true };
  } catch (err) {
    try {
      await connection.rollback();
    } catch (_) {
      // ignore
    }
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * RF_S1 — relatório de produtos (tipo, categoria, laboratório, mais/menos vendidos).
 */
async function getProductReport(options = {}) {
  const limit = Math.min(500, Math.max(5, parseInt(options.limit, 10) || 50));
  const sort = String(options.sort || 'most').toLowerCase() === 'least' ? 'least' : 'most';
  const categoryId = options.category_id ? parseInt(options.category_id, 10) : null;
  const productTypeId = options.product_type_id ? parseInt(options.product_type_id, 10) : null;
  const labId = options.lab_id ? parseInt(options.lab_id, 10) : null;
  const minQty = options.min_qty ? parseInt(options.min_qty, 10) : null;
  const search = options.search ? String(options.search).trim() : '';
  const productStatus = options.product_status ? String(options.product_status).trim().toUpperCase() : '';

  const whereParts = ['p.status != ?'];
  const params = ['DISCONTINUED'];
  if (categoryId) {
    whereParts.push('pc.category_id = ?');
    params.push(categoryId);
  }
  if (productTypeId) {
    whereParts.push('p.product_type_id = ?');
    params.push(productTypeId);
  }
  if (labId) {
    whereParts.push('p.lab_id = ?');
    params.push(labId);
  }
  if (productStatus) {
    whereParts.push('p.status = ?');
    params.push(productStatus);
  }
  if (search) {
    whereParts.push('(p.name LIKE ? OR p.sku LIKE ?)');
    params.push(`%${search}%`, `%${search}%`);
  }

  const salesWhere = ["o.payment_status = 'PAID'"];
  const salesParams = [];
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  if (from && to) {
    salesWhere.push('o.created_at >= ? AND o.created_at <= DATE_ADD(?, INTERVAL 1 DAY)');
    salesParams.push(from, to);
  } else {
    const days = options.days != null ? Number(options.days) : 90;
    salesWhere.push('o.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)');
    salesParams.push(days);
  }

  const havingParts = [];
  const havingParams = [];
  if (minQty != null && Number.isFinite(minQty) && minQty > 0) {
    havingParts.push('COALESCE(SUM(oi.quantity), 0) >= ?');
    havingParams.push(minQty);
  }
  const havingClause = havingParts.length ? `HAVING ${havingParts.join(' AND ')}` : '';
  const orderDir = sort === 'least' ? 'ASC' : 'DESC';

  const [rows] = await pool.execute(
    `SELECT
      p.id,
      p.name AS product_name,
      p.sku,
      p.unit_price,
      p.status AS product_status,
      pt.name AS type_name,
      l.name AS lab_name,
      GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS categories,
      COALESCE(SUM(oi.quantity), 0) AS qty_sold,
      COALESCE(SUM(oi.line_total), 0) AS revenue,
      CASE
        WHEN COALESCE(SUM(oi.quantity), 0) > 0
        THEN COALESCE(SUM(oi.line_total), 0) / SUM(oi.quantity)
        ELSE 0
      END AS avg_ticket
     FROM products p
     LEFT JOIN product_types pt ON pt.id = p.product_type_id
     LEFT JOIN labs l ON l.id = p.lab_id
     LEFT JOIN product_categories pc ON pc.product_id = p.id
     LEFT JOIN categories c ON c.id = pc.category_id
     LEFT JOIN order_items oi ON oi.product_id = p.id
     LEFT JOIN orders o ON o.id = oi.order_id AND ${salesWhere.join(' AND ')}
     WHERE ${whereParts.join(' AND ')}
     GROUP BY p.id, p.name, p.sku, p.unit_price, p.status, pt.name, l.name
     ${havingClause}
     ORDER BY qty_sold ${orderDir}, revenue ${orderDir}
     LIMIT ${limit}`,
    [...salesParams, ...params, ...havingParams]
  );
  return rows || [];
}

/**
 * RF_S2 — relatório de vendas (cliente, categoria, produto, pagamento, período).
 */
async function getSalesReport(options = {}) {
  const limit = Math.min(500, Math.max(10, parseInt(options.limit, 10) || 100));
  const customerId = options.customer_id ? parseInt(options.customer_id, 10) : null;
  const categoryId = options.category_id ? parseInt(options.category_id, 10) : null;
  const productId = options.product_id ? parseInt(options.product_id, 10) : null;
  const paymentMethod = options.payment_method ? String(options.payment_method).trim().toUpperCase() : '';
  const orderStatus = options.order_status ? String(options.order_status).trim().toUpperCase() : '';
  const search = options.search ? String(options.search).trim() : '';

  const whereParts = ["o.payment_status = 'PAID'"];
  const params = [];
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  if (from && to) {
    whereParts.push('o.created_at >= ? AND o.created_at <= DATE_ADD(?, INTERVAL 1 DAY)');
    params.push(from, to);
  } else {
    const days = options.days != null ? Number(options.days) : 30;
    whereParts.push('o.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)');
    params.push(days);
  }
  if (customerId) {
    whereParts.push('o.customer_id = ?');
    params.push(customerId);
  }
  if (productId) {
    whereParts.push('oi.product_id = ?');
    params.push(productId);
  }
  if (categoryId) {
    whereParts.push('EXISTS (SELECT 1 FROM product_categories pc2 WHERE pc2.product_id = oi.product_id AND pc2.category_id = ?)');
    params.push(categoryId);
  }
  if (paymentMethod) {
    whereParts.push('o.payment_method = ?');
    params.push(paymentMethod);
  }
  if (orderStatus) {
    whereParts.push('o.status = ?');
    params.push(orderStatus);
  }
  if (search) {
    whereParts.push('(u.full_name LIKE ? OR p.name LIKE ? OR CAST(o.id AS CHAR) LIKE ?)');
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }

  const [rows] = await pool.execute(
    `SELECT
      o.id AS order_id,
      o.created_at,
      o.status AS order_status,
      u.full_name AS customer_name,
      p.name AS product_name,
      p.sku,
      (SELECT GROUP_CONCAT(DISTINCT cat.name ORDER BY cat.name SEPARATOR ', ')
       FROM product_categories pc3
       INNER JOIN categories cat ON cat.id = pc3.category_id
       WHERE pc3.product_id = p.id) AS category_name,
      oi.quantity,
      oi.line_total,
      o.payment_method
     FROM orders o
     INNER JOIN order_items oi ON oi.order_id = o.id
     INNER JOIN products p ON p.id = oi.product_id
     INNER JOIN customers c ON c.id = o.customer_id
     INNER JOIN users u ON u.id = c.user_id
     WHERE ${whereParts.join(' AND ')}
     ORDER BY o.created_at DESC, o.id DESC
     LIMIT ${limit}`,
    params
  );
  return rows || [];
}

/**
 * RF_S3 — relatório de clientes (PF/PJ, cidade, nome, inadimplente, gasto total).
 */
async function getCustomerReport(options = {}) {
  const limit = Math.min(500, Math.max(10, parseInt(options.limit, 10) || 100));
  const personType = options.person_type ? String(options.person_type).toUpperCase() : '';
  const city = options.city ? String(options.city).trim() : '';
  const name = options.name ? String(options.name).trim() : '';
  const search = options.search ? String(options.search).trim() : '';
  const delinquentOnly = options.delinquent === '1' || options.delinquent === 'true';
  const minSpent = options.min_spent ? parseFloat(options.min_spent) : null;

  const whereParts = ["r.name = 'CLIENTE'"];
  const params = [];
  if (personType === 'PF') {
    whereParts.push("CHAR_LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(u.document,''),'.',''),'-',''),'/',''),' ','')) <= 11");
  } else if (personType === 'PJ') {
    whereParts.push("CHAR_LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(u.document,''),'.',''),'-',''),'/',''),' ','')) > 11");
  }
  if (city) {
    whereParts.push('a.city LIKE ?');
    params.push(`%${city}%`);
  }
  if (name) {
    whereParts.push('u.full_name LIKE ?');
    params.push(`%${name}%`);
  }
  if (search) {
    whereParts.push('(u.full_name LIKE ? OR u.email LIKE ? OR u.document LIKE ?)');
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  if (delinquentOnly) {
    whereParts.push(`EXISTS (
      SELECT 1 FROM orders ox
      WHERE ox.customer_id = c.id
        AND (ox.payment_status = 'FAILED'
          OR (ox.payment_status = 'PENDING' AND ox.created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)))
    )`);
  }
  if (minSpent != null && Number.isFinite(minSpent) && minSpent > 0) {
    whereParts.push(`(
      SELECT COALESCE(SUM(o2.total), 0) FROM orders o2
      WHERE o2.customer_id = c.id AND o2.payment_status = 'PAID'
    ) >= ?`);
    params.push(minSpent);
  }

  const [rows] = await pool.execute(
    `SELECT
      c.id AS customer_id,
      u.full_name,
      u.email,
      u.document,
      u.phone,
      a.city,
      CASE
        WHEN CHAR_LENGTH(REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(u.document,''),'.',''),'-',''),'/',''),' ','')) > 11 THEN 'PJ'
        ELSE 'PF'
      END AS person_type,
      (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id AND o.payment_status = 'PAID') AS paid_orders,
      (SELECT COALESCE(SUM(o.total), 0) FROM orders o WHERE o.customer_id = c.id AND o.payment_status = 'PAID') AS total_spent,
      (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id AND (o.payment_status = 'FAILED'
        OR (o.payment_status = 'PENDING' AND o.created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)))) AS delinquent_flags
     FROM customers c
     INNER JOIN users u ON u.id = c.user_id
     INNER JOIN roles r ON r.id = u.role_id
     LEFT JOIN addresses a ON a.id = c.default_address_id
     WHERE ${whereParts.join(' AND ')}
     ORDER BY total_spent DESC, u.full_name
     LIMIT ${limit}`,
    params
  );
  return rows || [];
}

/**
 * RF_04 — relatório de serviços (profissional, status, serviço, pagamento, período).
 */
async function getServiceReport(options = {}) {
  const limit = Math.min(500, Math.max(10, parseInt(options.limit, 10) || 100));
  const professionalId = options.professional_id ? parseInt(options.professional_id, 10) : null;
  const serviceId = options.service_id ? parseInt(options.service_id, 10) : null;
  const statusFilter = options.status_filter ? String(options.status_filter) : '';
  const paymentStatus = options.payment_status ? String(options.payment_status).trim().toUpperCase() : '';
  const modality = options.modality ? String(options.modality).trim().toUpperCase() : '';
  const channel = options.channel ? String(options.channel).trim().toUpperCase() : '';
  const search = options.search ? String(options.search).trim() : '';

  const whereParts = ['1=1'];
  const params = [];
  const from = options.from ? toDateOrNull(options.from) : null;
  const to = options.to ? toDateOrNull(options.to) : null;
  if (from && to) {
    whereParts.push('sa.created_at >= ? AND sa.created_at <= DATE_ADD(?, INTERVAL 1 DAY)');
    params.push(from, to);
  } else {
    const days = options.days != null ? Number(options.days) : 90;
    whereParts.push('sa.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)');
    params.push(days);
  }
  if (professionalId) {
    whereParts.push('sa.professional_id = ?');
    params.push(professionalId);
  }
  if (serviceId) {
    whereParts.push('sa.service_id = ?');
    params.push(serviceId);
  }
  if (statusFilter === 'completed') {
    whereParts.push("sa.status = 'COMPLETED'");
  } else if (statusFilter === 'open') {
    whereParts.push("sa.status IN ('RESERVED','CONFIRMED','IN_PROGRESS')");
  } else if (statusFilter === 'cancelled') {
    whereParts.push("sa.status = 'CANCELLED'");
  }
  if (paymentStatus) {
    whereParts.push('sa.payment_status = ?');
    params.push(paymentStatus);
  }
  if (modality) {
    whereParts.push('sa.modality = ?');
    params.push(modality);
  }
  if (channel) {
    whereParts.push('sa.booking_channel = ?');
    params.push(channel);
  }
  if (search) {
    whereParts.push('(sa.customer_name LIKE ? OR hs.name LIKE ? OR sp.full_name LIKE ? OR CAST(sa.id AS CHAR) LIKE ?)');
    params.push(`%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`);
  }

  const [rows] = await pool.execute(
    `SELECT
      sa.id,
      sa.scheduled_start,
      sa.status,
      sa.payment_status,
      sa.payment_method,
      sa.modality,
      sa.booking_channel,
      sa.total_amount,
      hs.name AS service_name,
      sp.full_name AS professional_name,
      sa.customer_name,
      sa.customer_email
     FROM service_appointments sa
     INNER JOIN health_services hs ON hs.id = sa.service_id
     LEFT JOIN service_professionals sp ON sp.id = sa.professional_id
     WHERE ${whereParts.join(' AND ')}
     ORDER BY sa.scheduled_start DESC
     LIMIT ${limit}`,
    params
  );
  return rows || [];
}

module.exports = {
  getFinanceSummary,
  getRevenueByPaymentMethod,
  listOrdersFinance,
  getOrderFinanceDetail,
  getMostSoldProducts,
  getRevenueByDay,
  listRecentReceipts,
  markPaymentForOrderAdmin,
  getProductReport,
  getSalesReport,
  getCustomerReport,
  getServiceReport,
};

