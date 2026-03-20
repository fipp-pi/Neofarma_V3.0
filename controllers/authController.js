const bcrypt = require('bcrypt');
const Role = require('../models/Role');
const User = require('../models/User');
const Address = require('../models/Address');
const { pool } = require('../config/database');

function getLogin(req, res) {
  res.render('login', {
    title: 'Login - NeoFarma',
    bodyClass: 'login-page',
  });
}

function getRegister(req, res) {
  res.render('register', {
    title: 'Registrar - NeoFarma',
    bodyClass: 'register-page',
  });
}

/**
 * POST /register - Cria conta (user + customer + endereço).
 * Body: full_name, email, password, document?, phone?, birth_date?, country?, cep, street, number, complement?, district, city, state
 */
async function postRegister(req, res, next) {
  let conn = null;
  try {
    const {
      full_name, email, password, document, phone, birth_date, country,
      cep, street, number, complement, district, city, state
    } = req.body || {};

    if (!full_name || !full_name.trim()) {
      return res.status(400).json({ ok: false, message: 'Nome completo é obrigatório.' });
    }
    if (!email || !email.trim()) {
      return res.status(400).json({ ok: false, message: 'E-mail é obrigatório.' });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ ok: false, message: 'Senha deve ter no mínimo 6 caracteres.' });
    }
    const cepClean = (cep && String(cep).replace(/\D/g, '')) || '';
    if (cepClean.length !== 8) {
      return res.status(400).json({ ok: false, message: 'CEP inválido (informe 8 dígitos).' });
    }
    if (!street || !street.trim()) {
      return res.status(400).json({ ok: false, message: 'Rua / logradouro é obrigatório.' });
    }
    if (!number || !String(number).trim()) {
      return res.status(400).json({ ok: false, message: 'Número do endereço é obrigatório.' });
    }
    if (!district || !district.trim()) {
      return res.status(400).json({ ok: false, message: 'Bairro é obrigatório.' });
    }
    if (!city || !city.trim()) {
      return res.status(400).json({ ok: false, message: 'Cidade é obrigatória.' });
    }
    if (!state || !state.trim()) {
      return res.status(400).json({ ok: false, message: 'Estado (UF) é obrigatório.' });
    }

    const existing = await User.findByEmail(email.trim());
    if (existing) {
      return res.status(409).json({ ok: false, message: 'Este e-mail já está cadastrado.' });
    }

    const roleCliente = await Role.findByName('CLIENTE');
    if (!roleCliente) {
      return res.status(500).json({ ok: false, message: 'Configuração do sistema indisponível.' });
    }

    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
    } catch (txErr) {
      conn.release();
      throw txErr;
    }

    const password_hash = await bcrypt.hash(password, 10);
    const userId = await User.create({
      role_id: roleCliente.id,
      full_name: full_name.trim(),
      email: email.trim().toLowerCase(),
      password_hash,
      document: document && document.trim() ? document.trim() : null,
      phone: phone && phone.trim() ? phone.trim() : null,
      birth_date: birth_date && birth_date.trim() ? birth_date.trim() : null,
    });

    const addressId = await Address.create({
      street: street.trim(),
      number: String(number).trim(),
      complement: complement && String(complement).trim() ? String(complement).trim() : null,
      district: district.trim(),
      city: city.trim(),
      state: String(state).trim().toUpperCase().slice(0, 2),
      country: (country && String(country).trim()) || 'Brasil',
      zip_code: cepClean,
    });

    const [insertCust] = await conn.execute(
      'INSERT INTO customers (user_id, default_address_id) VALUES (?, ?)',
      [userId, addressId]
    );
    const customerId = insertCust.insertId;
    await conn.execute(
      'INSERT INTO customer_addresses (customer_id, address_id, label, is_default) VALUES (?, ?, ?, 1)',
      [customerId, addressId, 'Principal']
    );

    await conn.commit();
    conn.release();
    res.status(201).json({ ok: true, message: 'Conta criada com sucesso. Faça login.', redirect: '/login' });
  } catch (err) {
    if (conn) {
      await conn.rollback().catch(() => {});
      conn.release();
    }
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'Este e-mail já está cadastrado.' });
    }
    if (err.code === 'ER_NO_REFERENCED_ROW_2' || (err.message && err.message.includes('default_address_id'))) {
      return res.status(500).json({ ok: false, message: 'Tabela customers sem coluna default_address_id. Adicione a coluna ou use apenas customer_addresses.' });
    }
    next(err);
  }
}

/**
 * POST /login - Autentica com email e senha (tabela users).
 * Body: email, password (ou senha).
 * Resposta: { ok, message, redirect? } ou 401.
 */
async function postLogin(req, res, next) {
  try {
    if (!req.session) {
      console.error('Login: req.session não disponível. Verifique se express-session está montado antes das rotas.');
      return res.status(500).json({ ok: false, message: 'Erro de configuração do servidor. Tente novamente mais tarde.' });
    }

    const body = req.body || {};
    const email = (body.email || '').trim().toLowerCase();
    const password = body.password || body.senha || '';

    if (!email || !password) {
      return res.status(400).json({ ok: false, message: 'Email e senha são obrigatórios.' });
    }

    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({ ok: false, message: 'Email ou senha inválidos.' });
    }

    const passwordHash = user.password_hash || user.PASSWORD_HASH;
    if (!passwordHash) {
      console.error('Login: usuário sem password_hash no banco (id=%s).', user.id);
      return res.status(401).json({ ok: false, message: 'Email ou senha inválidos.' });
    }

    let match = false;
    try {
      match = await bcrypt.compare(password, passwordHash);
    } catch (bcryptErr) {
      console.error('Login: bcrypt.compare falhou:', bcryptErr.message);
      return res.status(401).json({ ok: false, message: 'Email ou senha inválidos.' });
    }
    if (!match) {
      return res.status(401).json({ ok: false, message: 'Email ou senha inválidos.' });
    }

    req.session.userId = user.id;
    req.session.userName = user.full_name || user.email;
    const role = String(user.role_name || '').toUpperCase();
    const defaultRedirect = (role === 'ADMIN' || role === 'FUNCIONARIO') ? '/admin' : '/account';
    const wantedRedirect = (body.redirect || '').trim();
    const redirect = wantedRedirect && wantedRedirect.startsWith('/') && !wantedRedirect.includes('//')
      ? wantedRedirect
      : defaultRedirect;
    res.status(200).json({
      ok: true,
      message: 'Login realizado com sucesso.',
      redirect,
    });
  } catch (err) {
    next(err);
  }
}

function getLogout(req, res) {
  req.session.destroy((err) => {
    if (err) console.error('Logout session destroy:', err);
    res.redirect('/');
  });
}

module.exports = { getLogin, getRegister, postRegister, postLogin, getLogout };
