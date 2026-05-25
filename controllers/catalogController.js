const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const Customer = require('../models/Customer');
const Promotion = require('../models/Promotion');
const StorefrontConfig = require('../models/StorefrontConfig');
const promotionService = require('../services/promotionService');
const { buildHomeSectionStyles } = require('../utils/sectionColors');
const { getValidStockMapByProductIds, getValidStockByProductId } = require('../services/inventoryService');
const { pool } = require('../config/database');

/**
 * Fim do domingo da semana corrente — usado no cronômetro de ofertas flash da home.
 */
function getFlashOfferEndLabel() {
  const now = new Date();
  const end = new Date(now);
  const day = now.getDay();
  const daysUntilSunday = day === 0 ? 0 : 7 - day;
  end.setDate(now.getDate() + daysUntilSunday);
  const y = end.getFullYear();
  const m = String(end.getMonth() + 1).padStart(2, '0');
  const d = String(end.getDate()).padStart(2, '0');
  return `${y}/${m}/${d}`;
}

/**
 * Deriva URL de miniatura para imagens processadas em WebP.
 */
function withThumb(url) {
  if (!url) return null;
  if (/^\/uploads\/products\/.+\.webp$/i.test(url) && !/-thumb\.webp$/i.test(url)) {
    return url.replace(/\.webp$/i, '-thumb.webp');
  }
  return url;
}

/**
 * Formata CEP para mostrar no detalhe do produto.
 */
function formatZip(zip) {
  const digits = String(zip || '').replace(/\D/g, '');
  if (digits.length !== 8) return '';
  return `${digits.slice(0, 5)}-${digits.slice(5)}`;
}

/**
 * Monta o objeto padrão de produto para os cards da vitrine.
 * Junta preço, imagem e estoque em um formato único.
 */
function normalizeCard(product, imageUrl, stock = 0, extra = {}) {
  const unit = Number(product.unit_price || 0);
  const promo = product.promotional_price != null ? Number(product.promotional_price) : null;
  const hasPromo = promo != null && promo > 0 && promo < unit;
  const discountPercent = hasPromo && unit > 0 ? Math.round((1 - promo / unit) * 100) : 0;
  return {
    ...product,
    image_url: imageUrl || '/assets/img/product/product-1.webp',
    thumb_url: withThumb(imageUrl) || '/assets/img/product/product-1.webp',
    price_display: unit.toFixed(2).replace('.', ','),
    promo_display: hasPromo ? promo.toFixed(2).replace('.', ',') : null,
    has_promo: hasPromo,
    discount_percent: discountPercent,
    available_stock: Number(stock || 0),
    can_buy: Number(stock || 0) > 0,
    qty_sold: Number(extra.qty_sold || 0),
  };
}

/**
 * Enriquece linhas de produto com imagem principal e estoque válido (FEFO).
 */
async function enrichProductCards(products = [], qtySoldMap = {}) {
  const ids = products.map((p) => p.id);
  if (!ids.length) return [];
  const imageRows = await ProductImage.findByProductIds(ids);
  const firstImageByProduct = {};
  imageRows.forEach((row) => {
    if (!firstImageByProduct[row.product_id]) firstImageByProduct[row.product_id] = row.image_url;
  });
  const stockMap = await getValidStockMapByProductIds(ids);
  return products.map((p) => normalizeCard(
    p,
    firstImageByProduct[p.id],
    stockMap.get(Number(p.id)) || 0,
    { qty_sold: qtySoldMap[p.id] || qtySoldMap[Number(p.id)] || 0 }
  ));
}

/**
 * Iniciais para avatar da marca/laboratório.
 */
function labInitials(name) {
  const parts = String(name || '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return 'NF';
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

/**
 * Busca laboratórios com estatísticas e amostras de produtos para a home.
 */
async function fetchLabHighlightsForHome(limit = 6) {
  const cap = Math.min(Math.max(Number(limit) || 6, 1), 12);
  const [rows] = await pool.execute(
    `SELECT l.id, l.name,
            COUNT(DISTINCT p.id) AS product_count,
            SUM(CASE WHEN p.promotional_price IS NOT NULL AND p.promotional_price > 0
                      AND p.promotional_price < p.unit_price THEN 1 ELSE 0 END) AS promo_count,
            MIN(p.unit_price) AS min_price
     FROM labs l
     INNER JOIN products p ON p.lab_id = l.id AND p.status = 'ACTIVE'
     WHERE l.is_active = 1
     GROUP BY l.id, l.name
     HAVING product_count > 0
     ORDER BY product_count DESC, l.name ASC
     LIMIT ${cap}`
  );
  if (!rows.length) return [];

  const labs = rows.map((r) => ({
    id: r.id,
    name: r.name,
    count: Number(r.product_count) || 0,
    promo_count: Number(r.promo_count) || 0,
    min_price: Number(r.min_price) || 0,
    min_price_display: Number(r.min_price || 0).toFixed(2).replace('.', ','),
    initials: labInitials(r.name),
    samples: [],
  }));

  await Promise.all(labs.map(async (lab) => {
    const [products] = await pool.execute(
      `SELECT p.id, p.name
       FROM products p
       WHERE p.lab_id = ? AND p.status = 'ACTIVE'
       ORDER BY (CASE WHEN p.promotional_price IS NOT NULL AND p.promotional_price > 0
                      AND p.promotional_price < p.unit_price THEN 0 ELSE 1 END),
                p.name ASC
       LIMIT 3`,
      [lab.id]
    );
    const ids = products.map((p) => p.id);
    const imageMap = {};
    if (ids.length) {
      const imageRows = await ProductImage.findByProductIds(ids);
      imageRows.forEach((row) => {
        if (!imageMap[row.product_id]) imageMap[row.product_id] = row.image_url;
      });
    }
    lab.samples = products.map((p) => {
      const img = imageMap[p.id];
      return {
        id: p.id,
        name: p.name,
        image_url: img || '/assets/img/product/product-1.webp',
        thumb_url: withThumb(img) || '/assets/img/product/product-1.webp',
      };
    });
  }));

  return labs;
}

/**
 * Fallback: agrupa produtos já carregados por laboratório.
 */
function buildLabHighlights(products = []) {
  const grouped = new Map();
  products.forEach((p) => {
    const key = p.lab_name || 'NeoFarma';
    if (!grouped.has(key)) {
      grouped.set(key, {
        name: key,
        count: 0,
        sample: p,
      });
    }
    grouped.get(key).count += 1;
  });
  return Array.from(grouped.values())
    .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name))
    .slice(0, 4)
    .map((lab) => ({
      ...lab,
      initials: labInitials(lab.name),
      promo_count: 0,
      min_price_display: lab.sample && lab.sample.price_display
        ? lab.sample.price_display
        : null,
      samples: lab.sample ? [{
        id: lab.sample.id,
        name: lab.sample.name,
        image_url: lab.sample.image_url,
        thumb_url: lab.sample.thumb_url || lab.sample.image_url,
      }] : [],
    }));
}

/**
 * Página de catálogo geral (com destaque por laboratório).
 */
async function listCatalog(req, res, next) {
  try {
    const selectedLab = String(req.query.lab || '').trim();
    const allActive = await Product.findAll({ status: 'ACTIVE' });
    const ids = allActive.map((p) => p.id);
    const imageRows = await ProductImage.findByProductIds(ids);
    const firstImageByProduct = {};
    imageRows.forEach((row) => {
      if (!firstImageByProduct[row.product_id]) firstImageByProduct[row.product_id] = row.image_url;
    });

    const stockMap = await getValidStockMapByProductIds(ids);
    const normalized = allActive.map((p) => normalizeCard(p, firstImageByProduct[p.id], stockMap.get(Number(p.id)) || 0));
    const filtered = selectedLab
      ? normalized.filter((p) => String(p.lab_name || 'NeoFarma').toLowerCase() === selectedLab.toLowerCase())
      : normalized;
    const emPromocao = filtered.filter((p) => p.has_promo).slice(0, 12);
    const maisVendidos = filtered.slice(0, 12);
    const populares = filtered
      .filter((p) => !maisVendidos.some((m) => m.id === p.id))
      .slice(0, 12);
    const availableLabs = Array.from(new Set(normalized.map((p) => p.lab_name || 'NeoFarma'))).sort((a, b) => a.localeCompare(b));

    res.render('catalog', {
      title: selectedLab ? `Produtos - ${selectedLab} - NeoFarma` : 'Produtos - NeoFarma',
      bodyClass: 'category-page',
      activeNav: 'category',
      emPromocao,
      maisVendidos,
      populares,
      allProducts: filtered,
      selectedLab,
      availableLabs,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Catálogo avançado com filtros server-side e paginação.
 * Mantém query SQL dinâmica para evitar carregar catálogo inteiro em memória.
 */
async function listCategory(req, res, next) {
  try {
    const q = String(req.query.q || '').trim();
    const lab = String(req.query.lab || '').trim();
    const categoryId = parseInt(req.query.category, 10) || null;
    const minPrice = Number(req.query.min_price || 0);
    const maxPrice = Number(req.query.max_price || 0);
    const sort = String(req.query.sort || 'relevance');
    const promoOnly = String(req.query.promo || '') === '1';
    const inStockOnly = String(req.query.in_stock || '') === '1';
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const pageSize = 12;
    const offset = (page - 1) * pageSize;

    const where = [`p.status = 'ACTIVE'`];
    const params = [];

    if (q) {
      where.push('(p.name LIKE ? OR p.sku LIKE ? OR l.name LIKE ?)');
      const term = `%${q}%`;
      params.push(term, term, term);
    }
    if (lab) {
      where.push('l.name = ?');
      params.push(lab);
    }
    if (categoryId) {
      where.push('pc.category_id = ?');
      params.push(categoryId);
    }
    if (Number.isFinite(minPrice) && minPrice > 0) {
      where.push('COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) >= ?');
      params.push(minPrice);
    }
    if (Number.isFinite(maxPrice) && maxPrice > 0) {
      where.push('COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) <= ?');
      params.push(maxPrice);
    }
    if (promoOnly) {
      where.push('p.promotional_price IS NOT NULL AND p.promotional_price > 0 AND p.promotional_price < p.unit_price');
    }
    if (inStockOnly) {
      where.push(`EXISTS (
        SELECT 1 FROM inventory_batches b
        WHERE b.product_id = p.id
          AND b.quantity > 0
          AND b.expiry_date >= CURDATE()
      )`);
    }

    const bestsellerOrder = sort === 'bestsellers'
      ? `(SELECT COALESCE(SUM(oi.quantity), 0)
          FROM order_items oi
          INNER JOIN orders o ON o.id = oi.order_id AND o.payment_status = 'PAID'
          WHERE oi.product_id = p.id
            AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)) DESC, p.name ASC`
      : null;

    let orderBy = 'p.created_at DESC, p.id DESC';
    if (sort === 'price_asc') orderBy = 'COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) ASC, p.name ASC';
    if (sort === 'price_desc') orderBy = 'COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) DESC, p.name ASC';
    if (sort === 'name_asc') orderBy = 'p.name ASC';
    if (sort === 'name_desc') orderBy = 'p.name DESC';
    if (sort === 'bestsellers') orderBy = bestsellerOrder;
    if (sort === 'discount') {
      orderBy = `CASE
        WHEN p.promotional_price IS NOT NULL AND p.promotional_price > 0 AND p.promotional_price < p.unit_price
        THEN (p.unit_price - p.promotional_price) / p.unit_price
        ELSE 0 END DESC, p.name ASC`;
    }

    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const [countRows] = await pool.execute(
      `SELECT COUNT(DISTINCT p.id) AS total
       FROM products p
       LEFT JOIN labs l ON l.id = p.lab_id
       LEFT JOIN product_categories pc ON pc.product_id = p.id
       ${whereSql}`,
      params
    );
    const total = Number(countRows && countRows[0] && countRows[0].total ? countRows[0].total : 0);
    const totalPages = Math.max(1, Math.ceil(total / pageSize));
    const safePage = Math.min(page, totalPages);
    const safeOffset = (safePage - 1) * pageSize;

    const [rows] = await pool.execute(
      `SELECT p.*, l.name AS lab_name
       FROM products p
       LEFT JOIN labs l ON l.id = p.lab_id
       LEFT JOIN product_categories pc ON pc.product_id = p.id
       ${whereSql}
       GROUP BY p.id
       ORDER BY ${orderBy}
       LIMIT ${pageSize} OFFSET ${safeOffset}`,
      params
    );

    const products = await enrichProductCards(rows);

    const [labsRows] = await pool.execute(
      `SELECT l.name, COUNT(DISTINCT p.id) AS total
       FROM labs l
       INNER JOIN products p ON p.lab_id = l.id AND p.status = 'ACTIVE'
       GROUP BY l.name
       ORDER BY l.name ASC`
    );
    const [catsRows] = await pool.execute(
      `SELECT c.id, c.name, COUNT(DISTINCT p.id) AS total
       FROM categories c
       LEFT JOIN product_categories pc ON pc.category_id = c.id
       LEFT JOIN products p ON p.id = pc.product_id AND p.status = 'ACTIVE'
       WHERE c.is_active = 1
       GROUP BY c.id, c.name
       HAVING total > 0
       ORDER BY c.name ASC`
    );
    const [priceRows] = await pool.execute(
      `SELECT
        MIN(COALESCE(NULLIF(promotional_price, 0), unit_price)) AS min_price,
        MAX(COALESCE(NULLIF(promotional_price, 0), unit_price)) AS max_price
       FROM products
       WHERE status = 'ACTIVE'`
    );
    const minBound = Number(priceRows && priceRows[0] && priceRows[0].min_price ? priceRows[0].min_price : 0);
    const maxBound = Number(priceRows && priceRows[0] && priceRows[0].max_price ? priceRows[0].max_price : 0);

    const activeFilters = [];
    if (q) activeFilters.push({ key: 'q', label: 'Busca: ' + q });
    if (lab) activeFilters.push({ key: 'lab', label: 'Lab: ' + lab });
    if (categoryId) {
      const cat = (catsRows || []).find((c) => Number(c.id) === categoryId);
      activeFilters.push({ key: 'category', label: cat ? cat.name : 'Categoria' });
    }
    if (promoOnly) activeFilters.push({ key: 'promo', label: 'Em promoção' });
    if (inStockOnly) activeFilters.push({ key: 'in_stock', label: 'Com estoque' });
    if (minPrice > 0) activeFilters.push({ key: 'min_price', label: 'Mín. R$ ' + minPrice.toFixed(2).replace('.', ',') });
    if (maxPrice > 0) activeFilters.push({ key: 'max_price', label: 'Máx. R$ ' + maxPrice.toFixed(2).replace('.', ',') });

    res.render('category', {
      title: 'Catálogo - NeoFarma',
      bodyClass: 'category-page storefront-catalog',
      activeNav: 'category',
      products,
      labs: labsRows || [],
      categories: catsRows || [],
      filters: {
        q,
        lab,
        category: categoryId || '',
        min_price: Number.isFinite(minPrice) && minPrice > 0 ? minPrice : '',
        max_price: Number.isFinite(maxPrice) && maxPrice > 0 ? maxPrice : '',
        sort,
        promo: promoOnly ? '1' : '',
        in_stock: inStockOnly ? '1' : '',
      },
      activeFilters,
      priceBounds: {
        min: minBound,
        max: maxBound,
      },
      pagination: {
        page: safePage,
        pageSize,
        total,
        totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Monta os blocos da home com produtos ativos.
 */
async function home(req, res, next) {
  try {
    await promotionService.expireOutdatedPromotions();
    const storefront = await StorefrontConfig.getConfig();
    const homeCfg = storefront.home;
    const themeCfg = storefront.theme;

    const promoCarouselCfg = homeCfg.promoCarousel || {};
    const flashCfg = homeCfg.flashOffer || {};
    const bestsellersCfg = homeCfg.bestsellers || {};
    const categoriesCfg = homeCfg.categories || {};
    const newArrivalsCfg = homeCfg.newArrivals || {};

    const promoLimit = promoCarouselCfg.limit || 16;
    const promoId = promoCarouselCfg.promotionId || null;

    const [promoRows, recentRows, bestSellerRank, catsRows, activePromotions] = await Promise.all([
      promotionService.findActivePromoProductRows(promoLimit, promoId),
      Product.findRecent(newArrivalsCfg.limit || 8),
      Product.findBestSellerIds(bestsellersCfg.limit || 12, bestsellersCfg.days || 90),
      pool.execute(
        `SELECT c.id, c.name, COUNT(DISTINCT p.id) AS total
         FROM categories c
         LEFT JOIN product_categories pc ON pc.category_id = c.id
         LEFT JOIN products p ON p.id = pc.product_id AND p.status = 'ACTIVE'
         WHERE c.is_active = 1
         GROUP BY c.id, c.name
         HAVING total > 0
         ORDER BY total DESC, c.name ASC
         LIMIT ${Math.min(20, categoriesCfg.limit || 8)}`
      ).then(([rows]) => rows || []),
      Promotion.findActiveNow(),
    ]);

    const qtySoldMap = {};
    bestSellerRank.forEach((r) => { qtySoldMap[r.product_id] = r.qty_sold; });

    let bestSellerProducts = [];
    if (bestSellerRank.length) {
      const ids = bestSellerRank.map((r) => r.product_id);
      bestSellerProducts = await Product.findByIdsPreservingOrder(ids);
    }
    if (bestSellerProducts.length < (bestsellersCfg.limit || 8)) {
      const fallback = recentRows.filter((p) => !bestSellerProducts.some((b) => b.id === p.id));
      bestSellerProducts = bestSellerProducts.concat(fallback).slice(0, bestsellersCfg.limit || 12);
    }

    let flashPromoRows = promoRows;
    if (flashCfg.promotionId) {
      flashPromoRows = await promotionService.findActivePromoProductRows(flashCfg.limit || 4, flashCfg.promotionId);
    }

    const emPromocao = await enrichProductCards(promoRows);
    const maisVendidos = await enrichProductCards(bestSellerProducts, qtySoldMap);
    const novidades = await enrichProductCards(recentRows);
    const ofertas = await enrichProductCards(flashPromoRows.slice(0, flashCfg.limit || 8));
    const featuredPromo = emPromocao[0] || maisVendidos[0] || novidades[0] || null;
    const hero = featuredPromo || maisVendidos[0] || null;
    const heroMini = maisVendidos.slice(1, 3).length
      ? maisVendidos.slice(1, 3)
      : novidades.slice(0, 2);
    const labLimit = (homeCfg.labHighlights || {}).limit || 6;
    let labHighlights = await fetchLabHighlightsForHome(labLimit);
    if (!labHighlights.length) {
      labHighlights = buildLabHighlights(maisVendidos.concat(emPromocao));
    }
    const flashOfferEnd = (await promotionService.resolveFlashEndDate(homeCfg, activePromotions))
      || getFlashOfferEndLabel();
    const topDiscount = emPromocao.reduce((best, p) => (
      !best || (p.discount_percent || 0) > (best.discount_percent || 0) ? p : best
    ), null);

    const promoStylesMap = {};
    activePromotions.forEach((p) => { promoStylesMap[p.id] = p.style; });

    res.render('index', {
      title: 'NeoFarma — Farmácia Online',
      bodyClass: 'index-page storefront-home',
      activeNav: 'home',
      hero,
      heroMini,
      emPromocao,
      maisVendidos,
      novidades,
      ofertas,
      labHighlights,
      featuredPromo,
      categories: catsRows,
      flashOfferEnd,
      topDiscount,
      homeConfig: homeCfg,
      themeConfig: themeCfg,
      sectionStylesCss: buildHomeSectionStyles(homeCfg),
      activePromotions,
      promoStylesMap,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Página de detalhes do produto com galeria, estoque e relacionados.
 */
async function getProductDetail(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(404).render('404', { title: 'Produto não encontrado' });
    const product = await Product.findById(id);
    if (!product || product.status !== 'ACTIVE') return res.status(404).render('404', { title: 'Produto não encontrado' });

    const images = await ProductImage.findByProductId(id);
    const gallery = images.length ? images : [{ image_url: '/assets/img/product/product-1.webp' }];
    const mainImage = gallery[0].image_url;

    // Recomendação básica: outros ativos, excluindo o item atual.
    const related = (await Product.findAll({ status: 'ACTIVE' }))
      .filter((p) => p.id !== id)
      .slice(0, 4);
    const relatedIds = related.map((p) => p.id);
    const relatedImages = await ProductImage.findByProductIds(relatedIds);
    const relatedFirst = {};
    relatedImages.forEach((r) => {
      if (!relatedFirst[r.product_id]) relatedFirst[r.product_id] = r.image_url;
    });
    const relatedStockMap = await getValidStockMapByProductIds(relatedIds);
    const relatedCards = related.map((p) => normalizeCard(p, relatedFirst[p.id], relatedStockMap.get(Number(p.id)) || 0));

    const unit = Number(product.unit_price || 0);
    const promo = product.promotional_price != null ? Number(product.promotional_price) : null;
    const hasPromo = promo != null && promo > 0 && promo < unit;
    const availableStock = await getValidStockByProductId(id);
    let defaultShippingCep = '';
    if (req.session && req.session.userId) {
      const profile = await Customer.getProfileByUserId(req.session.userId);
      defaultShippingCep = formatZip(profile && (profile.zip_code || profile.cep));
    }

    res.render('product-detail-dynamic', {
      title: `${product.name} - NeoFarma`,
      bodyClass: 'product-details-page',
      activeNav: 'category',
      product: {
        ...product,
        has_promo: hasPromo,
        price_display: unit.toFixed(2).replace('.', ','),
        promo_display: hasPromo ? promo.toFixed(2).replace('.', ',') : null,
        available_stock: availableStock,
        can_buy: availableStock > 0,
      },
      mainImage,
      gallery: gallery.map((g) => ({
        image_url: g.image_url,
        thumb_url: withThumb(g.image_url),
      })),
      related: relatedCards,
      defaultShippingCep,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  home,
  listCatalog,
  listCategory,
  getProductDetail,
};
