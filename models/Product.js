const { pool } = require('../config/database');

/**
 * Converte nome em slug para URL do produto.
 */
function slugify(text) {
  return (text || '')
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Garante slug único para não repetir no banco.
 */
async function buildUniqueSlug(baseText, excludeId = null) {
  const base = slugify(baseText) || 'produto';
  let candidate = base;
  let attempt = 1;
  while (attempt <= 500) {
    let sql = 'SELECT id FROM products WHERE slug = ?';
    const params = [candidate];
    if (excludeId) {
      sql += ' AND id <> ?';
      params.push(excludeId);
    }
    sql += ' LIMIT 1';
    const [rows] = await pool.execute(sql, params);
    if (!rows.length) return candidate;
    attempt += 1;
    candidate = `${base}-${attempt}`;
  }
  return `${base}-${Date.now()}`;
}

/**
 * Tipos considerados medicamentos para exigência de EAN-13 (RF_B2).
 */
function productTypeRequiresEan(productType, prescriptionRequired = false) {
  if (prescriptionRequired) return true;
  const hay = `${productType?.slug || ''} ${productType?.name || ''}`.toLowerCase();
  return /medicament|homeopat|fitoterap|manipulad|medicin|controlad|cha-medicinal/.test(hay);
}

/**
 * Busca produto pelo SKU (opcionalmente ignorando um id na edição).
 */
async function findBySku(sku, excludeId = null) {
  const code = String(sku || '').trim();
  if (!code) return null;
  let sql = 'SELECT id, name, sku FROM products WHERE sku = ?';
  const params = [code];
  if (excludeId) {
    sql += ' AND id <> ?';
    params.push(excludeId);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

/**
 * Busca produto pelo EAN-13 (opcionalmente ignorando um id na edição).
 */
async function findByEan13(ean13, excludeId = null) {
  const code = String(ean13 || '').replace(/\D/g, '');
  if (!code) return null;
  let sql = 'SELECT id, name, ean13 FROM products WHERE ean13 = ?';
  const params = [code];
  if (excludeId) {
    sql += ' AND id <> ?';
    params.push(excludeId);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

/**
 * Busca produto pelo GTIN-14 (opcionalmente ignorando um id na edição).
 */
async function findByGtin14(gtin14, excludeId = null) {
  const code = String(gtin14 || '').replace(/\D/g, '');
  if (!code) return null;
  let sql = 'SELECT id, name, gtin14 FROM products WHERE gtin14 = ?';
  const params = [code];
  if (excludeId) {
    sql += ' AND id <> ?';
    params.push(excludeId);
  }
  sql += ' LIMIT 1';
  const [rows] = await pool.execute(sql, params);
  return rows[0] || null;
}

/**
 * Cria produto novo.
 */
async function create(data) {
  const slug = await buildUniqueSlug(data.slug || data.name);
  const [result] = await pool.execute(
    `INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, gtin14, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.lab_id || null,
      data.main_supplier_id || null,
      data.product_type_id || null,
      data.name,
      slug,
      data.sku || null,
      data.ean13 || null,
      data.gtin14 || null,
      data.description || null,
      data.composition || null,
      data.usage_info || null,
      data.prescription_required ? 1 : 0,
      data.unit_price,
      data.promotional_price || null,
      data.status || 'ACTIVE',
    ]
  );
  return result.insertId;
}

/**
 * Busca produto por id com nome do laboratório e fornecedor.
 */
async function findById(id) {
  const [rows] = await pool.execute(
    `SELECT p.*, l.name AS lab_name, s.corporate_name AS supplier_name
     FROM products p
     LEFT JOIN labs l ON p.lab_id = l.id
     LEFT JOIN suppliers s ON p.main_supplier_id = s.id
     WHERE p.id = ?`,
    [id]
  );
  return rows[0] || null;
}

/**
 * Lista produtos com filtros simples (status e busca).
 */
async function findAll(filters = {}) {
  let sql = `SELECT p.*, l.name AS lab_name FROM products p LEFT JOIN labs l ON p.lab_id = l.id WHERE 1=1`;
  const params = [];
  if (filters.status) {
    sql += ' AND p.status = ?';
    params.push(filters.status);
  }
  if (filters.search) {
    sql += ' AND (p.name LIKE ? OR p.sku LIKE ?)';
    const term = `%${filters.search}%`;
    params.push(term, term);
  }
  sql += ' ORDER BY p.name';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Busca vários produtos de uma vez pelo array de ids.
 */
async function findByIds(ids = [], filters = {}) {
  if (!Array.isArray(ids) || ids.length === 0) return [];
  const placeholders = ids.map(() => '?').join(', ');
  let sql = `SELECT p.*, l.name AS lab_name
             FROM products p
             LEFT JOIN labs l ON p.lab_id = l.id
             WHERE p.id IN (${placeholders})`;
  const params = [...ids];
  if (filters.status) {
    sql += ' AND p.status = ?';
    params.push(filters.status);
  }
  sql += ' ORDER BY p.name';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Atualiza produto e, se necessário, recalcula slug único.
 */
async function updateById(id, data) {
  const localData = { ...data };
  if (localData.slug !== undefined || localData.name !== undefined) {
    localData.slug = await buildUniqueSlug(localData.slug || localData.name, id);
  }
  const fields = [];
  const values = [];
  const allowed = ['lab_id', 'main_supplier_id', 'product_type_id', 'name', 'slug', 'sku', 'ean13', 'gtin14', 'description', 'composition', 'usage_info', 'prescription_required', 'unit_price', 'promotional_price', 'status'];
  allowed.forEach((key) => {
    if (localData[key] !== undefined) {
      fields.push(`${key} = ?`);
      values.push(key === 'prescription_required' ? (localData[key] ? 1 : 0) : localData[key]);
    }
  });
  if (fields.length === 0) return 0;
  values.push(id);
  const [result] = await pool.execute(`UPDATE products SET ${fields.join(', ')} WHERE id = ?`, values);
  return result.affectedRows;
}

/**
 * Produtos em promoção ativa (preço promocional menor que unitário).
 */
async function findOnPromotion(limit = 12) {
  const lim = Math.min(50, Math.max(1, parseInt(limit, 10) || 12));
  const [rows] = await pool.execute(
    `SELECT p.*, l.name AS lab_name
     FROM products p
     LEFT JOIN labs l ON l.id = p.lab_id
     WHERE p.status = 'ACTIVE'
       AND p.promotional_price IS NOT NULL
       AND p.promotional_price > 0
       AND p.promotional_price < p.unit_price
     ORDER BY (p.unit_price - p.promotional_price) / p.unit_price DESC, p.name ASC
     LIMIT ${lim}`
  );
  return rows;
}

/**
 * Produtos mais recentes do catálogo ativo.
 */
async function findRecent(limit = 12) {
  const lim = Math.min(50, Math.max(1, parseInt(limit, 10) || 12));
  const [rows] = await pool.execute(
    `SELECT p.*, l.name AS lab_name
     FROM products p
     LEFT JOIN labs l ON l.id = p.lab_id
     WHERE p.status = 'ACTIVE'
     ORDER BY p.created_at DESC, p.id DESC
     LIMIT ${lim}`
  );
  return rows;
}

/**
 * Ranking de vendas por quantidade em pedidos pagos.
 * @returns {Promise<Array<{ product_id: number, qty_sold: number }>>}
 */
async function findBestSellerIds(limit = 12, days = 90) {
  const lim = Math.min(50, Math.max(1, parseInt(limit, 10) || 12));
  const d = Math.min(365, Math.max(7, parseInt(days, 10) || 90));
  const [rows] = await pool.execute(
    `SELECT oi.product_id, SUM(oi.quantity) AS qty_sold
     FROM order_items oi
     INNER JOIN orders o ON o.id = oi.order_id
     INNER JOIN products p ON p.id = oi.product_id AND p.status = 'ACTIVE'
     WHERE o.payment_status = 'PAID'
       AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
     GROUP BY oi.product_id
     ORDER BY qty_sold DESC
     LIMIT ${lim}`,
    [d]
  );
  return (rows || []).map((r) => ({
    product_id: Number(r.product_id),
    qty_sold: Number(r.qty_sold || 0),
  }));
}

/**
 * Busca produtos ativos preservando a ordem dos ids informados.
 */
async function findByIdsPreservingOrder(ids = []) {
  if (!Array.isArray(ids) || ids.length === 0) return [];
  const rows = await findByIds(ids, { status: 'ACTIVE' });
  const byId = new Map(rows.map((r) => [Number(r.id), r]));
  return ids.map((id) => byId.get(Number(id))).filter(Boolean);
}

/**
 * Verifica vínculos que impedem ou alertam sobre a exclusão do produto.
 */
async function getDeletionBlockers(id) {
  const productId = Number(id);
  if (!Number.isFinite(productId) || productId <= 0) {
    return { exists: false, product: null, blockers: [], warnings: [], canDelete: false };
  }

  const product = await findById(productId);
  if (!product) {
    return { exists: false, product: null, blockers: [], warnings: [], canDelete: false };
  }

  const [
    [orderItemsRow],
    [pendingRow],
    [purchaseRow],
    [disposalsRow],
    [prescriptionsRow],
    [batchesRow],
    [imagesRow],
  ] = await Promise.all([
    pool.execute(
      `SELECT COUNT(*) AS items, COUNT(DISTINCT order_id) AS refs
       FROM order_items WHERE product_id = ?`,
      [productId]
    ),
    pool.execute('SELECT COUNT(*) AS c FROM order_pending_items WHERE product_id = ?', [productId]),
    pool.execute(
      `SELECT COUNT(*) AS items, COUNT(DISTINCT purchase_order_id) AS refs
       FROM purchase_order_items WHERE product_id = ?`,
      [productId]
    ),
    pool.execute('SELECT COUNT(*) AS c FROM inventory_disposals WHERE product_id = ?', [productId]),
    pool.execute('SELECT COUNT(*) AS c FROM prescription_items WHERE product_id = ?', [productId]),
    pool.execute(
      `SELECT COUNT(*) AS lots, COALESCE(SUM(quantity), 0) AS qty
       FROM inventory_batches WHERE product_id = ?`,
      [productId]
    ),
    pool.execute('SELECT COUNT(*) AS c FROM product_images WHERE product_id = ?', [productId]),
  ]);

  const blockers = [];
  const warnings = [];

  const salesItems = Number(orderItemsRow[0]?.items || 0);
  const salesOrders = Number(orderItemsRow[0]?.refs || 0);
  if (salesItems > 0) {
    blockers.push({
      code: 'sales_orders',
      title: 'Pedidos de venda',
      count: salesItems,
      refs: salesOrders,
      description: 'O produto consta em pedidos de clientes já registrados no sistema.',
      detail: salesOrders === 1
        ? '1 pedido de venda contém este produto.'
        : `${salesOrders} pedidos de venda contêm este produto (${salesItems} item(ns)).`,
    });
  }

  const pendingItems = Number(pendingRow[0]?.c || 0);
  if (pendingItems > 0) {
    blockers.push({
      code: 'pending_orders',
      title: 'Itens pendentes em pedidos',
      count: pendingItems,
      description: 'Há itens aguardando separação ou reposição de estoque em pedidos abertos.',
      detail: pendingItems === 1
        ? '1 item pendente vinculado a este produto.'
        : `${pendingItems} itens pendentes vinculados a este produto.`,
    });
  }

  const purchaseItems = Number(purchaseRow[0]?.items || 0);
  const purchaseOrders = Number(purchaseRow[0]?.refs || 0);
  if (purchaseItems > 0) {
    blockers.push({
      code: 'purchase_orders',
      title: 'Pedidos de compra',
      count: purchaseItems,
      refs: purchaseOrders,
      description: 'O produto foi incluído em ordens de compra com fornecedores.',
      detail: purchaseOrders === 1
        ? '1 pedido de compra referencia este produto.'
        : `${purchaseOrders} pedidos de compra referenciam este produto (${purchaseItems} linha(s)).`,
    });
  }

  const disposals = Number(disposalsRow[0]?.c || 0);
  if (disposals > 0) {
    blockers.push({
      code: 'inventory_disposals',
      title: 'Histórico de descartes',
      count: disposals,
      description: 'Existem registros de descarte de estoque vinculados a este produto.',
      detail: disposals === 1
        ? '1 descarte registrado no histórico.'
        : `${disposals} descartes registrados no histórico.`,
    });
  }

  const prescriptions = Number(prescriptionsRow[0]?.c || 0);
  if (prescriptions > 0) {
    blockers.push({
      code: 'prescriptions',
      title: 'Receitas médicas',
      count: prescriptions,
      description: 'O produto está associado a receitas cadastradas no sistema.',
      detail: prescriptions === 1
        ? '1 receita referencia este produto.'
        : `${prescriptions} receitas referenciam este produto.`,
    });
  }

  const batchLots = Number(batchesRow[0]?.lots || 0);
  const batchQty = Number(batchesRow[0]?.qty || 0);
  if (batchLots > 0) {
    warnings.push({
      code: 'inventory_batches',
      title: 'Lotes de estoque',
      count: batchLots,
      refs: batchQty,
      description: batchQty > 0
        ? 'Os lotes e saldos em estoque serão removidos junto com o produto.'
        : 'Os lotes cadastrados serão removidos junto com o produto.',
      detail: batchQty > 0
        ? `${batchLots} lote(s) com ${batchQty} unidade(s) em estoque.`
        : `${batchLots} lote(s) sem saldo.`,
    });
  }

  const images = Number(imagesRow[0]?.c || 0);
  if (images > 0) {
    warnings.push({
      code: 'product_images',
      title: 'Imagens do catálogo',
      count: images,
      description: 'As imagens vinculadas serão excluídas permanentemente.',
      detail: images === 1 ? '1 imagem será removida.' : `${images} imagens serão removidas.`,
    });
  }

  try {
    const [promoRow] = await pool.execute(
      'SELECT COUNT(DISTINCT promotion_id) AS c FROM promotion_products WHERE product_id = ?',
      [productId]
    );
    const promos = Number(promoRow[0]?.c || 0);
    if (promos > 0) {
      warnings.push({
        code: 'promotions',
        title: 'Promoções',
        count: promos,
        description: 'O produto será retirado das campanhas promocionais vinculadas.',
        detail: promos === 1 ? '1 promoção ativa ou cadastrada.' : `${promos} promoções vinculadas.`,
      });
    }
  } catch (_) {
    // Tabela opcional em ambientes sem módulo de promoções inicializado.
  }

  return {
    exists: true,
    product: {
      id: product.id,
      name: product.name,
      sku: product.sku || null,
      status: product.status || null,
    },
    blockers,
    warnings,
    canDelete: blockers.length === 0,
    recommendations: blockers.length
      ? [
          'Altere o status do produto para Inativo ou Descontinuado para retirá-lo da vitrine sem perder o histórico.',
          'Registros de vendas, compras, descartes e receitas são mantidos por exigência de auditoria e rastreabilidade.',
        ]
      : [
          'Esta ação é permanente e não pode ser desfeita.',
          batchQty > 0
            ? 'Todo o estoque em lotes será removido junto com o produto.'
            : 'Dados auxiliares (imagens, lotes vazios, categorias) serão removidos automaticamente.',
        ],
  };
}

/**
 * Exclui produto pelo id.
 */
async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM products WHERE id = ?', [id]);
  return result.affectedRows;
}

/**
 * Produtos com ao menos um lote com saldo > 0 (inclui vencidos e catálogo inativo/descontinuado).
 * Usado em RF_F5 — descarte não depende do produto estar ACTIVE na vitrine.
 */
async function findForDisposal() {
  const [rows] = await pool.execute(
    `SELECT p.id, p.name, p.sku, p.status
     FROM products p
     WHERE EXISTS (
       SELECT 1 FROM inventory_batches b
       WHERE b.product_id = p.id AND b.quantity > 0
     )
     ORDER BY p.name ASC`
  );
  return rows;
}

module.exports = {
  create,
  findById,
  findAll,
  findByIds,
  findByIdsPreservingOrder,
  findOnPromotion,
  findRecent,
  findBestSellerIds,
  findForDisposal,
  findBySku,
  findByEan13,
  findByGtin14,
  productTypeRequiresEan,
  getDeletionBlockers,
  updateById,
  deleteById,
  slugify,
};
