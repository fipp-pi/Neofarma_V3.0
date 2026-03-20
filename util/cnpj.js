/**
 * Remove caracteres não numéricos do CNPJ.
 * @param {string} cnpj
 * @returns {string}
 */
function stripCNPJ(cnpj) {
  if (typeof cnpj !== 'string') return '';
  return cnpj.replace(/[^0-9]/g, '');
}

/**
 * Valida CNPJ (dígitos verificadores e regras básicas).
 * Aceita string com ou sem formatação (14 dígitos).
 * @param {string} cnpj
 * @returns {boolean}
 */
function isValidCNPJ(cnpj) {
  const digits = stripCNPJ(cnpj);
  if (digits.length !== 14) return false;
  if (/^(\d)\1+$/.test(digits)) return false; // todos iguais

  const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  let sum = 0;
  for (let i = 0; i < 12; i++) sum += parseInt(digits[i], 10) * weights1[i];
  let remainder = sum % 11;
  const digit1 = remainder < 2 ? 0 : 11 - remainder;
  if (digit1 !== parseInt(digits[12], 10)) return false;

  sum = 0;
  for (let i = 0; i < 13; i++) sum += parseInt(digits[i], 10) * weights2[i];
  remainder = sum % 11;
  const digit2 = remainder < 2 ? 0 : 11 - remainder;
  if (digit2 !== parseInt(digits[13], 10)) return false;

  return true;
}

/**
 * Formata CNPJ para exibição (00.000.000/0000-00).
 * @param {string} cnpj
 * @returns {string}
 */
function formatCNPJ(cnpj) {
  const d = stripCNPJ(cnpj);
  if (d.length !== 14) return cnpj;
  return d.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, '$1.$2.$3/$4-$5');
}

module.exports = { stripCNPJ, isValidCNPJ, formatCNPJ };
