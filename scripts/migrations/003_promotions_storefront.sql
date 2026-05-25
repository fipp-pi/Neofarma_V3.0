-- Promoções campanha + vitrine configurável (home/tema)
-- Executar uma vez no banco neofarma.

CREATE TABLE IF NOT EXISTS promotions (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(120) NOT NULL,
  slug            VARCHAR(140) NOT NULL UNIQUE,
  description     TEXT NULL,
  discount_type   ENUM('PERCENT','FIXED_PRICE') NOT NULL DEFAULT 'PERCENT',
  discount_value  DECIMAL(10,2) NOT NULL DEFAULT 0,
  starts_at       DATETIME NOT NULL,
  ends_at         DATETIME NOT NULL,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  priority        INT NOT NULL DEFAULT 0,
  style_json      JSON NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_promotions_window (is_active, starts_at, ends_at),
  INDEX idx_promotions_priority (priority DESC)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS promotion_products (
  promotion_id      BIGINT UNSIGNED NOT NULL,
  product_id        BIGINT UNSIGNED NOT NULL,
  fixed_promo_price DECIMAL(10,2) NULL,
  PRIMARY KEY (promotion_id, product_id),
  CONSTRAINT fk_pp_promotion FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
  CONSTRAINT fk_pp_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS storefront_config (
  id          TINYINT UNSIGNED NOT NULL PRIMARY KEY DEFAULT 1,
  home_json   JSON NOT NULL,
  theme_json  JSON NOT NULL,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
