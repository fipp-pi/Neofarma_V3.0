const WHOLE_UNITS_MSG = 'A quantidade deve ser um número inteiro (unidades).';

/**
 * Converte valor para quantidade inteira de unidades. Rejeita decimais (ex.: 2.5).
 *
 * @param {*} value
 * @param {{ min?: number, allowZero?: boolean, emptyMessage?: string }} [opts]
 * @returns {{ ok: true, value: number } | { ok: false, message: string }}
 */
function parseWholeUnits(value, opts = {}) {
  const min = opts.min ?? (opts.allowZero ? 0 : 1);
  const emptyMessage = opts.emptyMessage || 'Informe uma quantidade válida.';

  if (value === null || value === undefined) {
    return { ok: false, message: emptyMessage };
  }

  const str = String(value).trim();
  if (str === '') {
    return { ok: false, message: emptyMessage };
  }

  const normalized = str.replace(',', '.');
  if (/^-?\d+\.\d+$/.test(normalized)) {
    const fraction = normalized.split('.')[1].replace(/0+$/, '');
    if (fraction !== '') {
      return { ok: false, message: WHOLE_UNITS_MSG };
    }
  }

  const num = Number(normalized);
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
      message: min === 1 ? 'Informe uma quantidade maior que zero.' : `Informe uma quantidade igual ou maior que ${min}.`,
    };
  }

  return { ok: true, value: num };
}

/**
 * @param {*} value
 * @param {{ min?: number, allowZero?: boolean, emptyMessage?: string }} [opts]
 * @returns {number}
 */
function parseWholeUnitsOrThrow(value, opts = {}) {
  const result = parseWholeUnits(value, opts);
  if (!result.ok) {
    const err = new Error(result.message);
    err.code = 'INVALID_QUANTITY';
    throw err;
  }
  return result.value;
}

module.exports = {
  parseWholeUnits,
  parseWholeUnitsOrThrow,
  WHOLE_UNITS_MSG,
};
