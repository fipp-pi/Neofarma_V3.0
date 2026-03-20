const bcrypt = require('bcrypt');
const Customer = require('../models/Customer');

/**
 * GET /admin/clientes - Lista clientes (página + dados para a tabela via API ou render).
 * Aqui enviamos a lista para o EJS; o front pode também chamar /api/clientes para JSON.
 */
async function listClients(req, res, next) {
  try {
    const search = req.query.search || req.query.q || null;
    const clients = await Customer.findAll(search);
    res.render('list_clients', {
      title: 'Clientes - NeoFarma',
      bodyClass: 'admin-page',
      clients: clients || [],
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
    title: 'Novo Cliente - NeoFarma',
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
    if (!data.nome && !data.full_name) {
      return res.status(400).json({ ok: false, message: 'Nome é obrigatório.' });
    }
    if (!data.email) {
      return res.status(400).json({ ok: false, message: 'E-mail é obrigatório.' });
    }
    if (!data.telefone && !data.phone) {
      return res.status(400).json({ ok: false, message: 'Telefone é obrigatório.' });
    }
    const senha = data.senha || '';
    if (!senha || senha.length < 6) {
      return res.status(400).json({ ok: false, message: 'Senha é obrigatória (mínimo 6 caracteres).' });
    }
    if (senha !== (data.confirmar_senha || '')) {
      return res.status(400).json({ ok: false, message: 'As senhas não coincidem.' });
    }
    if (!data.cep && !data.zip_code) {
      return res.status(400).json({ ok: false, message: 'CEP é obrigatório.' });
    }
    if (!data.numero && !data.number) {
      return res.status(400).json({ ok: false, message: 'Número do endereço é obrigatório.' });
    }
    const document = data.document || data.cpf || null;
    const birthDate = data.birth_date ? String(data.birth_date).trim() || null : null;
    const payload = {
      nome: data.nome || data.full_name,
      email: data.email,
      telefone: data.telefone || data.phone,
      document: document && String(document).replace(/\D/g, '').length === 11 ? String(document).replace(/\D/g, '') : null,
      birth_date: birthDate,
      pais: data.pais || 'Brasil',
      cep: (data.cep || data.zip_code || '').toString().replace(/\D/g, ''),
      rua: data.rua || data.street,
      numero: data.numero || data.number,
      complement: data.complement || null,
      bairro: data.bairro || data.district,
      cidade: data.cidade || data.city,
      estado: data.estado || data.state,
    };
    const passwordHash = await bcrypt.hash(senha, 10);
    const result = await Customer.createClient(payload, passwordHash);
    res.status(201).json({ ok: true, message: 'Cliente cadastrado com sucesso.', id: result.customerId });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY' || err.message?.includes('Duplicate')) {
      return res.status(409).json({ ok: false, message: 'Este e-mail já está cadastrado.' });
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
