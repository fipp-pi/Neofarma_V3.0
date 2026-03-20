// Suprime aviso DEP0169 (url.parse em dependência indireta) até que a lib seja atualizada
const prevEmit = process.emit;
process.emit = function (name, data, ...args) {
  if (name === 'warning' && data && data.name === 'DeprecationWarning' && (data.code === 'DEP0169' || (data.message && data.message.includes('url.parse')))) {
    return false;
  }
  return prevEmit.apply(this, [name, data, ...args]);
};

// Importações de módulos fundamentais
require('dotenv').config({ quiet: true });
const express = require('express');
const session = require('express-session');
const path = require('path');
const { testConnection } = require('./config/database');
const { loadUserForViews, requireAdmin } = require('./middleware/authMiddleware');

// ==========================================
// INICIALIZAÇÃO DO APLICATIVO
// ==========================================
const app = express();

// ==========================================
// CONFIGURAÇÕES (VIEW ENGINE - V)
// ==========================================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ==========================================
// MIDDLEWARES GLOBAIS
// ==========================================
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Sessão: login com expiração (ex.: 24h). Em produção use store em Redis ou DB.
const SESSION_MAX_AGE_MS = parseInt(process.env.SESSION_MAX_AGE_MS, 10) || 24 * 60 * 60 * 1000; // 24h
app.use(session({
  secret: process.env.SESSION_SECRET || 'neofarma-session-secret-change-in-production',
  resave: false,
  saveUninitialized: false,
  name: 'neofarma.sid',
  cookie: {
    maxAge: SESSION_MAX_AGE_MS,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
  },
}));

// Disponibiliza a quantidade total de itens do carrinho nas views
app.use((req, res, next) => {
  const items = (req.session && req.session.cart && Array.isArray(req.session.cart.items))
    ? req.session.cart.items
    : [];
  const count = items.reduce((acc, item) => acc + (parseInt(item.quantity, 10) || 0), 0);
  res.locals.cartItemCount = count;
  next();
});

// Disponibiliza usuário logado nas views (res.locals.user)
app.use(loadUserForViews);

// ==========================================
// ROTAS (MVC: routes -> controllers -> models)
// ==========================================
const indexRoutes = require('./routes/indexRoutes');
const apiRoutes = require('./routes/apiRoutes');
const adminRoutes = require('./routes/adminRoutes');

app.use('/', indexRoutes);
app.use('/api', apiRoutes);
app.use('/admin', requireAdmin, adminRoutes);

// ==========================================
// TRATAMENTO DE ERROS (404 & 500)
// ==========================================
app.use((req, res, next) => {
  res.status(404).render('404', { title: 'Página Não Encontrada' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  const wantsJson = req.xhr || /application\/json/.test(req.get('accept') || '') || (req.method === 'POST' && req.path === '/login');
  const isUploadError = err && (err.name === 'MulterError' || /Tipo de arquivo não permitido/i.test(err.message || ''));
  if (wantsJson) {
    if (isUploadError) {
      return res.status(400).json({ ok: false, message: err.message || 'Falha no upload da imagem.' });
    }
    return res.status(500).json({ ok: false, message: 'Erro interno no servidor. Tente novamente.' });
  }
  res.status(500).render('500', { title: 'Erro Interno no Servidor' });
});

// ==========================================
// INICIALIZAÇÃO DO SERVIDOR
// ==========================================
const PORT = process.env.PORT || 3555;

app.listen(PORT, async () => {
  console.log(`🚀 Servidor Neofarma rodando na porta ${PORT}`);
  console.log(`🔗 Acesse: http://localhost:${PORT}`);
  const ok = await testConnection();
  if (ok) console.log('✅ MySQL conectado (neofarma).');
  else console.log('⚠️ MySQL não conectado. Verifique config/database.js e o banco neofarma.');
});

module.exports = app;
