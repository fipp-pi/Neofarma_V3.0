/**
 * Regras de lotes de estoque.
 * Aqui o sistema decide validade, risco e baixa/reposição de quantidade.
 */
const { pool } = require('../config/database');

/**
 * Cria um lote para o produto. `batch_code` é único por produto no schema.
 *
 * @param {{ product_id: number, batch_code: string, mfg_date?: string|null, expiry_date: string, quantity: number }} data
 * @param {import('mysql2/promise').Pool|import('mysql2/promise').PoolConnection} [connection]
 * @returns {Promise<number>} insertId
 */
async function create(data, connection = pool) {
  const [result] = await connection.execute(
    `INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
     VALUES (?, ?, ?, ?, ?)`,
    [data.product_id, data.batch_code, data.mfg_date || null, data.expiry_date, data.quantity]
  );
  return result.insertId;
}

/**
 * Lotes de um produto com status de validade calculado e ordenação administrativa.
 *
 * @param {number|string} productId
 * @param {{ sort?: 'expiry_asc'|'expiry_desc'|'qty_desc'|'qty_asc', status?: 'ALL'|'EXPIRED'|'EXPIRING'|'VALID' }} [options]
 */
async function findByProductId(productId, options = {}) {
  const sortKey = String(options.sort || 'expiry_asc');
  const statusFilter = String(options.status || 'ALL').toUpperCase();
  const onlyWithStock = options.onlyWithStock === true;
  const withDisposal = options.withDisposal === true;
  const hideDisposed = options.hideDisposed === true || options.hideDisposed === '1' || options.hideDisposed === 1;
  let orderBy = 'ORDER BY b.expiry_date ASC, b.id ASC';
  if (sortKey === 'expiry_desc') orderBy = 'ORDER BY b.expiry_date DESC, b.id DESC';
  if (sortKey === 'qty_desc') orderBy = 'ORDER BY b.quantity DESC, b.expiry_date ASC, b.id ASC';
  if (sortKey === 'qty_asc') orderBy = 'ORDER BY b.quantity ASC, b.expiry_date ASC, b.id ASC';

  let where = 'WHERE b.product_id = ?';
  const params = [productId];
  if (statusFilter === 'EXPIRED') where += ' AND b.expiry_date < CURDATE()';
  if (statusFilter === 'EXPIRING') where += ' AND b.expiry_date >= CURDATE() AND b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)';
  if (statusFilter === 'VALID') where += ' AND b.expiry_date > DATE_ADD(CURDATE(), INTERVAL 30 DAY)';
  if (onlyWithStock) where += ' AND b.quantity > 0';
  if (withDisposal && hideDisposed) {
    where += ' AND NOT (COALESCE(d.disposed_qty, 0) > 0 AND b.quantity = 0)';
  }

  const disposalFrom = withDisposal ? DISPOSAL_JOIN : '';
  const disposalSelect = withDisposal ? `, ${DISPOSAL_SELECT}` : '';

  const [rows] = await pool.execute(
    `SELECT b.id, b.product_id, b.batch_code, b.mfg_date, b.expiry_date, b.quantity,
            CASE
              WHEN b.expiry_date < CURDATE() THEN 'EXPIRED'
              WHEN b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING'
              ELSE 'VALID'
            END AS validity_status,
            DATEDIFF(b.expiry_date, CURDATE()) AS days_to_expiry
            ${disposalSelect}
     FROM inventory_batches b
     ${disposalFrom}
     ${where}
     ${orderBy}`,
    params
  );
  return rows;
}

/**
 * Busca lote pelo id.
 */
async function findById(id) {
  const [rows] = await pool.execute(
    `SELECT id, product_id, batch_code, mfg_date, expiry_date, quantity
     FROM inventory_batches
     WHERE id = ?
     LIMIT 1`,
    [id]
  );
  return rows[0] || null;
}

/**
 * Atualização parcial apenas de campos permitidos.
 *
 * @param {number|string} id
 * @param {Partial<{ batch_code: string, mfg_date: string|null, expiry_date: string, quantity: number }>} data
 */
async function updateById(id, data) {
  const fields = [];
  const values = [];
  const allowed = ['batch_code', 'mfg_date', 'expiry_date', 'quantity'];
  allowed.forEach((key) => {
    if (data[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(data[key]);
    }
  });
  if (!fields.length) return 0;
  values.push(id);
  const [result] = await pool.execute(
    `UPDATE inventory_batches SET ${fields.join(', ')} WHERE id = ?`,
    values
  );
  return result.affectedRows;
}

/**
 * Exclui lote pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM inventory_batches WHERE id = ?', [id]);
  return result.affectedRows;
}

/**
 * Soma estoque **vendável** por produto (não vencido, quantidade positiva).
 *
 * @param {Array<number|string>} productIds
 * @returns {Promise<Array<{ product_id: number, valid_stock: number }>>}
 */
async function getValidStockByProductIds(productIds = []) {
  if (!Array.isArray(productIds) || productIds.length === 0) return [];
  const placeholders = productIds.map(() => '?').join(', ');
  const [rows] = await pool.execute(
    `SELECT product_id, COALESCE(SUM(quantity), 0) AS valid_stock
     FROM inventory_batches
     WHERE product_id IN (${placeholders})
       AND quantity > 0
       AND expiry_date >= CURDATE()
     GROUP BY product_id`,
    productIds
  );
  return rows;
}

/**
 * Alertas: lotes com quantidade > 0 que vencem até `daysAhead` dias ou já venceram.
 *
 * @param {number} [daysAhead]
 */
async function listExpiringOrExpired(daysAhead = 30) {
  const [rows] = await pool.execute(
    `SELECT b.*, p.name AS product_name,
            CASE
              WHEN b.expiry_date < CURDATE() THEN 'EXPIRED'
              WHEN b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) THEN 'EXPIRING'
              ELSE 'OK'
            END AS validity_status
     FROM inventory_batches b
     INNER JOIN products p ON p.id = b.product_id
     WHERE b.quantity > 0
       AND b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
     ORDER BY b.expiry_date ASC, b.id ASC`,
    [daysAhead, daysAhead]
  );
  return rows;
}

/**
 * Contadores agregados para cards do dashboard admin (lotes vencidos / a vencer).
 *
 * @param {number} [daysAhead] janela “próximo do vencimento” em dias
 */
async function getDashboardValidityCounts(daysAhead = 30) {
  const [rows] = await pool.execute(
    `SELECT
       SUM(CASE WHEN expiry_date < CURDATE() AND quantity > 0 THEN 1 ELSE 0 END) AS expired_count,
       SUM(CASE WHEN expiry_date >= CURDATE() AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND quantity > 0 THEN 1 ELSE 0 END) AS expiring_count
     FROM inventory_batches`,
    [daysAhead]
  );
  return rows[0] || { expired_count: 0, expiring_count: 0 };
}

/**
 * Por produto: quantos lotes vencidos vs. vencendo na janela (para badges na lista de produtos).
 *
 * @param {Array<number|string>} productIds
 * @param {number} [daysAhead]
 */
async function getRiskByProductIds(productIds = [], daysAhead = 30) {
  if (!Array.isArray(productIds) || productIds.length === 0) return [];
  const placeholders = productIds.map(() => '?').join(', ');
  const [rows] = await pool.execute(
    `SELECT
       product_id,
       SUM(CASE WHEN expiry_date < CURDATE() AND quantity > 0 THEN 1 ELSE 0 END) AS expired_batches,
       SUM(CASE WHEN expiry_date >= CURDATE() AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND quantity > 0 THEN 1 ELSE 0 END) AS expiring_batches
     FROM inventory_batches
     WHERE product_id IN (${placeholders})
     GROUP BY product_id`,
    [daysAhead, ...productIds]
  );
  return rows;
}

/**
 * Lotes vencidos com saldo > 0 — aguardam descarte manual (RF_F5).
 */
async function countExpiredAwaitingDisposal() {
  const [rows] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM inventory_batches
     WHERE expiry_date < CURDATE()
       AND quantity > 0`
  );
  return Number(rows[0]?.total || 0);
}

/** Subquery reutilizada: totais de descarte por lote. */
const DISPOSAL_JOIN = `
  LEFT JOIN (
    SELECT batch_id,
           COALESCE(SUM(quantity), 0) AS disposed_qty,
           COUNT(*) AS disposal_count,
           MAX(created_at) AS last_disposed_at
    FROM inventory_disposals
    GROUP BY batch_id
  ) d ON d.batch_id = b.id`;

const DISPOSAL_SELECT = `
  COALESCE(d.disposed_qty, 0) AS disposed_qty,
  COALESCE(d.disposal_count, 0) AS disposal_count,
  d.last_disposed_at,
  CASE
    WHEN COALESCE(d.disposed_qty, 0) = 0 THEN 'NONE'
    WHEN b.quantity = 0 THEN 'FULL'
    ELSE 'PARTIAL'
  END AS disposal_status`;

function applyGlobalFilters(options = {}) {
  const statusFilter = String(options.status || 'ALL').toUpperCase();
  const search = String(options.search || '').trim();
  const hideDisposed = options.hideDisposed === true || options.hideDisposed === '1' || options.hideDisposed === 1;
  let where = 'WHERE 1=1';
  const params = [];
  if (statusFilter === 'EXPIRED') where += ' AND b.expiry_date < CURDATE()';
  if (statusFilter === 'EXPIRING') where += ' AND b.expiry_date >= CURDATE() AND b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)';
  if (statusFilter === 'VALID') where += ' AND b.expiry_date > DATE_ADD(CURDATE(), INTERVAL 30 DAY)';
  if (hideDisposed) {
    where += ' AND NOT (COALESCE(d.disposed_qty, 0) > 0 AND b.quantity = 0)';
  }
  if (search) {
    where += ' AND (p.name LIKE ? OR b.batch_code LIKE ?)';
    const term = `%${search}%`;
    params.push(term, term);
  }
  return { where, params, sortKey: String(options.sort || 'expiry_asc'), hideDisposed };
}

function buildGlobalOrderBy(sortKey) {
  let orderBy = 'ORDER BY b.expiry_date ASC, b.id ASC';
  if (sortKey === 'expiry_desc') orderBy = 'ORDER BY b.expiry_date DESC, b.id DESC';
  if (sortKey === 'qty_desc') orderBy = 'ORDER BY b.quantity DESC, b.expiry_date ASC';
  if (sortKey === 'qty_asc') orderBy = 'ORDER BY b.quantity ASC, b.expiry_date ASC';
  if (sortKey === 'product_asc') orderBy = 'ORDER BY p.name ASC, b.expiry_date ASC, b.id ASC';
  if (sortKey === 'product_desc') orderBy = 'ORDER BY p.name DESC, b.expiry_date ASC, b.id ASC';
  if (sortKey === 'days_asc') orderBy = 'ORDER BY DATEDIFF(b.expiry_date, CURDATE()) ASC, b.id ASC';
  if (sortKey === 'days_desc') orderBy = 'ORDER BY DATEDIFF(b.expiry_date, CURDATE()) DESC, b.id ASC';
  return orderBy;
}

/**
 * Lista global de lotes (admin) com join em produto; filtros e ordenação por whitelist.
 *
 * @param {{ status?: string, search?: string, sort?: string, hideDisposed?: boolean|string }} [options]
 */
async function findAllGlobal(options = {}) {
  const { where, params, sortKey } = applyGlobalFilters(options);
  const orderBy = buildGlobalOrderBy(sortKey);

  const [rows] = await pool.execute(
    `SELECT b.id, b.product_id, b.batch_code, b.mfg_date, b.expiry_date, b.quantity,
            p.name AS product_name, p.sku,
            CASE
              WHEN b.expiry_date < CURDATE() THEN 'EXPIRED'
              WHEN b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING'
              ELSE 'VALID'
            END AS validity_status,
            DATEDIFF(b.expiry_date, CURDATE()) AS days_to_expiry,
            ${DISPOSAL_SELECT}
     FROM inventory_batches b
     INNER JOIN products p ON p.id = b.product_id
     ${DISPOSAL_JOIN}
     ${where}
     ${orderBy}`,
    params
  );
  return rows;
}

/**
 * Mesma base de `findAllGlobal` com contagem total e página.
 *
 * @param {{ status?: string, search?: string, sort?: string, page?: number, pageSize?: number, hideDisposed?: boolean|string }} [options]
 * @returns {Promise<{ rows: object[], total: number, page: number, pageSize: number }>}
 */
async function findAllGlobalPaginated(options = {}) {
  const { where, params, sortKey } = applyGlobalFilters(options);
  const orderBy = buildGlobalOrderBy(sortKey);
  const page = Math.max(1, parseInt(options.page, 10) || 1);
  const pageSize = Math.min(200, Math.max(10, parseInt(options.pageSize, 10) || 25));
  const offset = (page - 1) * pageSize;

  const [countRows] = await pool.execute(
    `SELECT COUNT(*) AS total
     FROM inventory_batches b
     INNER JOIN products p ON p.id = b.product_id
     ${DISPOSAL_JOIN}
     ${where}`,
    params
  );
  const total = Number((countRows[0] && countRows[0].total) || 0);

  const [rows] = await pool.execute(
    `SELECT b.id, b.product_id, b.batch_code, b.mfg_date, b.expiry_date, b.quantity,
            p.name AS product_name, p.sku,
            CASE
              WHEN b.expiry_date < CURDATE() THEN 'EXPIRED'
              WHEN b.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 'EXPIRING'
              ELSE 'VALID'
            END AS validity_status,
            DATEDIFF(b.expiry_date, CURDATE()) AS days_to_expiry,
            ${DISPOSAL_SELECT}
     FROM inventory_batches b
     INNER JOIN products p ON p.id = b.product_id
     ${DISPOSAL_JOIN}
     ${where}
     ${orderBy}
     LIMIT ${pageSize} OFFSET ${offset}`,
    params
  );

  return { rows, total, page, pageSize };
}

/**
 * Exclusão em massa por ids (usada no admin global).
 *
 * @param {number[]} ids
 * @returns {Promise<number>} affectedRows
 */
async function deleteManyByIds(ids = []) {
  if (!Array.isArray(ids) || ids.length === 0) return 0;
  const placeholders = ids.map(() => '?').join(', ');
  const [result] = await pool.execute(
    `DELETE FROM inventory_batches WHERE id IN (${placeholders})`,
    ids
  );
  return result.affectedRows;
}

/**
 * **First Expire, First Out**: aloca quantidade nos lotes não vencidos, na ordem de validade.
 * Trava linhas com `FOR UPDATE`, decrementa `quantity` no mesmo `connection` (transação externa).
 *
 * @param {import('mysql2/promise').PoolConnection} connection
 * @param {number|string} productId
 * @param {number|string} requestedQty
 * @returns {Promise<Array<{ batch_id: number, quantity: number, expiry_date: string }>>}
 * @throws {Error & { code: 'INSUFFICIENT_STOCK' }}
 */
async function allocateFEFO(connection, productId, requestedQty) {
  const qty = Number(requestedQty || 0);
  if (qty <= 0) return [];

  const [rows] = await connection.execute(
    `SELECT id, expiry_date, quantity
     FROM inventory_batches
     WHERE product_id = ?
       AND quantity > 0
       AND expiry_date >= CURDATE()
     ORDER BY expiry_date ASC, id ASC
     FOR UPDATE`,
    [productId]
  );

  let remaining = qty;
  const allocations = [];
  for (const row of rows) {
    if (remaining <= 0) break;
    const take = Math.min(Number(row.quantity), remaining);
    if (take > 0) {
      allocations.push({
        batch_id: row.id,
        quantity: take,
        expiry_date: row.expiry_date,
      });
      remaining -= take;
    }
  }

  if (remaining > 0) {
    const err = new Error('Estoque insuficiente para atender o pedido.');
    err.code = 'INSUFFICIENT_STOCK';
    throw err;
  }

  for (const alloc of allocations) {
    await connection.execute(
      'UPDATE inventory_batches SET quantity = quantity - ? WHERE id = ?',
      [alloc.quantity, alloc.batch_id]
    );
  }

  return allocations;
}

/**
 * Reverte baixa de estoque (ex.: cancelamento com pagamento ainda pendente).
 * Espera o mesmo formato usado na saída de {@link allocateFEFO}: `{ batch_id, quantity }`.
 *
 * @param {import('mysql2/promise').PoolConnection} connection
 * @param {Array<{ batch_id?: number, quantity?: number }>} [allocations]
 * @returns {Promise<void>}
 */
async function restoreAllocations(connection, allocations = []) {
  if (!Array.isArray(allocations) || !allocations.length) return;
  for (const a of allocations) {
    const q = Number(a.quantity || 0);
    if (!a.batch_id || q <= 0) continue;
    await connection.execute('UPDATE inventory_batches SET quantity = quantity + ? WHERE id = ?', [q, a.batch_id]);
  }
}

module.exports = {
  create,
  findById,
  findByProductId,
  updateById,
  deleteById,
  getValidStockByProductIds,
  listExpiringOrExpired,
  getDashboardValidityCounts,
  getRiskByProductIds,
  findAllGlobal,
  findAllGlobalPaginated,
  deleteManyByIds,
  allocateFEFO,
  restoreAllocations,
  countExpiredAwaitingDisposal,
};
