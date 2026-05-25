const { pool } = require('../config/database');
const { slugify } = require('../util/slug');
const { DEFAULT_PROMO_STYLE } = require('../utils/storefrontDefaults');

let tablesReady = false;

async function ensureTables() {
  if (tablesReady) return;
  await pool.execute(`
    CREATE TABLE IF NOT EXISTS promotions (
      id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      name            VARCHAR(120) NOT NULL,
      slug            VARCHAR(140) NOT NULL UNIQUE,
      description     TEXT NULL,
      discount_type   ENUM('PERCENT','FIXED_PRICE') NOT NULL DEFAULT 'PERCENT',
      discount_value  DECIMAL(10,2) NOT NULL DEFAULT 0,
      starts_at       DATETIME NOT NULL,
      ends_at         DATETIME NOT NULL,
      is_active       TINYINT(1) NOT NULL DEFAULT 1,
      priority        INT NOT NULL DEFAULT 0,
      style_json      JSON NULL,
      created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_promotions_window (is_active, starts_at, ends_at),
      INDEX idx_promotions_priority (priority DESC)
    ) ENGINE=InnoDB
  `);
  await pool.execute(`
    CREATE TABLE IF NOT EXISTS promotion_products (
      promotion_id      BIGINT UNSIGNED NOT NULL,
      product_id        BIGINT UNSIGNED NOT NULL,
      fixed_promo_price DECIMAL(10,2) NULL,
      PRIMARY KEY (promotion_id, product_id),
      CONSTRAINT fk_pp_promotion FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
      CONSTRAINT fk_pp_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
    ) ENGINE=InnoDB
  `);
  tablesReady = true;
}

function parseStyle(row) {
  if (!row || !row.style_json) return { ...DEFAULT_PROMO_STYLE };
  try {
    const raw = typeof row.style_json === 'string' ? JSON.parse(row.style_json) : row.style_json;
    return { ...DEFAULT_PROMO_STYLE, ...(raw || {}) };
  } catch (_) {
    return { ...DEFAULT_PROMO_STYLE };
  }
}

function mapRow(row) {
  if (!row) return null;
  return {
    ...row,
    is_active: !!row.is_active,
    style: parseStyle(row),
  };
}

async function findAll() {
  await ensureTables();
  const [rows] = await pool.execute(
    `SELECT p.*,
            (SELECT COUNT(*) FROM promotion_products pp WHERE pp.promotion_id = p.id) AS products_count
     FROM promotions p
     ORDER BY p.priority DESC, p.starts_at DESC, p.id DESC`
  );
  return (rows || []).map(mapRow);
}

async function findById(id) {
  await ensureTables();
  const [rows] = await pool.execute('SELECT * FROM promotions WHERE id = ? LIMIT 1', [id]);
  return mapRow(rows[0]);
}

async function findActiveNow() {
  await ensureTables();
  const [rows] = await pool.execute(
    `SELECT * FROM promotions
     WHERE is_active = 1
       AND starts_at <= NOW()
       AND ends_at >= NOW()
     ORDER BY priority DESC, id DESC`
  );
  return (rows || []).map(mapRow);
}

async function findProductIds(promotionId) {
  await ensureTables();
  const [rows] = await pool.execute(
    'SELECT product_id, fixed_promo_price FROM promotion_products WHERE promotion_id = ?',
    [promotionId]
  );
  return rows || [];
}

async function listProductsForPromotion(promotionId) {
  await ensureTables();
  const [rows] = await pool.execute(
    `SELECT p.id, p.name, p.sku, p.unit_price, p.promotional_price, pp.fixed_promo_price
     FROM promotion_products pp
     INNER JOIN products p ON p.id = pp.product_id
     WHERE pp.promotion_id = ?
     ORDER BY p.name ASC`,
    [promotionId]
  );
  return rows || [];
}

async function getActiveForProduct(productId) {
  await ensureTables();
  const [rows] = await pool.execute(
    `SELECT pr.*, pp.fixed_promo_price
     FROM promotion_products pp
     INNER JOIN promotions pr ON pr.id = pp.promotion_id
     WHERE pp.product_id = ?
       AND pr.is_active = 1
       AND pr.starts_at <= NOW()
       AND pr.ends_at >= NOW()
     ORDER BY pr.priority DESC, pr.id DESC
     LIMIT 1`,
    [productId]
  );
  const row = rows[0];
  if (!row) return null;
  return { ...mapRow(row), fixed_promo_price: row.fixed_promo_price };
}

async function getProductsByPromotionId(promotionId, limit = 50) {
  await ensureTables();
  if (!promotionId) return [];
  const lim = Math.min(100, Math.max(1, parseInt(limit, 10) || 50));
  const [rows] = await pool.execute(
    `SELECT p.*, l.name AS lab_name
     FROM promotion_products pp
     INNER JOIN products p ON p.id = pp.product_id
     LEFT JOIN labs l ON l.id = p.lab_id
     WHERE pp.promotion_id = ? AND p.status = 'ACTIVE'
     ORDER BY p.name ASC
     LIMIT ${lim}`,
    [promotionId]
  );
  return rows || [];
}

async function buildUniqueSlug(name, excludeId = null) {
  let base = slugify(name) || 'promocao';
  let candidate = base;
  for (let i = 0; i < 200; i += 1) {
    let sql = 'SELECT id FROM promotions WHERE slug = ?';
    const params = [candidate];
    if (excludeId) {
      sql += ' AND id <> ?';
      params.push(excludeId);
    }
    sql += ' LIMIT 1';
    const [rows] = await pool.execute(sql, params);
    if (!rows.length) return candidate;
    candidate = `${base}-${i + 2}`;
  }
  return `${base}-${Date.now()}`;
}

async function create(data) {
  await ensureTables();
  const slug = data.slug || await buildUniqueSlug(data.name);
  const styleJson = JSON.stringify(data.style || DEFAULT_PROMO_STYLE);
  const [result] = await pool.execute(
    `INSERT INTO promotions (name, slug, description, discount_type, discount_value, starts_at, ends_at, is_active, priority, style_json)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.name,
      slug,
      data.description || null,
      data.discount_type || 'PERCENT',
      data.discount_value,
      data.starts_at,
      data.ends_at,
      data.is_active ? 1 : 0,
      data.priority || 0,
      styleJson,
    ]
  );
  return result.insertId;
}

async function updateById(id, data) {
  await ensureTables();
  const slug = data.slug || (data.name ? await buildUniqueSlug(data.name, id) : undefined);
  const fields = [];
  const values = [];
  const allowed = {
    name: 'name',
    slug: 'slug',
    description: 'description',
    discount_type: 'discount_type',
    discount_value: 'discount_value',
    starts_at: 'starts_at',
    ends_at: 'ends_at',
    is_active: 'is_active',
    priority: 'priority',
  };
  Object.keys(allowed).forEach((key) => {
    if (data[key] !== undefined) {
      fields.push(`${allowed[key]} = ?`);
      values.push(key === 'is_active' ? (data[key] ? 1 : 0) : data[key]);
    }
  });
  if (slug !== undefined) {
    if (!fields.some((f) => f.startsWith('slug'))) {
      fields.push('slug = ?');
      values.push(slug);
    }
  }
  if (data.style !== undefined) {
    fields.push('style_json = ?');
    values.push(JSON.stringify(data.style));
  }
  if (!fields.length) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE promotions SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

async function replaceProducts(promotionId, items = []) {
  await ensureTables();
  await pool.execute('DELETE FROM promotion_products WHERE promotion_id = ?', [promotionId]);
  if (!items.length) return;
  const placeholders = items.map(() => '(?, ?, ?)').join(', ');
  const params = [];
  items.forEach((item) => {
    params.push(promotionId, item.product_id, item.fixed_promo_price ?? null);
  });
  await pool.execute(
    `INSERT INTO promotion_products (promotion_id, product_id, fixed_promo_price) VALUES ${placeholders}`,
    params
  );
}

async function deleteById(id) {
  await ensureTables();
  const [result] = await pool.execute('DELETE FROM promotions WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  ensureTables,
  findAll,
  findById,
  findActiveNow,
  findProductIds,
  listProductsForPromotion,
  getActiveForProduct,
  getProductsByPromotionId,
  create,
  updateById,
  replaceProducts,
  deleteById,
};
