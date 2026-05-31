/**
 * Admin: gestão de lotes de estoque (CRUD por produto, listagem global, export CSV, exclusão em massa).
 * Auditoria é best-effort — falhas em `audit_logs` não impedem a operação principal.
 *
 * @see docs/code-commenting.md
 */
const InventoryBatch = require('../models/InventoryBatch');
const InventoryDisposal = require('../models/InventoryDisposal');
const Product = require('../models/Product');
const displayLabels = require('../utils/displayLabels');
const { formatDateTimeSecBr, formatDateBr } = require('../utils/dateFormat');
const { parseWholeUnits } = require('../utils/quantity');
const { pool } = require('../config/database');

/**
 * Registra ação administrativa para rastreabilidade (quem fez o quê nos lotes).
 *
 * @param {import('express').Request} req
 * @param {'CREATE'|'UPDATE'|'DELETE'|'DELETE_MANY'} action
 * @param {Record<string, unknown>} details
 */
async function writeAudit(req, action, details) {
  try {
    const userId = req.session && req.session.userId ? Number(req.session.userId) : null;
    await pool.execute(
      `INSERT INTO audit_logs (user_id, entity, entity_id, action, details)
       VALUES (?, 'inventory_batch', ?, ?, ?)`,
      [userId, details && details.batch_id ? Number(details.batch_id) : null, action, JSON.stringify(details || {})]
    );
  } catch (_) {
    // Auditoria não deve quebrar fluxo principal.
  }
}

/**
 * GET /admin/produtos/:id/lotes — JSON com lotes do produto (filtro/ordenação via query).
 */
async function listBatches(req, res, next) {
  try {
    const productId = Number(req.params.id);
    const rows = await InventoryBatch.findByProductId(productId, {
      status: req.query.status,
      sort: req.query.sort,
      withDisposal: true,
      hideDisposed: req.query.hideDisposed === '1' || req.query.hideDisposed === 'true',
    });
    res.json({ ok: true, batches: rows });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/produtos/:id/lotes — cria lote; código único por produto (índice no banco).
 */
async function createBatch(req, res, next) {
  try {
    const product_id = Number(req.params.id);
    const { batch_code, mfg_date, expiry_date, quantity } = req.body || {};
    if (!batch_code || !expiry_date) {
      return res.status(400).json({ ok: false, message: 'Informe lote e validade.' });
    }
    const qtyParsed = parseWholeUnits(quantity, { allowZero: true, emptyMessage: 'Informe a quantidade do lote.' });
    if (!qtyParsed.ok) {
      return res.status(400).json({ ok: false, message: qtyParsed.message });
    }
    const id = await InventoryBatch.create({
      product_id,
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: qtyParsed.value,
    });
    await writeAudit(req, 'CREATE', {
      batch_id: id,
      product_id,
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: qtyParsed.value,
    });
    res.status(201).json({ ok: true, id });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'Já existe esse código de lote para o produto.' });
    }
    next(err);
  }
}

/**
 * PUT /admin/produtos/lotes/:batchId — atualiza lote existente.
 */
async function updateBatch(req, res, next) {
  try {
    const batchId = Number(req.params.batchId);
    const { batch_code, mfg_date, expiry_date, quantity } = req.body || {};
    if (!batch_code || !expiry_date) {
      return res.status(400).json({ ok: false, message: 'Informe lote e validade.' });
    }
    const qtyParsed = parseWholeUnits(quantity, { allowZero: true, emptyMessage: 'Informe a quantidade do lote.' });
    if (!qtyParsed.ok) {
      return res.status(400).json({ ok: false, message: qtyParsed.message });
    }
    const batch = await InventoryBatch.findById(batchId);
    if (!batch) return res.status(404).json({ ok: false, message: 'Lote não encontrado.' });
    const payload = {
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: qtyParsed.value,
    };
    await InventoryBatch.updateById(batchId, {
      ...payload,
    });
    await writeAudit(req, 'UPDATE', {
      batch_id: batchId,
      product_id: batch.product_id,
      before: batch,
      after: payload,
    });
    res.json({ ok: true });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'Já existe esse código de lote para o produto.' });
    }
    next(err);
  }
}

/**
 * DELETE /admin/produtos/lotes/:batchId — remove lote se não houver referência em pedidos.
 */
async function deleteBatch(req, res, next) {
  try {
    const batchId = Number(req.params.batchId);
    const batch = await InventoryBatch.findById(batchId);
    const n = await InventoryBatch.deleteById(batchId);
    if (!n) return res.status(404).json({ ok: false, message: 'Lote não encontrado.' });
    await writeAudit(req, 'DELETE', {
      batch_id: batchId,
      product_id: batch ? batch.product_id : null,
      deleted: batch || null,
    });
    res.json({ ok: true });
  } catch (err) {
    if (err && err.code === 'ER_ROW_IS_REFERENCED_2') {
      return res.status(409).json({ ok: false, message: 'Não é possível excluir lote já utilizado em pedidos.' });
    }
    next(err);
  }
}

/**
 * GET /admin/lotes — página paginada com filtros e resumo por status de validade.
 */
async function listAllBatchesPage(req, res, next) {
  try {
    const status = req.query.status || 'ALL';
    const sort = req.query.sort || 'expiry_asc';
    const search = req.query.search || '';
    const hideDisposed = req.query.hideDisposed === '1' || req.query.hideDisposed === 'true';
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const pageSize = Math.min(200, Math.max(10, parseInt(req.query.pageSize, 10) || 25));
    const paged = await InventoryBatch.findAllGlobalPaginated({ status, sort, search, page, pageSize, hideDisposed });
    const validityCounts = await InventoryBatch.getDashboardValidityCounts(30);
    const expiredAwaiting = await InventoryBatch.countExpiredAwaitingDisposal();
    const stockSummary = await InventoryBatch.getGlobalStockSummary();
    const [validRows] = await pool.execute(
      `SELECT COUNT(*) AS c FROM inventory_batches WHERE quantity > 0 AND expiry_date > DATE_ADD(CURDATE(), INTERVAL 30 DAY)`
    );
    const totalPages = Math.max(1, Math.ceil(paged.total / pageSize));
    res.render('admin/lotes', {
      title: 'Lotes - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'lotes',
      rows: paged.rows,
      filters: { status, sort, search, hideDisposed },
      summary: {
        valid: Number(validRows[0]?.c || 0),
        expiring: Number(validityCounts.expiring_count || 0),
        expired: Number(validityCounts.expired_count || 0),
        expiredAwaiting,
        totalUnits: Number(stockSummary.total_units || 0),
        productsWithStock: Number(stockSummary.products_with_stock || 0),
        batchesWithStock: Number(stockSummary.batches_with_stock || 0),
      },
      expiredAwaiting,
      pagination: {
        total: paged.total,
        page: paged.page,
        pageSize: paged.pageSize,
        totalPages,
      },
      disposedOk: req.query.disposed === '1',
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/lotes/export.csv — exporta conjunto filtrado (BOM UTF-8 para Excel).
 */
async function exportCsv(req, res, next) {
  try {
    const status = req.query.status || 'ALL';
    const sort = req.query.sort || 'expiry_asc';
    const search = req.query.search || '';
    const hideDisposed = req.query.hideDisposed === '1' || req.query.hideDisposed === 'true';
    const rows = await InventoryBatch.findAllGlobal({ status, sort, search, hideDisposed });
    const header = ['id', 'product_id', 'product_name', 'sku', 'batch_code', 'mfg_date', 'expiry_date', 'validity_status', 'days_to_expiry', 'quantity', 'disposal_status', 'disposed_qty', 'last_disposed_at'];
    const lines = [header.join(';')];
    rows.forEach((r) => {
      lines.push([
        r.id, r.product_id, `"${String(r.product_name || '').replace(/"/g, '""')}"`, r.sku || '', r.batch_code || '',
        formatDateBr(r.mfg_date),
        formatDateBr(r.expiry_date),
        displayLabels.validityStatus(r.validity_status),
        r.days_to_expiry, r.quantity,
        displayLabels.disposalStatus(r.disposal_status || 'NONE'), r.disposed_qty || 0,
        formatDateTimeSecBr(r.last_disposed_at),
      ].join(';'));
    });
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="lotes.csv"');
    res.send('\uFEFF' + lines.join('\n'));
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/lotes/:id — detalhe operacional do lote (JSON).
 */
async function getBatchDetail(req, res, next) {
  try {
    const batchId = Number(req.params.id);
    if (!batchId) return res.status(400).json({ ok: false, message: 'Lote inválido.' });
    const detail = await InventoryBatch.getDetailById(batchId);
    if (!detail) return res.status(404).json({ ok: false, message: 'Lote não encontrado.' });
    return res.json({ ok: true, ...detail });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/lotes/delete-many — exclusão em lote; falha se algum lote já foi usado em pedido.
 */
async function deleteManyBatches(req, res, next) {
  try {
    const ids = Array.isArray(req.body && req.body.ids) ? req.body.ids.map((v) => Number(v)).filter((n) => Number.isFinite(n)) : [];
    if (!ids.length) return res.status(400).json({ ok: false, message: 'Selecione ao menos um lote.' });
    const rows = await Promise.all(ids.map((id) => InventoryBatch.findById(id)));
    const deleted = await InventoryBatch.deleteManyByIds(ids);
    await writeAudit(req, 'DELETE_MANY', {
      ids,
      deleted,
      batches: rows.filter(Boolean),
    });
    res.json({ ok: true, deleted });
  } catch (err) {
    if (err && err.code === 'ER_ROW_IS_REFERENCED_2') {
      return res.status(409).json({ ok: false, message: 'Um ou mais lotes já foram usados em pedidos.' });
    }
    next(err);
  }
}

async function renderDisposalsPage(req, res, next) {
  try {
    const [history, products, expiredAwaiting] = await Promise.all([
      InventoryDisposal.findAll(80),
      Product.findForDisposal(),
      InventoryBatch.countExpiredAwaitingDisposal(),
    ]);
    res.render('admin/descartes', {
      title: 'Descarte de estoque - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'descartes',
      history,
      products,
      stats: {
        expiredAwaiting: Number(expiredAwaiting || 0),
        historyCount: Array.isArray(history) ? history.length : 0,
        productsEligible: Array.isArray(products) ? products.length : 0,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function registerDisposal(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const b = req.body || {};
    const productId = Number(b.product_id);
    const batchId = Number(b.batch_id);
    const reason = String(b.reason || '').trim();
    const qtyParsed = parseWholeUnits(b.quantity, { emptyMessage: 'Informe a quantidade a descartar.' });
    if (!productId || !batchId || !reason) {
      return res.status(400).json({ ok: false, message: 'Preencha produto, lote, quantidade e motivo.' });
    }
    if (!qtyParsed.ok) {
      return res.status(400).json({ ok: false, message: qtyParsed.message });
    }
    const quantity = qtyParsed.value;
    await connection.beginTransaction();
    const id = await InventoryDisposal.create(
      {
        product_id: productId,
        batch_id: batchId,
        quantity,
        reason,
        disposed_by: req.session?.userId || null,
      },
      connection
    );
    await writeAudit(req, 'DISPOSAL', { batch_id: batchId, product_id: productId, quantity, reason, disposal_id: id });
    await connection.commit();
    const [batchRows] = await pool.execute(
      'SELECT batch_code, quantity FROM inventory_batches WHERE id = ? LIMIT 1',
      [batchId]
    );
    const batch = batchRows[0];
    return res.status(201).json({
      ok: true,
      message: 'Descarte registrado e estoque atualizado.',
      batch_code: batch?.batch_code || null,
      remaining_qty: batch ? Number(batch.quantity) : null,
    });
  } catch (err) {
    await connection.rollback();
    if (err.code === 'INVALID') {
      return res.status(400).json({ ok: false, message: err.message });
    }
    if (err.code === 'INSUFFICIENT_STOCK' || err.code === 'BATCH_NOT_FOUND') {
      return res.status(409).json({ ok: false, message: err.message });
    }
    next(err);
  } finally {
    connection.release();
  }
}

async function listBatchesForProduct(req, res, next) {
  try {
    const productId = Number(req.params.productId);
    const rows = await InventoryBatch.findByProductId(productId, {
      status: 'ALL',
      sort: 'expiry_asc',
      onlyWithStock: true,
    });
    return res.json({ ok: true, batches: rows });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listAllBatchesPage,
  exportCsv,
  getBatchDetail,
  deleteManyBatches,
  listBatches,
  createBatch,
  updateBatch,
  deleteBatch,
  renderDisposalsPage,
  registerDisposal,
  listBatchesForProduct,
};
