// Importações de módulos fundamentais
const express = require('express');
const path = require('path');

// Módulos comentados que serão implementados futuramente
// const session = require('express-session'); // Para gerenciar sessões de usuários (Login/Roles)
// const cookieParser = require('cookie-parser'); // Para ler cookies
// const cors = require('cors'); // Para permitir requisições de outras origens, se houver API separada
// require('dotenv').config(); // Para carregar variáveis de ambiente (credenciais de Banco de Dados, Senhas)

// ==========================================
// INICIALIZAÇÃO DO APLICATIVO
// ==========================================
const app = express();

// ==========================================
// CONFIGURAÇÕES (VIEW ENGINE - V)
// ==========================================
// Define o EJS (ou outro) como motor de visualização para renderizar o HTML dinâmico
// app.set('view engine', 'ejs');
// app.set('views', path.join(__dirname, 'views')); // Define a pasta onde ficarão as Views

// ==========================================
// MIDDLEWARES GLOBAIS
// ==========================================
// app.use(cors());
app.use(express.json()); // Permite o servidor entender requisições com corpo JSON (API)
app.use(express.urlencoded({ extended: true })); // Permite entender dados enviados por formulários HTML
app.use(express.static(path.join(__dirname, 'public'))); // Define a pasta de arquivos estáticos (CSS, JS do cliente, Imagens)

// Middlewares de Sessão / Autenticação (A ser implementado depois)
/*
app.use(cookieParser());
app.use(session({
    secret: process.env.SESSION_SECRET || 'chave_secreta_neofarma',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false } // 'true' quando estiver em HTTPS
}));
*/

// ==========================================
// IMPORTAÇÃO DE ROTAS (ROUTER -> CONTROLLERS - C)
// ==========================================
// Nesse padrão MVC, os arquivos de rota recebem a requisição e chamam a função correspondente no Controller.
// const indexRoutes = require('./routes/indexRoutes'); // Rotas públicas (Home, Categoria)
// const authRoutes = require('./routes/authRoutes');   // Rotas de login, registro, logout
// const productRoutes = require('./routes/productRoutes'); // Rotas do catálogo de produtos
// const adminRoutes = require('./routes/adminRoutes'); // Rotas do painel administrativo (CRUD, relatórios)

// ==========================================
// DEFINIÇÃO DAS ROTAS NO APP
// ==========================================
// app.use('/', indexRoutes);
// app.use('/auth', authRoutes);
// app.use('/produtos', productRoutes);
// app.use('/admin', adminRoutes);

// Rota de Teste (Pode ser removida assim que configurar as indexRoutes)
app.get('/', (req, res) => {
    res.send('<h1>Servidor Neofarma rodando com sucesso!</h1><p>A estrutura MVC base está pronta.</p>');
});

// ==========================================
// TRATAMENTO DE ERROS GENÉRICOS (404 & 500)
// ==========================================

// Middleware para capturar rota não encontrada (Erro 404 - Not Found)
/*
app.use((req, res, next) => {
    res.status(404).render('404', { title: 'Página Não Encontrada' });
});
*/

// Middleware Global para Tratamento de Erros no provedor (Erro 500 - Internal Server Error)
/*
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).render('500', { title: 'Erro Interno no Servidor' });
});
*/

// ==========================================
// INICIALIZAÇÃO DO SERVIDOR (LISTEN)
// ==========================================
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 Servidor Neofarma rodando na porta ${PORT}`);
    console.log(`🔗 Acesse: http://localhost:${PORT}`);
});

// Exporta o aplicativo Express para caso de testes automatizados ou importação separada no futuro
module.exports = app;
