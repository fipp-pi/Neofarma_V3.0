/**
 * Configuração da conexão MySQL (NeoFarma)
 * Use variáveis de ambiente (.env) ou valores padrão abaixo.
 */
require('dotenv').config({ quiet: true });
const mysql = require('mysql2/promise');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Joao2510.',
  database: process.env.DB_NAME || 'neofarma',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
};

const pool = mysql.createPool(dbConfig);

/**
 * Testa a conexão com o banco (opcional, para uso no startup).
 */
async function testConnection() {
  try {
    const conn = await pool.getConnection();
    conn.release();
    return true;
  } catch (err) {
    console.error('Erro ao conectar ao MySQL:', err.message);
    return false;
  }
}

module.exports = { pool, testConnection };
