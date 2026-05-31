/**
 * Gera uma sequência numérica aleatória para códigos simples.
 */
function randomNumeric(len) {
  let out = '';
  while (out.length < len) out += Math.floor(Math.random() * 10);
  return out.slice(0, len);
}

/**
 * Hash estável para gerar dados determinísticos de simulação.
 * Usa variação do FNV-1a 32-bit.
 */
function hash32(str) {
  let h = 2166136261;
  for (let i = 0; i < str.length; i += 1) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

// PRNG determinístico usado para manter previews idênticos entre telas.
function mulberry32(seed) {
  let t = seed >>> 0;
  return function () {
    t += 0x6D2B79F5;
    let x = t;
    x = Math.imul(x ^ (x >>> 15), x | 1);
    x ^= x + Math.imul(x ^ (x >>> 7), x | 61);
    return ((x ^ (x >>> 14)) >>> 0) / 4294967296;
  };
}

/**
 * Gera um QR visual fictício (SVG) apenas para simulação de UX.
 * Não deve ser usado como QR real de cobrança.
 */
function generatePseudoQrSvgDataUri(text, opts = {}) {
  const qrModules = Number(opts.qrModules || 29);
  const quiet = Number(opts.quiet || 4);
  const total = qrModules + quiet * 2;

  const seed = hash32(String(text || ''));
  const rnd = mulberry32(seed);

  const grid = Array.from({ length: qrModules }, () => Array.from({ length: qrModules }, () => rnd() < 0.36));

  function setFinder(originX, originY) {
    for (let y = 0; y < 7; y += 1) {
      for (let x = 0; x < 7; x += 1) {
        const isBorder = x === 0 || x === 6 || y === 0 || y === 6;
        const isInner = x >= 2 && x <= 4 && y >= 2 && y <= 4;
        grid[originY + y][originX + x] = isBorder || isInner;
      }
    }
  }

  // Finder patterns em 3 cantos (aparência visual de QR).
  setFinder(0, 0);
  setFinder(qrModules - 7, 0);
  setFinder(0, qrModules - 7);

  // Timing patterns (linha e coluna 6)
  for (let i = 0; i < qrModules; i += 1) {
    grid[6][i] = (i % 2 === 0);
    grid[i][6] = (i % 2 === 0);
  }

  // Alignment visual simplificado (não segue especificação oficial).
  const ax = qrModules - 9;
  const ay = qrModules - 9;
  for (let y = 0; y < 5; y += 1) {
    for (let x = 0; x < 5; x += 1) {
      const isBorder = x === 0 || x === 4 || y === 0 || y === 4;
      const isCenter = x === 2 && y === 2;
      if (isBorder || isCenter) grid[ay + y][ax + x] = true;
      else grid[ay + y][ax + x] = false;
    }
  }

  const rects = [];
  for (let y = 0; y < qrModules; y += 1) {
    for (let x = 0; x < qrModules; x += 1) {
      if (!grid[y][x]) continue;
      rects.push(`<rect x="${x + quiet}" y="${y + quiet}" width="1" height="1" />`);
    }
  }

  const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${total}" height="${total}" viewBox="0 0 ${total} ${total}">
  <rect width="${total}" height="${total}" fill="#FFFFFF"/>
  <g fill="#000000">
    ${rects.join('\n    ')}
  </g>
</svg>`;

  // Data URI em base64 para evitar problemas de encoding/renderização.
  return `data:image/svg+xml;base64,${Buffer.from(svg, 'utf8').toString('base64')}`;
}

/**
 * Gera dígitos usando um gerador já criado (determinístico).
 */
function randomDigitsFromRnd(rnd, len) {
  let out = '';
  for (let i = 0; i < len; i += 1) out += Math.floor(rnd() * 10);
  return out;
}

/**
 * Monta os dados simulados de pagamento PIX.
 * É usado pelo checkout e pela tela de preview.
 */
function buildPixPayload(orderId, amount, opts = {}) {
  const ref = opts.orderRef != null ? opts.orderRef : orderId;
  const copyPaste = `00020126360014BR.GOV.BCB.PIX0114neofarma@pix520400005303986540${amount.toFixed(2).replace('.', '')}5802BR5908NeoFarma6009SaoPaulo62070503***6304${String(ref).padStart(4, '0')}`;
  const pseudoQr = generatePseudoQrSvgDataUri(copyPaste, { qrModules: 29, quiet: 4 });
  return {
    status: 'PENDING',
    pix_qr_code: pseudoQr,
    pix_copy_paste: copyPaste,
  };
}

/**
 * Monta os dados simulados de boleto (código e vencimento).
 * Mantém consistência entre telas usando referência do pedido.
 */
function buildBoletoPayload(orderId, opts = {}) {
  const orderRef = opts.orderRef != null ? opts.orderRef : orderId;
  const dueDateStr = opts.dueDate
    ? String(opts.dueDate)
    : (() => {
        const dueDate = new Date();
        dueDate.setDate(dueDate.getDate() + 3);
        return dueDate.toISOString().slice(0, 10);
      })();

  // Código determinístico garante consistência entre preview e confirmação.
  const seedBase = String(orderRef) + ':' + String(dueDateStr);
  const seed = hash32(seedBase);
  const rnd = mulberry32(seed);

  const d1 = randomDigitsFromRnd(rnd, 5);
  const d2 = randomDigitsFromRnd(rnd, 5);
  const d3 = randomDigitsFromRnd(rnd, 5);
  const d4 = randomDigitsFromRnd(rnd, 6);
  const d5 = randomDigitsFromRnd(rnd, 5);
  const d6 = randomDigitsFromRnd(rnd, 6);
  const d7 = randomDigitsFromRnd(rnd, 1);
  const d8 = randomDigitsFromRnd(rnd, 14);

  const barcode = `${d1}.${d2} ${d3}.${d4} ${d5}.${d6} ${d7} ${d8}`;
  return {
    status: 'PENDING',
    boleto_barcode: barcode,
    boleto_due_date: dueDateStr,
  };
}

/**
 * Tenta identificar a bandeira do cartão pelos primeiros dígitos.
 */
function detectBrand(cardNumber = '') {
  const clean = String(cardNumber).replace(/\D/g, '');
  if (/^4/.test(clean)) return 'VISA';
  if (/^5[1-5]/.test(clean)) return 'MASTERCARD';
  if (/^3[47]/.test(clean)) return 'AMEX';
  return 'OUTRO';
}

/**
 * Cria as opções de parcelamento para mostrar no checkout.
 */
function buildInstallments(total) {
  const plans = [];
  for (let i = 1; i <= 12; i += 1) {
    const interest = i <= 3 ? 0 : 0.015 * (i - 3);
    const finalAmount = total * (1 + interest);
    plans.push({
      installments: i,
      interest_rate: Number((interest * 100).toFixed(2)),
      installment_value: Number((finalAmount / i).toFixed(2)),
      total_value: Number(finalAmount.toFixed(2)),
    });
  }
  return plans;
}

/**
 * Simula autorização de cartão: valida formato mínimo e retorna metadados.
 * Não integra com adquirente real.
 */
function validateCreditCardInput({ card_number, card_holder, card_expiry, card_cvv }) {
  const clean = String(card_number || '').replace(/\D/g, '');
  const brand = detectBrand(clean);
  const minLen = brand === 'AMEX' ? 15 : 13;
  const maxLen = brand === 'AMEX' ? 15 : 19;
  if (clean.length < minLen || clean.length > maxLen) {
    const err = new Error('Número do cartão inválido.');
    err.code = 'INVALID_CARD';
    throw err;
  }

  const holder = String(card_holder || '').trim();
  if (holder.length < 3 || !/[A-Za-zÀ-ÿ]/.test(holder)) {
    const err = new Error('Informe o nome do titular como impresso no cartão.');
    err.code = 'INVALID_CARD_HOLDER';
    throw err;
  }

  const expiryDigits = String(card_expiry || '').replace(/\D/g, '');
  if (expiryDigits.length !== 4) {
    const err = new Error('Validade do cartão inválida. Use MM/AA.');
    err.code = 'INVALID_CARD_EXPIRY';
    throw err;
  }
  const month = Number(expiryDigits.slice(0, 2));
  const year = Number(expiryDigits.slice(2, 4));
  if (month < 1 || month > 12) {
    const err = new Error('Mês de validade inválido.');
    err.code = 'INVALID_CARD_EXPIRY';
    throw err;
  }
  const now = new Date();
  const currentYear = now.getFullYear() % 100;
  const currentMonth = now.getMonth() + 1;
  if (year < currentYear || (year === currentYear && month < currentMonth)) {
    const err = new Error('Cartão expirado.');
    err.code = 'INVALID_CARD_EXPIRY';
    throw err;
  }

  const cvvDigits = String(card_cvv || '').replace(/\D/g, '');
  const cvvLen = brand === 'AMEX' ? 4 : 3;
  if (cvvDigits.length !== cvvLen) {
    const err = new Error('CVV inválido.');
    err.code = 'INVALID_CARD_CVV';
    throw err;
  }
}

function buildCardPayload({ card_number, card_holder, card_expiry, card_cvv, installments, total }) {
  validateCreditCardInput({ card_number, card_holder, card_expiry, card_cvv });
  const clean = String(card_number || '').replace(/\D/g, '');
  const allPlans = buildInstallments(total);
  const selected = allPlans.find((p) => p.installments === Number(installments || 1)) || allPlans[0];
  return {
    status: 'PAID',
    card_brand: detectBrand(clean),
    card_last4: clean.slice(-4),
    installments: selected.installments,
    interest_rate: selected.interest_rate,
  };
}

/**
 * Dispatcher central de payload por método de pagamento.
 * Mantém um único ponto de regra para PIX, Boleto e Cartão.
 */
function buildPaymentPayload(method, data) {
  const orderRef = data.orderRef != null ? data.orderRef : data.orderId;
  if (method === 'PIX') return buildPixPayload(data.orderId, data.amount, { orderRef });
  if (method === 'BOLETO') return buildBoletoPayload(data.orderId, { orderRef, dueDate: data.boleto_due_date });
  if (method === 'CREDIT_CARD') return buildCardPayload(data);
  const err = new Error('Método de pagamento inválido.');
  err.code = 'INVALID_PAYMENT_METHOD';
  throw err;
}

module.exports = {
  buildInstallments,
  buildPaymentPayload,
};
