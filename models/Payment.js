const { pool } = require('../config/database');

/**
 * Salva um registro de pagamento ligado ao pedido.
 */
async function create(data, connection = pool) {
  const [result] = await connection.execute(
    `INSERT INTO payments
      (order_id, method, status, amount, pix_qr_code, pix_copy_paste, boleto_barcode, boleto_due_date, card_brand, card_last4, installments, interest_rate)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.order_id,
      data.method,
      data.status || 'PENDING',
      data.amount,
      data.pix_qr_code || null,
      data.pix_copy_paste || null,
      data.boleto_barcode || null,
      data.boleto_due_date || null,
      data.card_brand || null,
      data.card_last4 || null,
      data.installments || null,
      data.interest_rate || null,
    ]
  );
  return result.insertId;
}

/**
 * Busca o último pagamento de um pedido.
 */
async function findByOrderId(orderId) {
  const [rows] = await pool.execute(
    `SELECT * FROM payments WHERE order_id = ? ORDER BY id DESC LIMIT 1`,
    [orderId]
  );
  return rows[0] || null;
}

/**
 * Atualiza status de pagamento pelo id do pedido.
 */
async function updateStatusByOrderId(orderId, status, connection = pool) {
  const [result] = await connection.execute(
    'UPDATE payments SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE order_id = ?',
    [status, orderId]
  );
  return result.affectedRows;
}

module.exports = { create, findByOrderId, updateStatusByOrderId };
