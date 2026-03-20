const { pool } = require('../config/database');

/**
 * Cria um novo usuário.
 * @param {Object} data - { role_id, full_name, email, password_hash, document?, phone?, birth_date? }
 */
async function create(data) {
  const [result] = await pool.execute(
    `INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      data.role_id,
      data.full_name,
      data.email,
      data.password_hash,
      data.document || null,
      data.phone || null,
      data.birth_date || null,
    ]
  );
  return result.insertId;
}

/**
 * Busca usuário por id.
 */
async function findById(id) {
  const [rows] = await pool.execute(
    'SELECT u.*, r.name AS role_name FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.id = ?',
    [id]
  );
  return rows[0] || null;
}

/**
 * Busca usuário por email.
 */
async function findByEmail(email) {
  const [rows] = await pool.execute(
    'SELECT u.*, r.name AS role_name FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.email = ?',
    [email]
  );
  return rows[0] || null;
}

/**
 * Lista usuários (com filtro opcional por role).
 */
async function findAll(roleName = null) {
  let sql = 'SELECT u.*, r.name AS role_name FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE 1=1';
  const params = [];
  if (roleName) {
    sql += ' AND r.name = ?';
    params.push(roleName);
  }
  sql += ' ORDER BY u.id';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Atualiza usuário por id.
 */
async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['full_name', 'email', 'password_hash', 'document', 'phone', 'birth_date', 'is_active'];
  for (const key of allowed) {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(data[key]);
    }
  }
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(
    `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
    values
  );
  return result.affectedRows;
}

/**
 * Remove usuário por id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM users WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  create,
  findById,
  findByEmail,
  findAll,
  updateById,
  deleteById,
};
