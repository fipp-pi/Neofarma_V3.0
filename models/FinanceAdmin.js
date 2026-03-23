/**
 * Consultas agregadas e ações administrativas do painel financeiro.
 * Regras: período por `from`/`to` (YYYY-MM-DD) ou janela móvel em dias; receita considera pedidos `PAID` onde aplicável.
 *
 * @see docs/code-commenting.md
 */
const { pool } = require('../config/database');

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
      p.pix_qr_code
    FROM orders o
    INNER JOIN customers c ON c.id = o.customer_id
    INNER JOIN users u ON u.id = c.user_id
    LEFT JOIN payments p ON p.order_id = o.id
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

module.exports = {
  getFinanceSummary,
  getRevenueByPaymentMethod,
  listOrdersFinance,
  getMostSoldProducts,
  getRevenueByDay,
  listRecentReceipts,
  markPaymentForOrderAdmin,
};

