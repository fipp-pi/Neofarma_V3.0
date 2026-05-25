USE neofarma;

-- ============================================================
-- Validação automática do fluxo Checkout + FEFO
-- Ajuste @product_id se desejar testar outro produto
-- ============================================================

SET @product_id := 1;
SET @latest_order_id := (SELECT id FROM orders ORDER BY id DESC LIMIT 1);

-- 1) Verificações básicas de existência
SELECT
  'ORDER_EXISTS' AS check_name,
  CASE WHEN @latest_order_id IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status,
  @latest_order_id AS details;

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

-- 2) Consistência financeira do pedido
SELECT
  'ORDER_TOTAL_MATCH' AS check_name,
  CASE
    WHEN o.id IS NULL THEN 'FAIL'
    WHEN ROUND(o.subtotal + o.shipping_cost, 2) = ROUND(o.total, 2) THEN 'PASS'
    ELSE 'FAIL'
  END AS status,
  CONCAT('subtotal=', IFNULL(o.subtotal, 0), ', shipping=', IFNULL(o.shipping_cost, 0), ', total=', IFNULL(o.total, 0)) AS details
FROM orders o
WHERE o.id = @latest_order_id;

SELECT
  'ORDER_ITEMS_SUM_MATCH_SUBTOTAL' AS check_name,
  CASE
    WHEN o.id IS NULL THEN 'FAIL'
    WHEN ROUND(IFNULL(x.items_sum, 0), 2) = ROUND(IFNULL(o.subtotal, 0), 2) THEN 'PASS'
    ELSE 'FAIL'
  END AS status,
  CONCAT('items_sum=', IFNULL(x.items_sum, 0), ', subtotal=', IFNULL(o.subtotal, 0)) AS details
FROM orders o
LEFT JOIN (
  SELECT order_id, SUM(line_total) AS items_sum
  FROM order_items
  GROUP BY order_id
) x ON x.order_id = o.id
WHERE o.id = @latest_order_id;

-- 3) Validação FEFO: lote usado no pedido deve ser o menor vencimento elegível
WITH first_eligible AS (
  SELECT
    b.product_id,
    MIN(b.expiry_date) AS first_expiry
  FROM inventory_batches b
  WHERE b.quantity >= 0
    AND b.expiry_date >= CURDATE()
  GROUP BY b.product_id
),
used_batches AS (
  SELECT
    oi.product_id,
    ib.expiry_date AS used_expiry,
    oi.order_id
  FROM order_items oi
  INNER JOIN inventory_batches ib ON ib.id = oi.batch_id
  WHERE oi.order_id = @latest_order_id
)
SELECT
  'FEFO_ORDER_CHECK' AS check_name,
  CASE
    WHEN NOT EXISTS (SELECT 1 FROM used_batches) THEN 'FAIL'
    WHEN EXISTS (
      SELECT 1
      FROM used_batches u
      INNER JOIN first_eligible f ON f.product_id = u.product_id
      WHERE u.used_expiry > f.first_expiry
    ) THEN 'FAIL'
    ELSE 'PASS'
  END AS status,
  'PASS = lotes usados vencem primeiro (ou empatam no menor vencimento)' AS details;

-- 4) Bloqueio de lotes vencidos: nenhum item do pedido deve apontar para lote vencido
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
  'PASS = nenhum lote vencido foi vendido' AS details;

-- 5) Snapshot útil do último pedido
SELECT
  o.id,
  o.customer_id,
  o.status,
  o.payment_method,
  o.payment_status,
  o.subtotal,
  o.shipping_cost,
  o.total,
  o.created_at
FROM orders o
WHERE o.id = @latest_order_id;

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

SELECT
  p.id AS product_id,
  p.name,
  b.id AS batch_id,
  b.batch_code,
  b.expiry_date,
  b.quantity AS current_quantity
FROM products p
INNER JOIN inventory_batches b ON b.product_id = p.id
WHERE p.id = @product_id
ORDER BY b.expiry_date ASC, b.id ASC;
