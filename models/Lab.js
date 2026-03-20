const { pool } = require('../config/database');

async function create(data) {
  const [result] = await pool.execute(
    `INSERT INTO labs (name, cnpj, email, phone, address_id, is_active)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [
      data.name,
      data.cnpj || null,
      data.email || null,
      data.phone || null,
      data.address_id || null,
      data.is_active !== undefined ? (data.is_active ? 1 : 0) : 1,
    ]
  );
  return result.insertId;
}

async function findById(id) {
  const [rows] = await pool.execute(
    'SELECT l.*, a.street, a.number, a.city, a.state, a.zip_code FROM labs l LEFT JOIN addresses a ON l.address_id = a.id WHERE l.id = ?',
    [id]
  );
  return rows[0] || null;
}

async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM labs WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY name';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function findAllWithAddress(activeOnly = false) {
  let sql = 'SELECT l.*, a.street, a.number, a.complement, a.district, a.city, a.state, a.country, a.zip_code FROM labs l LEFT JOIN addresses a ON l.address_id = a.id WHERE 1=1';
  if (activeOnly) sql += ' AND l.is_active = 1';
  sql += ' ORDER BY l.name';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['name', 'cnpj', 'email', 'phone', 'address_id', 'is_active'];
  allowed.forEach((key) => {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(key === 'is_active' ? (data[key] ? 1 : 0) : data[key]);
    }
  });
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE labs SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM labs WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, findAll, findAllWithAddress, updateById, deleteById };
