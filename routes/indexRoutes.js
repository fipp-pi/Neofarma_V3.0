const express = require('express');
const router = express.Router();
const { pageController, pages } = require('../controllers/pageController');
const authController = require('../controllers/authController');
const accountController = require('../controllers/accountController');
const catalogController = require('../controllers/catalogController');
const commerceController = require('../controllers/commerceController');
const serviceAppointmentAdminController = require('../controllers/serviceAppointmentAdminController');
const { requireAuth } = require('../middleware/authMiddleware');

// Rotas específicas primeiro (têm prioridade sobre o loop de páginas abaixo)
router.get('/account', requireAuth, accountController.getAccount);
router.post('/account', requireAuth, accountController.postAccount);
router.post('/account/alterar-senha', requireAuth, accountController.postAlterarSenha);
router.post('/account/address', requireAuth, accountController.postAddress);
router.put('/account/address/:id', requireAuth, accountController.putAddress);
router.delete('/account/address/:id', requireAuth, accountController.deleteAddress);
router.post('/account/address/:id/default', requireAuth, accountController.setAddressDefault);
router.post('/account/orders/:id/cancel', requireAuth, accountController.postCancelOrder);
router.get('/account/agendamentos', requireAuth, serviceAppointmentAdminController.renderCustomerBookingPage);
router.get('/account/agendamentos/pagar/:id', requireAuth, serviceAppointmentAdminController.renderCustomerPaymentPage);
router.get('/account/agendamentos/recibo/:id', requireAuth, serviceAppointmentAdminController.renderCustomerReceiptPage);
router.get('/logout', authController.getLogout);
router.get('/', catalogController.home);
router.get('/cart', commerceController.renderCart);
router.get('/checkout', requireAuth, commerceController.renderCheckout);
router.get('/order-confirmation', requireAuth, commerceController.renderOrderConfirmation);
router.get('/category', catalogController.listCategory);
router.get('/produtos', catalogController.listCatalog);
router.get('/produtos/:id', catalogController.getProductDetail);

pages.forEach((p) => {
  if (p.path === '/account' || p.path === '/' || p.path === '/cart' || p.path === '/checkout' || p.path === '/order-confirmation') return;
  const handler = pageController[p.path === '/' ? 'index' : p.path.slice(1).replace(/\//g, '_')];
  if (handler) router.get(p.path, handler);
});

// POST criar conta (registro público) - dados na tabela users + customers
router.post('/register', authController.postRegister);
// POST login - valida email/senha na tabela users
router.post('/login', authController.postLogin);

module.exports = router;
