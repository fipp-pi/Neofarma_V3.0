const User = require('../models/User');
const InventoryBatch = require('../models/InventoryBatch');

/**
 * Redireciona para /login se não houver sessão (usuário não logado).
 * Use em rotas que exigem login (ex: /account).
 */
function requireAuth(req, res, next) {
  if (req.session && req.session.userId) {
    return next();
  }
  const wantsJson = req.xhr || /^application\/json/.test(req.get('accept') || '');
  if (wantsJson) {
    return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
  }
  res.redirect('/login?redirect=' + encodeURIComponent(req.originalUrl || '/account'));
}

/** Roles permitidas para acessar /admin */
const ADMIN_ROLES = ['ADMIN', 'FUNCIONARIO', 'ESTOQUISTA'];

/**
 * Restringe /admin apenas a usuários logados com role ADMIN ou FUNCIONARIO.
 * Redireciona para /login se não logado; renderiza 403 se logado mas sem permissão.
 */
async function requireAdmin(req, res, next) {
  if (!req.session || !req.session.userId) {
    const wantsJson = req.xhr || /^application\/json/.test(req.get('accept') || '');
    if (wantsJson) {
      return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
    }
    return res.redirect('/login?redirect=' + encodeURIComponent(req.originalUrl || '/admin'));
  }
  try {
    const user = await User.findById(req.session.userId);
    if (!user) {
      req.session.destroy(() => {});
      return res.redirect('/login?redirect=' + encodeURIComponent(req.originalUrl || '/admin'));
    }
    const role = (user.role_name || '').toUpperCase();
    if (!ADMIN_ROLES.includes(role)) {
      const wantsJson = req.xhr || /^application\/json/.test(req.get('accept') || '');
      if (wantsJson) {
        return res.status(403).json({ ok: false, message: 'Acesso negado. Apenas administradores ou funcionários.' });
      }
      return res.status(403).render('403', { title: 'Acesso negado', message: 'Apenas administradores ou funcionários podem acessar esta área.' });
    }
    res.locals.adminUser = { id: user.id, full_name: user.full_name, email: user.email, role_name: user.role_name };
    try {
      const expiredAwaiting = await InventoryBatch.countExpiredAwaitingDisposal();
      res.locals.adminAlerts = { expiredAwaitingDisposal: expiredAwaiting };
    } catch (_) {
      res.locals.adminAlerts = { expiredAwaitingDisposal: 0 };
    }
    const adminPath = String(req.originalUrl || req.url || req.path || '').split('?')[0].replace(/\/$/, '') || '/';
    res.locals.requestPath = adminPath;
    if (adminPath === '/admin/agendamentos-servicos/caixa' || adminPath.startsWith('/admin/agendamentos-servicos/caixa/')) {
      res.locals.activeAdmin = 'agendamentos_caixa';
    }
    next();
  } catch (err) {
    next(err);
  }
}

/**
 * Carrega o usuário da sessão em res.locals.user para uso nas views.
 * Não bloqueia a rota; apenas preenche res.locals.user quando logado.
 */
async function loadUserForViews(req, res, next) {
  res.locals.user = null;
  if (req.session && req.session.userId) {
    try {
      const user = await User.findById(req.session.userId);
      if (user) {
        res.locals.user = {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
        };
      }
    } catch (err) {
      // ignora erro (ex: usuário deletado); sessão será limpa no próximo request se necessário
    }
  }
  next();
}

module.exports = {
  requireAuth,
  requireAdmin,
  loadUserForViews,
};
