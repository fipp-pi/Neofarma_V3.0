/**
 * Remove caracteres não numéricos de códigos GTIN/EAN.
 * @param {string|number} value
 * @returns {string}
 */
function stripGtin(value) {
  if (typeof value !== 'string' && typeof value !== 'number') return '';
  return String(value).replace(/\D/g, '');
}

/** @deprecated Use stripGtin */
const stripEan13 = stripGtin;

/**
 * Valida dígito verificador GS1 (EAN-8/12/13/14, GTIN).
 * @param {string} digits Apenas números
 * @param {number} expectedLength Tamanho total esperado (inclui verificador)
 * @returns {boolean}
 */
function isValidGtinChecksum(digits, expectedLength) {
  const code = String(digits || '');
  if (code.length !== expectedLength) return false;
  if (/^(\d)\1+$/.test(code)) return false;

  let sum = 0;
  for (let i = 0; i < expectedLength - 1; i += 1) {
    const n = parseInt(code[i], 10);
    sum += i % 2 === 0 ? n : n * 3;
  }
  const check = (10 - (sum % 10)) % 10;
  return check === parseInt(code[expectedLength - 1], 10);
}

/**
 * Valida EAN-13 (13 dígitos e dígito verificador GS1).
 * @param {string} ean
 * @returns {boolean}
 */
function isValidEan13(ean) {
  return isValidGtinChecksum(stripGtin(ean), 13);
}

/**
 * Valida GTIN-14 para caixas de distribuição (14 dígitos + verificador GS1).
 * @param {string} gtin
 * @returns {boolean}
 */
function isValidGtin14(gtin) {
  return isValidGtinChecksum(stripGtin(gtin), 14);
}

module.exports = {
  stripGtin,
  stripEan13,
  isValidGtinChecksum,
  isValidEan13,
  isValidGtin14,
};
