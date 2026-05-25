-- Alinhamento ERS NeoFarma — executar uma vez em bancos já existentes.
-- Instalações novas: use scripts/DB_Neofarma_clean.sql (schema ERS já incorporado).

-- RF_F2: itens aguardando confirmação de pagamento (sem baixa de estoque)
CREATE TABLE IF NOT EXISTS order_pending_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id      BIGINT UNSIGNED NOT NULL,
  product_id    BIGINT UNSIGNED NOT NULL,
  quantity      INT NOT NULL,
  unit_price    DECIMAL(12,2) NOT NULL,
  line_total    DECIMAL(12,2) NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_order_pending_items_order (order_id),
  CONSTRAINT fk_order_pending_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_pending_items_product
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- RF_B3: tipos de produto
CREATE TABLE IF NOT EXISTS product_types (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(120) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

SET @col_exists := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'products' AND COLUMN_NAME = 'product_type_id'
);
SET @sql_pt := IF(@col_exists = 0,
  'ALTER TABLE products ADD COLUMN product_type_id BIGINT UNSIGNED NULL AFTER main_supplier_id,
   ADD CONSTRAINT fk_products_product_type FOREIGN KEY (product_type_id) REFERENCES product_types(id) ON UPDATE CASCADE ON DELETE SET NULL',
  'SELECT 1');
PREPARE stmt FROM @sql_pt; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- RF_F5: descarte de estoque
CREATE TABLE IF NOT EXISTS inventory_disposals (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id      BIGINT UNSIGNED NOT NULL,
  batch_id        BIGINT UNSIGNED NOT NULL,
  quantity        INT NOT NULL,
  reason          VARCHAR(255) NOT NULL,
  disposed_by     BIGINT UNSIGNED NULL COMMENT 'users.id do funcionário',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_disposals_product (product_id),
  INDEX idx_disposals_batch (batch_id),
  CONSTRAINT fk_disposals_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_disposals_batch FOREIGN KEY (batch_id) REFERENCES inventory_batches(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_disposals_user FOREIGN KEY (disposed_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- RF_F3: fluxo de compras (aguardando entrega)
ALTER TABLE purchase_orders
  MODIFY COLUMN status ENUM('DRAFT','AWAITING_DELIVERY','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT';

SET @po_pay := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'purchase_orders' AND COLUMN_NAME = 'payment_status'
);
SET @sql_po := IF(@po_pay = 0,
  "ALTER TABLE purchase_orders
     ADD COLUMN payment_status ENUM('PENDING','PAID','FAILED') NOT NULL DEFAULT 'PENDING' AFTER status,
     ADD COLUMN payment_method ENUM('PIX','TRANSFER','BOLETO','CASH') NULL AFTER payment_status,
     ADD COLUMN notes TEXT NULL AFTER total_amount",
  'SELECT 1');
PREPARE stmt2 FROM @sql_po; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

SET @po_qty := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'purchase_order_items' AND COLUMN_NAME = 'quantity_received'
);
SET @sql_poi := IF(@po_qty = 0,
  'ALTER TABLE purchase_order_items
     ADD COLUMN quantity_received INT NOT NULL DEFAULT 0 AFTER quantity,
     ADD COLUMN batch_code VARCHAR(60) NULL AFTER quantity_received,
     ADD COLUMN expiry_date DATE NULL AFTER batch_code',
  'SELECT 1');
PREPARE stmt3 FROM @sql_poi; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;

-- Perfil estoquista (RF_F5)
INSERT IGNORE INTO roles (name, description) VALUES ('ESTOQUISTA', 'Estoquista — descarte e conferência de estoque');

UPDATE purchase_orders SET status = 'AWAITING_DELIVERY' WHERE status = 'OPEN';
UPDATE purchase_orders SET status = 'DRAFT' WHERE status NOT IN ('DRAFT','AWAITING_DELIVERY','RECEIVED','CANCELLED');
