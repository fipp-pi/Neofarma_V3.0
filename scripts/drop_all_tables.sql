-- ============================================================
-- NEOFARMA — Remover TODAS as tabelas (zerar dados + estrutura)
-- ============================================================
--
-- O banco `neofarma` continua existindo; apenas as tabelas são
-- apagadas. Depois, recrie a estrutura com os scripts oficiais.
--
-- USO (PowerShell / terminal):
--   mysql -u root -p neofarma < scripts/drop_all_tables.sql
--
-- RECRIAR ESTRUTURA (ordem sugerida):
--   1. mysql -u root -p < scripts/DB_Neofarma_clean.sql
--   2. mysql -u root -p neofarma < scripts/migrations/001_order_fulfillment_columns.sql
--   3. mysql -u root -p neofarma < scripts/migrations/003_promotions_storefront.sql
--
-- DADOS DE DEMONSTRAÇÃO (opcional):
--   mysql -u root -p neofarma < scripts/demo_neofarma.sql
--
-- ATENÇÃO: operação irreversível. Faça backup antes se necessário.
-- ============================================================

USE PFS1_10442511034;

SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------
-- Opção A (recomendada): remove dinamicamente TODAS as tabelas
-- do schema atual, independente de FKs ou tabelas extras.
-- ----------------------------------------------------------------
SET @drop_sql = (
  SELECT IF(
    COUNT(*) = 0,
    'SELECT ''Nenhuma tabela encontrada em neofarma.'' AS info',
    CONCAT(
      'DROP TABLE IF EXISTS ',
      GROUP_CONCAT(CONCAT('`', table_name, '`') ORDER BY table_name SEPARATOR ', ')
    )
  )
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_type = 'BASE TABLE'
);

PREPARE drop_stmt FROM @drop_sql;
EXECUTE drop_stmt;
DEALLOCATE PREPARE drop_stmt;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;

-- Confirmação
SELECT
  COUNT(*) AS tabelas_restantes
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_type = 'BASE TABLE';

-- Esperado: tabelas_restantes = 0
