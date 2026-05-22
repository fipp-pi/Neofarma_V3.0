const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Convenção de organização das rotas:
// 1) Separar por bloco de serviço.
// 2) Dentro de cada bloco, priorizar ordem: GET -> POST -> PUT -> DELETE.
// 3) Manter rotas específicas antes das genéricas para evitar conflito.

// ===== Telas públicas de autenticação =====
router.get('/login', authController.getLogin);
router.get('/register', authController.getRegister);

module.exports = router;
