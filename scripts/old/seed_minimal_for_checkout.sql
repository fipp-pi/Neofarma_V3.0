USE neofarma;

-- ============================================================
-- Seed mínimo para testar catálogo, carrinho, checkout e FEFO
-- ============================================================

-- 1) Roles base
INSERT INTO roles (name, description) VALUES
  ('ADMIN', 'Administrador do sistema'),
  ('FUNCIONARIO', 'Funcionário da farmácia'),
  ('CLIENTE', 'Cliente da loja')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- 2) Métodos auxiliares
INSERT INTO payment_methods (name, description) VALUES
  ('CARTAO_CREDITO', 'Cartão de crédito'),
  ('PIX', 'Pagamento instantâneo PIX'),
  ('BOLETO', 'Boleto bancário')
ON DUPLICATE KEY UPDATE description = VALUES(description);

INSERT INTO shipping_methods (name, description, estimated_days) VALUES
  ('PADRAO', 'Envio padrão', 7),
  ('EXPRESSO', 'Envio expresso', 3)
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  estimated_days = VALUES(estimated_days);

-- 3) Endereço padrão
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code)
SELECT 'Rua Teste', '100', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010000'
WHERE NOT EXISTS (
  SELECT 1
  FROM addresses
  WHERE street = 'Rua Teste' AND number = '100' AND zip_code = '19010000'
);

SET @address_id := (
  SELECT id
  FROM addresses
  WHERE street = 'Rua Teste' AND number = '100' AND zip_code = '19010000'
  ORDER BY id DESC
  LIMIT 1
);

-- 4) Lab + Supplier
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active)
SELECT 'Lab Teste NeoFarma', '11111111000191', 'lab@teste.com', '18999990001', @address_id, 1
WHERE NOT EXISTS (SELECT 1 FROM labs WHERE name = 'Lab Teste NeoFarma');

SET @lab_id := (SELECT id FROM labs WHERE name = 'Lab Teste NeoFarma' ORDER BY id DESC LIMIT 1);

INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active)
SELECT 'Fornecedor Teste LTDA', 'Fornecedor Teste', '22222222000191', 'forn@teste.com', '18999990002', @address_id, 1
WHERE NOT EXISTS (SELECT 1 FROM suppliers WHERE corporate_name = 'Fornecedor Teste LTDA');

SET @supplier_id := (
  SELECT id
  FROM suppliers
  WHERE corporate_name = 'Fornecedor Teste LTDA'
  ORDER BY id DESC
  LIMIT 1
);

-- 5) Categoria
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT NULL, 'Fitoterápicos', 'fitoterapicos', 'Categoria de teste', 1
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug = 'fitoterapicos');

SET @category_id := (SELECT id FROM categories WHERE slug = 'fitoterapicos' LIMIT 1);

-- 6) Produto ativo
INSERT INTO products
  (lab_id, main_supplier_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
SELECT
  @lab_id,
  @supplier_id,
  'Produto Teste FEFO',
  'produto-teste-fefo',
  'SKU-TESTE-FEFO',
  '7891234567890',
  'Produto criado para validar checkout e FEFO',
  'Composição teste',
  'Uso teste',
  0,
  49.90,
  39.90,
  'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'produto-teste-fefo');

SET @product_id := (SELECT id FROM products WHERE slug = 'produto-teste-fefo' LIMIT 1);

-- 7) Relação produto-categoria
INSERT INTO product_categories (product_id, category_id)
SELECT @product_id, @category_id
WHERE NOT EXISTS (
  SELECT 1 FROM product_categories WHERE product_id = @product_id AND category_id = @category_id
);

-- 8) Imagem de fallback
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT @product_id, '/assets/img/product/product-1.webp', 0
WHERE NOT EXISTS (
  SELECT 1 FROM product_images WHERE product_id = @product_id
);

-- 9) Cliente de teste (senha: Cliente@123)
SET @role_cliente_id := (SELECT id FROM roles WHERE name = 'CLIENTE' LIMIT 1);

INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT
  @role_cliente_id,
  'Cliente Teste',
  'cliente.teste@neofarma.com',
  '$2b$10$N9qo8uLOickgx2ZMRZo5i.ejv6Lx0x6Wn2fNQbB8p4TQ9I6M4wG9K',
  '12345678900',
  '18999990003',
  '1995-01-01',
  1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cliente.teste@neofarma.com');

SET @user_id := (SELECT id FROM users WHERE email = 'cliente.teste@neofarma.com' LIMIT 1);

INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT @user_id, @address_id, 0
WHERE NOT EXISTS (SELECT 1 FROM customers WHERE user_id = @user_id);

SET @customer_id := (SELECT id FROM customers WHERE user_id = @user_id LIMIT 1);

INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT @customer_id, @address_id, 'Principal', 1
WHERE NOT EXISTS (
  SELECT 1
  FROM customer_addresses
  WHERE customer_id = @customer_id AND address_id = @address_id
);

-- 10) Lotes para FEFO
DELETE FROM inventory_batches WHERE product_id = @product_id;

INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
VALUES
  (@product_id, 'SEED-FEFO-A', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 5),
  (@product_id, 'SEED-FEFO-B', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 120 DAY), 10),
  (@product_id, 'SEED-FEFO-EXP', DATE_SUB(CURDATE(), INTERVAL 300 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 50);

-- 11) Resumo final
SELECT
  @product_id AS product_id_teste,
  @customer_id AS customer_id_teste,
  @user_id AS user_id_teste,
  @address_id AS address_id_teste;

SELECT id, name, slug, status, unit_price, promotional_price
FROM products
WHERE id = @product_id;

SELECT id, batch_code, expiry_date, quantity
FROM inventory_batches
WHERE product_id = @product_id
ORDER BY expiry_date ASC;
