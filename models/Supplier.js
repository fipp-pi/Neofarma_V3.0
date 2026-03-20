const { pool } = require('../config/database');

async function create(data) {
  const [result] = await pool.execute(
    `INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      data.corporate_name,
      data.trade_name || null,
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
    'SELECT s.*, a.street, a.number, a.city, a.state, a.zip_code FROM suppliers s LEFT JOIN addresses a ON s.address_id = a.id WHERE s.id = ?',
    [id]
  );
  return rows[0] || null;
}

async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM suppliers WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY corporate_name';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function findAllWithAddress(activeOnly = false) {
  let sql = 'SELECT s.*, a.street, a.number, a.complement, a.district, a.city, a.state, a.country, a.zip_code FROM suppliers s LEFT JOIN addresses a ON s.address_id = a.id WHERE 1=1';
  if (activeOnly) sql += ' AND s.is_active = 1';
  sql += ' ORDER BY s.corporate_name';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['corporate_name', 'trade_name', 'cnpj', 'email', 'phone', 'address_id', 'is_active'];
  allowed.forEach((key) => {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(key === 'is_active' ? (data[key] ? 1 : 0) : data[key]);
    }
  });
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE suppliers SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM suppliers WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, findAll, findAllWithAddress, updateById, deleteById };
