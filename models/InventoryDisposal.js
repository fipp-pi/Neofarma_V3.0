const { pool } = require('../config/database');
const InventoryBatch = require('./InventoryBatch');
const { parseWholeUnitsOrThrow } = require('../utils/quantity');

async function create({ product_id, batch_id, quantity, reason, disposed_by }, connection = pool) {
  let qty;
  try {
    qty = parseWholeUnitsOrThrow(quantity, { emptyMessage: 'Informe a quantidade a descartar.' });
  } catch (err) {
    if (err.code === 'INVALID_QUANTITY') {
      const invalidErr = new Error(err.message);
      invalidErr.code = 'INVALID';
      throw invalidErr;
    }
    throw err;
  }
  if (!product_id || !batch_id || !String(reason || '').trim()) {
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

async function findByBatchId(batchId, limit = 50) {
  const id = Number(batchId);
  if (!Number.isFinite(id) || id <= 0) return [];
  const lim = Math.max(1, Math.min(100, Number(limit) || 50));
  const [rows] = await pool.execute(
    `SELECT d.id, d.quantity, d.reason, d.created_at, u.full_name AS disposed_by_name
     FROM inventory_disposals d
     LEFT JOIN users u ON u.id = d.disposed_by
     WHERE d.batch_id = ?
     ORDER BY d.created_at DESC
     LIMIT ${lim}`,
    [id]
  );
  return rows;
}

module.exports = { create, findAll, findByBatchId };
