const { pool } = require('../config/database');
const Promotion = require('../models/Promotion');

/**
 * Calcula preço promocional com base na campanha.
 */
function computePromoPrice(unitPrice, promotion, fixedPrice = null) {
  const unit = Number(unitPrice || 0);
  if (unit <= 0) return null;
  if (fixedPrice != null && Number(fixedPrice) > 0) {
    const fp = Number(fixedPrice);
    return fp < unit ? fp : null;
  }
  const type = String(promotion.discount_type || 'PERCENT').toUpperCase();
  const val = Number(promotion.discount_value || 0);
  if (type === 'PERCENT' && val > 0 && val < 100) {
    const price = unit * (1 - val / 100);
    return price > 0 && price < unit ? Math.round(price * 100) / 100 : null;
  }
  if (type === 'FIXED_PRICE' && val > 0 && val < unit) {
    return val;
  }
  return null;
}

/**
 * Sincroniza promotional_price de um produto com a campanha ativa de maior prioridade.
 */
async function syncProductPromoPrice(productId) {
  const promo = await Promotion.getActiveForProduct(productId);
  const [rows] = await pool.execute(
    'SELECT id, unit_price FROM products WHERE id = ? LIMIT 1',
    [productId]
  );
  const product = rows[0];
  if (!product) return;

  let promoPrice = null;
  if (promo) {
    promoPrice = computePromoPrice(product.unit_price, promo, promo.fixed_promo_price);
  }
  await pool.execute(
    'UPDATE products SET promotional_price = ? WHERE id = ?',
    [promoPrice, productId]
  );
}

/**
 * Sincroniza todos os produtos vinculados a uma campanha.
 */
async function syncPromotionProducts(promotionId) {
  const links = await Promotion.findProductIds(promotionId);
  const ids = links.map((l) => l.product_id);
  await Promise.all(ids.map((id) => syncProductPromoPrice(id)));
  return ids.length;
}

/**
 * Recalcula preços de todos os produtos que estiveram em campanhas (após expirar/desativar).
 */
async function syncAllAffectedProducts() {
  const [rows] = await pool.execute(
    'SELECT DISTINCT product_id FROM promotion_products'
  );
  const ids = (rows || []).map((r) => r.product_id);
  for (const id of ids) {
    await syncProductPromoPrice(id);
  }
  return ids.length;
}

/**
 * Desativa campanhas expiradas e limpa preços.
 */
async function expireOutdatedPromotions() {
  await Promotion.ensureTables();
  const [result] = await pool.execute(
    `UPDATE promotions SET is_active = 0 WHERE is_active = 1 AND ends_at < NOW()`
  );
  await syncAllAffectedProducts();
  return result.affectedRows || 0;
}

/**
 * Produtos ativos em promoção (via promotional_price ou campanha).
 */
async function findActivePromoProductRows(limit = 16, promotionId = null) {
  await expireOutdatedPromotions();
  if (promotionId) {
    return Promotion.getProductsByPromotionId(promotionId, limit);
  }
  const Product = require('../models/Product');
  return Product.findOnPromotion(limit);
}

/**
 * Data ISO para countdown (YYYY/MM/DD) a partir da campanha ou fallback.
 */
function formatCountdownDate(date) {
  if (!date) return null;
  const d = new Date(date);
  if (Number.isNaN(d.getTime())) return null;
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}/${m}/${day}`;
}

async function resolveFlashEndDate(homeConfig, promotions = []) {
  const flash = homeConfig?.flashOffer || {};
  if (flash.promotionId) {
    const promo = promotions.find((p) => Number(p.id) === Number(flash.promotionId))
      || await Promotion.findById(flash.promotionId);
    if (promo && promo.ends_at) return formatCountdownDate(promo.ends_at);
  }
  if (flash.usePromotionEnd !== false) {
    const active = promotions.filter((p) => p.is_active && p.ends_at);
    if (active.length) {
      const earliest = active.reduce((a, b) => (
        new Date(a.ends_at) < new Date(b.ends_at) ? a : b
      ));
      return formatCountdownDate(earliest.ends_at);
    }
  }
  return null;
}

module.exports = {
  computePromoPrice,
  syncProductPromoPrice,
  syncPromotionProducts,
  syncAllAffectedProducts,
  expireOutdatedPromotions,
  findActivePromoProductRows,
  formatCountdownDate,
  resolveFlashEndDate,
};
