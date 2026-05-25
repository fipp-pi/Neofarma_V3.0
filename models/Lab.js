const { pool } = require('../config/database');

/**
 * Cria um laboratório no banco.
 * Conversa direto com a tabela `labs`.
 */
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

/**
 * Busca um laboratório pelo id (já trazendo endereço).
 */
async function findById(id) {
  const [rows] = await pool.execute(
    'SELECT l.*, a.street, a.number, a.city, a.state, a.zip_code FROM labs l LEFT JOIN addresses a ON l.address_id = a.id WHERE l.id = ?',
    [id]
  );
  return rows[0] || null;
}

/**
 * Lista laboratórios, podendo filtrar só os ativos.
 */
async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM labs WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY name';
  const [rows] = await pool.execute(sql);
  return rows;
}

/**
 * Lista laboratórios com campos completos de endereço.
 */
async function findAllWithAddress(activeOnly = false) {
  let sql = 'SELECT l.*, a.street, a.number, a.complement, a.district, a.city, a.state, a.country, a.zip_code FROM labs l LEFT JOIN addresses a ON l.address_id = a.id WHERE 1=1';
  if (activeOnly) sql += ' AND l.is_active = 1';
  sql += ' ORDER BY l.name';
  const [rows] = await pool.execute(sql);
  return rows;
}

/**
 * Atualiza os dados de um laboratório existente.
 */
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

/**
 * Busca laboratório pelo CNPJ (opcionalmente ignorando um id na edição).
 */
async function findByCnpj(cnpj, excludeId = null) {
  const code = String(cnpj || '').replace(/\D/g, '');
  if (!code) return null;
  let sql = 'SELECT id, name, cnpj FROM labs WHERE cnpj = ?';
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
 * Remove laboratório pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM labs WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = { create, findById, findAll, findAllWithAddress, findByCnpj, updateById, deleteById };
