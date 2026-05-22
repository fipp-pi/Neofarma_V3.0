const HealthService = require('../models/HealthService');
const ServiceProfessional = require('../models/ServiceProfessional');
const ServiceAppointment = require('../models/ServiceAppointment');

const SLOT_STEP_MINUTES = 15;
const MIN_LEAD_MS = 24 * 60 * 60 * 1000;
const MAX_BOOKING_DAYS = 90;

/**
 * Data local no formato YYYY-MM-DD (evita bug de UTC com toISOString).
 */
function toLocalDateString(date) {
  const d = date instanceof Date ? date : new Date(date);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

/**
 * Interpreta YYYY-MM-DD como meio-dia local (evita mudar o dia da semana).
 */
function parseLocalDateOnly(dateStr) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(dateStr || '').trim());
  if (!m) return null;
  return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]), 12, 0, 0, 0);
}

/**
 * Monta Date local a partir de data + hora.
 */
function buildLocalDateTime(dateStr, hours, minutes) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(dateStr || '').trim());
  if (!m) return null;
  const d = new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]), hours, minutes, 0, 0);
  return Number.isNaN(d.getTime()) ? null : d;
}

/**
 * Converte TIME/HH:MM para minutos desde meia-noite.
 */
function timeToMinutes(value) {
  const raw = String(value || '').trim();
  const parts = raw.split(':').map((p) => Number(p));
  if (!parts.length || parts.some((n) => !Number.isFinite(n))) return null;
  return parts[0] * 60 + (parts[1] || 0);
}

/**
 * Valor para input datetime-local / POST.
 */
function formatSlotIsoLocal(date) {
  const pad = (n) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/**
 * Exibe horário amigável (ex.: 09:15).
 */
function formatSlotLabel(date) {
  const pad = (n) => String(n).padStart(2, '0');
  return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/**
 * Regras comuns antes de reservar (domingo, feriado, antecedência, modalidade).
 */
async function validateBookingRules({ startAt, modality, service, minLeadMs = MIN_LEAD_MS }) {
  if (!service || !service.is_active) {
    return { ok: false, code: 'SERVICE_INVALID', message: 'Serviço inválido/inativo.' };
  }
  if (!startAt || Number.isNaN(startAt.getTime())) {
    return { ok: false, code: 'DATETIME_INVALID', message: 'Data/hora inválida.' };
  }
  const mod = String(modality || 'IN_STORE').toUpperCase();
  if (mod === 'HOME' && !service.home_available) {
    return { ok: false, code: 'HOME_NOT_AVAILABLE', message: 'Este serviço não está disponível em domicílio.' };
  }
  if (mod === 'IN_STORE' && !service.in_store_available) {
    return { ok: false, code: 'IN_STORE_NOT_AVAILABLE', message: 'Este serviço não está disponível na farmácia.' };
  }
  const minLead = new Date(Date.now() + minLeadMs);
  if (startAt < minLead) {
    return { ok: false, code: 'MIN_LEAD', message: 'Agendamento deve ser feito com no mínimo 1 dia de antecedência.' };
  }
  if (startAt.getDay() === 0) {
    return { ok: false, code: 'SUNDAY', message: 'Não é possível agendar em domingo.' };
  }
  const dateOnly = toLocalDateString(startAt);
  if (await ServiceAppointment.isHoliday(dateOnly)) {
    return { ok: false, code: 'HOLIDAY', message: 'Não é possível agendar em feriado cadastrado.' };
  }
  return { ok: true, dateOnly };
}

/**
 * Verifica disponibilidade do profissional e conflitos para um intervalo.
 */
async function validateProfessionalSlot({ professionalId, startAt, endAt, ignoreAppointmentId = null }) {
  if (!professionalId) {
    return { ok: false, code: 'PROFESSIONAL_REQUIRED', message: 'Selecione um profissional.' };
  }
  const hasAvailability = await ServiceProfessional.hasAvailability(professionalId, startAt, endAt);
  if (!hasAvailability) {
    return { ok: false, code: 'NO_AVAILABILITY', message: 'Profissional sem disponibilidade para esse dia/horário.' };
  }
  const hasConflict = await ServiceAppointment.hasScheduleConflict(startAt, endAt, professionalId, ignoreAppointmentId);
  if (hasConflict) {
    return { ok: false, code: 'CONFLICT', message: 'Horário indisponível. Escolha outro horário.' };
  }
  return { ok: true };
}

/**
 * Lista horários livres em um dia para profissional + serviço.
 */
async function listAvailableSlots({ professionalId, serviceId, date, ignoreAppointmentId = null }) {
  const proId = Number(professionalId);
  const svcId = Number(serviceId);
  const dayDate = parseLocalDateOnly(date);
  if (!proId || !svcId || !dayDate) {
    return { ok: false, code: 'INVALID_PARAMS', message: 'Parâmetros inválidos.', slots: [] };
  }

  const service = await HealthService.findById(svcId);
  if (!service || !service.is_active) {
    return { ok: false, code: 'SERVICE_INVALID', message: 'Serviço inválido.', slots: [] };
  }

  const professional = await ServiceProfessional.findById(proId);
  if (!professional || !professional.is_active) {
    return { ok: false, code: 'PROFESSIONAL_INVALID', message: 'Profissional inválido.', slots: [] };
  }

  const dateOnly = toLocalDateString(dayDate);
  if (dayDate.getDay() === 0) {
    return { ok: true, date: dateOnly, slots: [], message: 'Domingo indisponível.' };
  }
  if (await ServiceAppointment.isHoliday(dateOnly)) {
    return { ok: true, date: dateOnly, slots: [], message: 'Feriado — sem horários.' };
  }

  const durationMin = Number(service.duration_minutes) || 30;
  const dayOfWeek = dayDate.getDay();
  const windows = await ServiceProfessional.listAvailabilityForDay(proId, dayOfWeek);
  if (!windows.length) {
    return { ok: true, date: dateOnly, slots: [], duration_minutes: durationMin };
  }

  const minLead = new Date(Date.now() + MIN_LEAD_MS);
  const slots = [];
  const seen = new Set();

  for (const w of windows) {
    const winStart = timeToMinutes(w.start_time);
    const winEnd = timeToMinutes(w.end_time);
    if (winStart == null || winEnd == null || winEnd <= winStart) continue;

    const lastStart = winEnd - durationMin;
    for (let m = winStart; m <= lastStart; m += SLOT_STEP_MINUTES) {
      const startAt = buildLocalDateTime(dateOnly, Math.floor(m / 60), m % 60);
      if (!startAt) continue;
      const endAt = new Date(startAt.getTime() + durationMin * 60000);
      if (startAt < minLead) continue;

      const iso = formatSlotIsoLocal(startAt);
      if (seen.has(iso)) continue;

      const avail = await ServiceProfessional.hasAvailability(proId, startAt, endAt);
      if (!avail) continue;
      const conflict = await ServiceAppointment.hasScheduleConflict(startAt, endAt, proId, ignoreAppointmentId);
      if (conflict) continue;

      seen.add(iso);
      slots.push({ value: iso, label: formatSlotLabel(startAt), start: iso, end: formatSlotIsoLocal(endAt) });
    }
  }

  slots.sort((a, b) => a.value.localeCompare(b.value));
  return { ok: true, date: dateOnly, slots, duration_minutes: durationMin };
}

/**
 * Verifica se existe ao menos um horário livre no dia (para calendário).
 */
async function dayHasAvailableSlot({ professionalId, serviceId, date, ignoreAppointmentId = null }) {
  const { slots } = await listAvailableSlots({ professionalId, serviceId, date, ignoreAppointmentId });
  return !!(slots && slots.length);
}

/**
 * Lista dias (YYYY-MM-DD) com pelo menos um horário livre no intervalo.
 */
async function listAvailableDays({ professionalId, serviceId, from, to, ignoreAppointmentId = null }) {
  const proId = Number(professionalId);
  const svcId = Number(serviceId);
  const fromDate = parseLocalDateOnly(from) || parseLocalDateOnly(toLocalDateString(new Date(Date.now() + MIN_LEAD_MS)));
  let toDate = parseLocalDateOnly(to);
  if (!proId || !svcId || !fromDate) {
    return { ok: false, code: 'INVALID_PARAMS', message: 'Parâmetros inválidos.', days: [] };
  }
  if (!toDate) {
    toDate = new Date(fromDate);
    toDate.setDate(toDate.getDate() + 60);
  }
  if (toDate < fromDate) {
    return { ok: false, code: 'INVALID_RANGE', message: 'Intervalo de datas inválido.', days: [] };
  }

  const maxEnd = new Date(fromDate);
  maxEnd.setDate(maxEnd.getDate() + MAX_BOOKING_DAYS);
  if (toDate > maxEnd) toDate = maxEnd;

  const service = await HealthService.findById(svcId);
  if (!service || !service.is_active) {
    return { ok: false, code: 'SERVICE_INVALID', message: 'Serviço inválido.', days: [] };
  }

  const days = [];
  const cursor = new Date(fromDate.getFullYear(), fromDate.getMonth(), fromDate.getDate(), 12, 0, 0, 0);
  const end = new Date(toDate.getFullYear(), toDate.getMonth(), toDate.getDate(), 12, 0, 0, 0);

  while (cursor <= end) {
    const dateStr = toLocalDateString(cursor);
    if (cursor.getDay() !== 0 && !(await ServiceAppointment.isHoliday(dateStr))) {
      const windows = await ServiceProfessional.listAvailabilityForDay(proId, cursor.getDay());
      if (windows.length) {
        const has = await dayHasAvailableSlot({
          professionalId: proId,
          serviceId: svcId,
          date: dateStr,
          ignoreAppointmentId,
        });
        if (has) days.push(dateStr);
      }
    }
    cursor.setDate(cursor.getDate() + 1);
  }

  return { ok: true, days };
}

/**
 * Tenta interpretar address_text salvo no agendamento domiciliar.
 */
function parseAddressText(text) {
  if (!text || !String(text).trim()) return {};
  const parts = String(text).split(' - ').map((s) => s.trim()).filter(Boolean);
  if (parts.length < 3) return { street: String(text).trim() };
  const cityState = parts[parts.length - 1];
  const district = parts[parts.length - 2];
  const head = parts.slice(0, -2).join(' - ');
  const slash = cityState.lastIndexOf('/');
  const city = slash >= 0 ? cityState.slice(0, slash).trim() : cityState;
  const state = slash >= 0 ? cityState.slice(slash + 1).trim() : '';
  const comma = head.lastIndexOf(',');
  if (comma < 0) return { street: head, district, city, state };
  const street = head.slice(0, comma).trim();
  const numPart = head.slice(comma + 1).trim();
  const innerDash = numPart.indexOf(' - ');
  if (innerDash >= 0) {
    return {
      street,
      number: numPart.slice(0, innerDash).trim(),
      complement: numPart.slice(innerDash + 3).trim(),
      district,
      city,
      state,
    };
  }
  return { street, number: numPart, district, city, state };
}

module.exports = {
  SLOT_STEP_MINUTES,
  MIN_LEAD_MS,
  MAX_BOOKING_DAYS,
  toLocalDateString,
  parseLocalDateOnly,
  buildLocalDateTime,
  formatSlotIsoLocal,
  validateBookingRules,
  validateProfessionalSlot,
  listAvailableSlots,
  listAvailableDays,
  parseAddressText,
};
