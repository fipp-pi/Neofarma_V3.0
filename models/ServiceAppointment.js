const { pool } = require('../config/database');
const HealthService = require('./HealthService');
const ServiceProfessional = require('./ServiceProfessional');

/**
 * Garante que colunas novas existam na tabela de agendamentos.
 * Isso evita erro quando o banco está desatualizado.
 */
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

/**
 * Garante que a tabela de feriados exista.
 */
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

/**
 * Cancela reservas que passaram do tempo limite de pagamento.
 */
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

/**
 * Verifica se o profissional já tem outro agendamento no mesmo horário.
 */
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

/**
 * Cria uma reserva de agendamento (ainda aguardando pagamento/confirmação).
 */
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

/**
 * Busca um agendamento por id com dados do serviço e profissional.
 */
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

/**
 * Lista agendamentos para o painel administrativo.
 */
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

/**
 * Lista agendamentos de um cliente específico.
 */
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

/**
 * Lista atendimentos com pagamento presencial ainda pendente (caixa).
 */
async function listCashPending(options = {}) {
  await ensureAppointmentColumns();
  const from = options.from ? String(options.from).trim() : '';
  const to = options.to ? String(options.to).trim() : '';
  const professionalId = Number(options.professional_id || 0);
  const paymentMethod = options.payment_method ? String(options.payment_method).trim().toUpperCase() : '';
  let sql = `SELECT a.*, s.name AS service_name, p.full_name AS professional_name
             FROM service_appointments a
             INNER JOIN health_services s ON s.id = a.service_id
             LEFT JOIN service_professionals p ON p.id = a.professional_id
             WHERE a.payment_method IN ('CASH', 'PIX', 'CREDIT_CARD', 'DEBIT_CARD')
               AND a.payment_status = 'PENDING'
               AND a.booking_channel = 'ADMIN'
               AND a.status IN ('CONFIRMED', 'IN_PROGRESS', 'COMPLETED')`;
  const params = [];
  if (paymentMethod && paymentMethod !== 'ALL') {
    sql += ' AND a.payment_method = ?';
    params.push(paymentMethod);
  }
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

/**
 * Lista feriados cadastrados para bloquear agenda.
 */
async function listHolidays(activeOnly = true) {
  await ensureHolidaysTable();
  let sql = 'SELECT id, holiday_date, name, is_active FROM service_holidays WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY holiday_date ASC';
  const [rows] = await pool.execute(sql);
  return rows;
}

/**
 * Cria um novo feriado.
 */
async function addHoliday(dateStr, name) {
  await ensureHolidaysTable();
  const [result] = await pool.execute(
    `INSERT INTO service_holidays (holiday_date, name, is_active)
     VALUES (?, ?, 1)`,
    [dateStr, name]
  );
  return result.insertId;
}

/**
 * Remove um feriado pelo id.
 */
async function deleteHoliday(id) {
  await ensureHolidaysTable();
  const [result] = await pool.execute('DELETE FROM service_holidays WHERE id = ?', [id]);
  return result.affectedRows;
}

/**
 * Verifica se uma data é feriado ativo.
 */
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

/**
 * Atualiza resultado do pagamento da reserva (aprovado ou recusado).
 */
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

/**
 * Monta um código amigável para identificar pagamento de serviço.
 */
function buildPaymentRef(id) {
  return `SRV-${String(id).padStart(8, '0')}`;
}

/**
 * Confirma pagamento pelo lado do cliente (simulação).
 * Segurança: valida o customer_id, status e expiração da reserva.
 */
async function payByCustomer({ id, customerId, payment_method }) {
  await ensureAppointmentColumns();
  const apptId = Number(id);
  const custId = Number(customerId);
  if (!apptId || !custId) return { ok: false, code: 'INVALID', message: 'Agendamento inválido.' };
  const method = payment_method ? String(payment_method).toUpperCase() : null;
  if (method && !['PIX', 'CREDIT_CARD', 'DEBIT_CARD'].includes(method)) {
    return { ok: false, code: 'PAYMENT_METHOD_INVALID', message: 'Forma de pagamento inválida.' };
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute(
      `SELECT id, customer_id, status, payment_status, payment_method, reservation_expires_at,
              service_id, professional_id, scheduled_start, scheduled_end
       FROM service_appointments
       WHERE id = ?
       FOR UPDATE`,
      [apptId]
    );
    const current = rows && rows[0] ? rows[0] : null;
    if (!current) {
      await connection.rollback();
      return { ok: false, code: 'NOT_FOUND', message: 'Agendamento não encontrado.' };
    }
    if (Number(current.customer_id || 0) !== custId) {
      await connection.rollback();
      return { ok: false, code: 'FORBIDDEN', message: 'Você não pode pagar este agendamento.' };
    }
    const status = String(current.status || '').toUpperCase();
    if (!['RESERVED', 'PAYMENT_FAILED'].includes(status)) {
      await connection.rollback();
      return { ok: false, code: 'INVALID_STATUS', message: 'Este agendamento não está disponível para pagamento.' };
    }
    if (!current.reservation_expires_at || new Date(current.reservation_expires_at).getTime() < Date.now()) {
      await connection.rollback();
      return { ok: false, code: 'EXPIRED', message: 'Reserva expirada. Refaça o agendamento.' };
    }

    const startAt = new Date(current.scheduled_start);
    const endAt = new Date(current.scheduled_end);
    const proId = Number(current.professional_id);
    if (!proId || Number.isNaN(startAt.getTime()) || Number.isNaN(endAt.getTime())) {
      await connection.rollback();
      return { ok: false, code: 'INVALID', message: 'Dados do agendamento incompletos.' };
    }
    const hasAvailability = await ServiceProfessional.hasAvailability(proId, startAt, endAt);
    if (!hasAvailability) {
      await connection.rollback();
      return { ok: false, code: 'NO_AVAILABILITY', message: 'O horário não está mais disponível. Refaça o agendamento.' };
    }
    const hasConflict = await hasScheduleConflict(startAt, endAt, proId, apptId);
    if (hasConflict) {
      await connection.rollback();
      return { ok: false, code: 'CONFLICT', message: 'O horário foi ocupado por outro cliente. Refaça o agendamento.' };
    }
    const service = await HealthService.findById(current.service_id);
    if (!service || !service.is_active) {
      await connection.rollback();
      return { ok: false, code: 'SERVICE_INVALID', message: 'Serviço indisponível. Refaça o agendamento.' };
    }

    const paymentRef = buildPaymentRef(apptId);
    const [result] = await connection.execute(
      `UPDATE service_appointments
       SET status = 'CONFIRMED',
           payment_status = 'PAID',
           payment_ref = ?,
           payment_method = COALESCE(?, payment_method),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [paymentRef, method, apptId]
    );
    await connection.commit();
    return { ok: !!(result && result.affectedRows), payment_ref: paymentRef };
  } catch (err) {
    try { await connection.rollback(); } catch (_) {}
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * Confirma agendamento para pagamento presencial.
 */
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

/**
 * Marca atendimento como "em andamento".
 */
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

/**
 * Finaliza atendimento e salva dados clínicos.
 */
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

/**
 * Marca cliente como ausente e registra estorno parcial.
 */
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

/**
 * Marca atendimento como não finalizado e aplica regras de estorno.
 */
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

/**
 * Marca pagamento presencial como pago.
 */
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

/**
 * Atualiza dados principais de um agendamento.
 */
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

/**
 * Exclui agendamento pelo id.
 */
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
  payByCustomer,
  confirmCashBooking,
  markInProgress,
  markCompleted,
  markNoShow,
  markIncomplete,
  markCashAsPaid,
  updateById,
  deleteById,
};
