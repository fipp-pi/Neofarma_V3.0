/**
 * Painel financeiro (admin): dashboards, relatórios, recibos, lista de pedidos e API JSON para modais/tabelas.
 * Dados agregados vêm de `models/FinanceAdmin`.
 *
 * @see docs/code-commenting.md
 */
const FinanceAdmin = require('../models/FinanceAdmin');

/**
 * GET /admin/financas — resumo (30 dias) + gráficos de status e receita por método.
 */
async function renderFinanceDashboard(req, res, next) {
  try {
    const summary = await FinanceAdmin.getFinanceSummary({ days: 30 });
    const revenueByMethod = await FinanceAdmin.getRevenueByPaymentMethod({ days: 30 });

    res.render('admin/financas-dashboard', {
      title: 'Finanças - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      summary,
      revenueByMethod,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/financas/relatorios — tabelas detalhadas com filtro de período (query `from` / `to`).
 */
async function renderFinanceReportsPage(req, res, next) {
  try {
    const from = req.query.from || null;
    const to = req.query.to || null;

    const revenueByMethod = await FinanceAdmin.getRevenueByPaymentMethod({ from, to, days: 30 });
    const mostSold = await FinanceAdmin.getMostSoldProducts({ limit: 10, from, to, days: 30 });
    const revenueByDay = await FinanceAdmin.getRevenueByDay({ from, to, days: 30, limitDays: 14 });

    res.render('admin/financas-relatorios', {
      title: 'Finanças - Relatórios - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'financas',
      filters: { from, to },
      revenueByMethod,
      mostSold,
      revenueByDay,
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

module.exports = {
  renderFinanceDashboard,
  renderFinanceReportsPage,
  renderFinanceReceiptsPage,
  renderFinanceOrdersPage,
  apiMarkPayment,
  apiListOrdersFinance,
};
