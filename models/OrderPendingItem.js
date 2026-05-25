const { pool } = require('../config/database');

async function createMany(orderId, lines, connection = pool) {
  for (const line of lines) {
    await connection.execute(
      `INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
       VALUES (?, ?, ?, ?, ?)`,
      [orderId, line.product_id, line.quantity, line.unit_price, line.line_total]
    );
  }
}

async function findByOrderId(orderId, connection = pool) {
  const [rows] = await connection.execute(
    `SELECT opi.*, p.name AS product_name, p.sku
     FROM order_pending_items opi
     INNER JOIN products p ON p.id = opi.product_id
     WHERE opi.order_id = ?
     ORDER BY opi.id ASC`,
    [orderId]
  );
  return rows;
}

async function deleteByOrderId(orderId, connection = pool) {
  const [result] = await connection.execute('DELETE FROM order_pending_items WHERE order_id = ?', [orderId]);
  return result.affectedRows;
}

async function countByOrderId(orderId, connection = pool) {
  const [rows] = await connection.execute(
    'SELECT COUNT(*) AS c FROM order_pending_items WHERE order_id = ?',
    [orderId]
  );
  return Number(rows[0]?.c || 0);
}

module.exports = { createMany, findByOrderId, deleteByOrderId, countByOrderId };
