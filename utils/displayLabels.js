/**
 * Rótulos em português (Brasil) para enums exibidos na interface.
 * Valores internos (PAID, IN_STORE, etc.) permanecem no banco/API.
 */

const PAYMENT_STATUS = {
  PENDING: 'Pendente',
  PAID: 'Pago',
  FAILED: 'Falhou',
  REFUNDED_PARTIAL: 'Estorno parcial',
  REFUNDED: 'Estornado',
};

const PAYMENT_METHOD = {
  PIX: 'PIX',
  BOLETO: 'Boleto',
  CREDIT_CARD: 'Cartão de crédito',
  DEBIT_CARD: 'Cartão de débito',
  CASH: 'Dinheiro',
  TRANSFER: 'Transferência',
};

const ORDER_STATUS = {
  CONFIRMED: 'Confirmado',
  PROCESSING: 'Em processamento',
  SHIPPED: 'Enviado',
  DELIVERED: 'Entregue',
  CANCELLED: 'Cancelado',
  PENDING: 'Pendente',
};

const APPOINTMENT_STATUS = {
  RESERVED: 'Reservado',
  PAYMENT_FAILED: 'Pagamento falhou',
  CONFIRMED: 'Confirmado',
  IN_PROGRESS: 'Em atendimento',
  COMPLETED: 'Concluído',
  CANCELLED: 'Cancelado',
  NO_SHOW: 'Cliente ausente',
  INCOMPLETE: 'Não finalizado',
};

const MODALITY = {
  IN_STORE: 'Na farmácia',
  HOME: 'Domicílio',
  IN_PERSON: 'Presencial',
  HOME_VISIT: 'Domiciliar',
  ONLINE: 'Online',
};

const BOOKING_CHANNEL = {
  ADMIN: 'Balcão / Admin',
  CUSTOMER_ONLINE: 'Cliente online',
};

const PRODUCT_STATUS = {
  ACTIVE: 'Ativo',
  INACTIVE: 'Inativo',
  DISCONTINUED: 'Descontinuado',
};

const PERSON_TYPE = {
  PF: 'Pessoa física',
  PJ: 'Pessoa jurídica',
};

const PURCHASE_STATUS = {
  DRAFT: 'Rascunho',
  AWAITING_DELIVERY: 'Aguardando entrega',
  RECEIVED: 'Recebida',
  CANCELLED: 'Cancelada',
};

const VALIDITY_STATUS = {
  VALID: 'Válido',
  EXPIRING: 'Próximo do vencimento',
  EXPIRED: 'Vencido',
};

const DISPOSAL_STATUS = {
  NONE: 'Sem descarte',
  PARTIAL: 'Descarte parcial',
  FULL: 'Descartado totalmente',
};

const SOURCE_TYPE = {
  ORDER: 'Pedido',
  SERVICE: 'Serviço de saúde',
};

const MAPS = {
  paymentStatus: PAYMENT_STATUS,
  paymentMethod: PAYMENT_METHOD,
  orderStatus: ORDER_STATUS,
  appointmentStatus: APPOINTMENT_STATUS,
  modality: MODALITY,
  bookingChannel: BOOKING_CHANNEL,
  productStatus: PRODUCT_STATUS,
  personType: PERSON_TYPE,
  purchaseStatus: PURCHASE_STATUS,
  validityStatus: VALIDITY_STATUS,
  disposalStatus: DISPOSAL_STATUS,
  sourceType: SOURCE_TYPE,
};

/** @param {unknown} value */
function normalize(value) {
  return String(value == null ? '' : value).trim().toUpperCase();
}

/** @param {string} key */
function fallbackLabel(key) {
  if (!key) return '—';
  return key
    .replace(/_/g, ' ')
    .toLowerCase()
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

/**
 * @param {string} category - chave em MAPS (ex.: paymentStatus)
 * @param {unknown} value
 * @returns {string}
 */
function label(category, value) {
  const key = normalize(value);
  if (!key) return '—';
  const map = MAPS[category];
  if (!map) return fallbackLabel(key);
  return map[key] || fallbackLabel(key);
}

/**
 * @param {unknown} value
 * @returns {'success'|'danger'|'warning'|'info'|'secondary'|'muted'}
 */
function paymentStatusBadge(value) {
  const k = normalize(value);
  if (k === 'PAID') return 'success';
  if (k === 'FAILED') return 'danger';
  if (k === 'REFUNDED_PARTIAL' || k === 'REFUNDED') return 'info';
  if (k === 'PENDING') return 'warning';
  return 'secondary';
}

/**
 * @param {unknown} value
 * @returns {'success'|'danger'|'warning'|'info'|'secondary'|'muted'}
 */
function appointmentStatusBadge(value) {
  const k = normalize(value);
  if (k === 'COMPLETED') return 'success';
  if (k === 'CANCELLED' || k === 'NO_SHOW' || k === 'PAYMENT_FAILED') return 'danger';
  if (k === 'IN_PROGRESS' || k === 'CONFIRMED') return 'info';
  if (k === 'RESERVED' || k === 'INCOMPLETE') return 'warning';
  return 'muted';
}

/**
 * @param {unknown} value
 * @returns {'success'|'danger'|'warning'|'muted'}
 */
function productStatusBadge(value) {
  const k = normalize(value);
  if (k === 'ACTIVE') return 'success';
  if (k === 'DISCONTINUED') return 'danger';
  return 'muted';
}

module.exports = {
  MAPS,
  label,
  paymentStatus: (v) => label('paymentStatus', v),
  paymentMethod: (v) => label('paymentMethod', v),
  orderStatus: (v) => label('orderStatus', v),
  appointmentStatus: (v) => label('appointmentStatus', v),
  modality: (v) => label('modality', v),
  bookingChannel: (v) => label('bookingChannel', v),
  productStatus: (v) => label('productStatus', v),
  personType: (v) => label('personType', v),
  purchaseStatus: (v) => label('purchaseStatus', v),
  validityStatus: (v) => label('validityStatus', v),
  disposalStatus: (v) => label('disposalStatus', v),
  sourceType: (v) => label('sourceType', v),
  paymentStatusBadge,
  appointmentStatusBadge,
  productStatusBadge,
};
