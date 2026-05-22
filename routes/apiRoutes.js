const express = require('express');
const router = express.Router();
const clientController = require('../controllers/clientController');
const commerceController = require('../controllers/commerceController');
const serviceAppointmentAdminController = require('../controllers/serviceAppointmentAdminController');
const { requireAuth } = require('../middleware/authMiddleware');

// Convenção de organização das rotas:
// 1) Separar por bloco de serviço.
// 2) Dentro de cada bloco, priorizar ordem: GET -> POST -> PUT -> DELETE.
// 3) Manter rotas específicas antes das genéricas para evitar conflito.

// ===== API de clientes =====
router.get('/clientes', clientController.apiList);
router.get('/clientes/:id', clientController.apiGetOne);
router.post('/clientes/excluir-massa', clientController.apiDeleteMany);
router.put('/clientes/:id', clientController.apiUpdate);
router.delete('/clientes/:id', clientController.apiDelete);

// ===== API de carrinho =====
router.get('/cart', commerceController.apiGetCart);
router.post('/cart/items', commerceController.apiAddToCart);
router.put('/cart/items/:productId', commerceController.apiUpdateCartItem);
router.delete('/cart/items/:productId', commerceController.apiRemoveCartItem);
router.delete('/cart', commerceController.apiClearCart);

// ===== API de frete =====
router.post('/shipping/quote', commerceController.apiShippingQuote);
router.post('/shipping/select', commerceController.apiSetShipping);

// ===== API de checkout/pagamento =====
router.post('/checkout/payment-preview', requireAuth, commerceController.apiPaymentPreview);
router.post('/checkout/finalize', requireAuth, commerceController.finalizeCheckout);

// ===== API de agendamentos (cliente) =====
router.get('/service-appointments/availability/slots', requireAuth, serviceAppointmentAdminController.getAvailabilitySlots);
router.get('/service-appointments/availability/days', requireAuth, serviceAppointmentAdminController.getAvailableDays);
router.post('/service-appointments', requireAuth, serviceAppointmentAdminController.createCustomerBooking);
router.post('/service-appointments/:id/pay', requireAuth, serviceAppointmentAdminController.payCustomerAppointment);

module.exports = router;
