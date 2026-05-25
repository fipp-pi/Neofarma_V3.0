-- ============================================================
-- Galeria de imagens por produto (vitrine)
-- Execute este script no banco neofarma se a tabela não existir.
-- ============================================================

CREATE TABLE IF NOT EXISTS product_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(500) NOT NULL COMMENT 'URL ou caminho da imagem (ex: /assets/img/produtos/foto.jpg)',
  sort_order INT NOT NULL DEFAULT 0 COMMENT 'Ordem de exibição na vitrine (menor = primeiro)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_images_product
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  INDEX idx_product_images_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
