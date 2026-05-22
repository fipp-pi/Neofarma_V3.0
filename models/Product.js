const { pool } = require('../config/database');

/**
 * Converte nome em slug para URL do produto.
 */
function slugify(text) {
  return (text || '')
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Garante slug único para não repetir no banco.
 */
async function buildUniqueSlug(baseText, excludeId = null) {
  const base = slugify(baseText) || 'produto';
  let candidate = base;
  let attempt = 1;
  while (attempt <= 500) {
    let sql = 'SELECT id FROM products WHERE slug = ?';
    const params = [candidate];
    if (excludeId) {
      sql += ' AND id <> ?';
      params.push(excludeId);
    }
    sql += ' LIMIT 1';
    const [rows] = await pool.execute(sql, params);
    if (!rows.length) return candidate;
    attempt += 1;
    candidate = `${base}-${attempt}`;
  }
  return `${base}-${Date.now()}`;
}

/**
 * Cria produto novo.
 */
async function create(data) {
  const slug = await buildUniqueSlug(data.slug || data.name);
  const [result] = await pool.execute(
    `INSERT INTO products (lab_id, main_supplier_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.lab_id || null,
      data.main_supplier_id || null,
      data.name,
      slug,
      data.sku || null,
      data.ean13 || null,
      data.description || null,
      data.composition || null,
      data.usage_info || null,
      data.prescription_required ? 1 : 0,
      data.unit_price,
      data.promotional_price || null,
      data.status || 'ACTIVE',
    ]
  );
  return result.insertId;
}

/**
 * Busca produto por id com nome do laboratório e fornecedor.
 */
async function findById(id) {
  const [rows] = await pool.execute(
    `SELECT p.*, l.name AS lab_name, s.corporate_name AS supplier_name
     FROM products p
     LEFT JOIN labs l ON p.lab_id = l.id
     LEFT JOIN suppliers s ON p.main_supplier_id = s.id
     WHERE p.id = ?`,
    [id]
  );
  return rows[0] || null;
}

/**
 * Lista produtos com filtros simples (status e busca).
 */
async function findAll(filters = {}) {
  let sql = `SELECT p.*, l.name AS lab_name FROM products p LEFT JOIN labs l ON p.lab_id = l.id WHERE 1=1`;
  const params = [];
  if (filters.status) {
    sql += ' AND p.status = ?';
    params.push(filters.status);
  }
  if (filters.search) {
    sql += ' AND (p.name LIKE ? OR p.sku LIKE ?)';
    const term = `%${filters.search}%`;
    params.push(term, term);
  }
  sql += ' ORDER BY p.name';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Busca vários produtos de uma vez pelo array de ids.
 */
async function findByIds(ids = [], filters = {}) {
  if (!Array.isArray(ids) || ids.length === 0) return [];
  const placeholders = ids.map(() => '?').join(', ');
  let sql = `SELECT p.*, l.name AS lab_name
             FROM products p
             LEFT JOIN labs l ON p.lab_id = l.id
             WHERE p.id IN (${placeholders})`;
  const params = [...ids];
  if (filters.status) {
    sql += ' AND p.status = ?';
    params.push(filters.status);
  }
  sql += ' ORDER BY p.name';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Atualiza produto e, se necessário, recalcula slug único.
 */
async function updateById(id, data) {
  const localData = { ...data };
  if (localData.slug !== undefined || localData.name !== undefined) {
    localData.slug = await buildUniqueSlug(localData.slug || localData.name, id);
  }
  const fields = [];
  const values = [];
  const allowed = ['lab_id', 'main_supplier_id', 'name', 'slug', 'sku', 'ean13', 'description', 'composition', 'usage_info', 'prescription_required', 'unit_price', 'promotional_price', 'status'];
  allowed.forEach((key) => {
    if (localData[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(key === 'prescription_required' ? (localData[key] ? 1 : 0) : localData[key]);
    }
  });
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE products SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

/**
 * Exclui produto pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM products WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, findAll, findByIds, updateById, deleteById, slugify };
