const Promotion = require('../models/Promotion');
const StorefrontConfig = require('../models/StorefrontConfig');
const Product = require('../models/Product');
const promotionService = require('../services/promotionService');
const { mergePromoStyle } = require('../utils/storefrontDefaults');
const { SECTION_COLOR_SCHEMA, buildHomeSectionStyles } = require('../utils/sectionColors');

function jsonOk(res, data = {}) {
  return res.json({ ok: true, ...data });
}

function jsonErr(res, status, message, fields) {
  const body = { ok: false, message };
  if (fields) body.fields = fields;
  return res.status(status).json(body);
}

function parseDateTimeInput(value) {
  if (!value) return null;
  const s = String(value).trim();
  if (!s) return null;
  const normalized = s.includes('T') ? s.replace('T', ' ') : s;
  if (normalized.length === 16) return `${normalized}:00`;
  return normalized;
}

function promotionStatus(promo) {
  const now = Date.now();
  const start = new Date(promo.starts_at).getTime();
  const end = new Date(promo.ends_at).getTime();
  if (!promo.is_active) return { key: 'inactive', label: 'Inativa' };
  if (now < start) return { key: 'scheduled', label: 'Agendada' };
  if (now > end) return { key: 'expired', label: 'Expirada' };
  return { key: 'active', label: 'Ativa' };
}

/**
 * GET /admin/vitrine — painel promoções + home + tema.
 */
async function renderPage(req, res, next) {
  try {
    await promotionService.expireOutdatedPromotions();
    const [promotions, config] = await Promise.all([
      Promotion.findAll(),
      StorefrontConfig.getConfig(),
    ]);
    const list = promotions.map((p) => ({
      ...p,
      status: promotionStatus(p),
    }));
    const stats = {
      total: list.length,
      active: list.filter((p) => p.status.key === 'active').length,
      scheduled: list.filter((p) => p.status.key === 'scheduled').length,
      products: list.reduce((acc, p) => acc + Number(p.products_count || 0), 0),
    };
    res.render('admin/vitrine-promocoes', {
      title: 'Vitrine e Promoções - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'vitrine',
      promotions: list,
      stats,
      homeConfig: config.home,
      themeConfig: config.theme,
      sectionColorSchema: SECTION_COLOR_SCHEMA,
      configUpdatedAt: config.updated_at,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/vitrine/promocoes/:id — detalhe JSON para edição.
 */
async function getPromotionJson(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const promo = await Promotion.findById(id);
    if (!promo) return jsonErr(res, 404, 'Promoção não encontrada.');
    const products = await Promotion.listProductsForPromotion(id);
    return jsonOk(res, { promotion: promo, products });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/vitrine/promocoes — criar/atualizar campanha.
 */
async function savePromotion(req, res, next) {
  try {
    const body = req.body || {};
    const id = parseInt(body.id, 10) || null;
    const name = String(body.name || '').trim();
    const startsAt = parseDateTimeInput(body.starts_at);
    const endsAt = parseDateTimeInput(body.ends_at);
    const discountType = String(body.discount_type || 'PERCENT').toUpperCase();
    const discountValue = Number(String(body.discount_value || '').replace(',', '.'));
    const fields = {};

    if (name.length < 3) fields.name = 'Informe um nome com pelo menos 3 caracteres.';
    if (!startsAt) fields.starts_at = 'Data/hora de início obrigatória.';
    if (!endsAt) fields.ends_at = 'Data/hora de término obrigatória.';
    if (startsAt && endsAt && new Date(startsAt) >= new Date(endsAt)) {
      fields.ends_at = 'O término deve ser posterior ao início.';
    }
    if (!['PERCENT', 'FIXED_PRICE'].includes(discountType)) {
      fields.discount_type = 'Tipo de desconto inválido.';
    }
    if (!Number.isFinite(discountValue) || discountValue <= 0) {
      fields.discount_value = 'Informe um valor de desconto válido.';
    }
    if (discountType === 'PERCENT' && discountValue >= 100) {
      fields.discount_value = 'Percentual deve ser menor que 100%.';
    }

    const style = mergePromoStyle(body.style || {});
    const productItems = Array.isArray(body.products) ? body.products : [];
    if (!productItems.length) {
      fields.products = 'Selecione ao menos um produto para a promoção.';
    }

    if (Object.keys(fields).length) {
      return jsonErr(res, 400, 'Corrija os campos destacados.', fields);
    }

    const payload = {
      name,
      description: String(body.description || '').trim() || null,
      discount_type: discountType,
      discount_value: discountValue,
      starts_at: startsAt,
      ends_at: endsAt,
      is_active: body.is_active !== false && body.is_active !== '0',
      priority: parseInt(body.priority, 10) || 0,
      style,
    };

    let promotionId = id;
    if (id) {
      await Promotion.updateById(id, payload);
    } else {
      promotionId = await Promotion.create(payload);
    }

    const normalizedProducts = productItems.map((item) => ({
      product_id: parseInt(item.product_id || item.id, 10),
      fixed_promo_price: item.fixed_promo_price != null && item.fixed_promo_price !== ''
        ? Number(String(item.fixed_promo_price).replace(',', '.'))
        : null,
    })).filter((item) => item.product_id);

    await Promotion.replaceProducts(promotionId, normalizedProducts);
    await promotionService.syncPromotionProducts(promotionId);

    return jsonOk(res, {
      message: id ? 'Promoção atualizada.' : 'Promoção criada.',
      id: promotionId,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * DELETE /admin/vitrine/promocoes/:id
 */
async function deletePromotion(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const promo = await Promotion.findById(id);
    if (!promo) return jsonErr(res, 404, 'Promoção não encontrada.');
    const productIds = (await Promotion.findProductIds(id)).map((r) => r.product_id);
    await Promotion.deleteById(id);
    await Promise.all(productIds.map((pid) => promotionService.syncProductPromoPrice(pid)));
    return jsonOk(res, { message: 'Promoção removida.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/vitrine/home — salvar seções da página inicial.
 */
async function saveHomeConfig(req, res, next) {
  try {
    const home = req.body?.home || req.body;
    if (!home || typeof home !== 'object') {
      return jsonErr(res, 400, 'Configuração inválida.');
    }
    const saved = await StorefrontConfig.saveHome(home);
    return jsonOk(res, { message: 'Página inicial atualizada.', home: saved });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/vitrine/theme — salvar tema global da vitrine.
 */
async function saveThemeConfig(req, res, next) {
  try {
    const theme = req.body?.theme || req.body;
    if (!theme || typeof theme !== 'object') {
      return jsonErr(res, 400, 'Tema inválido.');
    }
    const saved = await StorefrontConfig.saveTheme(theme);
    return jsonOk(res, { message: 'Tema da vitrine atualizado.', theme: saved });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/vitrine/api/produtos?q=
 */
async function searchProducts(req, res, next) {
  try {
    const q = String(req.query.q || '').trim();
    let rows;
    if (q) {
      rows = await Product.findAll({ status: 'ACTIVE', search: q });
    } else {
      rows = (await Product.findAll({ status: 'ACTIVE' })).slice(0, 30);
    }
    const list = rows.slice(0, 40).map((p) => ({
      id: p.id,
      name: p.name,
      sku: p.sku,
      unit_price: p.unit_price,
      promotional_price: p.promotional_price,
      lab_name: p.lab_name,
    }));
    return jsonOk(res, { products: list });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /admin/vitrine/sync — recalcular todos os preços promocionais.
 */
async function syncAll(req, res, next) {
  try {
    await promotionService.expireOutdatedPromotions();
    const count = await promotionService.syncAllAffectedProducts();
    return jsonOk(res, { message: `Preços sincronizados (${count} produtos).`, count });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  renderPage,
  getPromotionJson,
  savePromotion,
  deletePromotion,
  saveHomeConfig,
  saveThemeConfig,
  searchProducts,
  syncAll,
};
