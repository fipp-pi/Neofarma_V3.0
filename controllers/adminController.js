const Lab = require('../models/Lab');
const Supplier = require('../models/Supplier');
const Category = require('../models/Category');
const ProductType = require('../models/ProductType');
const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const InventoryBatch = require('../models/InventoryBatch');
const FinanceAdmin = require('../models/FinanceAdmin');
const Address = require('../models/Address');
const { isValidCNPJ, stripCNPJ } = require('../util/cnpj');
const { isValidEan13, isValidGtin14, stripGtin } = require('../util/ean13');
const { resolveSlug, validateSlug } = require('../util/slug');
const { pool } = require('../config/database');
const { formatDateLongBr } = require('../utils/dateFormat');
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
 * Formata valor monetário para exibição (pt-BR).
 */
function formatCurrencyBRL(value) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(value || 0));
}

/**
 * Dashboard com KPIs, alertas operacionais e atalhos.
 */
async function dashboard(req, res, next) {
  try {
    const [validityCounts, expiredAwaiting, financeSummary, entityRows, recentOrderRows, appointmentRows] = await Promise.all([
      InventoryBatch.getDashboardValidityCounts(30),
      InventoryBatch.countExpiredAwaitingDisposal(),
      FinanceAdmin.getFinanceSummary({ days: 30 }),
      pool.execute(
        `SELECT
          (SELECT COUNT(*) FROM products WHERE status = 'ACTIVE') AS products_active,
          (SELECT COUNT(*) FROM customers) AS customers_total,
          (SELECT COUNT(*) FROM service_appointments WHERE status NOT IN ('CANCELLED')) AS appointments_active`
      ).then(([rows]) => rows[0] || {}),
      pool.execute(
        `SELECT o.id, o.total, o.payment_status, o.status, o.created_at, u.full_name AS customer_name
         FROM orders o
         LEFT JOIN customers c ON c.id = o.customer_id
         LEFT JOIN users u ON u.id = c.user_id
         ORDER BY o.created_at DESC, o.id DESC
         LIMIT 5`
      ).then(([rows]) => rows || []),
      pool.execute(
        `SELECT
           COUNT(*) AS total,
           SUM(CASE WHEN payment_method = 'CASH' AND payment_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_cash
         FROM service_appointments`
      ).then(([rows]) => rows[0] || {}),
    ]);

    const appointmentCounts = {
      total: Number(appointmentRows.total || 0),
      pendingCash: Number(appointmentRows.pending_cash || 0),
    };

    const validity = {
      expired: Number(validityCounts.expired_count || 0),
      expiring: Number(validityCounts.expiring_count || 0),
      expiredAwaiting: Number(expiredAwaiting || 0),
    };

    const kpis = {
      revenuePaid: Number(financeSummary.revenue_paid || 0),
      revenuePaidFormatted: formatCurrencyBRL(financeSummary.revenue_paid),
      transactions30d: Number(financeSummary.total_transactions || 0),
      pendingPayments: Number(financeSummary.pending_count || 0),
      productsActive: Number(entityRows.products_active || 0),
      customersTotal: Number(entityRows.customers_total || 0),
      appointmentsActive: Number(entityRows.appointments_active || 0),
    };

    const alerts = [
      {
        key: 'expiredAwaiting',
        level: validity.expiredAwaiting > 0 ? 'danger' : 'ok',
        count: validity.expiredAwaiting,
        title: 'Aguardando descarte',
        text: validity.expiredAwaiting > 0
          ? `${validity.expiredAwaiting} lote(s) vencido(s) com saldo em estoque.`
          : 'Nenhum lote vencido pendente de baixa.',
        href: '/admin/descartes',
        icon: 'bi-trash3',
      },
      {
        key: 'expired',
        level: validity.expired > 0 ? 'danger' : 'ok',
        count: validity.expired,
        title: 'Lotes vencidos',
        text: validity.expired > 0 ? 'Lotes vencidos ainda com quantidade registrada.' : 'Sem lotes vencidos com saldo.',
        href: '/admin/lotes?status=EXPIRED',
        icon: 'bi-exclamation-triangle',
      },
      {
        key: 'expiring',
        level: validity.expiring > 0 ? 'warning' : 'ok',
        count: validity.expiring,
        title: 'Vencendo em 30 dias',
        text: validity.expiring > 0 ? 'Produtos com lotes próximos do vencimento.' : 'Nenhum lote crítico nos próximos 30 dias.',
        href: '/admin/produtos?batchRisk=EXPIRING',
        icon: 'bi-clock-history',
      },
      {
        key: 'pendingCash',
        level: appointmentCounts.pendingCash > 0 ? 'warning' : 'ok',
        count: appointmentCounts.pendingCash,
        title: 'Caixa pendente',
        text: appointmentCounts.pendingCash > 0
          ? 'Agendamentos com recebimento em dinheiro pendente.'
          : 'Caixa de serviços em dia.',
        href: '/admin/agendamentos-servicos/caixa',
        icon: 'bi-cash-coin',
      },
      {
        key: 'pendingPayments',
        level: kpis.pendingPayments > 0 ? 'info' : 'ok',
        count: kpis.pendingPayments,
        title: 'Pagamentos pendentes',
        text: kpis.pendingPayments > 0 ? 'Pedidos ou serviços aguardando confirmação.' : 'Sem pendências de pagamento.',
        href: '/admin/financas/pedidos',
        icon: 'bi-hourglass-split',
      },
    ];

    const recentOrders = (recentOrderRows || []).map((row) => ({
      id: row.id,
      customer_name: row.customer_name || 'Cliente',
      total: Number(row.total || 0),
      totalFormatted: formatCurrencyBRL(row.total),
      payment_status: row.payment_status || 'PENDING',
      status: row.status || '',
      created_at: row.created_at,
    }));

    const now = new Date();
    const greetingHour = now.getHours();
    let greeting = 'Bom dia';
    if (greetingHour >= 12 && greetingHour < 18) greeting = 'Boa tarde';
    else if (greetingHour >= 18) greeting = 'Boa noite';

    res.render('admin/dashboard', {
      title: 'Painel Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'dashboard',
      validityCounts: validity,
      appointmentCounts,
      kpis,
      alerts,
      recentOrders,
      greeting,
      todayFormatted: formatDateLongBr(now),
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
    const stats = (list || []).reduce((acc, item) => {
      acc.total += 1;
      if (item.is_active) acc.active += 1; else acc.inactive += 1;
      if (String(item.city || '').trim()) acc.withCity += 1;
      if (String(item.email || '').trim()) acc.withEmail += 1;
      return acc;
    }, { total: 0, active: 0, inactive: 0, withCity: 0, withEmail: 0 });
    res.render('admin/laboratorios', { title: 'Laboratórios - Admin', bodyClass: 'admin-page', activeAdmin: 'laboratorios', list, stats });
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
    const fields = {};
    const editId = data.id ? parseInt(data.id, 10) : null;

    const name = String(data.name || '').trim();
    if (!name) {
      fields.name = 'Informe o nome do laboratório.';
    } else if (name.length < 2) {
      fields.name = 'O nome deve ter pelo menos 2 caracteres.';
    }

    const cnpjRaw = data.cnpj ? stripCNPJ(String(data.cnpj)) : '';
    if (!cnpjRaw) {
      fields.cnpj = 'Informe o CNPJ do laboratório.';
    } else if (cnpjRaw.length !== 14) {
      fields.cnpj = 'O CNPJ deve conter 14 dígitos.';
    } else if (!isValidCNPJ(cnpjRaw)) {
      fields.cnpj = 'CNPJ inválido — verifique os dígitos verificadores.';
    }

    const email = String(data.email || '').trim();
    if (!email) {
      fields.email = 'Informe o e-mail de contato.';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      fields.email = 'Informe um e-mail válido.';
    }

    const phoneDisplay = String(data.phone || '').trim();
    const phoneDigits = phoneDisplay.replace(/\D/g, '');
    if (!phoneDisplay) {
      fields.phone = 'Informe o telefone de contato.';
    } else if (phoneDigits.length < 10) {
      fields.phone = 'Informe um telefone válido (mínimo 10 dígitos).';
    }

    const street = String(data.street || '').trim();
    const number = String(data.number || '').trim();
    const city = String(data.city || '').trim();
    const state = String(data.state || '').trim().toUpperCase();
    const zipRaw = String(data.zip_code || '').replace(/\D/g, '');
    const district = String(data.district || '').trim();
    const complement = String(data.complement || '').trim();
    const hasAddressPartial = [street, number, city, state, zipRaw, district, complement].some(Boolean);

    if (hasAddressPartial) {
      if (zipRaw.length !== 8) {
        fields.zip_code = 'Informe um CEP válido (8 dígitos).';
      }
      if (!street) {
        fields.street = 'Informe o logradouro.';
      }
      if (!number) {
        fields.number = 'Informe o número.';
      }
      if (!city) {
        fields.city = 'Informe a cidade.';
      }
      if (!state || state.length !== 2) {
        fields.state = 'Informe a UF com 2 letras.';
      }
    } else if (zipRaw.length > 0 && zipRaw.length !== 8) {
      fields.zip_code = 'Informe um CEP válido (8 dígitos).';
    }

    if (Object.keys(fields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields,
      });
    }

    const cnpjConflict = await Lab.findByCnpj(cnpjRaw, Number.isInteger(editId) && editId > 0 ? editId : null);
    if (cnpjConflict) {
      return res.status(409).json({
        ok: false,
        message: 'CNPJ já cadastrado para outro laboratório.',
        fields: { cnpj: 'Este CNPJ já está em uso.' },
      });
    }

    const cnpjVal = cnpjRaw;

    let addressId = null;
    if (hasAddressPartial) {
      const addr = {
        street,
        number,
        complement: complement || null,
        district: district || null,
        city,
        state,
        zip_code: zipRaw,
      };
      if (Number.isInteger(editId) && editId > 0 && data.address_id) {
        await Address.updateById(parseInt(data.address_id, 10), addr);
        addressId = parseInt(data.address_id, 10);
      } else {
        addressId = await Address.create(addr);
      }
    } else if (Number.isInteger(editId) && editId > 0 && data.address_id) {
      addressId = null;
    }

    const payload = {
      name,
      cnpj: cnpjVal,
      email: email || null,
      phone: phoneDisplay || null,
      address_id: addressId,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (Number.isInteger(editId) && editId > 0) {
      await Lab.updateById(editId, payload);
      return res.json({
        ok: true,
        message: `Laboratório "${name}" atualizado com sucesso.`,
        id: editId,
        name,
      });
    }
    const id = await Lab.create(payload);
    return res.status(201).json({
      ok: true,
      message: `Laboratório "${name}" cadastrado com sucesso.`,
      id,
      name,
    });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes('labs.cnpj')) {
        return res.status(409).json({
          ok: false,
          message: 'CNPJ já cadastrado para outro laboratório.',
          fields: { cnpj: 'Este CNPJ já está em uso.' },
        });
      }
    }
    next(err);
  }
}

/**
 * Remove laboratório pelo id.
 */
async function deleteLab(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const lab = await Lab.findById(id);
    if (!lab) return res.status(404).json({ ok: false, message: 'Laboratório não encontrado.' });
    const n = await Lab.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Laboratório não encontrado.' });
    res.json({ ok: true, message: `Laboratório "${lab.name}" removido com sucesso.` });
  } catch (err) {
    if (err && (err.code === 'ER_ROW_IS_REFERENCED_2' || err.code === 'ER_ROW_IS_REFERENCED')) {
      return res.status(409).json({
        ok: false,
        message: 'Não é possível excluir: existem produtos vinculados a este laboratório.',
      });
    }
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
    const stats = (list || []).reduce((acc, item) => {
      acc.total += 1;
      if (item.is_active) acc.active += 1; else acc.inactive += 1;
      if (String(item.trade_name || '').trim()) acc.withTrade += 1;
      if (String(item.city || '').trim()) acc.withCity += 1;
      return acc;
    }, { total: 0, active: 0, inactive: 0, withTrade: 0, withCity: 0 });
    res.render('admin/fornecedores', { title: 'Fornecedores - Admin', bodyClass: 'admin-page', activeAdmin: 'fornecedores', list, stats });
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
    const fields = {};
    const editId = data.id ? parseInt(data.id, 10) : null;

    const corporateName = String(data.corporate_name || '').trim();
    if (!corporateName) {
      fields.corporate_name = 'Informe a razão social do fornecedor.';
    } else if (corporateName.length < 2) {
      fields.corporate_name = 'A razão social deve ter pelo menos 2 caracteres.';
    }

    const tradeName = String(data.trade_name || '').trim();

    const cnpjRaw = data.cnpj ? stripCNPJ(String(data.cnpj)) : '';
    if (!cnpjRaw) {
      fields.cnpj = 'Informe o CNPJ do fornecedor.';
    } else if (cnpjRaw.length !== 14) {
      fields.cnpj = 'O CNPJ deve conter 14 dígitos.';
    } else if (!isValidCNPJ(cnpjRaw)) {
      fields.cnpj = 'CNPJ inválido — verifique os dígitos verificadores.';
    }

    const email = String(data.email || '').trim();
    if (!email) {
      fields.email = 'Informe o e-mail de contato.';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      fields.email = 'Informe um e-mail válido.';
    }

    const phoneDisplay = String(data.phone || '').trim();
    const phoneDigits = phoneDisplay.replace(/\D/g, '');
    if (!phoneDisplay) {
      fields.phone = 'Informe o telefone de contato.';
    } else if (phoneDigits.length < 10) {
      fields.phone = 'Informe um telefone válido (mínimo 10 dígitos).';
    }

    const street = String(data.street || '').trim();
    const number = String(data.number || '').trim();
    const city = String(data.city || '').trim();
    const state = String(data.state || '').trim().toUpperCase();
    const zipRaw = String(data.zip_code || '').replace(/\D/g, '');
    const district = String(data.district || '').trim();
    const complement = String(data.complement || '').trim();
    const hasAddressPartial = [street, number, city, state, zipRaw, district, complement].some(Boolean);

    if (hasAddressPartial) {
      if (zipRaw.length !== 8) {
        fields.zip_code = 'Informe um CEP válido (8 dígitos).';
      }
      if (!street) {
        fields.street = 'Informe o logradouro.';
      }
      if (!number) {
        fields.number = 'Informe o número.';
      }
      if (!city) {
        fields.city = 'Informe a cidade.';
      }
      if (!state || state.length !== 2) {
        fields.state = 'Informe a UF com 2 letras.';
      }
    } else if (zipRaw.length > 0 && zipRaw.length !== 8) {
      fields.zip_code = 'Informe um CEP válido (8 dígitos).';
    }

    if (Object.keys(fields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields,
      });
    }

    const cnpjConflict = await Supplier.findByCnpj(cnpjRaw, Number.isInteger(editId) && editId > 0 ? editId : null);
    if (cnpjConflict) {
      return res.status(409).json({
        ok: false,
        message: 'CNPJ já cadastrado para outro fornecedor.',
        fields: { cnpj: 'Este CNPJ já está em uso.' },
      });
    }

    let addressId = null;
    if (hasAddressPartial) {
      const addr = {
        street,
        number,
        complement: complement || null,
        district: district || null,
        city,
        state,
        zip_code: zipRaw,
      };
      if (Number.isInteger(editId) && editId > 0 && data.address_id) {
        await Address.updateById(parseInt(data.address_id, 10), addr);
        addressId = parseInt(data.address_id, 10);
      } else {
        addressId = await Address.create(addr);
      }
    } else if (Number.isInteger(editId) && editId > 0 && data.address_id) {
      addressId = null;
    }

    const payload = {
      corporate_name: corporateName,
      trade_name: tradeName || null,
      cnpj: cnpjRaw,
      email,
      phone: phoneDisplay,
      address_id: addressId,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (Number.isInteger(editId) && editId > 0) {
      await Supplier.updateById(editId, payload);
      return res.json({
        ok: true,
        message: `Fornecedor "${corporateName}" atualizado com sucesso.`,
        id: editId,
        corporate_name: corporateName,
      });
    }
    const id = await Supplier.create(payload);
    return res.status(201).json({
      ok: true,
      message: `Fornecedor "${corporateName}" cadastrado com sucesso.`,
      id,
      corporate_name: corporateName,
    });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes('suppliers.cnpj')) {
        return res.status(409).json({
          ok: false,
          message: 'CNPJ já cadastrado para outro fornecedor.',
          fields: { cnpj: 'Este CNPJ já está em uso.' },
        });
      }
    }
    next(err);
  }
}

/**
 * Remove fornecedor pelo id.
 */
async function deleteSupplier(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const supplier = await Supplier.findById(id);
    if (!supplier) return res.status(404).json({ ok: false, message: 'Fornecedor não encontrado.' });
    const n = await Supplier.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Fornecedor não encontrado.' });
    res.json({
      ok: true,
      message: `Fornecedor "${supplier.corporate_name}" removido com sucesso.`,
    });
  } catch (err) {
    if (err && (err.code === 'ER_ROW_IS_REFERENCED_2' || err.code === 'ER_ROW_IS_REFERENCED')) {
      return res.status(409).json({
        ok: false,
        message: 'Não é possível excluir: existem produtos ou compras vinculados a este fornecedor.',
      });
    }
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
    const slugRegistry = (list || []).reduce((acc, c) => {
      if (c && c.slug) acc[String(c.slug).toLowerCase()] = { id: c.id, name: c.name };
      return acc;
    }, {});
    const stats = (list || []).reduce((acc, c) => {
      acc.total += 1;
      if (c.is_active) acc.active += 1; else acc.inactive += 1;
      if (c.parent_id) acc.sub += 1; else acc.root += 1;
      return acc;
    }, { total: 0, active: 0, inactive: 0, root: 0, sub: 0 });
    res.render('admin/categorias', {
      title: 'Categorias - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'categorias',
      list,
      parentNames,
      slugRegistry,
      stats,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Verifica disponibilidade de slug (categorias, tipos de produto).
 * GET /admin/api/slug-disponivel?scope=category|product_type&slug=&name=&excludeId=
 */
async function checkSlugAvailability(req, res, next) {
  try {
    const scope = String(req.query.scope || '').trim().toLowerCase();
    const scopes = {
      category: { findBySlug: Category.findBySlug, entityLabel: 'categoria' },
      product_type: { findBySlug: ProductType.findBySlug, entityLabel: 'tipo de produto' },
    };
    const config = scopes[scope];
    if (!config) {
      return res.status(400).json({ ok: false, available: false, message: 'Escopo de slug inválido.' });
    }

    const slugRaw = String(req.query.slug || '').trim().toLowerCase();
    const name = String(req.query.name || '').trim();
    const slug = resolveSlug(slugRaw, name);
    const slugCheck = validateSlug(slug, { explicit: !!slugRaw });
    if (!slugCheck.ok) {
      return res.json({
        ok: true,
        available: false,
        reason: 'invalid',
        slug,
        message: slugCheck.error,
      });
    }

    const excludeId = req.query.excludeId ? parseInt(req.query.excludeId, 10) : null;
    const conflict = await config.findBySlug(
      slugCheck.slug,
      Number.isInteger(excludeId) && excludeId > 0 ? excludeId : null
    );
    if (conflict) {
      return res.json({
        ok: true,
        available: false,
        reason: 'taken',
        slug: slugCheck.slug,
        conflict: { id: conflict.id, name: conflict.name },
        message: `Este slug já está em uso por outra ${config.entityLabel}.`,
      });
    }

    return res.json({
      ok: true,
      available: true,
      reason: 'available',
      slug: slugCheck.slug,
      message: 'Slug disponível.',
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Trata conflito UNIQUE de slug no MySQL.
 */
function slugDuplicateResponse(tableKey, entityLabel) {
  return {
    ok: false,
    message: `Slug já cadastrado para outro ${entityLabel}.`,
    fields: { slug: 'Este slug já está em uso.' },
  };
}

/**
 * Cria ou atualiza categoria.
 */
async function saveCategory(req, res, next) {
  try {
    const data = req.body || {};
    const fields = {};
    const editId = data.id ? parseInt(data.id, 10) : null;

    const name = String(data.name || '').trim();
    if (!name) {
      fields.name = 'Informe o nome da categoria.';
    } else if (name.length < 2) {
      fields.name = 'O nome deve ter pelo menos 2 caracteres.';
    }

    const slugRaw = String(data.slug || '').trim().toLowerCase();
    const slug = resolveSlug(slugRaw, name);
    const slugValidation = validateSlug(slug, { explicit: !!slugRaw });
    if (!slugValidation.ok) {
      fields.slug = slugValidation.error;
    }

    const parentId = data.parent_id ? parseInt(data.parent_id, 10) : null;
    if (data.parent_id && (!Number.isInteger(parentId) || parentId <= 0)) {
      fields.parent_id = 'Selecione uma categoria pai válida.';
    } else if (Number.isInteger(editId) && editId > 0 && parentId === editId) {
      fields.parent_id = 'A categoria não pode ser pai de si mesma.';
    }

    const description = String(data.description || '').trim();
    if (description.length > 255) {
      fields.description = 'A descrição deve ter no máximo 255 caracteres.';
    }

    if (Object.keys(fields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields,
      });
    }

    if (Number.isInteger(parentId) && parentId > 0) {
      const parent = await Category.findById(parentId);
      if (!parent || !parent.is_active) {
        return res.status(400).json({
          ok: false,
          message: 'Categoria pai inválida ou inativa.',
          fields: { parent_id: 'Selecione uma categoria pai ativa.' },
        });
      }
    }

    const slugConflict = await Category.findBySlug(slugValidation.slug, Number.isInteger(editId) && editId > 0 ? editId : null);
    if (slugConflict) {
      return res.status(409).json({
        ...slugDuplicateResponse('categories', 'categoria'),
        conflict: { id: slugConflict.id, name: slugConflict.name },
      });
    }

    const payload = {
      name,
      slug: slugValidation.slug,
      parent_id: Number.isInteger(parentId) && parentId > 0 ? parentId : null,
      description: description || null,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (Number.isInteger(editId) && editId > 0) {
      await Category.updateById(editId, payload);
      return res.json({
        ok: true,
        message: `Categoria "${name}" atualizada com sucesso.`,
        id: editId,
        name,
      });
    }
    const id = await Category.create(payload);
    return res.status(201).json({
      ok: true,
      message: `Categoria "${name}" cadastrada com sucesso.`,
      id,
      name,
    });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes('categories.slug')) {
        return res.status(409).json(slugDuplicateResponse('categories', 'categoria'));
      }
    }
    next(err);
  }
}

/**
 * Exclui categoria pelo id.
 */
async function deleteCategory(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    const category = await Category.findById(id);
    if (!category) return res.status(404).json({ ok: false, message: 'Categoria não encontrada.' });
    if (await Category.hasChildren(id)) {
      return res.status(409).json({
        ok: false,
        message: 'Não é possível excluir: existem subcategorias vinculadas a esta categoria.',
      });
    }
    const n = await Category.deleteById(id);
    if (!n) return res.status(404).json({ ok: false, message: 'Categoria não encontrada.' });
    res.json({ ok: true, message: `Categoria "${category.name}" removida com sucesso.` });
  } catch (err) {
    if (err && (err.code === 'ER_ROW_IS_REFERENCED_2' || err.code === 'ER_ROW_IS_REFERENCED')) {
      return res.status(409).json({
        ok: false,
        message: 'Não é possível excluir: existem produtos vinculados a esta categoria.',
      });
    }
    next(err);
  }
}

// ---- Tipos de produto (RF_B3) ----
async function listProductTypes(req, res, next) {
  try {
    const list = await ProductType.findAll();
    const slugRegistry = (list || []).reduce((acc, t) => {
      if (t && t.slug) acc[String(t.slug).toLowerCase()] = { id: t.id, name: t.name };
      return acc;
    }, {});
    const stats = (list || []).reduce((acc, t) => {
      acc.total += 1;
      if (t.is_active) acc.active += 1; else acc.inactive += 1;
      return acc;
    }, { total: 0, active: 0, inactive: 0 });
    res.render('admin/tipos-produto', {
      title: 'Tipos de Produto - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'tipos_produto',
      list,
      slugRegistry,
      stats,
    });
  } catch (err) {
    next(err);
  }
}

async function saveProductType(req, res, next) {
  try {
    const data = req.body || {};
    const fields = {};
    const editId = data.id ? parseInt(data.id, 10) : null;

    const name = String(data.name || '').trim();
    if (!name) {
      fields.name = 'Informe o nome do tipo de produto.';
    } else if (name.length < 2) {
      fields.name = 'O nome deve ter pelo menos 2 caracteres.';
    }

    const slugRaw = String(data.slug || '').trim().toLowerCase();
    const slug = resolveSlug(slugRaw, name);
    const slugValidation = validateSlug(slug, { explicit: !!slugRaw });
    if (!slugValidation.ok) {
      fields.slug = slugValidation.error;
    }

    const description = String(data.description || '').trim();
    if (description.length > 255) {
      fields.description = 'A descrição deve ter no máximo 255 caracteres.';
    }

    if (Object.keys(fields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields,
      });
    }

    const slugConflict = await ProductType.findBySlug(
      slugValidation.slug,
      Number.isInteger(editId) && editId > 0 ? editId : null
    );
    if (slugConflict) {
      return res.status(409).json({
        ...slugDuplicateResponse('product_types', 'tipo de produto'),
        conflict: { id: slugConflict.id, name: slugConflict.name },
      });
    }

    const payload = {
      name,
      slug: slugValidation.slug,
      description: description || null,
      is_active: data.is_active !== undefined ? !!data.is_active : true,
    };

    if (Number.isInteger(editId) && editId > 0) {
      await ProductType.updateById(editId, payload);
      return res.json({
        ok: true,
        message: `Tipo "${name}" atualizado com sucesso.`,
        id: editId,
        name,
      });
    }
    const id = await ProductType.create(payload);
    return res.status(201).json({
      ok: true,
      message: `Tipo "${name}" cadastrado com sucesso.`,
      id,
      name,
    });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes('product_types.slug')) {
        return res.status(409).json(slugDuplicateResponse('product_types', 'tipo de produto'));
      }
    }
    next(err);
  }
}

async function deleteProductType(req, res, next) {
  try {
    const n = await ProductType.deleteById(Number(req.params.id));
    if (!n) return res.status(404).json({ ok: false, message: 'Não encontrado.' });
    return res.json({ ok: true, message: 'Tipo removido.' });
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
      product_type_id: p.product_type_id || null,
      expired_batches: (riskMap.get(Number(p.id)) || {}).expired_batches || 0,
      expiring_batches: (riskMap.get(Number(p.id)) || {}).expiring_batches || 0,
    }));
    if (riskFilter === 'EXPIRED') {
      list = list.filter((p) => p.expired_batches > 0);
    } else if (riskFilter === 'EXPIRING') {
      list = list.filter((p) => p.expiring_batches > 0);
    }
    const stats = listBase.reduce((acc, p) => {
      acc.total += 1;
      if (p.status === 'ACTIVE') acc.active += 1;
      if (p.status === 'INACTIVE') acc.inactive += 1;
      const risk = riskMap.get(Number(p.id)) || {};
      if ((risk.expired_batches || 0) > 0) acc.expired += 1;
      if ((risk.expiring_batches || 0) > 0) acc.expiring += 1;
      return acc;
    }, { total: 0, active: 0, inactive: 0, expired: 0, expiring: 0, filtered: list.length });
    const labs = await Lab.findAll(true);
    const suppliers = await Supplier.findAll(true);
    const categories = await Category.findAll(true);
    const productTypes = await ProductType.findAll(true);
    res.render('admin/produtos', {
      title: 'Produtos - Admin',
      bodyClass: 'admin-page',
      activeAdmin: 'produtos',
      list,
      labs,
      suppliers,
      categories,
      productTypes,
      riskFilter,
      stats,
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
    const fields = {};
    const name = String(data.name || '').trim();
    if (!name) {
      fields.name = 'Informe o nome do produto.';
    } else if (name.length < 2) {
      fields.name = 'O nome deve ter pelo menos 2 caracteres.';
    }

    const categoryId = data.category_id ? parseInt(data.category_id, 10) : NaN;
    if (!Number.isInteger(categoryId) || categoryId <= 0) {
      fields.category_id = 'Selecione uma categoria.';
    }

    const sku = String(data.sku || '').trim();
    if (!sku) {
      fields.sku = 'Informe o SKU do produto.';
    } else if (sku.length < 2) {
      fields.sku = 'O SKU deve ter pelo menos 2 caracteres.';
    }

    const labId = data.lab_id ? parseInt(data.lab_id, 10) : NaN;
    if (!Number.isInteger(labId) || labId <= 0) {
      fields.lab_id = 'Selecione o laboratório fabricante.';
    }

    const supplierId = data.main_supplier_id ? parseInt(data.main_supplier_id, 10) : NaN;
    if (!Number.isInteger(supplierId) || supplierId <= 0) {
      fields.main_supplier_id = 'Selecione o fornecedor principal.';
    }

    const productTypeId = data.product_type_id ? parseInt(data.product_type_id, 10) : NaN;
    if (!Number.isInteger(productTypeId) || productTypeId <= 0) {
      fields.product_type_id = 'Selecione o tipo de produto (RF_B3).';
    }

    const num = (v) => (v === '' || v === undefined || v === null ? null : parseFloat(String(v).replace(',', '.')));
    const unitPrice = num(data.unit_price);
    if (unitPrice === null || Number.isNaN(unitPrice)) {
      fields.unit_price = 'Informe o preço unitário.';
    } else if (unitPrice < 0) {
      fields.unit_price = 'O preço não pode ser negativo.';
    } else if (unitPrice === 0) {
      fields.unit_price = 'O preço unitário deve ser maior que zero.';
    }

    const promoPrice = num(data.promotional_price);
    if (promoPrice !== null && !Number.isNaN(promoPrice)) {
      if (promoPrice < 0) {
        fields.promotional_price = 'O preço promocional não pode ser negativo.';
      } else if (unitPrice !== null && promoPrice >= unitPrice) {
        fields.promotional_price = 'O preço promocional deve ser menor que o preço unitário.';
      }
    }

    const eanRaw = stripGtin(String(data.ean13 || ''));
    if (eanRaw.length > 0) {
      if (eanRaw.length !== 13) {
        fields.ean13 = 'O EAN-13 deve conter exatamente 13 dígitos.';
      } else if (!isValidEan13(eanRaw)) {
        fields.ean13 = 'EAN-13 inválido — verifique o dígito verificador.';
      }
    }

    const gtin14Raw = stripGtin(String(data.gtin14 || ''));
    if (gtin14Raw.length > 0) {
      if (gtin14Raw.length !== 14) {
        fields.gtin14 = 'O GTIN-14 deve conter exatamente 14 dígitos.';
      } else if (!isValidGtin14(gtin14Raw)) {
        fields.gtin14 = 'GTIN-14 inválido — verifique o dígito verificador.';
      }
    }

    const prescriptionRequired = !!data.prescription_required;
    const editId = data.id ? parseInt(data.id, 10) : null;

    if (Object.keys(fields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields,
      });
    }

    const category = await Category.findById(categoryId);
    if (!category || !category.is_active) {
      return res.status(400).json({
        ok: false,
        message: 'Categoria inválida ou inativa.',
        fields: { category_id: 'Selecione uma categoria ativa.' },
      });
    }

    const lab = await Lab.findById(labId);
    if (!lab || !lab.is_active) {
      return res.status(400).json({
        ok: false,
        message: 'Laboratório inválido ou inativo.',
        fields: { lab_id: 'Selecione um laboratório ativo.' },
      });
    }

    const supplier = await Supplier.findById(supplierId);
    if (!supplier || !supplier.is_active) {
      return res.status(400).json({
        ok: false,
        message: 'Fornecedor inválido ou inativo.',
        fields: { main_supplier_id: 'Selecione um fornecedor ativo.' },
      });
    }

    const productType = await ProductType.findById(productTypeId);
    if (!productType || !productType.is_active) {
      return res.status(400).json({
        ok: false,
        message: 'Tipo de produto inválido ou inativo.',
        fields: { product_type_id: 'Selecione um tipo de produto ativo.' },
      });
    }

    const asyncFields = {};
    const skuConflict = await Product.findBySku(sku, Number.isInteger(editId) ? editId : null);
    if (skuConflict) {
      asyncFields.sku = 'Este SKU já está em uso por outro produto.';
    }

    if (Product.productTypeRequiresEan(productType, prescriptionRequired)) {
      if (!eanRaw) {
        asyncFields.ean13 = 'Informe o EAN-13 para medicamentos e produtos sujeitos a receita.';
      }
    }

    if (eanRaw) {
      const eanConflict = await Product.findByEan13(eanRaw, Number.isInteger(editId) ? editId : null);
      if (eanConflict) {
        asyncFields.ean13 = 'Este EAN-13 já está em uso por outro produto.';
      }
    }

    if (gtin14Raw) {
      const gtinConflict = await Product.findByGtin14(gtin14Raw, Number.isInteger(editId) ? editId : null);
      if (gtinConflict) {
        asyncFields.gtin14 = 'Este GTIN-14 já está em uso por outro produto.';
      }
    }

    if (Object.keys(asyncFields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Corrija os campos destacados antes de salvar.',
        fields: asyncFields,
      });
    }

    const payload = {
      name,
      lab_id: labId,
      main_supplier_id: supplierId,
      product_type_id: productTypeId,
      sku,
      ean13: eanRaw || null,
      gtin14: gtin14Raw || null,
      description: data.description ? String(data.description).trim() : null,
      composition: data.composition ? String(data.composition).trim() : null,
      usage_info: data.usage_info ? String(data.usage_info).trim() : null,
      prescription_required: prescriptionRequired,
      unit_price: unitPrice,
      promotional_price: promoPrice,
      status: data.status || 'ACTIVE',
    };
    let productId;
    if (Number.isInteger(editId) && editId > 0) {
      productId = editId;
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

    if (Number.isInteger(editId) && editId > 0) {
      return res.json({ ok: true, message: 'Produto atualizado com sucesso.', id: productId, name: payload.name });
    }
    return res.status(201).json({ ok: true, message: 'Produto cadastrado com sucesso.', id: productId, name: payload.name });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      const msg = String(err.sqlMessage || err.message || '');
      if (msg.includes("products.sku")) {
        return res.status(409).json({
          ok: false,
          message: 'SKU já cadastrado para outro produto.',
          fields: { sku: 'Este SKU já está em uso.' },
        });
      }
      if (msg.includes("products.ean13")) {
        return res.status(409).json({
          ok: false,
          message: 'EAN-13 já cadastrado para outro produto.',
          fields: { ean13: 'Este EAN-13 já está em uso.' },
        });
      }
      if (msg.includes("products.gtin14")) {
        return res.status(409).json({
          ok: false,
          message: 'GTIN-14 já cadastrado para outro produto.',
          fields: { gtin14: 'Este GTIN-14 já está em uso.' },
        });
      }
      if (msg.includes("products.slug")) {
        return res.status(409).json({
          ok: false,
          message: 'Já existe um produto com nome muito parecido.',
          fields: { name: 'Ajuste o nome — o identificador (slug) gerado já existe.' },
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
  checkSlugAvailability,
  listLabs,
  saveLab,
  deleteLab,
  listSuppliers,
  saveSupplier,
  deleteSupplier,
  listCategories,
  saveCategory,
  deleteCategory,
  listProductTypes,
  saveProductType,
  deleteProductType,
  listProducts,
  saveProduct,
  deleteProduct,
  getProductImages,
  addProductImage,
  uploadProductImage,
  deleteProductImage,
};
