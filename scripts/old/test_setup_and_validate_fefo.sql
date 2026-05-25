USE neofarma;

-- ============================================================
-- Setup + Validação FEFO (end-to-end assistido por SQL)
-- ============================================================
-- O checkout precisa ser executado pela aplicação para criar pedido.
-- Este script prepara cenário determinístico e depois valida o último pedido.
-- ============================================================

-- 0) Parâmetros
-- Se @product_id ficar NULL, o script tenta pegar automaticamente o primeiro produto ACTIVE.
SET @product_id := NULL;
SET @qty_lote_a := 5;
SET @qty_lote_b := 10;

SET @product_id := COALESCE(
  @product_id,
  (SELECT id FROM products WHERE status = 'ACTIVE' ORDER BY id ASC LIMIT 1)
);

-- 1) Garantir produto ativo existente
SELECT id, name, status
FROM products
WHERE id = @product_id;

SELECT
  'PRODUCT_SELECTED' AS check_name,
  CASE WHEN @product_id IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status,
  COALESCE(CAST(@product_id AS CHAR), 'Nenhum produto ACTIVE encontrado') AS details;

-- 2) Limpar lotes anteriores do produto de teste
DELETE FROM inventory_batches
WHERE product_id = @product_id;

-- 3) Inserir lotes controlados
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
VALUES
  (@product_id, 'TEST-FEFO-A', '2025-01-01', DATE_ADD(CURDATE(), INTERVAL 20 DAY), @qty_lote_a),
  (@product_id, 'TEST-FEFO-B', '2025-01-01', DATE_ADD(CURDATE(), INTERVAL 120 DAY), @qty_lote_b),
  (@product_id, 'TEST-FEFO-EXP', '2024-01-01', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 50);

-- 4) Snapshot pré-checkout
SELECT
  'PRE_STOCK' AS snapshot_type,
  b.id, b.product_id, b.batch_code, b.expiry_date, b.quantity
FROM inventory_batches b
WHERE b.product_id = @product_id
ORDER BY b.expiry_date ASC, b.id ASC;

-- ============================================================
-- AGORA, no sistema web:
--   a) Adicione produto @product_id no carrinho (quantidade 3)
--   b) Finalize checkout
-- Depois volte e rode APENAS a seção "PÓS-CHECKOUT".
-- ============================================================

-- 5) PÓS-CHECKOUT: calcular último pedido
SET @latest_order_id := (SELECT id FROM orders ORDER BY id DESC LIMIT 1);

SELECT
  'ORDER_EXISTS' AS check_name,
  CASE WHEN @latest_order_id IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status,
  @latest_order_id AS details;

-- 6) Validação de itens e pagamento
SELECT
  'ORDER_HAS_ITEMS' AS check_name,
  CASE
    WHEN @latest_order_id IS NOT NULL
         AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = @latest_order_id)
    THEN 'PASS' ELSE 'FAIL'
  END AS status,
  (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = @latest_order_id) AS details;

SELECT
  'ORDER_HAS_PAYMENT' AS check_name,
  CASE
    WHEN @latest_order_id IS NOT NULL
         AND EXISTS (SELECT 1 FROM payments p WHERE p.order_id = @latest_order_id)
    THEN 'PASS' ELSE 'FAIL'
  END AS status,
  (SELECT COUNT(*) FROM payments p WHERE p.order_id = @latest_order_id) AS details;

-- 7) FEFO: o lote TEST-FEFO-A deve ser priorizado enquanto houver saldo
WITH used AS (
  SELECT
    oi.order_id,
    oi.product_id,
    oi.batch_id,
    b.batch_code,
    b.expiry_date,
    oi.quantity
  FROM order_items oi
  INNER JOIN inventory_batches b ON b.id = oi.batch_id
  WHERE oi.order_id = @latest_order_id
    AND oi.product_id = @product_id
)
SELECT
  'FEFO_TEST_LOT_PRIORITY' AS check_name,
  CASE
    WHEN NOT EXISTS (SELECT 1 FROM used) THEN 'FAIL'
    WHEN EXISTS (
      SELECT 1 FROM used
      WHERE batch_code = 'TEST-FEFO-B'
    ) AND (
      SELECT quantity FROM inventory_batches
      WHERE product_id = @product_id AND batch_code = 'TEST-FEFO-A'
      LIMIT 1
    ) > 0
    THEN 'FAIL'
    ELSE 'PASS'
  END AS status,
  'PASS = lote A (vence primeiro) foi consumido antes do lote B' AS details;

-- 8) Nenhum lote vencido pode aparecer no pedido
SELECT
  'NO_EXPIRED_BATCH_SOLD' AS check_name,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM order_items oi
      INNER JOIN inventory_batches b ON b.id = oi.batch_id
      WHERE oi.order_id = @latest_order_id
        AND b.expiry_date < CURDATE()
    ) THEN 'FAIL'
    ELSE 'PASS'
  END AS status,
  'PASS = lote vencido não vendido' AS details;

-- 9) Snapshot pós-checkout
SELECT
  'POST_STOCK' AS snapshot_type,
  b.id, b.product_id, b.batch_code, b.expiry_date, b.quantity
FROM inventory_batches b
WHERE b.product_id = @product_id
ORDER BY b.expiry_date ASC, b.id ASC;

SELECT
  oi.order_id,
  oi.product_id,
  p.name AS product_name,
  oi.batch_id,
  b.batch_code,
  b.expiry_date,
  oi.quantity,
  oi.unit_price,
  oi.line_total
FROM order_items oi
INNER JOIN products p ON p.id = oi.product_id
INNER JOIN inventory_batches b ON b.id = oi.batch_id
WHERE oi.order_id = @latest_order_id
ORDER BY b.expiry_date ASC, oi.id ASC;
