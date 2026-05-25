const { pool } = require('../config/database');

const STAFF_ROLES = ['ADMIN', 'FUNCIONARIO', 'ESTOQUISTA'];

/**
 * Lista funcionários (usuários com perfil administrativo/operacional).
 */
async function findAll() {
  const placeholders = STAFF_ROLES.map(() => '?').join(', ');
  const [rows] = await pool.execute(
    `SELECT
      e.id AS employee_id,
      u.id AS user_id,
      u.full_name,
      u.email,
      u.phone,
      u.document,
      u.is_active,
      r.name AS role_name,
      e.hire_date,
      e.role_title,
      e.salary
     FROM users u
     INNER JOIN roles r ON r.id = u.role_id
     LEFT JOIN employees e ON e.user_id = u.id
     WHERE r.name IN (${placeholders})
     ORDER BY u.full_name`,
    STAFF_ROLES
  );
  return rows || [];
}

async function findByUserId(userId) {
  const [rows] = await pool.execute('SELECT * FROM employees WHERE user_id = ?', [userId]);
  return rows[0] || null;
}

/**
 * Cria ou atualiza funcionário (user + employees).
 */
async function save(data) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const userId = data.user_id ? parseInt(data.user_id, 10) : null;
    const roleId = parseInt(data.role_id, 10);
    if (!roleId) throw Object.assign(new Error('Perfil inválido.'), { code: 'INVALID_ROLE' });

    if (userId) {
      await connection.execute(
        `UPDATE users SET role_id = ?, full_name = ?, email = ?, document = ?, phone = ?, is_active = ? WHERE id = ?`,
        [
          roleId,
          data.full_name,
          data.email,
          data.document || null,
          data.phone || null,
          data.is_active ? 1 : 0,
          userId,
        ]
      );
      if (data.password_hash) {
        await connection.execute('UPDATE users SET password_hash = ? WHERE id = ?', [data.password_hash, userId]);
      }
      const [empRows] = await connection.execute('SELECT id FROM employees WHERE user_id = ?', [userId]);
      const empRow = empRows[0];
      if (empRow) {
        await connection.execute(
          'UPDATE employees SET hire_date = ?, role_title = ?, salary = ? WHERE user_id = ?',
          [data.hire_date, data.role_title, data.salary, userId]
        );
      } else {
        await connection.execute(
          'INSERT INTO employees (user_id, hire_date, salary, role_title) VALUES (?, ?, ?, ?)',
          [userId, data.hire_date, data.salary, data.role_title]
        );
      }
      await connection.commit();
      return { ok: true, user_id: userId };
    }

    const [ins] = await connection.execute(
      `INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
       VALUES (?, ?, ?, ?, ?, ?, NULL, ?)`,
      [
        roleId,
        data.full_name,
        data.email,
        data.password_hash,
        data.document || null,
        data.phone || null,
        data.is_active ? 1 : 0,
      ]
    );
    const newUserId = ins.insertId;
    await connection.execute(
      'INSERT INTO employees (user_id, hire_date, salary, role_title) VALUES (?, ?, ?, ?)',
      [newUserId, data.hire_date, data.salary, data.role_title]
    );
    await connection.commit();
    return { ok: true, user_id: newUserId };
  } catch (err) {
    try {
      await connection.rollback();
    } catch (_) {
      // ignore
    }
    throw err;
  } finally {
    connection.release();
  }
}

module.exports = {
  STAFF_ROLES,
  findAll,
  findByUserId,
  save,
};
