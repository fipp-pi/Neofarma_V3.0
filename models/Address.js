const { pool } = require('../config/database');

/**
 * Cria um endereço.
 * @param {Object} data - { street, number, complement?, district?, city, state, country?, zip_code }
 */
async function create(data) {
  const [result] = await pool.execute(
    `INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.street,
      data.number,
      data.complement || null,
      data.district || null,
      data.city,
      data.state,
      data.country || 'Brasil',
      data.zip_code,
    ]
  );
  return result.insertId;
}

/**
 * Busca endereço por id.
 */
async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM addresses WHERE id = ?', [id]);
  return rows[0] || null;
}

/**
 * Atualiza endereço por id.
 */
async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['street', 'number', 'complement', 'district', 'city', 'state', 'country', 'zip_code'];
  for (const key of allowed) {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(data[key]);
    }
  }
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(
    `UPDATE addresses SET ${fields.join(', ')} WHERE id = ?`,
    values
  );
  return result.affectedRows;
}

/**
 * Remove endereço por id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM addresses WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, updateById, deleteById };
