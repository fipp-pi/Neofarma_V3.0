const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ quiet: true });

async function main() {
  const sqlPath = path.join(__dirname, 'demo_neofarma.sql');
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'Joao2510.',
    database: process.env.DB_NAME || 'neofarma',
    multipleStatements: true,
  });

  try {
    await conn.query(fs.readFileSync(sqlPath, 'utf8'));
    const [rows] = await conn.query(`
      SELECT 'Usuarios' AS item, COUNT(*) AS qtd FROM users WHERE email LIKE '%@loja.neofarma.com.br'
      UNION ALL SELECT 'Produtos', COUNT(*) FROM products WHERE sku LIKE 'NF-%'
      UNION ALL SELECT 'Lotes', COUNT(*) FROM inventory_batches ib INNER JOIN products p ON p.id=ib.product_id WHERE p.sku LIKE 'NF-%'
      UNION ALL SELECT 'Pedidos', COUNT(*) FROM orders o
        INNER JOIN customers c ON c.id=o.customer_id
        INNER JOIN users u ON u.id=c.user_id
        WHERE u.email LIKE '%@loja.neofarma.com.br'
      UNION ALL SELECT 'Agendamentos', COUNT(*) FROM service_appointments WHERE customer_email LIKE '%@loja.neofarma.com.br'
    `);
    console.log('Import OK');
    console.table(rows);
  } catch (err) {
    console.error('ERRO:', err.message);
    process.exit(1);
  } finally {
    await conn.end();
  }
}

main();
