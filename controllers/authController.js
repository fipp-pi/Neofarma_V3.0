const bcrypt = require('bcrypt');
const Role = require('../models/Role');
const User = require('../models/User');
const Address = require('../models/Address');
const { pool } = require('../config/database');

/**
 * Abre a tela de login.
 */
function getLogin(req, res) {
  res.render('login', {
    title: 'Login - NeoFarma',
    bodyClass: 'login-page',
  });
}

/**
 * Abre a tela de cadastro público.
 */
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

    conn = await pool.getConnection();
    await conn.beginTransaction();

    const password_hash = await bcrypt.hash(password, 10);
    const [userResult] = await conn.execute(
      `INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        roleCliente.id,
        full_name.trim(),
        email.trim().toLowerCase(),
        password_hash,
        document && document.trim() ? document.trim() : null,
        phone && phone.trim() ? phone.trim() : null,
        birth_date && birth_date.trim() ? birth_date.trim() : null,
      ]
    );
    const userId = userResult.insertId;

    const [addrResult] = await conn.execute(
      `INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        street.trim(),
        String(number).trim(),
        complement && String(complement).trim() ? String(complement).trim() : null,
        district.trim(),
        city.trim(),
        String(state).trim().toUpperCase().slice(0, 2),
        (country && String(country).trim()) || 'Brasil',
        cepClean,
      ]
    );
    const addressId = addrResult.insertId;

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
    console.error('Erro no registro:', err && err.message ? err.message : err);
    return res.status(500).json({ ok: false, message: 'Erro interno ao criar conta. Tente novamente.' });
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

/**
 * Encerra a sessão atual e volta para a home.
 */
function getLogout(req, res) {
  req.session.destroy((err) => {
    if (err) console.error('Logout session destroy:', err);
    res.redirect('/');
  });
}

module.exports = { getLogin, getRegister, postRegister, postLogin, getLogout };
