/**
 * Painel financeiro (admin): dashboards, relatórios, recibos, lista de pedidos e API JSON para modais/tabelas.
 * Dados agregados vêm de `models/FinanceAdmin`.
 *
 * @see docs/code-commenting.md
 */
const FinanceAdmin = require('../models/FinanceAdmin');
const Category = require('../models/Category');
const ProductType = require('../models/ProductType');
const HealthService = require('../models/HealthService');
const ServiceProfessional = require('../models/ServiceProfessional');
const Customer = require('../models/Customer');
const Product = require('../models/Product');
const Lab = require('../models/Lab');
const financeReportService = require('../services/financeReportService');

/**
 * GET /admin/financas — resumo (30 dias) + gráficos de status e receita por método.
 */
async function renderFinanceDashboard(req, res, next) {
  try {
    const from = req.query.from ? String(req.query.from).trim() : null;
    const to = req.query.to ? String(req.query.to).trim() : null;
    const daysRaw = parseInt(req.query.days, 10);
    const days = from && to ? null : (Number.isFinite(daysRaw) && daysRaw > 0 ? daysRaw : 30);
    const periodOpts = from && to ? { from, to } : { days };

    const [summary, revenueByMethod, revenueByDay, mostSold, recentReceipts] = await Promise.all([
      FinanceAdmin.getFinanceSummary(periodOpts),
      FinanceAdmin.getRevenueByPaymentMethod(periodOpts),
      FinanceAdmin.getRevenueByDay({ ...periodOpts, limitDays: 14 }),
      FinanceAdmin.getMostSoldProducts({ ...periodOpts, limit: 5 }),
      FinanceAdmin.listRecentReceipts({ ...periodOpts, limit: 8 }),
    ]);

    res.render('admin/financas-dashboard', {
      title: 'Finanças - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      summary,
      revenueByMethod,
      revenueByDay,
      mostSold,
      recentReceipts,
      filters: { from: from || '', to: to || '', days: days || 30 },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/relatorios — relatórios gerenciais com filtros avançados e exportação.
 */
async function renderFinanceReportsPage(req, res, next) {
  try {
    const filters = financeReportService.parseFilters(req.query);
    const reportData = await financeReportService.loadReportData(filters);
    const qs = financeReportService.buildQueryString(filters);

    const [categories, productTypes, labs, customers, products, professionals, services] = await Promise.all([
      Category.findAll(true),
      ProductType.findAll(true),
      Lab.findAll(true),
      Customer.findAll(),
      Product.findAll({}),
      ServiceProfessional.findAll ? ServiceProfessional.findAll() : Promise.resolve([]),
      HealthService.findAll ? HealthService.findAll(true) : Promise.resolve([]),
    ]);

    res.render('admin/financas-relatorios', {
      title: 'Finanças - Relatórios - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      filters,
      reportMeta: financeReportService.REPORT_META[filters.report],
      reportMetaAll: financeReportService.REPORT_META,
      filterDescription: financeReportService.describeFilters(filters),
      exportCsvUrl: `/admin/financas/relatorios/export.csv${qs}`,
      exportPrintUrl: `/admin/financas/relatorios/imprimir${qs}`,
      categories: categories || [],
      productTypes: productTypes || [],
      labs: labs || [],
      customers: customers || [],
      products: products || [],
      professionals: professionals || [],
      services: services || [],
      summary: reportData.summary || {},
      revenueByMethod: reportData.revenueByMethod || {},
      mostSold: reportData.mostSold || [],
      revenueByDay: reportData.revenueByDay || [],
      productReport: reportData.productReport || [],
      salesReport: reportData.salesReport || [],
      customerReport: reportData.customerReport || [],
      serviceReport: reportData.serviceReport || [],
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/relatorios/export.csv — exportação CSV (UTF-8 BOM, separador ;).
 */
async function exportFinanceReportCsv(req, res, next) {
  try {
    const filters = financeReportService.parseFilters(req.query);
    const reportData = await financeReportService.loadReportData(filters);
    const slug = filters.report === 'overview' ? 'panorama' : filters.report;
    const csv = financeReportService.getCsvForReport(filters, reportData);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="neofarma-relatorio-${slug}.csv"`);
    res.send(csv);
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/relatorios/imprimir — layout para impressão / salvar como PDF.
 */
async function exportFinanceReportPrint(req, res, next) {
  try {
    const filters = financeReportService.parseFilters(req.query);
    const reportData = await financeReportService.loadReportData(filters);
    const meta = financeReportService.REPORT_META[filters.report];
    res.render('admin/financas-relatorio-print', {
      layout: false,
      filters,
      reportMeta: meta,
      filterDescription: financeReportService.describeFilters(filters),
      summary: reportData.summary || {},
      revenueByMethod: reportData.revenueByMethod || {},
      mostSold: reportData.mostSold || [],
      revenueByDay: reportData.revenueByDay || [],
      productReport: reportData.productReport || [],
      salesReport: reportData.salesReport || [],
      customerReport: reportData.customerReport || [],
      serviceReport: reportData.serviceReport || [],
      generatedAt: new Date(),
      autoPrint: req.query.autoprint === '1',
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/recibos — últimas operações pagas (limite configurável).
 */
async function renderFinanceReceiptsPage(req, res, next) {
  try {
    const from = req.query.from || null;
    const to = req.query.to || null;
    const limit = parseInt(req.query.limit, 10) || 20;

    const recentReceipts = await FinanceAdmin.listRecentReceipts({ from, to, days: 30, limit });

    res.render('admin/financas-recibos', {
      title: 'Finanças - Recibos - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      filters: { from, to, limit },
      recentReceipts,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/pedidos — tabela paginada de pedidos com busca e filtro de pagamento.
 */
async function renderFinanceOrdersPage(req, res, next) {
  try {
    const payment_status = req.query.payment_status ? String(req.query.payment_status).toUpperCase() : 'ALL';
    const from = req.query.from || null;
    const to = req.query.to || null;
    const search = req.query.search || '';
    const page = parseInt(req.query.page, 10) || 1;
    const pageSize = parseInt(req.query.pageSize, 10) || 25;

    const ordersPage = await FinanceAdmin.listOrdersFinance({
      payment_status,
      from,
      to,
      search,
      page,
      pageSize,
    });

    res.render('admin/financas-pedidos', {
      title: 'Finanças - Pedidos - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      filters: { payment_status, from, to, search, page, pageSize },
      orders: ordersPage.orders,
      pagination: {
        total: ordersPage.total,
        page: ordersPage.page,
        pageSize: ordersPage.pageSize,
        totalPages: ordersPage.totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/financas/orders/:id/mark-payment — atualiza status de pagamento do pedido (fluxo administrativo / testes).
 */
async function apiMarkPayment(req, res, next) {
  try {
    const orderId = parseInt(req.params.id, 10);
    const { payment_status } = req.body || {};
    if (!orderId) return res.status(400).json({ ok: false, message: 'Pedido inválido.' });

    const result = await FinanceAdmin.markPaymentForOrderAdmin(orderId, payment_status);
    if (!result || !result.ok) return res.status(400).json({ ok: false, message: 'Falha ao atualizar pagamento.' });
    return res.json({ ok: true, message: 'Pagamento atualizado.' });
  } catch (err) {
    if (err && err.code === 'NOT_FOUND') return res.status(404).json({ ok: false, message: 'Pedido não encontrado.' });
    if (err && err.code === 'INVALID_PAYMENT_STATUS') return res.status(400).json({ ok: false, message: err.message });
    next(err);
  }
}

/**
 * GET /admin/financas/orders — mesmos filtros da página de pedidos, em JSON (ex.: modal “tela cheia”, AJAX).
 */
async function apiListOrdersFinance(req, res, next) {
  try {
    const payment_status = req.query.payment_status ? String(req.query.payment_status).toUpperCase() : 'ALL';
    const from = req.query.from || null;
    const to = req.query.to || null;
    const search = req.query.search || '';
    const page = parseInt(req.query.page, 10) || 1;
    const pageSize = parseInt(req.query.pageSize, 10) || 25;

    const ordersPage = await FinanceAdmin.listOrdersFinance({
      payment_status,
      from,
      to,
      search,
      page,
      pageSize,
    });

    return res.json({
      ok: true,
      orders: ordersPage.orders,
      pagination: {
        total: ordersPage.total,
        page: ordersPage.page,
        pageSize: ordersPage.pageSize,
        totalPages: ordersPage.totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/orders/:id — detalhe do pedido com itens, lotes e totais.
 */
async function apiGetOrderFinanceDetail(req, res, next) {
  try {
    const orderId = parseInt(req.params.id, 10);
    if (!orderId) return res.status(400).json({ ok: false, message: 'Pedido inválido.' });

    const detail = await FinanceAdmin.getOrderFinanceDetail(orderId);
    if (!detail) return res.status(404).json({ ok: false, message: 'Pedido não encontrado.' });

    return res.json({ ok: true, ...detail });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  renderFinanceDashboard,
  renderFinanceReportsPage,
  exportFinanceReportCsv,
  exportFinanceReportPrint,
  renderFinanceReceiptsPage,
  renderFinanceOrdersPage,
  apiMarkPayment,
  apiListOrdersFinance,
  apiGetOrderFinanceDetail,
};
