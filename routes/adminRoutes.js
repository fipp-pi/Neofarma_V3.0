const express = require('express');
const router = express.Router();
const admin = require('../controllers/adminController');
const clientController = require('../controllers/clientController');
const inventoryAdminController = require('../controllers/inventoryAdminController');
const financeAdminController = require('../controllers/financeAdminController');
const serviceAppointmentAdminController = require('../controllers/serviceAppointmentAdminController');
const { uploadProductImage } = require('../middleware/uploadProductImage');

// Convenção de organização das rotas:
// 1) Separar por bloco de serviço.
// 2) Dentro de cada bloco, priorizar ordem: GET -> POST -> PUT -> DELETE.
// 3) Manter rotas específicas antes das genéricas para evitar conflito.

// ===== Dashboard principal =====
router.get('/', admin.dashboard);

// ===== Gestão global de lotes =====
router.get('/lotes', inventoryAdminController.listAllBatchesPage);
router.get('/lotes/export.csv', inventoryAdminController.exportCsv);
router.post('/lotes/delete-many', inventoryAdminController.deleteManyBatches);

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

// ===== Financeiro =====
router.get('/financas', financeAdminController.renderFinanceDashboard);
router.get('/financas/orders', financeAdminController.apiListOrdersFinance);
router.get('/financas/relatorios', financeAdminController.renderFinanceReportsPage);
router.get('/financas/recibos', financeAdminController.renderFinanceReceiptsPage);
router.get('/financas/pedidos', financeAdminController.renderFinanceOrdersPage);
router.post('/financas/orders/:id/mark-payment', financeAdminController.apiMarkPayment);

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
router.delete('/produtos/:id', admin.deleteProduct);

module.exports = router;
