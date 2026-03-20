const { pool } = require('../config/database');

/**
 * Busca role por id.
 */
async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM roles WHERE id = ?', [id]);
  return rows[0] || null;
}

/**
 * Busca role por nome (ex: 'ADMIN', 'CLIENTE').
 */
async function findByName(name) {
  const [rows] = await pool.execute('SELECT * FROM roles WHERE name = ?', [name]);
  return rows[0] || null;
}

/**
 * Lista todas as roles.
 */
async function findAll() {
  const [rows] = await pool.execute('SELECT * FROM roles ORDER BY id');
  return rows;
}

module.exports = { findById, findByName, findAll };
