/**
 * Carrega dados e metadados dos relatórios financeiros (admin).
 */
const displayLabels = require('../utils/displayLabels');
const { formatDateTimeSecBr } = require('../utils/dateFormat');
const FinanceAdmin = require('../models/FinanceAdmin');

const REPORT_META = {
  overview: {
    id: 'overview',
    title: 'Panorama geral',
    subtitle: 'Visão consolidada de receitas, métodos de pagamento e produtos destaque.',
    icon: 'bi-speedometer2',
    color: 'primary',
  },
  products: {
    id: 'products',
    title: 'Desempenho de produtos',
    subtitle: 'Ranking de vendas por produto, categoria, tipo e laboratório.',
    icon: 'bi-box-seam',
    color: 'info',
  },
  sales: {
    id: 'sales',
    title: 'Vendas e pedidos',
    subtitle: 'Detalhamento linha a linha dos pedidos pagos no período.',
    icon: 'bi-bag-check',
    color: 'success',
  },
  customers: {
    id: 'customers',
    title: 'Carteira de clientes',
    subtitle: 'Perfil, localização, histórico de compras e indicadores de inadimplência.',
    icon: 'bi-people',
    color: 'warning',
  },
  services: {
    id: 'services',
    title: 'Serviços de saúde',
    subtitle: 'Agendamentos, profissionais, modalidades e receitas de serviços.',
    icon: 'bi-heart-pulse',
    color: 'danger',
  },
};

function parseFilters(query) {
  const report = String(query.report || 'overview').toLowerCase();
  const daysRaw = parseInt(query.days, 10);
  return {
    report: REPORT_META[report] ? report : 'overview',
    from: query.from ? String(query.from).trim() : '',
    to: query.to ? String(query.to).trim() : '',
    days: query.from && query.to ? null : (Number.isFinite(daysRaw) && daysRaw > 0 ? daysRaw : 90),
    category_id: query.category_id || '',
    product_type_id: query.product_type_id || '',
    lab_id: query.lab_id || '',
    sort: query.sort || 'most',
    search: query.search ? String(query.search).trim() : '',
    min_qty: query.min_qty || '',
    product_status: query.product_status || '',
    limit: Math.min(500, Math.max(10, parseInt(query.limit, 10) || 100)),
    customer_id: query.customer_id || '',
    product_id: query.product_id || '',
    payment_method: query.payment_method || '',
    order_status: query.order_status || '',
    person_type: query.person_type || '',
    city: query.city || '',
    name: query.name || '',
    delinquent: query.delinquent || '',
    min_spent: query.min_spent || '',
    professional_id: query.professional_id || '',
    service_id: query.service_id || '',
    status_filter: query.status_filter || '',
    payment_status: query.payment_status || '',
    modality: query.modality || '',
    channel: query.channel || '',
  };
}

function periodOpts(filters) {
  if (filters.from && filters.to) return { from: filters.from, to: filters.to };
  return { days: filters.days || 90 };
}

async function loadReportData(filters) {
  const opts = periodOpts(filters);
  const data = {
    revenueByMethod: {},
    mostSold: [],
    revenueByDay: [],
    productReport: [],
    salesReport: [],
    customerReport: [],
    serviceReport: [],
    summary: {},
  };

  if (filters.report === 'overview') {
    const ovDays = filters.from && filters.to ? opts : { days: filters.days || 30, ...opts };
    const [revenueByMethod, mostSold, revenueByDay, financeSummary] = await Promise.all([
      FinanceAdmin.getRevenueByPaymentMethod(ovDays),
      FinanceAdmin.getMostSoldProducts({ ...ovDays, limit: 15 }),
      FinanceAdmin.getRevenueByDay({ ...ovDays, limitDays: 31 }),
      FinanceAdmin.getFinanceSummary(ovDays),
    ]);
    data.revenueByMethod = revenueByMethod;
    data.mostSold = mostSold;
    data.revenueByDay = revenueByDay;
    data.summary = {
      revenue_paid: financeSummary.revenue_paid || 0,
      total_transactions: (financeSummary.total_orders || 0) + (financeSummary.total_services || 0),
      pending_count: financeSummary.pending_count || 0,
      failed_count: financeSummary.failed_count || 0,
    };
    return data;
  }

  if (filters.report === 'products') {
    data.productReport = await FinanceAdmin.getProductReport({
      ...opts,
      category_id: filters.category_id,
      product_type_id: filters.product_type_id,
      lab_id: filters.lab_id,
      sort: filters.sort,
      search: filters.search,
      min_qty: filters.min_qty,
      product_status: filters.product_status,
      limit: filters.limit,
    });
    data.summary = summarizeProducts(data.productReport);
    return data;
  }

  if (filters.report === 'sales') {
    data.salesReport = await FinanceAdmin.getSalesReport({
      ...opts,
      customer_id: filters.customer_id,
      category_id: filters.category_id,
      product_id: filters.product_id,
      payment_method: filters.payment_method,
      order_status: filters.order_status,
      search: filters.search,
      limit: filters.limit,
    });
    data.summary = summarizeSales(data.salesReport);
    return data;
  }

  if (filters.report === 'customers') {
    data.customerReport = await FinanceAdmin.getCustomerReport({
      person_type: filters.person_type,
      city: filters.city,
      name: filters.name,
      search: filters.search,
      delinquent: filters.delinquent,
      min_spent: filters.min_spent,
      from: filters.from,
      to: filters.to,
      days: filters.days,
      limit: filters.limit,
    });
    data.summary = summarizeCustomers(data.customerReport);
    return data;
  }

  if (filters.report === 'services') {
    data.serviceReport = await FinanceAdmin.getServiceReport({
      ...opts,
      professional_id: filters.professional_id,
      service_id: filters.service_id,
      status_filter: filters.status_filter,
      payment_status: filters.payment_status,
      modality: filters.modality,
      channel: filters.channel,
      search: filters.search,
      limit: filters.limit,
    });
    data.summary = summarizeServices(data.serviceReport);
    return data;
  }

  return data;
}

function summarizeProducts(rows) {
  const list = rows || [];
  return {
    count: list.length,
    total_qty: list.reduce((a, r) => a + Number(r.qty_sold || 0), 0),
    total_revenue: list.reduce((a, r) => a + Number(r.revenue || 0), 0),
  };
}

function summarizeSales(rows) {
  const list = rows || [];
  return {
    count: list.length,
    total_value: list.reduce((a, r) => a + Number(r.line_total || 0), 0),
    orders: new Set(list.map((r) => r.order_id)).size,
  };
}

function summarizeCustomers(rows) {
  const list = rows || [];
  return {
    count: list.length,
    delinquent: list.filter((r) => Number(r.delinquent_flags || 0) > 0).length,
    total_spent: list.reduce((a, r) => a + Number(r.total_spent || 0), 0),
  };
}

function summarizeServices(rows) {
  const list = rows || [];
  return {
    count: list.length,
    total_amount: list.reduce((a, r) => a + Number(r.total_amount || 0), 0),
    paid: list.filter((r) => String(r.payment_status).toUpperCase() === 'PAID').length,
  };
}

function buildQueryString(filters, extra) {
  const p = new URLSearchParams();
  Object.keys(filters).forEach((k) => {
    const v = filters[k];
    if (v !== '' && v != null && k !== 'report') p.set(k, String(v));
  });
  if (extra) Object.keys(extra).forEach((k) => p.set(k, String(extra[k])));
  p.set('report', filters.report);
  const s = p.toString();
  return s ? `?${s}` : '';
}

function csvEscape(v) {
  const s = v == null ? '' : String(v);
  if (/[;"\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
  return s;
}

function toCsv(rows, columns) {
  const lines = [columns.map((c) => c.header).join(';')];
  (rows || []).forEach((row) => {
    lines.push(columns.map((c) => csvEscape(typeof c.value === 'function' ? c.value(row) : row[c.key])).join(';'));
  });
  return '\uFEFF' + lines.join('\n');
}

function getCsvForReport(filters, data) {
  const rep = filters.report;
  if (rep === 'overview') {
    const lines = ['secao;campo;valor'];
    const s = data.summary || {};
    lines.push(`resumo;receita_paga;${Number(s.revenue_paid || 0).toFixed(2)}`);
    lines.push(`resumo;transacoes;${s.total_transactions || 0}`);
    lines.push(`resumo;pendentes;${s.pending_count || 0}`);
    lines.push(`resumo;falhas;${s.failed_count || 0}`);
    lines.push('');
    lines.push('metodo;receita');
    [
      ['PIX', data.revenueByMethod.PIX],
      ['BOLETO', data.revenueByMethod.BOLETO],
      ['CARTAO_CREDITO', data.revenueByMethod.CREDIT_CARD],
      ['CARTAO_DEBITO', data.revenueByMethod.DEBIT_CARD],
      ['DINHEIRO', data.revenueByMethod.CASH],
    ].forEach(([m, v]) => lines.push(`${m};${Number(v || 0).toFixed(2)}`));
    lines.push('');
    lines.push('dia;transacoes;receita');
    (data.revenueByDay || []).forEach((r) => {
      lines.push(`${r.day || ''};${r.orders_count || 0};${Number(r.revenue || 0).toFixed(2)}`);
    });
    lines.push('');
    lines.push('produto;sku;qtd;receita');
    (data.mostSold || []).forEach((p) => {
      lines.push(`${csvEscape(p.product_name)};${csvEscape(p.sku || '')};${p.qty_sold || 0};${Number(p.revenue || 0).toFixed(2)}`);
    });
    return '\uFEFF' + lines.join('\n');
  }
  if (rep === 'products') {
    return toCsv(data.productReport, [
      { header: 'produto', key: 'product_name' },
      { header: 'sku', key: 'sku' },
      { header: 'tipo', key: 'type_name' },
      { header: 'laboratorio', key: 'lab_name' },
      { header: 'categorias', key: 'categories' },
      { header: 'status', key: 'product_status', value: (r) => displayLabels.productStatus(r.product_status) },
      { header: 'preco_unit', value: (r) => Number(r.unit_price || 0).toFixed(2) },
      { header: 'qtd_vendida', key: 'qty_sold' },
      { header: 'receita', value: (r) => Number(r.revenue || 0).toFixed(2) },
      { header: 'ticket_medio', value: (r) => Number(r.avg_ticket || 0).toFixed(2) },
    ]);
  }
  if (rep === 'sales') {
    return toCsv(data.salesReport, [
      { header: 'pedido', key: 'order_id' },
      { header: 'data', value: (r) => formatDateTimeSecBr(r.created_at) },
      { header: 'cliente', key: 'customer_name' },
      { header: 'produto', key: 'product_name' },
      { header: 'categoria', key: 'category_name' },
      { header: 'qtd', key: 'quantity' },
      { header: 'valor_linha', value: (r) => Number(r.line_total || 0).toFixed(2) },
      { header: 'pagamento', value: (r) => displayLabels.paymentMethod(r.payment_method) },
      { header: 'status_pedido', value: (r) => displayLabels.orderStatus(r.order_status) },
    ]);
  }
  if (rep === 'customers') {
    return toCsv(data.customerReport, [
      { header: 'nome', key: 'full_name' },
      { header: 'email', key: 'email' },
      { header: 'documento', key: 'document' },
      { header: 'telefone', key: 'phone' },
      { header: 'tipo', value: (r) => displayLabels.personType(r.person_type) },
      { header: 'cidade', key: 'city' },
      { header: 'pedidos_pagos', key: 'paid_orders' },
      { header: 'total_gasto', value: (r) => Number(r.total_spent || 0).toFixed(2) },
      { header: 'inadimplente', value: (r) => (Number(r.delinquent_flags || 0) > 0 ? 'Sim' : 'Nao') },
    ]);
  }
  if (rep === 'services') {
    return toCsv(data.serviceReport, [
      { header: 'id', key: 'id' },
      { header: 'agendamento', value: (r) => formatDateTimeSecBr(r.scheduled_start) },
      { header: 'servico', key: 'service_name' },
      { header: 'profissional', key: 'professional_name' },
      { header: 'cliente', key: 'customer_name' },
      { header: 'modalidade', value: (r) => displayLabels.modality(r.modality) },
      { header: 'canal', value: (r) => displayLabels.bookingChannel(r.booking_channel) },
      { header: 'status', value: (r) => displayLabels.appointmentStatus(r.status) },
      { header: 'pagamento', value: (r) => displayLabels.paymentStatus(r.payment_status) },
      { header: 'metodo', value: (r) => displayLabels.paymentMethod(r.payment_method) },
      { header: 'valor', value: (r) => Number(r.total_amount || 0).toFixed(2) },
    ]);
  }
  return '\uFEFF';
}

function describeFilters(filters) {
  const parts = [];
  if (filters.from && filters.to) parts.push(`Período: ${filters.from} a ${filters.to}`);
  else if (filters.days) parts.push(`Últimos ${filters.days} dias`);
  if (filters.search) parts.push(`Busca: "${filters.search}"`);
  if (filters.category_id) parts.push(`Categoria #${filters.category_id}`);
  if (filters.product_type_id) parts.push(`Tipo #${filters.product_type_id}`);
  if (filters.payment_method) parts.push(`Pagamento: ${displayLabels.paymentMethod(filters.payment_method)}`);
  if (filters.delinquent === '1') parts.push('Somente inadimplentes');
  return parts.join(' · ') || 'Sem filtros adicionais';
}

module.exports = {
  REPORT_META,
  parseFilters,
  loadReportData,
  buildQueryString,
  getCsvForReport,
  describeFilters,
};
