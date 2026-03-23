const express = require('express');
const router = express.Router();
const clientController = require('../controllers/clientController');
const commerceController = require('../controllers/commerceController');
const serviceAppointmentAdminController = require('../controllers/serviceAppointmentAdminController');
const { requireAuth } = require('../middleware/authMiddleware');

router.get('/clientes', clientController.apiList);
router.get('/clientes/:id', clientController.apiGetOne);
router.put('/clientes/:id', clientController.apiUpdate);
router.delete('/clientes/:id', clientController.apiDelete);
router.post('/clientes/excluir-massa', clientController.apiDeleteMany);

router.get('/cart', commerceController.apiGetCart);
router.post('/cart/items', commerceController.apiAddToCart);
router.put('/cart/items/:productId', commerceController.apiUpdateCartItem);
router.delete('/cart/items/:productId', commerceController.apiRemoveCartItem);
router.delete('/cart', commerceController.apiClearCart);

router.post('/shipping/quote', commerceController.apiShippingQuote);
router.post('/shipping/select', commerceController.apiSetShipping);

router.post('/checkout/finalize', requireAuth, commerceController.finalizeCheckout);
router.post('/checkout/payment-preview', requireAuth, commerceController.apiPaymentPreview);
router.post('/service-appointments', requireAuth, serviceAppointmentAdminController.createCustomerBooking);

module.exports = router;
