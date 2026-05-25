const { pool } = require('../config/database');
const { slugify } = require('../util/slug');

/**
 * Cria categoria nova no banco.
 */
async function create(data) {
  const slug = data.slug || slugify(data.name);
  const [result] = await pool.execute(
    `INSERT INTO categories (parent_id, name, slug, description, is_active)
     VALUES (?, ?, ?, ?, ?)`,
    [
      data.parent_id || null,
      data.name,
      slug,
      data.description || null,
      data.is_active !== undefined ? (data.is_active ? 1 : 0) : 1,
    ]
  );
  return result.insertId;
}

/**
 * Busca categoria por id.
 */
async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM categories WHERE id = ?', [id]);
  return rows[0] || null;
}

/**
 * Lista categorias (opcional: só ativas).
 */
async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM categories WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY name';
  const [rows] = await pool.execute(sql);
  return rows;
}

/**
 * Atualiza categoria existente.
 */
async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['parent_id', 'name', 'slug', 'description', 'is_active'];
  allowed.forEach((key) => {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(key === 'is_active' ? (data[key] ? 1 : 0) : data[key]);
    }
  });
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE categories SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

/**
 * Busca categoria pelo slug (opcionalmente ignorando um id na edição).
 */
async function findBySlug(slug, excludeId = null) {
  const code = String(slug || '').trim().toLowerCase();
  if (!code) return null;
  let sql = 'SELECT id, name, slug FROM categories WHERE slug = ?';
  const params = [code];
  if (excludeId) {
    sql += ' AND id <> ?';
    params.push(excludeId);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

/**
 * Verifica se a categoria possui subcategorias.
 */
async function hasChildren(id) {
  const [rows] = await pool.execute('SELECT id FROM categories WHERE parent_id = ? LIMIT 1', [id]);
  return rows.length > 0;
}

/**
 * Remove categoria pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM categories WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  create,
  findById,
  findAll,
  findBySlug,
  hasChildren,
  updateById,
  deleteById,
  slugify,
};
