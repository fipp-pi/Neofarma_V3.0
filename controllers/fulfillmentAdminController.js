/**
 * Admin — expedição de pedidos da loja (despacho e entrega).
 */
const OrderFulfillment = require('../models/OrderFulfillment');
const FinanceAdmin = require('../models/FinanceAdmin');

async function renderPage(req, res, next) {
  try {
    const queue = String(req.query.queue || 'ALL').toUpperCase();
    const search = req.query.search || '';
    const page = parseInt(req.query.page, 10) || 1;
    const pageSize = parseInt(req.query.pageSize, 10) || 20;

    const [list, stats] = await Promise.all([
      OrderFulfillment.listOrders({ queue, search, page, pageSize }),
      OrderFulfillment.getQueueStats(),
    ]);

    res.render('admin/expedicao-pedidos', {
      title: 'Expedição de pedidos - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'expedicao',
      orders: list.orders,
      stats,
      filters: { queue, search, page, pageSize },
      pagination: {
        total: list.total,
        page: list.page,
        pageSize: list.pageSize,
        totalPages: list.totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function apiListOrders(req, res, next) {
  try {
    const queue = String(req.query.queue || 'ALL').toUpperCase();
    const search = req.query.search || '';
    const page = parseInt(req.query.page, 10) || 1;
    const pageSize = parseInt(req.query.pageSize, 10) || 20;
    const list = await OrderFulfillment.listOrders({ queue, search, page, pageSize });
    return res.json({
      ok: true,
      orders: list.orders,
      pagination: {
        total: list.total,
        page: list.page,
        pageSize: list.pageSize,
        totalPages: list.totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function apiGetOrderDetail(req, res, next) {
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

async function apiMarkShipped(req, res, next) {
  try {
    const orderId = parseInt(req.params.id, 10);
    const tracking_code = req.body?.tracking_code;
    if (!orderId) return res.status(400).json({ ok: false, message: 'Pedido inválido.' });
    const result = await OrderFulfillment.markShipped(orderId, { tracking_code }, req.session?.userId);
    return res.json({ ok: true, message: result.message });
  } catch (err) {
    if (err.code === 'NOT_FOUND') return res.status(404).json({ ok: false, message: err.message });
    if (['TRACKING_REQUIRED', 'INVALID_PAYMENT', 'INVALID_STATUS', 'STOCK_PENDING'].includes(err.code)) {
      return res.status(400).json({ ok: false, message: err.message });
    }
    next(err);
  }
}

async function apiMarkDelivered(req, res, next) {
  try {
    const orderId = parseInt(req.params.id, 10);
    if (!orderId) return res.status(400).json({ ok: false, message: 'Pedido inválido.' });
    const result = await OrderFulfillment.markDelivered(orderId, req.session?.userId);
    return res.json({ ok: true, message: result.message });
  } catch (err) {
    if (err.code === 'NOT_FOUND') return res.status(404).json({ ok: false, message: err.message });
    if (['INVALID_PAYMENT', 'INVALID_STATUS'].includes(err.code)) {
      return res.status(400).json({ ok: false, message: err.message });
    }
    next(err);
  }
}

module.exports = {
  renderPage,
  apiListOrders,
  apiGetOrderDetail,
  apiMarkShipped,
  apiMarkDelivered,
};
