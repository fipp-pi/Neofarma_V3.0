/**
 * Formatação de datas/horas para exibição — fuso America/Sao_Paulo (Brasília).
 */
const TZ = 'America/Sao_Paulo';

function parseDate(value) {
  if (value == null || value === '') return null;
  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) return null;
    if (
      value.getUTCHours() === 0 &&
      value.getUTCMinutes() === 0 &&
      value.getUTCSeconds() === 0 &&
      value.getUTCMilliseconds() === 0
    ) {
      const y = value.getUTCFullYear();
      const m = String(value.getUTCMonth() + 1).padStart(2, '0');
      const day = String(value.getUTCDate()).padStart(2, '0');
      return new Date(`${y}-${m}-${day}T12:00:00-03:00`);
    }
    return value;
  }
  const raw = String(value).trim();
  if (!raw) return null;

  const isoDateOnly = raw.match(/^(\d{4}-\d{2}-\d{2})T00:00:00(?:\.000)?Z$/);
  if (isoDateOnly) {
    return new Date(`${isoDateOnly[1]}T12:00:00-03:00`);
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    return new Date(`${raw}T12:00:00-03:00`);
  }

  const mysql = raw.match(/^(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}(?::\d{2})?)/);
  if (mysql) {
    const time = mysql[2].length === 5 ? `${mysql[2]}:00` : mysql[2];
    return new Date(`${mysql[1]}T${time}-03:00`);
  }

  const d = new Date(raw);
  return Number.isNaN(d.getTime()) ? null : d;
}

function formatDateBr(value) {
  const d = parseDate(value);
  if (!d) return '—';
  return new Intl.DateTimeFormat('pt-BR', {
    timeZone: TZ,
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(d);
}

function formatDateLongBr(value) {
  const d = parseDate(value) || new Date();
  return new Intl.DateTimeFormat('pt-BR', {
    timeZone: TZ,
    weekday: 'long',
    day: '2-digit',
    month: 'long',
    year: 'numeric',
  }).format(d);
}

function formatDateTimeBr(value) {
  const d = parseDate(value);
  if (!d) return '—';
  return new Intl.DateTimeFormat('pt-BR', {
    timeZone: TZ,
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(d);
}

function formatDateTimeSecBr(value) {
  const d = parseDate(value);
  if (!d) return '';
  return new Intl.DateTimeFormat('pt-BR', {
    timeZone: TZ,
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  }).format(d);
}

function formatDateInput(value) {
  const d = parseDate(value);
  if (!d) return '';
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: TZ,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(d);
}

function formatDatetimeLocal(value) {
  const d = parseDate(value);
  if (!d) return '';
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: TZ,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).formatToParts(d);
  const map = {};
  parts.forEach((p) => {
    if (p.type !== 'literal') map[p.type] = p.value;
  });
  return `${map.year}-${map.month}-${map.day}T${map.hour}:${map.minute}`;
}

module.exports = {
  TZ,
  parseDate,
  formatDateBr,
  formatDateLongBr,
  formatDateTimeBr,
  formatDateTimeSecBr,
  formatDateInput,
  formatDatetimeLocal,
};
