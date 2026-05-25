/**
 * RF_B1 — cadastro de funcionários (admin).
 */
const bcrypt = require('bcrypt');
const Employee = require('../models/Employee');
const Role = require('../models/Role');
const User = require('../models/User');

function requireAdminRole(req, res) {
  const role = ((res.locals.adminUser && res.locals.adminUser.role_name) || '').toUpperCase();
  if (role !== 'ADMIN') {
    const wantsJson = req.xhr || /^application\/json/.test(req.get('accept') || '');
    if (wantsJson) {
      res.status(403).json({ ok: false, message: 'Apenas administradores podem gerenciar funcionários.' });
      return false;
    }
    res.status(403).render('403', { title: 'Acesso negado', message: 'Apenas administradores podem gerenciar funcionários.' });
    return false;
  }
  return true;
}

async function renderPage(req, res, next) {
  try {
    const list = await Employee.findAll();
    const roles = (await Role.findAll()).filter((r) => Employee.STAFF_ROLES.includes(r.name));
    const stats = {
      total: list.length,
      active: list.filter((f) => f.is_active).length,
      inactive: list.filter((f) => !f.is_active).length,
      admins: list.filter((f) => String(f.role_name).toUpperCase() === 'ADMIN').length,
      operational: list.filter((f) => ['FUNCIONARIO', 'ESTOQUISTA'].includes(String(f.role_name).toUpperCase())).length,
    };
    res.render('admin/funcionarios', {
      title: 'Funcionários - Admin - NeoFarma',
      bodyClass: 'admin-page',
      activeAdmin: 'funcionarios',
      list,
      roles,
      stats,
      canEdit: ((res.locals.adminUser && res.locals.adminUser.role_name) || '').toUpperCase() === 'ADMIN',
    });
  } catch (err) {
    next(err);
  }
}

async function saveEmployee(req, res, next) {
  try {
    if (!requireAdminRole(req, res)) return;
    const data = req.body || {};
    const full_name = (data.full_name || '').trim();
    const email = (data.email || '').trim().toLowerCase();
    const role_id = parseInt(data.role_id, 10);
    const role_title = (data.role_title || '').trim();
    const hire_date = data.hire_date || null;
    const salary = parseFloat(data.salary) || 0;
    const user_id = data.user_id ? parseInt(data.user_id, 10) : null;

    if (!full_name || !email || !role_id || !role_title || !hire_date) {
      return res.status(400).json({ ok: false, message: 'Preencha nome, e-mail, perfil, cargo e data de admissão.' });
    }

    const role = await Role.findById(role_id);
    if (!role || !Employee.STAFF_ROLES.includes(role.name)) {
      return res.status(400).json({ ok: false, message: 'Perfil inválido para funcionário.' });
    }

    if (!user_id) {
      const password = data.password || '';
      if (password.length < 6) {
        return res.status(400).json({ ok: false, message: 'Senha deve ter no mínimo 6 caracteres.' });
      }
      const existing = await User.findByEmail(email);
      if (existing) {
        return res.status(409).json({ ok: false, message: 'E-mail já cadastrado.' });
      }
      const password_hash = await bcrypt.hash(password, 10);
      await Employee.save({
        full_name,
        email,
        role_id,
        role_title,
        hire_date,
        salary,
        document: data.document || null,
        phone: data.phone || null,
        is_active: data.is_active !== false,
        password_hash,
      });
      return res.json({ ok: true, message: 'Funcionário cadastrado.' });
    }

    const password = data.password || '';
    const payload = {
      user_id,
      full_name,
      email,
      role_id,
      role_title,
      hire_date,
      salary,
      document: data.document || null,
      phone: data.phone || null,
      is_active: data.is_active !== false,
    };
    if (password.length >= 6) {
      payload.password_hash = await bcrypt.hash(password, 10);
    }
    await Employee.save(payload);
    return res.json({ ok: true, message: 'Funcionário atualizado.' });
  } catch (err) {
    if (err && err.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ ok: false, message: 'E-mail já cadastrado.' });
    }
    next(err);
  }
}

module.exports = {
  renderPage,
  saveEmployee,
};
