const { pool } = require('../config/database');

/**
 * Lista imagens de um produto, ordenadas por sort_order.
 */
async function findByProductId(productId) {
  const [rows] = await pool.execute(
    'SELECT id, product_id, image_url, sort_order FROM product_images WHERE product_id = ? ORDER BY sort_order ASC, id ASC',
    [productId]
  );
  return rows;
}

/**
 * Lista imagens por múltiplos produtos.
 */
async function findByProductIds(productIds = []) {
  if (!Array.isArray(productIds) || productIds.length === 0) return [];
  const placeholders = productIds.map(() => '?').join(', ');
  const [rows] = await pool.execute(
    `SELECT id, product_id, image_url, sort_order
     FROM product_images
     WHERE product_id IN (${placeholders})
     ORDER BY product_id ASC, sort_order ASC, id ASC`,
    productIds
  );
  return rows;
}

/**
 * Busca uma imagem por id.
 */
async function findById(id) {
  const [rows] = await pool.execute(
    'SELECT id, product_id, image_url, sort_order FROM product_images WHERE id = ? LIMIT 1',
    [id]
  );
  return rows[0] || null;
}

/**
 * Adiciona uma imagem ao produto.
 * @param {number} productId
 * @param {string} imageUrl - URL ou caminho (ex: /assets/img/produtos/x.jpg)
 * @param {number} sortOrder - opcional, padrão 0
 */
async function add(productId, imageUrl, sortOrder = 0) {
  if (!imageUrl || !String(imageUrl).trim()) return null;
  const [result] = await pool.execute(
    'INSERT INTO product_images (product_id, image_url, sort_order) VALUES (?, ?, ?)',
    [productId, String(imageUrl).trim(), sortOrder]
  );
  return result.insertId;
}

/**
 * Remove uma imagem pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM product_images WHERE id = ?', [id]);
  return result.affectedRows;
}

/**
 * Atualiza a ordem de uma imagem.
 */
async function updateOrder(id, sortOrder) {
  const [result] = await pool.execute('UPDATE product_images SET sort_order = ? WHERE id = ?', [sortOrder, id]);
  return result.affectedRows;
}

/**
 * Verifica se a imagem pertence ao produto.
 */
async function belongsToProduct(imageId, productId) {
  const [rows] = await pool.execute('SELECT 1 FROM product_images WHERE id = ? AND product_id = ?', [imageId, productId]);
  return rows.length > 0;
}

module.exports = {
  findById,
  findByProductId,
  findByProductIds,
  add,
  deleteById,
  updateOrder,
  belongsToProduct,
};
