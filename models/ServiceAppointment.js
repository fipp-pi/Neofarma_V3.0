const { pool } = require('../config/database');

async function ensureAppointmentColumns() {
  const checks = [
    ['customer_id', 'ALTER TABLE service_appointments ADD COLUMN customer_id BIGINT UNSIGNED NULL AFTER professional_id'],
    ['payment_method', "ALTER TABLE service_appointments ADD COLUMN payment_method ENUM('CASH','PIX','CREDIT_CARD','DEBIT_CARD') NOT NULL DEFAULT 'PIX' AFTER payment_status"],
    ['booking_channel', "ALTER TABLE service_appointments ADD COLUMN booking_channel ENUM('ADMIN','CUSTOMER_ONLINE') NOT NULL DEFAULT 'ADMIN' AFTER payment_method"],
  ];
  for (const [columnName, alterSql] of checks) {
    const [rows] = await pool.execute(
      `SELECT COUNT(*) AS c
       FROM information_schema.COLUMNS
       WHERE TABLE_SCHEMA = DATABASE()
         AND TABLE_NAME = 'service_appointments'
         AND COLUMN_NAME = ?`,
      [columnName]
    );
    if (!Number(rows[0] && rows[0].c)) {
      await pool.execute(alterSql);
    }
  }
}

async function ensureHolidaysTable() {
  await pool.execute(
    `CREATE TABLE IF NOT EXISTS service_holidays (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      holiday_date DATE NOT NULL,
      name VARCHAR(120) NOT NULL,
      is_active TINYINT(1) NOT NULL DEFAULT 1,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uk_service_holidays_date (holiday_date)
    ) ENGINE=InnoDB`
  );
}

async function expirePendingReservations() {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'CANCELLED', payment_status = 'FAILED', updated_at = CURRENT_TIMESTAMP
     WHERE status IN ('RESERVED', 'PAYMENT_FAILED')
       AND reservation_expires_at IS NOT NULL
       AND reservation_expires_at < NOW()`
  );
  return result.affectedRows;
}

async function hasScheduleConflict(startAt, endAt, professionalId, ignoreId = null) {
  await ensureAppointmentColumns();
  let sql = `SELECT id
             FROM service_appointments
             WHERE status IN ('RESERVED', 'PAYMENT_FAILED', 'CONFIRMED', 'IN_PROGRESS')
               AND (reservation_expires_at IS NULL OR reservation_expires_at >= NOW())
               AND professional_id = ?
               AND scheduled_start < ?
               AND scheduled_end > ?`;
  const params = [professionalId, endAt, startAt];
  if (ignoreId) {
    sql += ' AND id <> ?';
    params.push(ignoreId);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return !!rows.length;
}

async function createReservation(data) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `INSERT INTO service_appointments
      (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, address_text, zip_code,
       travel_fee, total_amount, scheduled_start, scheduled_end, reservation_expires_at, status, payment_status, payment_method, booking_channel, payment_attempts, payment_ref)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
       CASE WHEN ? > 0 THEN DATE_ADD(NOW(), INTERVAL ? MINUTE) ELSE NULL END,
       ?, ?, ?, ?, 0, ?)`,
    [
      data.service_id,
      data.professional_id,
      data.customer_id || null,
      data.customer_name,
      data.customer_email || null,
      data.customer_phone || null,
      data.modality,
      data.address_text || null,
      data.zip_code || null,
      data.travel_fee,
      data.total_amount,
      data.scheduled_start,
      data.scheduled_end,
      Number(data.hold_minutes || 10),
      Number(data.hold_minutes || 10),
      data.status || 'RESERVED',
      data.payment_status || 'PENDING',
      data.payment_method || 'PIX',
      data.booking_channel || 'ADMIN',
      data.payment_ref || null,
    ]
  );
  return result.insertId;
}

async function findById(id) {
  await ensureAppointmentColumns();
  const [rows] = await pool.execute(
    `SELECT a.*, s.name AS service_name, s.requires_prescription, s.service_group, p.full_name AS professional_name, p.role_name AS professional_role
     FROM service_appointments a
     INNER JOIN health_services s ON s.id = a.service_id
     LEFT JOIN service_professionals p ON p.id = a.professional_id
     WHERE a.id = ?
     LIMIT 1`,
    [id]
  );
  return rows[0] || null;
}

async function listAll(filters = {}) {
  await ensureAppointmentColumns();
  const status = String(filters.status || 'ALL').toUpperCase();
  let sql = `SELECT a.*, s.name AS service_name, s.service_group, p.full_name AS professional_name, p.role_name AS professional_role
             FROM service_appointments a
             INNER JOIN health_services s ON s.id = a.service_id
             LEFT JOIN service_professionals p ON p.id = a.professional_id
             WHERE 1=1`;
  const params = [];
  if (status !== 'ALL') {
    sql += ' AND a.status = ?';
    params.push(status);
  }
  sql += ' ORDER BY a.scheduled_start ASC, a.id ASC';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function listByCustomerId(customerId) {
  await ensureAppointmentColumns();
  const [rows] = await pool.execute(
    `SELECT a.*, s.name AS service_name, p.full_name AS professional_name
     FROM service_appointments a
     INNER JOIN health_services s ON s.id = a.service_id
     LEFT JOIN service_professionals p ON p.id = a.professional_id
     WHERE a.customer_id = ?
     ORDER BY a.scheduled_start DESC, a.id DESC`,
    [customerId]
  );
  return rows;
}

async function listCashPending(options = {}) {
  await ensureAppointmentColumns();
  const from = options.from ? String(options.from).trim() : '';
  const to = options.to ? String(options.to).trim() : '';
  const professionalId = Number(options.professional_id || 0);
  let sql = `SELECT a.*, s.name AS service_name, p.full_name AS professional_name
             FROM service_appointments a
             INNER JOIN health_services s ON s.id = a.service_id
             LEFT JOIN service_professionals p ON p.id = a.professional_id
             WHERE a.payment_method = 'CASH'
               AND a.payment_status = 'PENDING'
               AND a.status IN ('CONFIRMED', 'IN_PROGRESS', 'COMPLETED')`;
  const params = [];
  if (from) {
    sql += ' AND DATE(a.scheduled_start) >= ?';
    params.push(from);
  }
  if (to) {
    sql += ' AND DATE(a.scheduled_start) <= ?';
    params.push(to);
  }
  if (professionalId > 0) {
    sql += ' AND a.professional_id = ?';
    params.push(professionalId);
  }
  sql += ' ORDER BY a.scheduled_start ASC, a.id ASC';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function listHolidays(activeOnly = true) {
  await ensureHolidaysTable();
  let sql = 'SELECT id, holiday_date, name, is_active FROM service_holidays WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY holiday_date ASC';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function addHoliday(dateStr, name) {
  await ensureHolidaysTable();
  const [result] = await pool.execute(
    `INSERT INTO service_holidays (holiday_date, name, is_active)
     VALUES (?, ?, 1)`,
    [dateStr, name]
  );
  return result.insertId;
}

async function deleteHoliday(id) {
  await ensureHolidaysTable();
  const [result] = await pool.execute('DELETE FROM service_holidays WHERE id = ?', [id]);
  return result.affectedRows;
}

async function isHoliday(dateStr) {
  await ensureHolidaysTable();
  const [rows] = await pool.execute(
    `SELECT id
     FROM service_holidays
     WHERE holiday_date = ?
       AND is_active = 1
     LIMIT 1`,
    [dateStr]
  );
  return !!rows.length;
}

async function updatePaymentResult(id, approved) {
  await ensureAppointmentColumns();
  if (approved) {
    const [result] = await pool.execute(
      `UPDATE service_appointments
       SET status = 'CONFIRMED', payment_status = 'PAID', updated_at = CURRENT_TIMESTAMP
       WHERE id = ?
         AND status IN ('RESERVED', 'PAYMENT_FAILED')
         AND reservation_expires_at >= NOW()`,
      [id]
    );
    return result.affectedRows;
  }
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'PAYMENT_FAILED', payment_status = 'FAILED', payment_attempts = payment_attempts + 1, updated_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND status IN ('RESERVED', 'PAYMENT_FAILED')
       AND reservation_expires_at >= NOW()`,
    [id]
  );
  return result.affectedRows;
}

async function confirmCashBooking(id) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'CONFIRMED', payment_status = 'PENDING', updated_at = CURRENT_TIMESTAMP
     WHERE id = ?
       AND status = 'RESERVED'`,
    [id]
  );
  return result.affectedRows;
}

async function markInProgress(id) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'IN_PROGRESS', updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status = 'CONFIRMED'`,
    [id]
  );
  return result.affectedRows;
}

async function markCompleted(id, data) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'COMPLETED',
         clinical_record = ?,
         vaccine_batch_code = ?,
         vaccine_expiry_date = ?,
         application_site = ?,
         observations = ?,
         completed_at = NOW(),
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status IN ('IN_PROGRESS', 'CONFIRMED')`,
    [
      data.clinical_record,
      data.vaccine_batch_code || null,
      data.vaccine_expiry_date || null,
      data.application_site || null,
      data.observations || null,
      id,
    ]
  );
  return result.affectedRows;
}

async function markNoShow(id, refundAmount) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'NO_SHOW',
         payment_status = 'REFUNDED_PARTIAL',
         refund_amount = ?,
         observations = 'Cliente ausente/Não realizado',
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status IN ('CONFIRMED', 'IN_PROGRESS')`,
    [refundAmount, id]
  );
  return result.affectedRows;
}

async function markIncomplete(id, reason, options = {}) {
  await ensureAppointmentColumns();
  const refundAmount = Number(options.refund_amount || 0);
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET status = 'INCOMPLETE',
         payment_status = CASE
           WHEN payment_status = 'PENDING' THEN 'FAILED'
           WHEN payment_status = 'PAID' THEN 'REFUNDED_PARTIAL'
           ELSE payment_status
         END,
         refund_amount = CASE
           WHEN payment_status = 'PAID' THEN ?
           ELSE refund_amount
         END,
         incomplete_reason = ?,
         observations = CONCAT(COALESCE(observations, ''), CASE WHEN COALESCE(observations, '') = '' THEN '' ELSE ' | ' END, 'Reagendamento necessário'),
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ? AND status IN ('CONFIRMED', 'IN_PROGRESS')`,
    [refundAmount, reason, id]
  );
  return result.affectedRows;
}

async function markCashAsPaid(id, paymentMethod = null) {
  await ensureAppointmentColumns();
  const allowed = ['CASH', 'PIX', 'CREDIT_CARD', 'DEBIT_CARD'];
  const normalized = String(paymentMethod || '').toUpperCase();
  const targetMethod = allowed.includes(normalized) ? normalized : null;
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET payment_status = 'PAID',
         payment_method = COALESCE(?, payment_method),
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ?
      AND payment_method IN ('CASH', 'PIX', 'CREDIT_CARD', 'DEBIT_CARD')
      AND payment_status IN ('PENDING', 'FAILED')
       AND status IN ('CONFIRMED', 'IN_PROGRESS', 'COMPLETED')`,
    [targetMethod, id]
  );
  return result.affectedRows;
}

async function updateById(id, data) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute(
    `UPDATE service_appointments
     SET service_id = ?,
         professional_id = ?,
         customer_name = ?,
         customer_email = ?,
         customer_phone = ?,
         modality = ?,
         address_text = ?,
         zip_code = ?,
         travel_fee = ?,
         total_amount = ?,
         scheduled_start = ?,
         scheduled_end = ?,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [
      data.service_id,
      data.professional_id,
      data.customer_name,
      data.customer_email || null,
      data.customer_phone || null,
      data.modality,
      data.address_text || null,
      data.zip_code || null,
      data.travel_fee || 0,
      data.total_amount || 0,
      data.scheduled_start,
      data.scheduled_end,
      id,
    ]
  );
  return result.affectedRows;
}

async function deleteById(id) {
  await ensureAppointmentColumns();
  const [result] = await pool.execute('DELETE FROM service_appointments WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  expirePendingReservations,
  hasScheduleConflict,
  createReservation,
  findById,
  listAll,
  listByCustomerId,
  listCashPending,
  listHolidays,
  addHoliday,
  deleteHoliday,
  isHoliday,
  updatePaymentResult,
  confirmCashBooking,
  markInProgress,
  markCompleted,
  markNoShow,
  markIncomplete,
  markCashAsPaid,
  updateById,
  deleteById,
};
