const { pool } = require('../config/database');

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

async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM categories WHERE id = ?', [id]);
  return rows[0] || null;
}

async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM categories WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY name';
  const [rows] = await pool.execute(sql);
  return rows;
}

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

async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM categories WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, findAll, updateById, deleteById, slugify };
