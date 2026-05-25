/**
 * Rótulos PT-BR para enums na interface (espelho de utils/displayLabels.js).
 */
(function (global) {
  var PAYMENT_STATUS = { PENDING: 'Pendente', PAID: 'Pago', FAILED: 'Falhou', REFUNDED_PARTIAL: 'Estorno parcial', REFUNDED: 'Estornado' };
  var PAYMENT_METHOD = { PIX: 'PIX', BOLETO: 'Boleto', CREDIT_CARD: 'Cartão de crédito', DEBIT_CARD: 'Cartão de débito', CASH: 'Dinheiro', TRANSFER: 'Transferência' };
  var ORDER_STATUS = { CONFIRMED: 'Confirmado', PROCESSING: 'Em processamento', SHIPPED: 'Enviado', DELIVERED: 'Entregue', CANCELLED: 'Cancelado', PENDING: 'Pendente' };
  var APPOINTMENT_STATUS = { RESERVED: 'Reservado', PAYMENT_FAILED: 'Pagamento falhou', CONFIRMED: 'Confirmado', IN_PROGRESS: 'Em atendimento', COMPLETED: 'Concluído', CANCELLED: 'Cancelado', NO_SHOW: 'Cliente ausente', INCOMPLETE: 'Não finalizado' };
  var MODALITY = { IN_STORE: 'Na farmácia', HOME: 'Domicílio', IN_PERSON: 'Presencial', HOME_VISIT: 'Domiciliar', ONLINE: 'Online' };
  var BOOKING_CHANNEL = { ADMIN: 'Balcão / Admin', CUSTOMER_ONLINE: 'Cliente online' };
  var PRODUCT_STATUS = { ACTIVE: 'Ativo', INACTIVE: 'Inativo', DISCONTINUED: 'Descontinuado' };
  var PERSON_TYPE = { PF: 'Pessoa física', PJ: 'Pessoa jurídica' };
  var PURCHASE_STATUS = { DRAFT: 'Rascunho', AWAITING_DELIVERY: 'Aguardando entrega', RECEIVED: 'Recebida', CANCELLED: 'Cancelada' };

  var MAPS = {
    paymentStatus: PAYMENT_STATUS,
    paymentMethod: PAYMENT_METHOD,
    orderStatus: ORDER_STATUS,
    appointmentStatus: APPOINTMENT_STATUS,
    modality: MODALITY,
    bookingChannel: BOOKING_CHANNEL,
    productStatus: PRODUCT_STATUS,
    personType: PERSON_TYPE,
    purchaseStatus: PURCHASE_STATUS,
  };

  function norm(v) {
    return String(v == null ? '' : v).trim().toUpperCase();
  }

  function fallback(key) {
    if (!key) return '—';
    return key.replace(/_/g, ' ').toLowerCase().replace(/\b\w/g, function (c) { return c.toUpperCase(); });
  }

  function label(category, value) {
    var key = norm(value);
    if (!key) return '—';
    var map = MAPS[category];
    if (!map) return fallback(key);
    return map[key] || fallback(key);
  }

  function paymentStatusBadge(value) {
    var k = norm(value);
    if (k === 'PAID') return 'success';
    if (k === 'FAILED') return 'danger';
    if (k === 'REFUNDED_PARTIAL' || k === 'REFUNDED') return 'info';
    if (k === 'PENDING') return 'warning';
    return 'secondary';
  }

  global.NeoLabels = {
    label: label,
    paymentStatus: function (v) { return label('paymentStatus', v); },
    paymentMethod: function (v) { return label('paymentMethod', v); },
    orderStatus: function (v) { return label('orderStatus', v); },
    appointmentStatus: function (v) { return label('appointmentStatus', v); },
    modality: function (v) { return label('modality', v); },
    bookingChannel: function (v) { return label('bookingChannel', v); },
    productStatus: function (v) { return label('productStatus', v); },
    personType: function (v) { return label('personType', v); },
    purchaseStatus: function (v) { return label('purchaseStatus', v); },
    paymentStatusBadge: paymentStatusBadge,
    MAPS: MAPS,
  };
})(typeof window !== 'undefined' ? window : globalThis);
