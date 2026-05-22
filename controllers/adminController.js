const Lab = require('../models/Lab');
const Supplier = require('../models/Supplier');
const Category = require('../models/Category');
const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const InventoryBatch = require('../models/InventoryBatch');
const Address = require('../models/Address');
const { isValidCNPJ, stripCNPJ } = require('../util/cnpj');
const { pool } = require('../config/database');
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

/**
 * Gera um nome de arquivo "limpo" para salvar imagens.
 */
function slugifyFilename(text) {
  return String(text || 'produto')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 50) || 'produto';
}

/**
 * Dashboard com alertas operacionais de validade de lote.
 */
async function dashboard(req, res, next) {
  try {
    const validityCounts = await InventoryBatch.getDashboardValidityCounts(30);
    let appointmentCounts = { total: 0, pendingCash: 0 };
    try {
      const [rows] = await pool.execute(
        `SELECT
           COUNT(*) AS total,
           SUM(CASE WHEN payment_method = 'CASH' AND payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_cash
         FROM service_appointments`
      );
      appointmentCounts = {
        total: Number(rows && rows[0] && rows[0].total ? rows[0].total : 0),
        pendingCash: Number(rows && rows[0] && rows[0].pending_cash ? rows[0].pending_cash : 0),
      };
    } catch (_) {
      appointmentCounts = { total: 0, pendingCash: 0 };
    }
    res.render('admin/dashboard', {
      title: 'Painel Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'dashboard',
      validityCounts: {
        expired: Number(validityCounts.expired_count || 0),
        expiring: Number(validityCounts.expiring_count || 0),
      },
      appointmentCounts,
    });
  } catch (err) {
    next(err);
  }
}

// ---- Laboratórios ----
/**
 * Lista laboratórios na tela administrativa.
 */
async function listLabs(req, res, next) {
  try {
    const list = await Lab.findAllWithAddress();
    res.render('admin/laboratorios', { title: 'Laboratórios - Admin', bodyClass: 'admin-page', activeAdmin: 'laboratorios', list });
  } catch (err) {
    next(err);
  }
}

/**
 * Cria ou atualiza laboratório (mesma função para os dois casos).
 */
async function saveLab(req, res, next) {
  try {
    const data = req.body || {};
    if (!data.name || !data.name.trim()) {
      return res.status(400).json({ ok: false, message: 'Nome é obrigatório.' });
    }
    const cnpjRaw = data.cnpj ? stripCNPJ(String(data.cnpj)) : '';
    if (cnpjRaw && cnpjRaw.length === 14 && !isValidCNPJ(cnpjRaw)) {
      return res.status(400).json({ ok: false, message: 'CNPJ inválido. Verifique os dois últimos dígitos (após o hífen) — eles são os dígitos verificadores.' });
    }
    const cnpjVal = cnpjRaw.length === 14 ? cnpjRaw : null;

    let addressId = null;
    const hasAddress = [data.street, data.number, data.city, data.state, data.zip_code].some(v => v && String(v).trim());
    if (hasAddress) {
      const addr = {
        street: (data.street && data.street.trim()) || '',
        number: (data.number && data.number.trim()) || '',
        complement: (data.complement && data.complement.trim()) || null,
        district: (data.district && data.district.trim()) || null,
        city: (data.city && data.city.trim()) || '',
        state: (data.state && data.state.trim()) || '',
        zip_code: (data.zip_code && data.zip_code.trim()) || '',
      };
      if (data.id && data.address_id) {
        await Address.updateById(parseInt(data.address_id, 10), addr);
        addressId = parseInt(data.address_id, 10);
      } else {
        addressId = await Address.create(addr);
      }
    } else {
      addressId = null;
    }

    const payload = {
      name: data.name.trim(),
      cnpj: cnpjVal,
      email: (data.email && data.email.trim()) || null,
      phone: (data.phone && data.phone.trim()) || null,
      address_id: addressId,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (data.id) {
      await Lab.updateById(parseInt(data.id, 10), payload);
      return res.json({ ok: true, message: 'Laboratório atualizado.' });
    }
    const id = await Lab.create(payload);
    res.status(201).json({ ok: true, message: 'Laboratório cadastrado.', id });
  } catch (err) {
    next(err);
  }
}

/**
 * Remove laboratório pelo id.
 */
async function deleteLab(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const n = await Lab.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Não encontrado.' });
    res.json({ ok: true, message: 'Laboratório removido.' });
  } catch (err) {
    next(err);
  }
}

// ---- Fornecedores ----
/**
 * Lista fornecedores no painel admin.
 */
async function listSuppliers(req, res, next) {
  try {
    const list = await Supplier.findAllWithAddress();
    res.render('admin/fornecedores', { title: 'Fornecedores - Admin', bodyClass: 'admin-page', activeAdmin: 'fornecedores', list });
  } catch (err) {
    next(err);
  }
}

/**
 * Cria ou atualiza fornecedor.
 */
async function saveSupplier(req, res, next) {
  try {
    const data = req.body || {};
    if (!data.corporate_name || !data.corporate_name.trim()) {
      return res.status(400).json({ ok: false, message: 'Razão social é obrigatória.' });
    }
    const cnpjRaw = data.cnpj ? stripCNPJ(String(data.cnpj)) : '';
    if (cnpjRaw && cnpjRaw.length === 14 && !isValidCNPJ(cnpjRaw)) {
      return res.status(400).json({ ok: false, message: 'CNPJ inválido. Verifique os dois últimos dígitos (após o hífen) — eles são os dígitos verificadores.' });
    }
    const cnpjVal = cnpjRaw.length === 14 ? cnpjRaw : null;

    let addressId = null;
    const hasAddress = [data.street, data.number, data.city, data.state, data.zip_code].some(v => v && String(v).trim());
    if (hasAddress) {
      const addr = {
        street: (data.street && data.street.trim()) || '',
        number: (data.number && data.number.trim()) || '',
        complement: (data.complement && data.complement.trim()) || null,
        district: (data.district && data.district.trim()) || null,
        city: (data.city && data.city.trim()) || '',
        state: (data.state && data.state.trim()) || '',
        zip_code: (data.zip_code && data.zip_code.trim()) || '',
      };
      if (data.id && data.address_id) {
        await Address.updateById(parseInt(data.address_id, 10), addr);
        addressId = parseInt(data.address_id, 10);
      } else {
        addressId = await Address.create(addr);
      }
    } else {
      addressId = null;
    }

    const payload = {
      corporate_name: data.corporate_name.trim(),
      trade_name: (data.trade_name && data.trade_name.trim()) || null,
      cnpj: cnpjVal,
      email: (data.email && data.email.trim()) || null,
      phone: (data.phone && data.phone.trim()) || null,
      address_id: addressId,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (data.id) {
      await Supplier.updateById(parseInt(data.id, 10), payload);
      return res.json({ ok: true, message: 'Fornecedor atualizado.' });
    }
    const id = await Supplier.create(payload);
    res.status(201).json({ ok: true, message: 'Fornecedor cadastrado.', id });
  } catch (err) {
    next(err);
  }
}

/**
 * Remove fornecedor pelo id.
 */
async function deleteSupplier(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const n = await Supplier.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Não encontrado.' });
    res.json({ ok: true, message: 'Fornecedor removido.' });
  } catch (err) {
    next(err);
  }
}

// ---- Categorias ----
/**
 * Lista categorias de produtos.
 */
async function listCategories(req, res, next) {
  try {
    const list = await Category.findAll();
    const parentNames = (list || []).reduce((acc, c) => { acc[c.id] = c.name; return acc; }, {});
    res.render('admin/categorias', { title: 'Categorias - Admin', bodyClass: 'admin-page', activeAdmin: 'categorias', list, parentNames });
  } catch (err) {
    next(err);
  }
}

/**
 * Cria ou atualiza categoria.
 */
async function saveCategory(req, res, next) {
  try {
    const data = req.body || {};
    if (!data.name || !data.name.trim()) {
      return res.status(400).json({ ok: false, message: 'Nome é obrigatório.' });
    }
    const payload = {
      name: data.name.trim(),
      slug: data.slug && data.slug.trim() ? data.slug.trim() : undefined,
      parent_id: data.parent_id ? parseInt(data.parent_id, 10) : null,
      description: data.description && data.description.trim() ? data.description.trim() : null,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };
    if (data.id) {
      const id = parseInt(data.id, 10);
      if (payload.parent_id === id) {
        return res.status(400).json({ ok: false, message: 'Categoria não pode ser pai de si mesma.' });
      }
      await Category.updateById(id, payload);
      return res.json({ ok: true, message: 'Categoria atualizada.' });
    }
    const id = await Category.create(payload);
    res.status(201).json({ ok: true, message: 'Categoria cadastrada.', id });
  } catch (err) {
    next(err);
  }
}

/**
 * Exclui categoria pelo id.
 */
async function deleteCategory(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const n = await Category.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Não encontrado.' });
    res.json({ ok: true, message: 'Categoria removida.' });
  } catch (err) {
    next(err);
  }
}

// ---- Produtos ----
/**
 * Lista produtos para gestão no admin.
 * Também traz indicadores de risco de lote (vencido/a vencer).
 */
async function listProducts(req, res, next) {
  try {
    const riskFilter = String(req.query.batchRisk || 'ALL').toUpperCase();
    const listBase = await Product.findAll();
    const ids = listBase.map((p) => Number(p.id));
    const riskRows = await InventoryBatch.getRiskByProductIds(ids, 30);
    const riskMap = new Map(riskRows.map((r) => [Number(r.product_id), {
      expired_batches: Number(r.expired_batches || 0),
      expiring_batches: Number(r.expiring_batches || 0),
    }]));
    // Cada produto usa a categoria principal (primeiro vínculo) para o form de edição.
    const [productCategoryRows] = await pool.execute(
      `SELECT pc.product_id, MIN(pc.category_id) AS category_id
       FROM product_categories pc
       GROUP BY pc.product_id`
    );
    const productCategoryMap = new Map(
      (productCategoryRows || []).map((r) => [Number(r.product_id), Number(r.category_id)])
    );
    let list = listBase.map((p) => ({
      ...p,
      category_id: productCategoryMap.get(Number(p.id)) || null,
      expired_batches: (riskMap.get(Number(p.id)) || {}).expired_batches || 0,
      expiring_batches: (riskMap.get(Number(p.id)) || {}).expiring_batches || 0,
    }));
    if (riskFilter === 'EXPIRED') {
      list = list.filter((p) => p.expired_batches > 0);
    } else if (riskFilter === 'EXPIRING') {
      list = list.filter((p) => p.expiring_batches > 0);
    }
    const labs = await Lab.findAll(true);
    const suppliers = await Supplier.findAll(true);
    const categories = await Category.findAll(true);
    res.render('admin/produtos', {
      title: 'Produtos - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'produtos',
      list,
      labs,
      suppliers,
      categories,
      riskFilter,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Cria ou atualiza produto e sincroniza categoria no vínculo N:N.
 */
async function saveProduct(req, res, next) {
  try {
    const data = req.body || {};
    if (!data.name || !data.name.trim()) {
      return res.status(400).json({ ok: false, message: 'Nome do produto é obrigatório.' });
    }
    const categoryId = data.category_id ? parseInt(data.category_id, 10) : NaN;
    if (!Number.isInteger(categoryId) || categoryId <= 0) {
      return res.status(400).json({ ok: false, message: 'Categoria é obrigatória.' });
    }
    // Categoria obrigatória para manter consistência do catálogo/filtros.
    const category = await Category.findById(categoryId);
    if (!category || !category.is_active) {
      return res.status(400).json({ ok: false, message: 'Categoria inválida ou inativa.' });
    }

    const num = (v) => (v === '' || v === undefined || v === null ? null : parseFloat(String(v).replace(',', '.')));
    const payload = {
      name: data.name.trim(),
      lab_id: data.lab_id ? parseInt(data.lab_id, 10) : null,
      main_supplier_id: data.main_supplier_id ? parseInt(data.main_supplier_id, 10) : null,
      sku: data.sku || null,
      ean13: data.ean13 || null,
      description: data.description || null,
      composition: data.composition || null,
      usage_info: data.usage_info || null,
      prescription_required: !!data.prescription_required,
      unit_price: num(data.unit_price) || 0,
      promotional_price: num(data.promotional_price),
      status: data.status || 'ACTIVE',
    };
    let productId;
    if (data.id) {
      productId = parseInt(data.id, 10);
      await Product.updateById(productId, payload);
    } else {
      productId = await Product.create(payload);
    }

    // Sincroniza relação N:N mantendo exatamente uma categoria selecionada no admin.
    await pool.execute('DELETE FROM product_categories WHERE product_id = ?', [productId]);
    await pool.execute(
      'INSERT INTO product_categories (product_id, category_id) VALUES (?, ?)',
      [productId, categoryId]
    );

    if (data.id) {
      return res.json({ ok: true, message: 'Produto atualizado.' });
    }
    return res.status(201).json({ ok: true, message: 'Produto cadastrado.', id: productId });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes("products.slug")) {
        return res.status(409).json({
          ok: false,
          message: 'Já existe um produto com slug parecido. Tente ajustar o nome do produto.',
        });
      }
      if (msg.includes("products.sku")) {
        return res.status(409).json({
          ok: false,
          message: 'SKU já cadastrado para outro produto.',
        });
      }
      if (msg.includes("products.ean13")) {
        return res.status(409).json({
          ok: false,
          message: 'EAN-13 já cadastrado para outro produto.',
        });
      }
      return res.status(409).json({
        ok: false,
        message: 'Já existe um produto com dados únicos iguais (slug/SKU/EAN).',
      });
    }
    next(err);
  }
}

/**
 * Remove produto pelo id.
 */
async function deleteProduct(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const n = await Product.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Não encontrado.' });
    res.json({ ok: true, message: 'Produto removido.' });
  } catch (err) {
    next(err);
  }
}

/**
 * Busca imagens cadastradas de um produto.
 */
async function getProductImages(req, res, next) {
  try {
    const productId = parseInt(req.params.id, 10);
    if (isNaN(productId)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ ok: false, message: 'Produto não encontrado.' });
    const images = await ProductImage.findByProductId(productId);
    res.json({ ok: true, data: images });
  } catch (err) {
    next(err);
  }
}

/**
 * Adiciona uma imagem ao produto via URL.
 */
async function addProductImage(req, res, next) {
  try {
    const productId = parseInt(req.params.id, 10);
    if (isNaN(productId)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ ok: false, message: 'Produto não encontrado.' });
    const imageUrl = (req.body && req.body.image_url) ? String(req.body.image_url).trim() : '';
    if (!imageUrl) return res.status(400).json({ ok: false, message: 'URL da imagem é obrigatória.' });
    const id = await ProductImage.add(productId, imageUrl);
    res.status(201).json({ ok: true, message: 'Imagem adicionada.', id });
  } catch (err) {
    next(err);
  }
}

/**
 * Faz upload da imagem do produto, gera versão principal e miniatura.
 */
async function uploadProductImage(req, res, next) {
  try {
    const productId = parseInt(req.params.id, 10);
    if (isNaN(productId)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ ok: false, message: 'Produto não encontrado.' });
    if (!req.file) return res.status(400).json({ ok: false, message: 'Nenhuma imagem enviada.' });

    const productDir = path.join(__dirname, '..', 'public', 'uploads', 'products', String(productId));
    fs.mkdirSync(productDir, { recursive: true });

    const productSlug = slugifyFilename(product.name);
    const baseName = `${productSlug}-${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const filename = `${baseName}.webp`;
    const thumbFilename = `${baseName}-thumb.webp`;
    const outputPath = path.join(productDir, filename);
    const thumbPath = path.join(productDir, thumbFilename);
    await sharp(req.file.buffer)
      .rotate()
      // Limita dimensões máximas para reduzir payload e custo de storage.
      .resize({ width: 2000, height: 2000, fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 82 })
      .toFile(outputPath);
    await sharp(req.file.buffer)
      .rotate()
      // Miniatura quadrada padronizada para listagens/cartões.
      .resize({ width: 480, height: 480, fit: 'cover' })
      .webp({ quality: 80 })
      .toFile(thumbPath);

    const imageUrl = `/uploads/products/${productId}/${filename}`;
    const thumbUrl = `/uploads/products/${productId}/${thumbFilename}`;
    const id = await ProductImage.add(productId, imageUrl);
    res.status(201).json({ ok: true, message: 'Imagem enviada com sucesso.', id, image_url: imageUrl, thumb_url: thumbUrl });
  } catch (err) {
    next(err);
  }
}

/**
 * Remove imagem do produto (arquivo físico + registro no banco).
 */
async function deleteProductImage(req, res, next) {
  try {
    const imageId = parseInt(req.params.id, 10);
    if (isNaN(imageId)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const image = await ProductImage.findById(imageId);
    if (!image) return res.status(404).json({ ok: false, message: 'Imagem não encontrada.' });

    // Remove arquivo físico apenas de uploads locais.
    if (image.image_url && image.image_url.startsWith('/uploads/products/')) {
      const relativePath = image.image_url.replace(/^\/+/, '').replace(/\//g, path.sep);
      const fullPath = path.join(__dirname, '..', 'public', relativePath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
      }
      const thumbFullPath = fullPath.replace(/\.webp$/i, '-thumb.webp');
      if (thumbFullPath !== fullPath && fs.existsSync(thumbFullPath)) {
        fs.unlinkSync(thumbFullPath);
      }
    }

    const n = await ProductImage.deleteById(imageId);
    if (!n) return res.status(404).json({ ok: false, message: 'Imagem não encontrada.' });
    res.json({ ok: true, message: 'Imagem removida.' });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  dashboard,
  listLabs,
  saveLab,
  deleteLab,
  listSuppliers,
  saveSupplier,
  deleteSupplier,
  listCategories,
  saveCategory,
  deleteCategory,
  listProducts,
  saveProduct,
  deleteProduct,
  getProductImages,
  addProductImage,
  uploadProductImage,
  deleteProductImage,
};
