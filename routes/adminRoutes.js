const express = require('express');
const router = express.Router();
const admin = require('../controllers/adminController');
const clientController = require('../controllers/clientController');
const inventoryAdminController = require('../controllers/inventoryAdminController');
const financeAdminController = require('../controllers/financeAdminController');
const serviceAppointmentAdminController = require('../controllers/serviceAppointmentAdminController');
const purchaseAdminController = require('../controllers/purchaseAdminController');
const employeeAdminController = require('../controllers/employeeAdminController');
const fulfillmentAdminController = require('../controllers/fulfillmentAdminController');
const promotionAdminController = require('../controllers/promotionAdminController');
const { uploadProductImage } = require('../middleware/uploadProductImage');

// Convenção de organização das rotas:
// 1) Separar por bloco de serviço.
// 2) Dentro de cada bloco, priorizar ordem: GET -> POST -> PUT -> DELETE.
// 3) Manter rotas específicas antes das genéricas para evitar conflito.

// ===== Dashboard principal =====
router.get('/', admin.dashboard);

// ===== API auxiliar (validação em tempo real) =====
router.get('/api/slug-disponivel', admin.checkSlugAvailability);

// ===== Gestão global de lotes =====
router.get('/lotes', inventoryAdminController.listAllBatchesPage);
router.get('/lotes/export.csv', inventoryAdminController.exportCsv);
router.get('/lotes/:id', inventoryAdminController.getBatchDetail);
router.post('/lotes/delete-many', inventoryAdminController.deleteManyBatches);

// ===== Funcionários (RF_B1) =====
router.get('/funcionarios', employeeAdminController.renderPage);
router.post('/funcionarios', employeeAdminController.saveEmployee);

// ===== Gestão de clientes =====
router.get('/clientes', clientController.listClients);
router.get('/clientes/novo', clientController.getRegisterNew);
router.post('/clientes/novo', clientController.postRegisterNew);

// ===== Gestão de laboratórios =====
router.get('/laboratorios', admin.listLabs);
router.post('/laboratorios', admin.saveLab);
router.delete('/laboratorios/:id', admin.deleteLab);

// ===== Gestão de fornecedores =====
router.get('/fornecedores', admin.listSuppliers);
router.post('/fornecedores', admin.saveSupplier);
router.delete('/fornecedores/:id', admin.deleteSupplier);

// ===== Gestão de categorias =====
router.get('/categorias', admin.listCategories);
router.post('/categorias', admin.saveCategory);
router.delete('/categorias/:id', admin.deleteCategory);

// ===== Tipos de produto (RF_B3) =====
router.get('/tipos-produto', admin.listProductTypes);
router.post('/tipos-produto', admin.saveProductType);
router.delete('/tipos-produto/:id', admin.deleteProductType);

// ===== Compras (RF_F3) =====
router.get('/compras/catalogo', purchaseAdminController.listSuppliersProducts);
router.get('/compras', purchaseAdminController.renderPage);
router.get('/compras/:id', purchaseAdminController.getOrderJson);
router.post('/compras', purchaseAdminController.createOrder);
router.post('/compras/:id/pagamento', purchaseAdminController.confirmPayment);
router.post('/compras/:id/receber', purchaseAdminController.receiveDelivery);
router.delete('/compras/:id', purchaseAdminController.cancelOrder);

// ===== Descarte (RF_F5) =====
router.get('/descartes', inventoryAdminController.renderDisposalsPage);
router.get('/descartes/produtos/:productId/lotes', inventoryAdminController.listBatchesForProduct);
router.post('/descartes', inventoryAdminController.registerDisposal);

// ===== Financeiro =====
router.get('/financas', financeAdminController.renderFinanceDashboard);
router.get('/financas/orders', financeAdminController.apiListOrdersFinance);
router.get('/financas/orders/:id', financeAdminController.apiGetOrderFinanceDetail);
router.get('/financas/relatorios', financeAdminController.renderFinanceReportsPage);
router.get('/financas/relatorios/export.csv', financeAdminController.exportFinanceReportCsv);
router.get('/financas/relatorios/imprimir', financeAdminController.exportFinanceReportPrint);
router.get('/financas/recibos', financeAdminController.renderFinanceReceiptsPage);
router.get('/financas/pedidos', financeAdminController.renderFinanceOrdersPage);
router.post('/financas/orders/:id/mark-payment', financeAdminController.apiMarkPayment);

// ===== Expedição de pedidos da loja =====
router.get('/expedicao', fulfillmentAdminController.renderPage);
router.get('/expedicao/pedidos', fulfillmentAdminController.apiListOrders);
router.get('/expedicao/pedidos/:id', fulfillmentAdminController.apiGetOrderDetail);
router.post('/expedicao/pedidos/:id/despachar', fulfillmentAdminController.apiMarkShipped);
router.post('/expedicao/pedidos/:id/entregar', fulfillmentAdminController.apiMarkDelivered);

// ===== Agendamentos de serviços =====
router.get('/agendamentos-servicos', serviceAppointmentAdminController.renderPage);
router.get('/agendamentos-servicos/caixa', serviceAppointmentAdminController.renderCashDeskPage);
router.get('/agendamentos-servicos/caixa/export.csv', serviceAppointmentAdminController.exportCashDeskCsv);
router.post('/agendamentos-servicos/servicos', serviceAppointmentAdminController.saveService);
router.post('/agendamentos-servicos/profissionais', serviceAppointmentAdminController.saveProfessional);
router.get('/agendamentos-servicos/profissionais/:id/disponibilidade', serviceAppointmentAdminController.getProfessionalAvailability);
router.get('/agendamentos-servicos/disponibilidade/slots', serviceAppointmentAdminController.getAvailabilitySlots);
router.get('/agendamentos-servicos/disponibilidade/dias', serviceAppointmentAdminController.getAvailableDays);
router.post('/agendamentos-servicos/feriados', serviceAppointmentAdminController.addHoliday);
router.post('/agendamentos-servicos/reservar', serviceAppointmentAdminController.reserveSlot);
router.post('/agendamentos-servicos/:id/pagamento', serviceAppointmentAdminController.processPayment);
router.post('/agendamentos-servicos/:id/iniciar', serviceAppointmentAdminController.startAttendance);
router.post('/agendamentos-servicos/:id/concluir', serviceAppointmentAdminController.completeAttendance);
router.post('/agendamentos-servicos/:id/ausente', serviceAppointmentAdminController.markNoShow);
router.post('/agendamentos-servicos/:id/nao-finalizado', serviceAppointmentAdminController.markIncomplete);
router.post('/agendamentos-servicos/:id/confirmar-pagamento', serviceAppointmentAdminController.markCashReceived);
router.post('/agendamentos-servicos/:id/receber-dinheiro', serviceAppointmentAdminController.markCashReceived);
router.put('/agendamentos-servicos/:id', serviceAppointmentAdminController.updateAppointment);
router.delete('/agendamentos-servicos/servicos/:id', serviceAppointmentAdminController.deleteService);
router.delete('/agendamentos-servicos/profissionais/:id', serviceAppointmentAdminController.deleteProfessional);
router.delete('/agendamentos-servicos/feriados/:id', serviceAppointmentAdminController.deleteHoliday);
router.delete('/agendamentos-servicos/:id', serviceAppointmentAdminController.deleteAppointment);

// ===== Vitrine e promoções =====
router.get('/vitrine', promotionAdminController.renderPage);
router.get('/vitrine/promocoes/:id', promotionAdminController.getPromotionJson);
router.get('/vitrine/api/produtos', promotionAdminController.searchProducts);
router.post('/vitrine/promocoes', promotionAdminController.savePromotion);
router.post('/vitrine/home', promotionAdminController.saveHomeConfig);
router.post('/vitrine/theme', promotionAdminController.saveThemeConfig);
router.post('/vitrine/sync', promotionAdminController.syncAll);
router.delete('/vitrine/promocoes/:id', promotionAdminController.deletePromotion);

// ===== Gestão de produtos e mídia =====
router.get('/produtos', admin.listProducts);
router.get('/produtos/:id/imagens', admin.getProductImages);
router.get('/produtos/:id/lotes', inventoryAdminController.listBatches);
router.post('/produtos', admin.saveProduct);
router.post('/produtos/:id/imagens', admin.addProductImage);
router.post('/produtos/:id/imagens/upload', uploadProductImage.single('image'), admin.uploadProductImage);
router.post('/produtos/:id/lotes', inventoryAdminController.createBatch);
router.put('/produtos/lotes/:batchId', inventoryAdminController.updateBatch);
router.delete('/produtos/lotes/:batchId', inventoryAdminController.deleteBatch);
router.delete('/produtos/imagens/:id', admin.deleteProductImage);
router.get('/produtos/:id/exclusao', admin.getProductDeletionInfo);
router.delete('/produtos/:id', admin.deleteProduct);

module.exports = router;
