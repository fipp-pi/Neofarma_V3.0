const InventoryBatch = require('../models/InventoryBatch');

/**
 * Converte linhas agregadas de estoque em mapa rápido por product_id.
 * @param {Array<{product_id:number|string, valid_stock:number|string}>} stockRows
 * @returns {Map<number, number>}
 */
function buildStockMap(stockRows = []) {
  const map = new Map();
  stockRows.forEach((row) => {
    map.set(Number(row.product_id), Number(row.valid_stock || 0));
  });
  return map;
}

/**
 * Retorna estoque válido por produto (desconsidera lotes vencidos).
 * @param {Array<number|string>} productIds
 * @returns {Promise<Map<number, number>>}
 */
async function getValidStockMapByProductIds(productIds = []) {
  const rows = await InventoryBatch.getValidStockByProductIds(productIds);
  return buildStockMap(rows);
}

/**
 * Atalho para obter estoque válido de um único produto.
 * @param {number|string} productId
 * @returns {Promise<number>}
 */
async function getValidStockByProductId(productId) {
  const map = await getValidStockMapByProductIds([productId]);
  return map.get(Number(productId)) || 0;
}

/**
 * Lista lotes vencidos ou próximos do vencimento para alertas operacionais.
 * @param {number} daysAhead
 */
async function getExpiryAlerts(daysAhead = 30) {
  return InventoryBatch.listExpiringOrExpired(daysAhead);
}

module.exports = {
  getValidStockMapByProductIds,
  getValidStockByProductId,
  getExpiryAlerts,
};
