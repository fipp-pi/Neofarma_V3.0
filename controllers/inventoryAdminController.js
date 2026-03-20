/**
 * Admin: gestão de lotes de estoque (CRUD por produto, listagem global, export CSV, exclusão em massa).
 * Auditoria é best-effort — falhas em `audit_logs` não impedem a operação principal.
 *
 * @see docs/code-commenting.md
 */
const InventoryBatch = require('../models/InventoryBatch');
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
    if (Number(quantity || 0) < 0) {
      return res.status(400).json({ ok: false, message: 'Quantidade não pode ser negativa.' });
    }
    const id = await InventoryBatch.create({
      product_id,
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: Number(quantity || 0),
    });
    await writeAudit(req, 'CREATE', {
      batch_id: id,
      product_id,
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: Number(quantity || 0),
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
    if (Number(quantity || 0) < 0) {
      return res.status(400).json({ ok: false, message: 'Quantidade não pode ser negativa.' });
    }
    const batch = await InventoryBatch.findById(batchId);
    if (!batch) return res.status(404).json({ ok: false, message: 'Lote não encontrado.' });
    const payload = {
      batch_code: String(batch_code).trim(),
      mfg_date: mfg_date || null,
      expiry_date,
      quantity: Number(quantity || 0),
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
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const pageSize = Math.min(200, Math.max(10, parseInt(req.query.pageSize, 10) || 25));
    const paged = await InventoryBatch.findAllGlobalPaginated({ status, sort, search, page, pageSize });
    const rows = paged.rows;
    const summary = rows.reduce((acc, r) => {
      if (r.validity_status === 'EXPIRED') acc.expired += 1;
      else if (r.validity_status === 'EXPIRING') acc.expiring += 1;
      else acc.valid += 1;
      return acc;
    }, { expired: 0, expiring: 0, valid: 0 });
    const totalPages = Math.max(1, Math.ceil(paged.total / pageSize));
    res.render('admin/lotes', {
      title: 'Lotes - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'lotes',
      rows,
      filters: { status, sort, search },
      summary,
      pagination: {
        total: paged.total,
        page: paged.page,
        pageSize: paged.pageSize,
        totalPages,
      },
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
    const rows = await InventoryBatch.findAllGlobal({ status, sort, search });
    const header = ['id', 'product_id', 'product_name', 'sku', 'batch_code', 'mfg_date', 'expiry_date', 'validity_status', 'days_to_expiry', 'quantity'];
    const lines = [header.join(';')];
    rows.forEach((r) => {
      lines.push([
        r.id, r.product_id, `"${String(r.product_name || '').replace(/"/g, '""')}"`, r.sku || '', r.batch_code || '',
        r.mfg_date ? String(r.mfg_date).slice(0, 10) : '',
        r.expiry_date ? String(r.expiry_date).slice(0, 10) : '',
        r.validity_status || '', r.days_to_expiry, r.quantity,
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

module.exports = {
  listAllBatchesPage,
  exportCsv,
  deleteManyBatches,
  listBatches,
  createBatch,
  updateBatch,
  deleteBatch,
};
