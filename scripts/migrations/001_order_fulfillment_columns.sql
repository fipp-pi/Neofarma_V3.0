-- Colunas de expedição em pedidos (MVP operacional)
-- Execute em bancos criados ANTES dessas colunas existirem em orders.
-- Compatível com MySQL 5.7+ e 8.x (não usa ADD COLUMN IF NOT EXISTS).
--
-- Se você acabou de rodar scripts/DB_Neofarma_clean.sql, as colunas já existem
-- e este script não altera nada (execução segura / idempotente).

USE PFS1_10442511034;

DROP PROCEDURE IF EXISTS neofarma_add_column_if_missing;

DELIMITER $$

CREATE PROCEDURE neofarma_add_column_if_missing(
  IN p_table VARCHAR(64),
  IN p_column VARCHAR(64),
  IN p_definition TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table
      AND COLUMN_NAME = p_column
  ) THEN
    SET @ddl = CONCAT(
      'ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_definition
    );
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END$$

DELIMITER ;

CALL neofarma_add_column_if_missing(
  'orders', 'tracking_code', 'VARCHAR(80) NULL AFTER shipping_deadline_days'
);
CALL neofarma_add_column_if_missing(
  'orders', 'shipped_at', 'DATETIME NULL AFTER tracking_code'
);
CALL neofarma_add_column_if_missing(
  'orders', 'delivered_at', 'DATETIME NULL AFTER shipped_at'
);
CALL neofarma_add_column_if_missing(
  'orders', 'delivered_by', 'BIGINT UNSIGNED NULL AFTER delivered_at'
);

-- FK opcional (ignorada se já existir)
SET @fk_exists = (
  SELECT COUNT(*)
  FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE()
    AND TABLE_NAME = 'orders'
    AND CONSTRAINT_NAME = 'fk_orders_delivered_by'
    AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);

SET @fk_sql = IF(
  @fk_exists = 0,
  'ALTER TABLE orders
     ADD CONSTRAINT fk_orders_delivered_by
     FOREIGN KEY (delivered_by) REFERENCES users(id)
     ON UPDATE CASCADE ON DELETE SET NULL',
  'SELECT ''FK fk_orders_delivered_by já existe'' AS info'
);

PREPARE fk_stmt FROM @fk_sql;
EXECUTE fk_stmt;
DEALLOCATE PREPARE fk_stmt;

DROP PROCEDURE IF EXISTS neofarma_add_column_if_missing;

-- Conferência rápida
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'orders'
  AND COLUMN_NAME IN ('tracking_code', 'shipped_at', 'delivered_at', 'delivered_by')
ORDER BY ORDINAL_POSITION;
