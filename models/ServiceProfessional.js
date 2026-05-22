const { pool } = require('../config/database');

/**
 * Verifica se já existe profissional parecido (email, telefone ou nome+cargo).
 */
async function findDuplicate(data) {
  const email = data.email ? String(data.email).trim().toLowerCase() : null;
  const phone = data.phone ? String(data.phone).replace(/\D/g, '') : null;
  const fullName = String(data.full_name || '').trim();
  const roleName = String(data.role_name || '').trim().toUpperCase();
  if (!fullName || !roleName) return null;

  let sql = `SELECT id, full_name, role_name, email, phone
             FROM service_professionals
             WHERE (
               (LOWER(COALESCE(email, '')) = LOWER(?) AND ? IS NOT NULL AND ? <> '')
               OR (REPLACE(REPLACE(REPLACE(REPLACE(COALESCE(phone, ''), '(', ''), ')', ''), '-', ''), ' ', '') = ? AND ? IS NOT NULL AND ? <> '')
               OR (full_name = ? AND role_name = ?)
             )`;
  const params = [email, email, email, phone, phone, phone, fullName, roleName];
  if (data.id) {
    sql += ' AND id <> ?';
    params.push(data.id);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

/**
 * Lista profissionais (todos ou só ativos).
 */
async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM service_professionals WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY full_name ASC';
  const [rows] = await pool.execute(sql);
  return rows;
}

/**
 * Busca profissional por id.
 */
async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM service_professionals WHERE id = ? LIMIT 1', [id]);
  return rows[0] || null;
}

/**
 * Cria ou atualiza profissional.
 */
async function upsert(data, connection = pool) {
  const duplicate = await findDuplicate(data);
  if (duplicate) {
    const err = new Error('Profissional já cadastrado.');
    err.code = 'DUPLICATE_PROFESSIONAL';
    if (data.email && duplicate.email && String(duplicate.email).toLowerCase() === String(data.email).toLowerCase()) err.field = 'email';
    else if (data.phone && duplicate.phone) err.field = 'phone';
    else err.field = 'name_role';
    throw err;
  }

  if (data.id) {
    const [result] = await connection.execute(
      `UPDATE service_professionals
       SET full_name = ?, role_name = ?, email = ?, phone = ?, council_type = ?, council_uf = ?, council_number = ?, is_active = ?
       WHERE id = ?`,
      [
        data.full_name,
        data.role_name,
        data.email ? String(data.email).trim().toLowerCase() : null,
        data.phone ? String(data.phone).replace(/\D/g, '') : null,
        data.council_type || null,
        data.council_uf ? String(data.council_uf).trim().toUpperCase() : null,
        data.council_number ? String(data.council_number).trim().toUpperCase() : null,
        data.is_active ? 1 : 0,
        data.id,
      ]
    );
    return { id: data.id, affectedRows: result.affectedRows };
  }
  const [result] = await connection.execute(
    `INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.full_name,
      data.role_name,
      data.email ? String(data.email).trim().toLowerCase() : null,
      data.phone ? String(data.phone).replace(/\D/g, '') : null,
      data.council_type || null,
      data.council_uf ? String(data.council_uf).trim().toUpperCase() : null,
      data.council_number ? String(data.council_number).trim().toUpperCase() : null,
      data.is_active ? 1 : 0,
    ]
  );
  return { id: result.insertId, affectedRows: result.affectedRows };
}

/**
 * Substitui a agenda de horários do profissional.
 */
async function replaceAvailability(professionalId, slots = [], connection = pool) {
  await connection.execute('DELETE FROM service_professional_availability WHERE professional_id = ?', [professionalId]);
  for (const s of slots) {
    await connection.execute(
      `INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
       VALUES (?, ?, ?, ?, 1)`,
      [professionalId, s.day_of_week, s.start_time, s.end_time]
    );
  }
}

/**
 * Lista faixas de horário cadastradas para um dia da semana.
 */
async function listAvailabilityForDay(professionalId, dayOfWeek) {
  const [rows] = await pool.execute(
    `SELECT day_of_week, start_time, end_time
     FROM service_professional_availability
     WHERE professional_id = ?
       AND day_of_week = ?
       AND is_active = 1
     ORDER BY start_time ASC`,
    [professionalId, dayOfWeek]
  );
  return rows;
}

/**
 * Lista toda a disponibilidade semanal do profissional (para edição no admin).
 */
async function listAvailability(professionalId) {
  const [rows] = await pool.execute(
    `SELECT day_of_week, start_time, end_time
     FROM service_professional_availability
     WHERE professional_id = ?
       AND is_active = 1
     ORDER BY day_of_week ASC, start_time ASC`,
    [professionalId]
  );
  return rows.map((r) => ({
    day_of_week: r.day_of_week,
    start_time: String(r.start_time || '').slice(0, 5),
    end_time: String(r.end_time || '').slice(0, 5),
  }));
}

/**
 * Confere se o profissional atende naquele dia e faixa de horário.
 */
async function hasAvailability(professionalId, startAt, endAt) {
  const startDay = new Date(startAt).getDay();
  const startTime = new Date(startAt).toTimeString().slice(0, 8);
  const endTime = new Date(endAt).toTimeString().slice(0, 8);
  const [rows] = await pool.execute(
    `SELECT id
     FROM service_professional_availability
     WHERE professional_id = ?
       AND day_of_week = ?
       AND is_active = 1
       AND start_time <= ?
       AND end_time >= ?
     LIMIT 1`,
    [professionalId, startDay, startTime, endTime]
  );
  return !!rows.length;
}

/**
 * Exclui profissional pelo id.
 */
async function deleteById(id, connection = pool) {
  const [result] = await connection.execute('DELETE FROM service_professionals WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  findAll,
  findById,
  upsert,
  replaceAvailability,
  listAvailabilityForDay,
  listAvailability,
  hasAvailability,
  deleteById,
};
