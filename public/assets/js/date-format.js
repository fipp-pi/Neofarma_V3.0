(function (global) {
  'use strict';

  var TZ = 'America/Sao_Paulo';

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
        var y = value.getUTCFullYear();
        var m = String(value.getUTCMonth() + 1).padStart(2, '0');
        var day = String(value.getUTCDate()).padStart(2, '0');
        return new Date(y + '-' + m + '-' + day + 'T12:00:00-03:00');
      }
      return value;
    }
    var raw = String(value).trim();
    if (!raw) return null;
    var isoDateOnly = raw.match(/^(\d{4}-\d{2}-\d{2})T00:00:00(?:\.000)?Z$/);
    if (isoDateOnly) return new Date(isoDateOnly[1] + 'T12:00:00-03:00');
    if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return new Date(raw + 'T12:00:00-03:00');
    var mysql = raw.match(/^(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}(?::\d{2})?)/);
    if (mysql) {
      var time = mysql[2].length === 5 ? mysql[2] + ':00' : mysql[2];
      return new Date(mysql[1] + 'T' + time + '-03:00');
    }
    var d = new Date(raw);
    return Number.isNaN(d.getTime()) ? null : d;
  }

  function formatDate(value) {
    var d = parseDate(value);
    if (!d) return '—';
    return new Intl.DateTimeFormat('pt-BR', {
      timeZone: TZ,
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    }).format(d);
  }

  function formatDateTime(value) {
    var d = parseDate(value);
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

  function formatDateTimeSec(value) {
    var d = parseDate(value);
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
    var d = parseDate(value);
    if (!d) return '';
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: TZ,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(d);
  }

  function toDatetimeLocal(value) {
    var d = parseDate(value);
    if (!d) return '';
    var parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: TZ,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
    }).formatToParts(d);
    var map = {};
    parts.forEach(function (p) {
      if (p.type !== 'literal') map[p.type] = p.value;
    });
    return map.year + '-' + map.month + '-' + map.day + 'T' + map.hour + ':' + map.minute;
  }

  function toDateInput(value) {
    return formatDateInput(value);
  }

  global.NeoDates = {
    TZ: TZ,
    parseDate: parseDate,
    formatDate: formatDate,
    formatDateTime: formatDateTime,
    formatDateTimeSec: formatDateTimeSec,
    formatDateInput: formatDateInput,
    toDatetimeLocal: toDatetimeLocal,
    toDateInput: toDateInput,
  };
})(window);
