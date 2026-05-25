-- GTIN-14 (caixa de distribuição) no cadastro de produto — executar uma vez em bancos existentes.

SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'gtin14'
);
SET @sql_gtin14 := IF(@col_exists = 0,
  'ALTER TABLE products ADD COLUMN gtin14 VARCHAR(20) NULL UNIQUE AFTER ean13',
  'SELECT 1');
PREPARE stmt FROM @sql_gtin14; EXECUTE stmt; DEALLOCATE PREPARE stmt;
