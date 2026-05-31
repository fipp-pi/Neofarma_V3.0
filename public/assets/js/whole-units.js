(function (global) {
  var WHOLE_UNITS_MSG = 'A quantidade deve ser um número inteiro (unidades).';

  function parseWholeUnits(value, opts) {
    opts = opts || {};
    var min = opts.min != null ? opts.min : (opts.allowZero ? 0 : 1);
    var emptyMessage = opts.emptyMessage || 'Informe uma quantidade válida.';

    if (value === null || value === undefined) {
      return { ok: false, message: emptyMessage };
    }

    var str = String(value).trim();
    if (str === '') {
      return { ok: false, message: emptyMessage };
    }

    var normalized = str.replace(',', '.');
    if (/^-?\d+\.\d+$/.test(normalized)) {
      var fraction = normalized.split('.')[1].replace(/0+$/, '');
      if (fraction !== '') {
        return { ok: false, message: WHOLE_UNITS_MSG };
      }
    }

    var num = Number(normalized);
    if (!Number.isFinite(num)) {
      return { ok: false, message: emptyMessage };
    }
    if (!Number.isInteger(num)) {
      return { ok: false, message: WHOLE_UNITS_MSG };
    }
    if (num < min) {
      if (min === 0) {
        return { ok: false, message: 'A quantidade não pode ser negativa.' };
      }
      return {
        ok: false,
        message: min === 1 ? 'Informe uma quantidade maior que zero.' : ('Informe uma quantidade igual ou maior que ' + min + '.'),
      };
    }

    return { ok: true, value: num };
  }

  global.NeoWholeUnits = {
    parseWholeUnits: parseWholeUnits,
    WHOLE_UNITS_MSG: WHOLE_UNITS_MSG,
  };
})(window);
