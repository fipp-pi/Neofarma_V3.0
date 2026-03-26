const HealthService = require('../models/HealthService');
const ServiceAppointment = require('../models/ServiceAppointment');
const ServiceProfessional = require('../models/ServiceProfessional');
const { pool } = require('../config/database');
const Customer = require('../models/Customer');

function toMoney(v) {
  return Number(v || 0).toFixed(2);
}

function calcTravelFee(modality, zip) {
  if (modality !== 'HOME') return 0;
  const cep = String(zip || '').replace(/\D/g, '');
  const tail = cep ? Number(cep.slice(-2)) : 0;
  return Number((15 + (tail % 10) * 1.5).toFixed(2));
}

function buildPaymentRef(id) {
  return `SRV-${String(id).padStart(8, '0')}`;
}

async function renderPage(req, res, next) {
  try {
    await ServiceAppointment.expirePendingReservations();
    const services = await HealthService.findAll(false);
    const professionals = await ServiceProfessional.findAll(false);
    const holidays = await ServiceAppointment.listHolidays(true);
    const statusFilter = String(req.query.status || 'ALL').toUpperCase();
    const appointments = await ServiceAppointment.listAll({ status: statusFilter });
    const summary = appointments.reduce((acc, a) => {
      acc.total += 1;
      if (a.status === 'RESERVED' || a.status === 'PAYMENT_FAILED') acc.reserved += 1;
      if (a.status === 'CONFIRMED') acc.confirmed += 1;
      if (a.status === 'IN_PROGRESS') acc.inProgress += 1;
      if (a.status === 'COMPLETED') acc.completed += 1;
      return acc;
    }, { total: 0, reserved: 0, confirmed: 0, inProgress: 0, completed: 0 });

    res.render('admin/agendamentos-servicos', {
      title: 'Agendar Serviços - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'agendamentos_servicos',
      services,
      appointments,
      professionals,
      holidays,
      statusFilter,
      summary,
      toMoney,
    });
  } catch (err) {
    next(err);
  }
}

async function renderCashDeskPage(req, res, next) {
  try {
    const from = String(req.query.from || '').trim();
    const to = String(req.query.to || '').trim();
    const professional_id = Number(req.query.professional_id || 0);
    const professionals = await ServiceProfessional.findAll(true);
    const rows = await ServiceAppointment.listCashPending({ from, to, professional_id });
    const totalPending = rows.reduce((acc, r) => acc + Number(r.total_amount || 0), 0);
    res.render('admin/agendamentos-caixa', {
      title: 'Caixa de Serviços - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'agendamentos_servicos',
      rows,
      professionals,
      filters: { from, to, professional_id },
      totalPending,
    });
  } catch (err) {
    next(err);
  }
}

async function exportCashDeskCsv(req, res, next) {
  try {
    const from = String(req.query.from || '').trim();
    const to = String(req.query.to || '').trim();
    const professional_id = Number(req.query.professional_id || 0);
    const rows = await ServiceAppointment.listCashPending({ from, to, professional_id });
    const header = [
      'agendamento_id',
      'data_hora',
      'cliente',
      'servico',
      'profissional',
      'valor_total',
      'modalidade',
      'status',
      'pagamento_status',
    ];
    const lines = [header.join(';')];
    rows.forEach((r) => {
      lines.push([
        r.id,
        r.scheduled_start ? String(r.scheduled_start).slice(0, 19).replace('T', ' ') : '',
        `"${String(r.customer_name || '').replace(/"/g, '""')}"`,
        `"${String(r.service_name || '').replace(/"/g, '""')}"`,
        `"${String(r.professional_name || '').replace(/"/g, '""')}"`,
        Number(r.total_amount || 0).toFixed(2),
        r.modality || '',
        r.status || '',
        r.payment_status || '',
      ].join(';'));
    });
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="caixa_servicos.csv"');
    res.send('\uFEFF' + lines.join('\n'));
  } catch (err) {
    next(err);
  }
}

async function addHoliday(req, res, next) {
  try {
    const b = req.body || {};
    const date = String(b.holiday_date || '').trim();
    const name = String(b.name || '').trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return res.status(400).json({ ok: false, message: 'Data inválida.' });
    if (!name) return res.status(400).json({ ok: false, message: 'Nome do feriado é obrigatório.' });
    await ServiceAppointment.addHoliday(date, name);
    return res.json({ ok: true, message: 'Feriado cadastrado.' });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'Já existe feriado cadastrado para esta data.' });
    }
    next(err);
  }
}

async function deleteHoliday(req, res, next) {
  try {
    const id = Number(req.params.id);
    const n = await ServiceAppointment.deleteHoliday(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Feriado não encontrado.' });
    return res.json({ ok: true, message: 'Feriado removido.' });
  } catch (err) {
    next(err);
  }
}

async function saveProfessional(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const b = req.body || {};
    if (!b.full_name || !String(b.full_name).trim()) {
      return res.status(400).json({ ok: false, message: 'Nome do profissional é obrigatório.' });
    }
    const role = String(b.role_name || 'FARMACEUTICO').toUpperCase();
    if (!['FARMACEUTICO', 'ENFERMEIRO'].includes(role)) {
      return res.status(400).json({ ok: false, message: 'Cargo inválido.' });
    }
    const councilUf = String(b.council_uf || '').trim().toUpperCase();
    const councilNumber = String(b.council_number || '').trim().toUpperCase();
    const requiredCouncilType = role === 'FARMACEUTICO' ? 'CRF' : 'COREN';
    const providedCouncilType = String(b.council_type || requiredCouncilType).trim().toUpperCase();
    if (providedCouncilType !== requiredCouncilType) {
      return res.status(400).json({ ok: false, message: `Registro inválido para o cargo. Use ${requiredCouncilType}.` });
    }
    if (!/^[A-Z]{2}$/.test(councilUf)) {
      return res.status(400).json({ ok: false, message: 'UF do conselho inválida (use 2 letras, ex.: SP).' });
    }
    if (!/^[A-Z0-9./-]{4,30}$/.test(councilNumber)) {
      return res.status(400).json({ ok: false, message: 'Número de registro inválido.' });
    }
    const payload = {
      id: b.id ? Number(b.id) : null,
      full_name: String(b.full_name).trim(),
      role_name: role,
      email: b.email ? String(b.email).trim() : null,
      phone: b.phone ? String(b.phone).trim() : null,
      council_type: requiredCouncilType,
      council_uf: councilUf,
      council_number: councilNumber,
      is_active: b.is_active !== undefined ? !!b.is_active : true,
    };
    await connection.beginTransaction();
    const up = await ServiceProfessional.upsert(payload, connection);

    const slots = Array.isArray(b.availability) ? b.availability
      .map((s) => ({
        day_of_week: Number(s.day_of_week),
        start_time: String(s.start_time || ''),
        end_time: String(s.end_time || ''),
      }))
      .filter((s) => Number.isInteger(s.day_of_week) && s.day_of_week >= 0 && s.day_of_week <= 6 && /^\d{2}:\d{2}(:\d{2})?$/.test(s.start_time) && /^\d{2}:\d{2}(:\d{2})?$/.test(s.end_time))
      : [];
    if (!payload.id || Array.isArray(b.availability)) {
      await ServiceProfessional.replaceAvailability(up.id, slots, connection);
    }
    await connection.commit();
    return res.json({ ok: true, id: up.id, message: 'Profissional salvo com disponibilidade.' });
  } catch (err) {
    try { await connection.rollback(); } catch (_) {}
    if (err && err.code === 'DUPLICATE_PROFESSIONAL') {
      if (err.field === 'email') return res.status(409).json({ ok: false, message: 'Já existe profissional com este e-mail.' });
      if (err.field === 'phone') return res.status(409).json({ ok: false, message: 'Já existe profissional com este telefone.' });
      return res.status(409).json({ ok: false, message: 'Já existe profissional com mesmo nome e cargo.' });
    }
    if (err && err.code === 'ER_DUP_ENTRY' && String(err.sqlMessage || '').includes('uk_service_professionals_council')) {
      return res.status(409).json({ ok: false, message: 'Já existe profissional com este registro profissional.' });
    }
    if (err && err.code === 'ER_NO_SUCH_TABLE') {
      return res.status(500).json({ ok: false, message: 'Tabela de agendamento não encontrada. Atualize o schema do banco (DB_Neofarma_clean.sql).' });
    }
    return res.status(500).json({ ok: false, message: 'Erro interno ao salvar profissional.' });
  } finally {
    connection.release();
  }
}

async function saveService(req, res, next) {
  try {
    const b = req.body || {};
    if (!b.name || !String(b.name).trim()) {
      return res.status(400).json({ ok: false, message: 'Nome do serviço é obrigatório.' });
    }
    const price = Number(b.price);
    const duration = Number(b.duration_minutes);
    if (!Number.isFinite(price) || price < 0) return res.status(400).json({ ok: false, message: 'Preço inválido.' });
    if (!Number.isFinite(duration) || duration <= 0) return res.status(400).json({ ok: false, message: 'Duração inválida.' });
    const serviceGroup = String(b.service_group || 'OUTRO').toUpperCase();
    if (!['VACINACAO', 'PROCEDIMENTO', 'TESTE_RAPIDO', 'ACOMPANHAMENTO', 'ORIENTACAO', 'OUTRO'].includes(serviceGroup)) {
      return res.status(400).json({ ok: false, message: 'Grupo de serviço inválido.' });
    }
    const minAge = b.min_age_years !== undefined && b.min_age_years !== null && String(b.min_age_years).trim() !== ''
      ? Number(b.min_age_years)
      : null;
    const maxAge = b.max_age_years !== undefined && b.max_age_years !== null && String(b.max_age_years).trim() !== ''
      ? Number(b.max_age_years)
      : null;
    const obsMinutes = Number(b.post_observation_minutes || 0);
    if (minAge !== null && (!Number.isInteger(minAge) || minAge < 0 || minAge > 120)) {
      return res.status(400).json({ ok: false, message: 'Idade mínima inválida.' });
    }
    if (maxAge !== null && (!Number.isInteger(maxAge) || maxAge < 0 || maxAge > 120)) {
      return res.status(400).json({ ok: false, message: 'Idade máxima inválida.' });
    }
    if (minAge !== null && maxAge !== null && maxAge < minAge) {
      return res.status(400).json({ ok: false, message: 'Idade máxima não pode ser menor que a mínima.' });
    }
    if (!Number.isInteger(obsMinutes) || obsMinutes < 0 || obsMinutes > 240) {
      return res.status(400).json({ ok: false, message: 'Tempo de observação inválido.' });
    }
    const data = {
      id: b.id ? Number(b.id) : null,
      name: String(b.name).trim(),
      price: Number(price.toFixed(2)),
      duration_minutes: Math.round(duration),
      requires_prescription: !!b.requires_prescription,
      service_group: serviceGroup,
      in_store_available: b.in_store_available !== undefined ? !!b.in_store_available : true,
      home_available: !!b.home_available,
      min_age_years: minAge,
      max_age_years: maxAge,
      post_observation_minutes: obsMinutes,
      prep_instructions: b.prep_instructions ? String(b.prep_instructions).trim() : null,
      contraindications: b.contraindications ? String(b.contraindications).trim() : null,
      required_supplies: b.required_supplies ? String(b.required_supplies).trim() : null,
      is_active: b.is_active !== undefined ? !!b.is_active : true,
      notes: b.notes ? String(b.notes).trim() : null,
    };
    const result = await HealthService.upsert(data);
    return res.json({ ok: true, id: result.id, message: data.id ? 'Serviço atualizado.' : 'Serviço criado.' });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'Já existe um serviço com esse nome.' });
    }
    next(err);
  }
}

async function deleteService(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const n = await HealthService.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Serviço não encontrado.' });
    return res.json({ ok: true, message: 'Serviço excluído.' });
  } catch (err) {
    if (err && err.code === 'ER_ROW_IS_REFERENCED_2') {
      return res.status(409).json({ ok: false, message: 'Serviço vinculado a agendamentos. Edite ou inative em vez de excluir.' });
    }
    next(err);
  }
}

async function reserveSlot(req, res, next) {
  try {
    await ServiceAppointment.expirePendingReservations();
    const b = req.body || {};
    const serviceId = Number(b.service_id);
    const service = await HealthService.findById(serviceId);
    if (!service || !service.is_active) return res.status(400).json({ ok: false, code: 'SERVICE_INVALID', message: 'Serviço inválido/inativo.' });

    const modality = String(b.modality || 'IN_STORE').toUpperCase();
    const paymentMethod = String(b.payment_method || 'PIX').toUpperCase();
    if (!['CASH', 'PIX', 'CREDIT_CARD', 'DEBIT_CARD'].includes(paymentMethod)) {
      return res.status(400).json({ ok: false, code: 'PAYMENT_METHOD_INVALID', message: 'Forma de pagamento inválida.' });
    }
    const bookingChannel = String(b.booking_channel || 'ADMIN').toUpperCase();
    if (!['ADMIN', 'CUSTOMER_ONLINE'].includes(bookingChannel)) {
      return res.status(400).json({ ok: false, code: 'BOOKING_CHANNEL_INVALID', message: 'Origem de agendamento inválida.' });
    }
    if (!['IN_STORE', 'HOME'].includes(modality)) return res.status(400).json({ ok: false, code: 'MODALITY_INVALID', message: 'Modalidade inválida.' });
    if (modality === 'HOME' && !service.home_available) {
      return res.status(400).json({ ok: false, code: 'HOME_NOT_AVAILABLE', message: 'Este serviço não está disponível em domicílio.' });
    }

    const startAt = new Date(b.scheduled_start);
    if (Number.isNaN(startAt.getTime())) return res.status(400).json({ ok: false, code: 'DATETIME_INVALID', message: 'Data/hora inválida.' });
    const minLead = new Date(Date.now() + (24 * 60 * 60 * 1000));
    if (startAt < minLead) {
      return res.status(400).json({ ok: false, code: 'MIN_LEAD', message: 'Agendamento deve ser feito com no mínimo 1 dia de antecedência.' });
    }
    if (startAt.getDay() === 0) {
      return res.status(400).json({ ok: false, code: 'SUNDAY', message: 'Não é possível agendar em domingo.' });
    }
    const dateOnly = startAt.toISOString().slice(0, 10);
    const holiday = await ServiceAppointment.isHoliday(dateOnly);
    if (holiday) {
      return res.status(400).json({ ok: false, code: 'HOLIDAY', message: 'Não é possível agendar em feriado cadastrado.' });
    }
    const professionalId = Number(b.professional_id);
    if (!professionalId) return res.status(400).json({ ok: false, code: 'PROFESSIONAL_REQUIRED', message: 'Selecione um profissional.' });
    const endAt = new Date(startAt.getTime() + Number(service.duration_minutes) * 60000);
    const hasAvailability = await ServiceProfessional.hasAvailability(professionalId, startAt, endAt);
    if (!hasAvailability) {
      return res.status(409).json({ ok: false, code: 'NO_AVAILABILITY', message: 'Profissional sem disponibilidade para esse dia/horário.' });
    }
    const hasConflict = await ServiceAppointment.hasScheduleConflict(startAt, endAt, professionalId);
    if (hasConflict) return res.status(409).json({ ok: false, code: 'CONFLICT', message: 'Horário indisponível. Escolha outro horário.' });

    if (modality === 'HOME') {
      const cep = String(b.zip_code || '').replace(/\D/g, '');
      if (cep.length !== 8) return res.status(400).json({ ok: false, code: 'ZIP_INVALID', message: 'CEP inválido para atendimento em domicílio.' });
      if (!String(b.street || '').trim() || !String(b.number || '').trim() || !String(b.district || '').trim() || !String(b.city || '').trim() || !String(b.state || '').trim()) {
        return res.status(400).json({ ok: false, code: 'ADDRESS_REQUIRED', message: 'Preencha endereço completo para atendimento em domicílio.' });
      }
    }

    const travelFee = calcTravelFee(modality, b.zip_code);
    const total = Number((Number(service.price) + travelFee).toFixed(2));
    const tempRef = `TMP-${Date.now()}`;
    const addressText = modality === 'HOME'
      ? `${String(b.street || '').trim()}, ${String(b.number || '').trim()}${b.complement ? ' - ' + String(b.complement).trim() : ''} - ${String(b.district || '').trim()} - ${String(b.city || '').trim()}/${String(b.state || '').trim()}`
      : null;
    const appointmentId = await ServiceAppointment.createReservation({
      service_id: serviceId,
      professional_id: professionalId,
      customer_id: b.customer_id ? Number(b.customer_id) : null,
      customer_name: String(b.customer_name || '').trim(),
      customer_email: b.customer_email ? String(b.customer_email).trim() : null,
      customer_phone: b.customer_phone ? String(b.customer_phone).trim() : null,
      modality,
      address_text: addressText,
      zip_code: modality === 'HOME' ? (b.zip_code ? String(b.zip_code).trim() : null) : null,
      travel_fee: travelFee,
      total_amount: total,
      scheduled_start: startAt,
      scheduled_end: endAt,
      payment_method: paymentMethod,
      booking_channel: bookingChannel,
      hold_minutes: paymentMethod === 'CASH' ? 0 : 10,
      status: paymentMethod === 'CASH' ? 'CONFIRMED' : 'RESERVED',
      payment_status: paymentMethod === 'CASH' ? 'PENDING' : 'PENDING',
      payment_ref: tempRef,
    });
    if (paymentMethod === 'CASH') {
      return res.status(201).json({
        ok: true,
        id: appointmentId,
        expires_in_minutes: 0,
        totals: { service: Number(service.price), travel: travelFee, total },
        message: 'Agendamento confirmado. Pagamento em dinheiro será realizado presencialmente.',
      });
    }
    return res.status(201).json({
      ok: true,
      id: appointmentId,
      payment_link: `/admin/agendamentos-servicos?pay=${appointmentId}`,
      expires_in_minutes: 10,
      totals: { service: Number(service.price), travel: travelFee, total },
      message: 'Reserva criada por 10 minutos. Prosseguir para pagamento.',
    });
  } catch (err) {
    next(err);
  }
}

async function renderCustomerBookingPage(req, res, next) {
  try {
    const profile = await Customer.getProfileByUserId(req.session.userId);
    if (!profile || !profile.customer_id) return res.redirect('/login?redirect=/account/agendamentos');
    await ServiceAppointment.expirePendingReservations();
    const services = (await HealthService.findAll(true)).filter((s) => s.is_active);
    const professionals = (await ServiceProfessional.findAll(true)).filter((p) => p.is_active);
    const holidays = await ServiceAppointment.listHolidays(true);
    const bookings = await ServiceAppointment.listByCustomerId(profile.customer_id);
    res.render('account-agendamentos', {
      title: 'Meus Agendamentos - NeoFarma',
      bodyClass: 'account-page',
      activeNav: 'account',
      profile,
      services,
      professionals,
      holidays,
      bookings,
    });
  } catch (err) {
    next(err);
  }
}

async function createCustomerBooking(req, res, next) {
  try {
    const profile = await Customer.getProfileByUserId(req.session.userId);
    if (!profile || !profile.customer_id) return res.status(403).json({ ok: false, message: 'Cliente não encontrado.' });
    req.body = {
      ...(req.body || {}),
      customer_id: profile.customer_id,
      customer_name: req.body && req.body.customer_name ? req.body.customer_name : profile.full_name,
      customer_email: req.body && req.body.customer_email ? req.body.customer_email : profile.email,
      customer_phone: req.body && req.body.customer_phone ? req.body.customer_phone : profile.phone,
      booking_channel: 'CUSTOMER_ONLINE',
      payment_method: req.body && req.body.payment_method ? req.body.payment_method : 'PIX',
    };
    return reserveSlot(req, res, next);
  } catch (err) {
    next(err);
  }
}

async function renderCustomerPaymentPage(req, res, next) {
  try {
    const profile = await Customer.getProfileByUserId(req.session.userId);
    if (!profile || !profile.customer_id) return res.redirect('/login?redirect=/account/agendamentos');
    await ServiceAppointment.expirePendingReservations();
    const id = Number(req.params.id);
    if (!id) return res.redirect('/account/agendamentos');
    const appointment = await ServiceAppointment.findById(id);
    if (!appointment || Number(appointment.customer_id || 0) !== Number(profile.customer_id)) {
      return res.redirect('/account/agendamentos');
    }
    res.render('account-agendamento-pagamento', {
      title: 'Pagamento do Agendamento - NeoFarma',
      bodyClass: 'account-page',
      activeNav: 'account',
      profile,
      appointment,
    });
  } catch (err) {
    next(err);
  }
}

async function renderCustomerReceiptPage(req, res, next) {
  try {
    const profile = await Customer.getProfileByUserId(req.session.userId);
    if (!profile || !profile.customer_id) return res.redirect('/login?redirect=/account/agendamentos');
    const id = Number(req.params.id);
    if (!id) return res.redirect('/account/agendamentos');
    const appointment = await ServiceAppointment.findById(id);
    if (!appointment || Number(appointment.customer_id || 0) !== Number(profile.customer_id)) {
      return res.redirect('/account/agendamentos');
    }
    const paymentStatus = String(appointment.payment_status || '').toUpperCase();
    if (!['PAID', 'REFUNDED_PARTIAL'].includes(paymentStatus)) {
      return res.redirect('/account/agendamentos');
    }
    res.render('account-agendamento-recibo', {
      title: 'Recibo do Agendamento - NeoFarma',
      bodyClass: 'account-page',
      activeNav: 'account',
      profile,
      appointment,
    });
  } catch (err) {
    next(err);
  }
}

async function payCustomerAppointment(req, res, next) {
  try {
    const profile = await Customer.getProfileByUserId(req.session.userId);
    if (!profile || !profile.customer_id) return res.status(403).json({ ok: false, code: 'CUSTOMER_NOT_FOUND', message: 'Cliente não encontrado.' });
    await ServiceAppointment.expirePendingReservations();
    const id = Number(req.params.id);
    const method = req.body && req.body.payment_method ? String(req.body.payment_method).toUpperCase() : null;
    const result = await ServiceAppointment.payByCustomer({ id, customerId: profile.customer_id, payment_method: method });
    if (result && result.ok) {
      return res.json({ ok: true, message: 'Pagamento confirmado e agendamento efetivado (simulação).', payment_ref: result.payment_ref });
    }
    const status = (result && result.code === 'NOT_FOUND') ? 404
      : (result && (result.code === 'FORBIDDEN')) ? 403
        : (result && (result.code === 'CONFLICT' || result.code === 'NO_AVAILABILITY')) ? 409
          : 400;
    return res.status(status).json({ ok: false, code: result.code || 'PAY_FAILED', message: result.message || 'Não foi possível confirmar o pagamento.' });
  } catch (err) {
    next(err);
  }
}

async function processPayment(req, res, next) {
  try {
    await ServiceAppointment.expirePendingReservations();
    const id = Number(req.params.id);
    const b = req.body || {};
    const approved = !!b.approved;
    const appointment = await ServiceAppointment.findById(id);
    if (!appointment) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    const updated = await ServiceAppointment.updatePaymentResult(id, approved);
    if (!updated) {
      return res.status(409).json({ ok: false, message: 'Reserva expirada. Refaça o agendamento.' });
    }
    if (!approved) {
      return res.status(400).json({ ok: false, message: 'Pagamento não autorizado. Tente novamente antes de 10 minutos.' });
    }
    return res.json({
      ok: true,
      message: 'Pagamento confirmado e agendamento efetivado. Notificação enviada (simulação).',
      payment_ref: buildPaymentRef(id),
      orientation: appointment.requires_prescription ? 'Apresentar receita médica no atendimento.' : 'Levar documento com foto.',
    });
  } catch (err) {
    next(err);
  }
}

async function startAttendance(req, res, next) {
  try {
    const id = Number(req.params.id);
    const n = await ServiceAppointment.markInProgress(id);
    if (!n) return res.status(400).json({ ok: false, message: 'Só é possível iniciar atendimento confirmado.' });
    return res.json({ ok: true, message: 'Atendimento iniciado.' });
  } catch (err) {
    next(err);
  }
}

async function completeAttendance(req, res, next) {
  try {
    const id = Number(req.params.id);
    const b = req.body || {};
    const appointment = await ServiceAppointment.findById(id);
    if (!appointment) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    const clinical = String(b.clinical_record || '').trim();
    if (!clinical) return res.status(400).json({ ok: false, message: 'Registro clínico é obrigatório.' });
    const isVaccination = String(appointment.service_group || '').toUpperCase() === 'VACINACAO';
    const vaccineBatchCode = b.vaccine_batch_code ? String(b.vaccine_batch_code).trim() : null;
    const vaccineExpiryDate = b.vaccine_expiry_date || null;
    if (isVaccination && (!vaccineBatchCode || !vaccineExpiryDate)) {
      return res.status(400).json({ ok: false, message: 'Para vacinação, informe lote e validade da vacina.' });
    }
    const n = await ServiceAppointment.markCompleted(id, {
      clinical_record: clinical,
      vaccine_batch_code: isVaccination ? vaccineBatchCode : null,
      vaccine_expiry_date: isVaccination ? vaccineExpiryDate : null,
      application_site: b.application_site ? String(b.application_site).trim() : null,
      observations: b.observations ? String(b.observations).trim() : null,
    });
    if (!n) return res.status(400).json({ ok: false, message: 'Atendimento não está em estado concluível.' });
    return res.json({ ok: true, message: 'Atendimento concluído. Comprovante/certificado enviado (simulação).' });
  } catch (err) {
    next(err);
  }
}

async function markNoShow(req, res, next) {
  try {
    const id = Number(req.params.id);
    const appt = await ServiceAppointment.findById(id);
    if (!appt) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    const refund = Number((Number(appt.total_amount || 0) * 0.5).toFixed(2));
    const n = await ServiceAppointment.markNoShow(id, refund);
    if (!n) return res.status(400).json({ ok: false, message: 'Não foi possível marcar como ausente nesse status.' });
    return res.json({ ok: true, message: `Cliente marcado como ausente. Estorno parcial de 50%: R$ ${toMoney(refund)}.` });
  } catch (err) {
    next(err);
  }
}

async function markIncomplete(req, res, next) {
  try {
    const id = Number(req.params.id);
    const reason = String((req.body && req.body.reason) || '').trim();
    if (!reason) return res.status(400).json({ ok: false, message: 'Motivo é obrigatório.' });
    const appointment = await ServiceAppointment.findById(id);
    if (!appointment) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    const hasPaid = String(appointment.payment_status || '').toUpperCase() === 'PAID';
    let refundPercent = Number((req.body && req.body.refund_percent) || 50);
    if (!Number.isFinite(refundPercent)) refundPercent = 50;
    refundPercent = Math.max(0, Math.min(100, refundPercent));
    const refundAmount = hasPaid
      ? Number((Number(appointment.total_amount || 0) * (refundPercent / 100)).toFixed(2))
      : 0;
    const n = await ServiceAppointment.markIncomplete(id, reason, { refund_amount: refundAmount });
    if (!n) return res.status(400).json({ ok: false, message: 'Não foi possível marcar como não finalizado.' });
    if (hasPaid) {
      return res.json({
        ok: true,
        message: `Marcado como não finalizado. Estorno parcial de ${refundPercent}% aplicado: R$ ${toMoney(refundAmount)}.`,
      });
    }
    return res.json({ ok: true, message: 'Marcado como não finalizado. Pagamento pendente foi reclassificado e alerta de reagendamento gerado.' });
  } catch (err) {
    next(err);
  }
}

async function markCashReceived(req, res, next) {
  try {
    const id = Number(req.params.id);
    const method = String((req.body && req.body.payment_method) || '').toUpperCase();
    if (method && !['CASH', 'PIX', 'CREDIT_CARD', 'DEBIT_CARD'].includes(method)) {
      return res.status(400).json({ ok: false, message: 'Método de pagamento inválido.' });
    }
    const n = await ServiceAppointment.markCashAsPaid(id, method || null);
    if (!n) return res.status(400).json({ ok: false, message: 'Não foi possível confirmar recebimento presencial neste status.' });
    const methodLabel = method === 'PIX'
      ? 'PIX'
      : method === 'CREDIT_CARD'
        ? 'cartão de crédito'
        : method === 'DEBIT_CARD'
          ? 'cartão de débito'
          : 'dinheiro';
    return res.json({ ok: true, message: `Pagamento presencial confirmado (${methodLabel}).` });
  } catch (err) {
    next(err);
  }
}

async function deleteProfessional(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const n = await ServiceProfessional.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Profissional não encontrado.' });
    return res.json({ ok: true, message: 'Profissional excluído.' });
  } catch (err) {
    next(err);
  }
}

async function updateAppointment(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const current = await ServiceAppointment.findById(id);
    if (!current) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });

    const b = req.body || {};
    const serviceId = Number(b.service_id);
    const service = await HealthService.findById(serviceId);
    if (!service || !service.is_active) return res.status(400).json({ ok: false, message: 'Serviço inválido/inativo.' });

    const professionalId = Number(b.professional_id);
    if (!professionalId) return res.status(400).json({ ok: false, message: 'Selecione um profissional.' });

    const modality = String(b.modality || 'IN_STORE').toUpperCase();
    if (!['IN_STORE', 'HOME'].includes(modality)) return res.status(400).json({ ok: false, message: 'Modalidade inválida.' });
    if (modality === 'HOME' && !service.home_available) {
      return res.status(400).json({ ok: false, message: 'Este serviço não está disponível em domicílio.' });
    }

    const startAt = new Date(b.scheduled_start);
    if (Number.isNaN(startAt.getTime())) return res.status(400).json({ ok: false, message: 'Data/hora inválida.' });
    if (startAt.getDay() === 0) return res.status(400).json({ ok: false, message: 'Não é possível agendar em domingo.' });
    const minLead = new Date(Date.now() + (24 * 60 * 60 * 1000));
    if (startAt < minLead) return res.status(400).json({ ok: false, message: 'Agendamento deve ser feito com no mínimo 1 dia de antecedência.' });
    const dateOnly = startAt.toISOString().slice(0, 10);
    if (await ServiceAppointment.isHoliday(dateOnly)) {
      return res.status(400).json({ ok: false, message: 'Não é possível agendar em feriado cadastrado.' });
    }

    const endAt = new Date(startAt.getTime() + Number(service.duration_minutes) * 60000);
    const hasAvailability = await ServiceProfessional.hasAvailability(professionalId, startAt, endAt);
    if (!hasAvailability) return res.status(409).json({ ok: false, message: 'Profissional sem disponibilidade para esse dia/horário.' });
    const hasConflict = await ServiceAppointment.hasScheduleConflict(startAt, endAt, professionalId, id);
    if (hasConflict) return res.status(409).json({ ok: false, message: 'Horário indisponível. Escolha outro horário.' });

    const zip = String(b.zip_code || '').trim();
    if (modality === 'HOME') {
      const required = [zip, b.street, b.number, b.district, b.city, b.state];
      if (required.some((v) => !String(v || '').trim())) {
        return res.status(400).json({ ok: false, message: 'Preencha endereço completo para atendimento em domicílio.' });
      }
    }
    const travelFee = calcTravelFee(modality, zip);
    const total = Number((Number(service.price || 0) + travelFee).toFixed(2));
    const addressText = modality === 'HOME'
      ? `${String(b.street || '').trim()}, ${String(b.number || '').trim()}${b.complement ? ' - ' + String(b.complement).trim() : ''} - ${String(b.district || '').trim()} - ${String(b.city || '').trim()}/${String(b.state || '').trim()}`
      : null;

    const n = await ServiceAppointment.updateById(id, {
      service_id: serviceId,
      professional_id: professionalId,
      customer_name: String(b.customer_name || '').trim(),
      customer_email: b.customer_email ? String(b.customer_email).trim() : null,
      customer_phone: b.customer_phone ? String(b.customer_phone).trim() : null,
      modality,
      address_text: addressText,
      zip_code: modality === 'HOME' ? zip : null,
      travel_fee: travelFee,
      total_amount: total,
      scheduled_start: startAt,
      scheduled_end: endAt,
    });
    if (!n) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    return res.json({ ok: true, message: 'Agendamento atualizado.', previous_status: current.status });
  } catch (err) {
    next(err);
  }
}

async function deleteAppointment(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!id) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const n = await ServiceAppointment.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Agendamento não encontrado.' });
    return res.json({ ok: true, message: 'Agendamento excluído.' });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  renderPage,
  renderCashDeskPage,
  exportCashDeskCsv,
  saveService,
  deleteService,
  saveProfessional,
  deleteProfessional,
  addHoliday,
  deleteHoliday,
  reserveSlot,
  updateAppointment,
  deleteAppointment,
  renderCustomerBookingPage,
  createCustomerBooking,
  renderCustomerPaymentPage,
  renderCustomerReceiptPage,
  payCustomerAppointment,
  processPayment,
  startAttendance,
  completeAttendance,
  markNoShow,
  markIncomplete,
  markCashReceived,
};
