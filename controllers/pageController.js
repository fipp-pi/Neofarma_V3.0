/**
 * Controller das páginas estáticas (apenas renderizam view com título/bodyClass/activeNav).
 */
function renderPage(view, options = {}) {
  return (req, res) => {
    res.render(view, {
      title: options.title || 'NeoFarma',
      bodyClass: options.bodyClass || '',
      activeNav: options.activeNav,
      ...options,
    });
  };
}

const pages = [
  { path: '/', view: 'index', title: 'Neofarma Home', bodyClass: 'index-page', activeNav: 'home' },
  { path: '/about', view: 'about', title: 'Sobre - NeoFarma', bodyClass: 'about-page', activeNav: 'about' },
  { path: '/contact', view: 'contact', title: 'Contato - NeoFarma', bodyClass: 'contact-page', activeNav: 'contact' },
  { path: '/category', view: 'category', title: 'Categorias - NeoFarma', bodyClass: 'category-page', activeNav: 'category' },
  { path: '/account', view: 'account', title: 'Minha Conta - NeoFarma', bodyClass: 'account-page' },
  { path: '/cart', view: 'cart', title: 'Carrinho - NeoFarma', bodyClass: 'cart-page' },
  { path: '/checkout', view: 'checkout', title: 'Checkout - NeoFarma', bodyClass: 'checkout-page' },
  { path: '/order-confirmation', view: 'order-confirmation', title: 'Pedido Confirmado - NeoFarma', bodyClass: 'order-confirmation-page' },
  { path: '/login', view: 'login', title: 'Login - NeoFarma', bodyClass: 'login-page' },
  { path: '/register', view: 'register', title: 'Registrar - NeoFarma', bodyClass: 'register-page' },
  { path: '/forgot-password', view: 'forgot_password', title: 'Recuperar Senha - NeoFarma', bodyClass: 'forgot-password-page' },
  { path: '/forgot-password-copy', view: 'forgot_password_copy', title: 'Recuperar Senha - NeoFarma', bodyClass: 'forgot-password-page' },
  { path: '/email-enviado', view: 'email_enviado', title: 'Email Enviado - NeoFarma' },
  { path: '/support', view: 'support', title: 'Suporte - NeoFarma' },
  { path: '/faq', view: 'faq', title: 'FAQ - NeoFarma' },
  { path: '/shiping-info', view: 'shiping-info', title: 'Envio - NeoFarma' },
  { path: '/payment-methods', view: 'payment-methods', title: 'Pagamentos - NeoFarma' },
  { path: '/privacy', view: 'privacy', title: 'Privacidade - NeoFarma' },
  { path: '/tos', view: 'tos', title: 'Termos - NeoFarma' },
  { path: '/return-policy', view: 'return-policy', title: 'Devoluções - NeoFarma' },
  { path: '/product-details', view: 'product-details', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 1 },
  { path: '/product-details2', view: 'product-details2', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 2 },
  { path: '/product-details3', view: 'product-details3', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 3 },
  { path: '/product-details4', view: 'product-details4', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 4 },
  { path: '/product-details5', view: 'product-details5', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 5 },
  { path: '/product-details6', view: 'product-details6', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 6 },
  { path: '/product-details7', view: 'product-details7', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 7 },
  { path: '/product-details8', view: 'product-details8', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 8 },
  { path: '/product-details9', view: 'product-details9', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 9 },
  { path: '/product-details10', view: 'product-details10', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 10 },
  { path: '/product-details11', view: 'product-details11', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 11 },
  { path: '/product-details12', view: 'product-details12', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 12 },
  { path: '/product-details13', view: 'product-details13', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 13 },
  { path: '/product-details14', view: 'product-details14', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 14 },
  { path: '/product-details15', view: 'product-details15', title: 'Detalhes do produto - NeoFarma', bodyClass: 'product-details-page', productId: 15 },
];

const pageController = {};
// Cria automaticamente os handlers de cada rota estática.
pages.forEach((p) => {
  pageController[p.path === '/' ? 'index' : p.path.slice(1).replace(/\//g, '_')] = renderPage(p.view, p);
});

module.exports = { pageController, pages };
