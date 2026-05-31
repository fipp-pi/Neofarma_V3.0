const { pool } = require('../config/database');
const PurchaseOrder = require('../models/PurchaseOrder');
const Supplier = require('../models/Supplier');
const Product = require('../models/Product');
const { parseWholeUnits } = require('../utils/quantity');

async function renderPage(req, res, next) {
  try {
    const status = String(req.query.status || 'ALL').toUpperCase();
    const [list, [countRows]] = await Promise.all([
      PurchaseOrder.findAll(status === 'ALL' ? {} : { status }),
      pool.execute(
        `SELECT
           COUNT(*) AS total,
           SUM(CASE WHEN status = 'DRAFT' THEN 1 ELSE 0 END) AS draft,
           SUM(CASE WHEN status = 'AWAITING_DELIVERY' THEN 1 ELSE 0 END) AS awaiting,
           SUM(CASE WHEN status = 'RECEIVED' THEN 1 ELSE 0 END) AS received,
           SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled
         FROM purchase_orders`
      ),
    ]);
    const row = countRows[0] || {};
    res.render('admin/compras', {
      title: 'Compras - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'compras',
      list,
      statusFilter: status,
      stats: {
        total: Number(row.total || 0),
        draft: Number(row.draft || 0),
        awaiting: Number(row.awaiting || 0),
        received: Number(row.received || 0),
        cancelled: Number(row.cancelled || 0),
        filtered: Array.isArray(list) ? list.length : 0,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function createOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const b = req.body || {};
    const supplierId = Number(b.supplier_id);
    if (!supplierId) return res.status(400).json({ ok: false, message: 'Selecione o fornecedor.' });
    const items = Array.isArray(b.items) ? b.items : [];
    const parsed = [];
    for (const it of items) {
      const qtyParsed = parseWholeUnits(it.quantity, { emptyMessage: 'Informe a quantidade do item.' });
      if (!qtyParsed.ok) {
        return res.status(400).json({ ok: false, message: qtyParsed.message });
      }
      const productId = Number(it.product_id);
      const unitCost = Number(String(it.unit_cost || '').replace(',', '.'));
      if (productId && qtyParsed.value > 0 && unitCost >= 0) {
        parsed.push({ product_id: productId, quantity: qtyParsed.value, unit_cost: unitCost });
      }
    }
    if (!parsed.length) return res.status(400).json({ ok: false, message: 'Adicione ao menos um produto.' });

    await connection.beginTransaction();
    const id = await PurchaseOrder.createDraft(
      {
        supplier_id: supplierId,
        employee_id: b.employee_id ? Number(b.employee_id) : null,
        payment_method: b.payment_method || 'PIX',
        notes: b.notes || null,
        expected_date: b.expected_date || null,
      },
      parsed,
      connection
    );
    await connection.commit();
    return res.status(201).json({ ok: true, id, message: 'Pedido de compra registrado (rascunho).' });
  } catch (err) {
    await connection.rollback();
    if (err.code === 'INVALID_QUANTITY') {
      return res.status(400).json({ ok: false, message: err.message });
    }
    next(err);
  } finally {
    connection.release();
  }
}

async function confirmPayment(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const id = Number(req.params.id);
    await connection.beginTransaction();
    const ok = await PurchaseOrder.confirmPayment(id, connection);
    if (!ok) {
      await connection.rollback();
      return res.status(400).json({ ok: false, message: 'Não foi possível confirmar pagamento desta compra.' });
    }
    await connection.commit();
    return res.json({ ok: true, message: 'Pagamento confirmado. Status: Aguardando Entrega.' });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
}

async function receiveDelivery(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const id = Number(req.params.id);
    const lines = Array.isArray(req.body?.items) ? req.body.items : [];
    await connection.beginTransaction();
    const result = await PurchaseOrder.receiveDelivery(id, lines, connection);
    if (!result.ok) {
      await connection.rollback();
      return res.status(400).json({ ok: false, message: result.message });
    }
    await connection.commit();
    return res.json({ ok: true, message: 'Entrada em estoque realizada. Compra concluída.' });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
}

async function cancelOrder(req, res, next) {
  try {
    const id = Number(req.params.id);
    const ok = await PurchaseOrder.cancelById(id);
    if (!ok) return res.status(400).json({ ok: false, message: 'Compra não pode ser cancelada.' });
    return res.json({ ok: true, message: 'Compra cancelada.' });
  } catch (err) {
    next(err);
  }
}

async function getOrderJson(req, res, next) {
  try {
    const id = Number(req.params.id);
    const order = await PurchaseOrder.findById(id);
    if (!order) return res.status(404).json({ ok: false, message: 'Compra não encontrada.' });
    const items = await PurchaseOrder.findItemsByOrderId(id);
    return res.json({ ok: true, order, items });
  } catch (err) {
    next(err);
  }
}

async function listSuppliersProducts(req, res, next) {
  try {
    const suppliers = await Supplier.findAll(true);
    const products = await Product.findAll({ status: 'ACTIVE' });
    return res.json({ ok: true, suppliers, products });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  renderPage,
  createOrder,
  confirmPayment,
  receiveDelivery,
  cancelOrder,
  getOrderJson,
  listSuppliersProducts,
};
