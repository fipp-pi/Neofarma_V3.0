const { pool } = require('../config/database');

const { slugify } = require('../util/slug');



async function create(data) {

  const slug = data.slug || slugify(data.name);

  const [result] = await pool.execute(

    `INSERT INTO product_types (name, slug, description, is_active) VALUES (?, ?, ?, ?)`,

    [data.name, slug, data.description || null, data.is_active !== undefined ? (data.is_active ? 1 : 0) : 1]

  );

  return result.insertId;

}



async function findById(id) {

  const [rows] = await pool.execute('SELECT * FROM product_types WHERE id = ? LIMIT 1', [id]);

  return rows[0] || null;

}



async function findAll(activeOnly = false) {

  let sql = 'SELECT * FROM product_types WHERE 1=1';

  if (activeOnly) sql += ' AND is_active = 1';

  sql += ' ORDER BY name ASC';

  const [rows] = await pool.execute(sql);

  return rows;

}



async function findBySlug(slug, excludeId = null) {

  const code = String(slug || '').trim().toLowerCase();

  if (!code) return null;

  let sql = 'SELECT id, name, slug FROM product_types WHERE slug = ?';

  const params = [code];

  if (excludeId) {

    sql += ' AND id <> ?';

    params.push(excludeId);

  }

  sql += ' LIMIT 1';

  const [rows] = await pool.execute(sql, params);

  return rows[0] || null;

}



async function updateById(id, data) {

  const fields = [];

  const values = [];

  ['name', 'slug', 'description', 'is_active'].forEach((key) => {

    if (data[key] !== undefined) {

      fields.push(`${key} = ?`);

      values.push(key === 'is_active' ? (data.is_active ? 1 : 0) : data[key]);

    }

  });

  if (!fields.length) return 0;

  values.push(id);

  const [result] = await pool.execute(`UPDATE product_types SET ${fields.join(', ')} WHERE id = ?`, values);

  return result.affectedRows;

}



async function deleteById(id) {

  const [result] = await pool.execute('DELETE FROM product_types WHERE id = ?', [id]);

  return result.affectedRows;

}



module.exports = { create, findById, findAll, findBySlug, updateById, deleteById, slugify };

