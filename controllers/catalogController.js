const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const Customer = require('../models/Customer');
const { getValidStockMapByProductIds, getValidStockByProductId } = require('../services/inventoryService');
const { pool } = require('../config/database');

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
function normalizeCard(product, imageUrl, stock = 0) {
  const unit = Number(product.unit_price || 0);
  const promo = product.promotional_price != null ? Number(product.promotional_price) : null;
  const hasPromo = promo != null && promo > 0 && promo < unit;
  return {
    ...product,
    image_url: imageUrl || '/assets/img/product/product-1.webp',
    thumb_url: withThumb(imageUrl) || '/assets/img/product/product-1.webp',
    price_display: unit.toFixed(2).replace('.', ','),
    promo_display: hasPromo ? promo.toFixed(2).replace('.', ',') : null,
    has_promo: hasPromo,
    available_stock: Number(stock || 0),
    can_buy: Number(stock || 0) > 0,
  };
}

/**
 * Monta vitrine de laboratórios para blocos de destaque da home.
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
    .slice(0, 4);
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

    // Ordenação controlada por whitelist para evitar SQL injection em ORDER BY.
    let orderBy = 'p.created_at DESC, p.id DESC';
    if (sort === 'price_asc') orderBy = 'COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) ASC, p.name ASC';
    if (sort === 'price_desc') orderBy = 'COALESCE(NULLIF(p.promotional_price, 0), p.unit_price) DESC, p.name ASC';
    if (sort === 'name_asc') orderBy = 'p.name ASC';
    if (sort === 'name_desc') orderBy = 'p.name DESC';

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
      `SELECT DISTINCT p.*, l.name AS lab_name
       FROM products p
       LEFT JOIN labs l ON l.id = p.lab_id
       LEFT JOIN product_categories pc ON pc.product_id = p.id
       ${whereSql}
       ORDER BY ${orderBy}
       LIMIT ${pageSize} OFFSET ${safeOffset}`,
      params
    );

    // Enriquecimento da vitrine: imagem principal + estoque válido agregado.
    const ids = rows.map((p) => p.id);
    const imageRows = await ProductImage.findByProductIds(ids);
    const firstImageByProduct = {};
    imageRows.forEach((row) => {
      if (!firstImageByProduct[row.product_id]) firstImageByProduct[row.product_id] = row.image_url;
    });
    const stockMap = await getValidStockMapByProductIds(ids);
    const products = rows.map((p) => normalizeCard(p, firstImageByProduct[p.id], stockMap.get(Number(p.id)) || 0));

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

    res.render('category', {
      title: 'Categoria - NeoFarma',
      bodyClass: 'category-page',
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
      },
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
    const allActive = await Product.findAll({ status: 'ACTIVE' });
    const ids = allActive.map((p) => p.id);
    const imageRows = await ProductImage.findByProductIds(ids);
    const firstImageByProduct = {};
    imageRows.forEach((row) => {
      if (!firstImageByProduct[row.product_id]) firstImageByProduct[row.product_id] = row.image_url;
    });
    const stockMap = await getValidStockMapByProductIds(ids);
    const normalized = allActive.map((p) => normalizeCard(p, firstImageByProduct[p.id], stockMap.get(Number(p.id)) || 0));

    // Regras simples de composição dos blocos da home.
    const emPromocao = normalized.filter((p) => p.has_promo).slice(0, 8);
    const maisVendidos = normalized.slice(0, 4);
    const populares = normalized.slice(4, 7);
    const novidades = normalized.slice(7, 10);
    const ofertas = normalized.filter((p) => p.has_promo).slice(0, 4);
    const hero = normalized[0] || null;
    const heroMini = normalized.slice(1, 3);
    const labHighlights = buildLabHighlights(normalized);
    const featuredPromo = emPromocao[0] || normalized[0] || null;

    res.render('index', {
      title: 'Neofarma Home',
      bodyClass: 'index-page',
      activeNav: 'home',
      hero,
      heroMini,
      emPromocao,
      maisVendidos,
      populares,
      novidades,
      ofertas,
      labHighlights,
      featuredPromo,
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
