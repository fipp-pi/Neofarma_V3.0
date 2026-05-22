/**
 * Funções de pedido e itens do pedido.
 * Esse arquivo conversa direto com tabelas `orders` e `order_items`.
 */
const { pool } = require('../config/database');

/**
 * Insere cabeçalho do pedido.
 *
 * @param {{
 *   customer_id: number|string,
 *   address_id: number,
 *   status?: string,
 *   subtotal: number,
 *   shipping_cost: number,
 *   total: number,
 *   payment_method: string,
 *   payment_status?: string,
 *   shipping_zip?: string|null,
 *   shipping_service?: string|null,
 *   shipping_deadline_days?: number|null
 * }} data
 * @param {import('mysql2/promise').Pool|import('mysql2/promise').PoolConnection} [connection]
 * @returns {Promise<number>} insertId
 */
async function createOrder(data, connection = pool) {
  const [result] = await connection.execute(
    `INSERT INTO orders
      (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.customer_id,
      data.address_id,
      data.status || 'CONFIRMED',
      data.subtotal,
      data.shipping_cost,
      data.total,
      data.payment_method,
      data.payment_status || 'PENDING',
      data.shipping_zip || null,
      data.shipping_service || null,
      data.shipping_deadline_days || null,
    ]
  );
  return result.insertId;
}

/**
 * Insere linha de pedido com vínculo ao lote (FEFO na saída).
 *
 * @param {{
 *   order_id: number,
 *   product_id: number,
 *   batch_id: number|null,
 *   quantity: number,
 *   unit_price: number,
 *   line_total: number
 * }} data
 * @param {import('mysql2/promise').Pool|import('mysql2/promise').PoolConnection} [connection]
 * @returns {Promise<number>} insertId
 */
async function createOrderItem(data, connection = pool) {
  const [result] = await connection.execute(
    `INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [data.order_id, data.product_id, data.batch_id, data.quantity, data.unit_price, data.line_total]
  );
  return result.insertId;
}

/**
 * Busca pedido pelo id.
 */
async function findById(orderId) {
  const [rows] = await pool.execute('SELECT * FROM orders WHERE id = ? LIMIT 1', [orderId]);
  return rows[0] || null;
}

/**
 * Itens com nome do produto e laboratório (exibição em confirmação / conta).
 *
 * @param {number|string} orderId
 */
async function findItemsByOrderId(orderId) {
  const [rows] = await pool.execute(
    `SELECT oi.*, p.name AS product_name, p.sku, l.name AS lab_name
     FROM order_items oi
     INNER JOIN products p ON p.id = oi.product_id
     LEFT JOIN labs l ON l.id = p.lab_id
     WHERE oi.order_id = ?
     ORDER BY oi.id ASC`,
    [orderId]
  );
  return rows;
}

/**
 * Histórico do cliente. `LIMIT` é interpolado (valor sanitizado) por limitação do driver com placeholders.
 *
 * @param {number|string} customerId
 * @param {number} [limit]
 */
async function findByCustomerId(customerId, limit = 30) {
  const cid = String(customerId);
  const lim = Math.max(1, Math.min(200, parseInt(limit, 10) || 30));
  const [rows] = await pool.execute(
    `SELECT
       o.id,
       o.customer_id,
       o.status,
       o.payment_method,
       o.payment_status,
       o.subtotal,
       o.shipping_cost,
       o.total,
       o.shipping_service,
       o.created_at,
       COALESCE(x.items_count, 0) AS items_count
     FROM orders o
     LEFT JOIN (
       SELECT order_id, SUM(quantity) AS items_count
       FROM order_items
       GROUP BY order_id
     ) x ON x.order_id = o.id
     WHERE o.customer_id = ?
     ORDER BY o.created_at DESC, o.id DESC
     LIMIT ${lim}`,
    [cid]
  );
  return rows;
}

/**
 * Pedido do cliente; `FOR UPDATE` opcional para cancelamento concorrente.
 *
 * @param {number|string} orderId
 * @param {number|string} customerId
 * @param {import('mysql2/promise').Pool|import('mysql2/promise').PoolConnection} [connection]
 * @param {{ forUpdate?: boolean }} [options]
 */
async function findByIdForCustomer(orderId, customerId, connection = pool, options = {}) {
  const forUpdate = options.forUpdate ? ' FOR UPDATE' : '';
  const [rows] = await connection.execute(
    `SELECT * FROM orders WHERE id = ? AND customer_id = ? LIMIT 1${forUpdate}`,
    [orderId, String(customerId)]
  );
  return rows[0] || null;
}

/**
 * Cancela somente se ainda `PENDING` e não cancelado (uma linha afetada = sucesso).
 *
 * @param {number|string} orderId
 * @param {number|string} customerId
 */
async function cancelPendingByIdForCustomer(orderId, customerId, connection = pool) {
  const [result] = await connection.execute(
    `UPDATE orders
     SET status = 'CANCELLED', payment_status = 'FAILED', updated_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND customer_id = ?
       AND payment_status = 'PENDING'
       AND status <> 'CANCELLED'`,
    [orderId, String(customerId)]
  );
  return result.affectedRows > 0;
}

module.exports = {
  createOrder,
  createOrderItem,
  findById,
  findItemsByOrderId,
  findByCustomerId,
  findByIdForCustomer,
  cancelPendingByIdForCustomer,
};
