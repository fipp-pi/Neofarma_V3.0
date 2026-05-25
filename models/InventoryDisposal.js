const { pool } = require('../config/database');
const InventoryBatch = require('./InventoryBatch');

async function create({ product_id, batch_id, quantity, reason, disposed_by }, connection = pool) {
  const qty = Number(quantity);
  if (!product_id || !batch_id || qty <= 0 || !String(reason || '').trim()) {
    const err = new Error('Dados de descarte inválidos.');
    err.code = 'INVALID';
    throw err;
  }

  const [batchRows] = await connection.execute(
    'SELECT id, product_id, quantity FROM inventory_batches WHERE id = ? FOR UPDATE',
    [batch_id]
  );
  const batch = batchRows[0];
  if (!batch || Number(batch.product_id) !== Number(product_id)) {
    const err = new Error('Lote não encontrado para este produto.');
    err.code = 'BATCH_NOT_FOUND';
    throw err;
  }
  if (Number(batch.quantity) < qty) {
    const err = new Error('Quantidade em estoque insuficiente para descarte.');
    err.code = 'INSUFFICIENT_STOCK';
    throw err;
  }

  await connection.execute('UPDATE inventory_batches SET quantity = quantity - ? WHERE id = ?', [qty, batch_id]);

  const [result] = await connection.execute(
    `INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by)
     VALUES (?, ?, ?, ?, ?)`,
    [product_id, batch_id, qty, String(reason).trim(), disposed_by || null]
  );

  return result.insertId;
}

async function findAll(limit = 100) {
  const lim = Math.max(1, Math.min(500, Number(limit) || 100));
  const [rows] = await pool.execute(
    `SELECT d.*, p.name AS product_name, p.sku, b.batch_code, b.expiry_date, u.full_name AS disposed_by_name
     FROM inventory_disposals d
     INNER JOIN products p ON p.id = d.product_id
     INNER JOIN inventory_batches b ON b.id = d.batch_id
     LEFT JOIN users u ON u.id = d.disposed_by
     ORDER BY d.created_at DESC
     LIMIT ${lim}`
  );
  return rows;
}

module.exports = { create, findAll };
