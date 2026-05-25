const bcrypt = require('bcrypt');
const { pool } = require('../config/database');

(async () => {
  const [rows] = await pool.query(`
    SELECT 'users stress' AS k, COUNT(*) AS v FROM users WHERE email LIKE 'stress.seed%'
    UNION ALL SELECT 'products stress', COUNT(*) FROM products WHERE slug LIKE 'stress-%'
    UNION ALL SELECT 'orders stress', COUNT(*) FROM orders WHERE customer_id IN (
      SELECT c.id FROM customers c INNER JOIN users u ON u.id = c.user_id WHERE u.email LIKE 'stress.seed%'
    )
    UNION ALL SELECT 'appointments', COUNT(*) FROM service_appointments WHERE customer_email LIKE 'stress.seed%'
    UNION ALL SELECT 'purchase orders', COUNT(*) FROM purchase_orders WHERE notes LIKE 'stress%'
  `);
  console.table(rows);
  const [u] = await pool.query("SELECT password_hash FROM users WHERE email = 'stress.seed.cliente01@neofarma.com' LIMIT 1");
  const ok = u[0] && (await bcrypt.compare('123456', u[0].password_hash));
  console.log('Login stress.seed.cliente01@neofarma.com / 123456 =>', ok ? 'OK' : 'FALHOU');
  process.exit(ok ? 0 : 1);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
