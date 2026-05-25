const bcrypt = require('bcrypt');
const Customer = require('../models/Customer');
const User = require('../models/User');
const { validateRegisterPayload, findRegisterDuplicateFields } = require('../utils/registerValidation');

/**
 * GET /admin/clientes - Lista clientes (página + dados para a tabela via API ou render).
 * Aqui enviamos a lista para o EJS; o front pode também chamar /api/clientes para JSON.
 */
async function listClients(req, res, next) {
  try {
    const search = req.query.search || req.query.q || null;
    const clients = await Customer.findAll(search);
    const list = clients || [];
    const stats = {
      total: list.length,
      withEmail: list.filter((c) => c.email).length,
      withPhone: list.filter((c) => c.phone).length,
      withCity: list.filter((c) => c.city && String(c.city).trim()).length,
      withDocument: list.filter((c) => c.document && String(c.document).trim()).length,
    };
    res.render('list_clients', {
      title: 'Clientes - Admin - NeoFarma',
      bodyClass: 'admin-page',
      clients: list,
      stats,
      activeAdmin: 'clientes',
      useAdminLayout: true,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /admin/clientes/novo - Formulário de novo cadastro (admin).
 */
function getRegisterNew(req, res) {
  res.render('register_new', {
    title: 'Novo Cliente - Admin - NeoFarma',
    bodyClass: 'admin-page',
    activeAdmin: 'clientes',
    useAdminLayout: true,
  });
}

/**
 * POST /admin/clientes/novo - Cadastra novo cliente (admin).
 * Espera: nome, email, telefone, senha, confirmar_senha, document?, birth_date?, pais, cep, rua, numero, complement?, bairro, cidade, estado.
 */
async function postRegisterNew(req, res, next) {
  try {
    const data = req.body || {};
    const { fields, payload } = validateRegisterPayload(data);
    const duplicateFields = await findRegisterDuplicateFields(payload, User);
    const allFields = { ...fields, ...duplicateFields };

    if (Object.keys(allFields).length) {
      return res.status(400).json({
        ok: false,
        message: 'Revise os campos destacados em vermelho antes de continuar.',
        fields: allFields,
      });
    }

    const passwordHash = await bcrypt.hash(payload.senha, 10);
    const result = await Customer.createClient(payload, passwordHash);
    res.status(201).json({ ok: true, message: 'Cliente cadastrado com sucesso.', id: result.customerId });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY' || err.message?.includes('Duplicate')) {
      return res.status(409).json({
        ok: false,
        message: 'Este e-mail já está cadastrado.',
        fields: { email: 'Este e-mail já está em uso por outro cliente.' },
      });
    }
    next(err);
  }
}

/**
 * GET /api/clientes - Lista clientes em JSON (para o front da list_clients.ejs, se usar fetch).
 */
async function apiList(req, res, next) {
  try {
    const search = req.query.search || req.query.q || null;
    const clients = await Customer.findAll(search);
    res.json({ ok: true, data: clients });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/clientes/:id - Um cliente por id.
 */
async function apiGetOne(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const client = await Customer.findById(id);
    if (!client) return res.status(404).json({ ok: false, message: 'Cliente não encontrado.' });
    res.json({ ok: true, data: client });
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/clientes/:id - Atualiza cliente.
 */
async function apiUpdate(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const client = await Customer.findById(id);
    if (!client) return res.status(404).json({ ok: false, message: 'Cliente não encontrado.' });
    await Customer.updateClient(id, req.body);
    res.json({ ok: true, message: 'Cliente atualizado com sucesso.' });
  } catch (err) {
    next(err);
  }
}

/**
 * DELETE /api/clientes/:id - Remove um cliente.
 */
async function apiDelete(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ ok: false, message: 'ID inválido.' });
    const deleted = await Customer.deleteById(id);
    if (!deleted) return res.status(404).json({ ok: false, message: 'Cliente não encontrado.' });
    res.json({ ok: true, message: 'Cliente removido com sucesso.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/clientes/excluir-massa - Exclui vários clientes por id.
 * Body: { ids: number[] }
 */
async function apiDeleteMany(req, res, next) {
  try {
    const ids = Array.isArray(req.body.ids) ? req.body.ids.map((n) => parseInt(n, 10)).filter((n) => !isNaN(n)) : [];
    if (ids.length === 0) return res.status(400).json({ ok: false, message: 'Nenhum ID válido.' });
    const deleted = await Customer.deleteManyByIds(ids);
    res.json({ ok: true, message: `${deleted} cliente(s) removido(s).`, count: deleted });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listClients,
  getRegisterNew,
  postRegisterNew,
  apiList,
  apiGetOne,
  apiUpdate,
  apiDelete,
  apiDeleteMany,
};
