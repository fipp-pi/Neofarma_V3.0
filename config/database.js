/**
 * Configuração da conexão MySQL (NeoFarma)
 * Credenciais via arquivo .env (copie de .env.example).
 */
require('dotenv').config({ quiet: true });
const mysql = require('mysql2/promise');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'neofarma',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
};

const pool = mysql.createPool(dbConfig);

function connectionHint(err) {
  if (!err || !err.code) return '';
  if (err.code === 'ER_ACCESS_DENIED_ERROR') {
    return [
      'Dica: senha incorreta, usuário sem permissão para seu IP atual,',
      'ou acesso permitido só na rede/VPN da faculdade.',
      'Confira DB_* no .env e teste com MySQL Workbench na mesma máquina.',
    ].join(' ');
  }
  if (err.code === 'ECONNREFUSED' || err.code === 'ETIMEDOUT' || err.code === 'ENOTFOUND') {
    return 'Dica: host/porta inacessíveis. VPN da faculdade ativa? Firewall bloqueando a porta 3306?';
  }
  return '';
}

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
    const hint = connectionHint(err);
    if (hint) console.error(hint);
    return false;
  }
}

module.exports = { pool, testConnection, dbConfig };
