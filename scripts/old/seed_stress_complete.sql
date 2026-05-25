-- ============================================================
-- NEOFARMA — SEED COMPLETO PARA TESTES DE ESTRESSE
-- Gerado por: node scripts/generate_seed_stress_sql.js
-- Pré-requisito: schema criado (DB_Neofarma_clean.sql + migration se necessário)
-- Senha padrão de TODOS os usuários seed: 123456
-- ============================================================

USE neofarma;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Limpeza de execuções anteriores (prefixo stress)
DELETE FROM inventory_disposals WHERE product_id IN (SELECT id FROM products WHERE slug LIKE 'stress-%');
DELETE FROM order_pending_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%'));
DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%'));
DELETE FROM payments WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%'));
DELETE FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%');
DELETE FROM purchase_order_items WHERE purchase_order_id IN (SELECT id FROM purchase_orders WHERE notes LIKE 'stress%');
DELETE FROM purchase_orders WHERE notes LIKE 'stress%';
DELETE FROM service_appointments WHERE customer_email LIKE 'stress.seed%' OR customer_name LIKE 'Cliente Stress%';
DELETE FROM service_professional_availability WHERE professional_id IN (SELECT id FROM service_professionals WHERE email LIKE 'stress.seed%');
DELETE FROM service_professionals WHERE email LIKE 'stress.seed%';
DELETE FROM prescription_items WHERE prescription_id IN (SELECT id FROM prescriptions WHERE notes LIKE 'stress%');
DELETE FROM prescriptions WHERE notes LIKE 'stress%';
DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE slug LIKE 'stress-%');
DELETE FROM product_categories WHERE product_id IN (SELECT id FROM products WHERE slug LIKE 'stress-%');
DELETE FROM inventory_batches WHERE product_id IN (SELECT id FROM products WHERE slug LIKE 'stress-%');
DELETE FROM products WHERE slug LIKE 'stress-%';
DELETE FROM customer_addresses WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%');
DELETE FROM customers WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'stress.seed%');
DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'stress.seed%');
DELETE FROM users WHERE email LIKE 'stress.seed%';
DELETE FROM suppliers WHERE email LIKE '%stress%' OR trade_name LIKE 'Stress %';
DELETE FROM labs WHERE email LIKE '%stress%' OR name LIKE 'Stress Lab %';
DELETE FROM addresses WHERE street LIKE 'Stress Seed %';
DELETE FROM categories WHERE slug LIKE 'stress-%';
DELETE FROM product_types WHERE slug LIKE 'stress-%';

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO roles (name, description) VALUES
  ('ADMIN','Administrador'),('FUNCIONARIO','Funcionário'),('ESTOQUISTA','Estoquista'),('CLIENTE','Cliente')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Tipos de produto (RF_B3)
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Fitoterápico', 'stress-fitoterapico', 'Produtos de origem vegetal medicinal', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Suplemento Alimentar', 'stress-suplemento-alimentar', 'Vitaminas, minerais e complementos', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Higiene Pessoal', 'stress-higiene-pessoal', 'Sabonetes, shampoos naturais', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Cosmético Natural', 'stress-cosmetico-natural', 'Dermocosméticos à base de ingredientes naturais', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Chá Medicinal', 'stress-cha-medicinal', 'Chás funcionais e infusões', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Óleo Essencial', 'stress-oleo-essencial', 'Aromaterapia e uso tópico diluído', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Homeopatia', 'stress-homeopatia', 'Medicamentos homeopáticos', 1);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Produto Manipulado', 'stress-produto-manipulado', 'Fórmulas magistrais padronizadas', 1);

-- Categorias (RF_B4)
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Fitoterápicos', 'stress-fitoterapicos', 'Linha fitoterápica', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Suplementos', 'stress-suplementos', 'Suplementação alimentar', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Chás e Infusões', 'stress-chas-infusiones', 'Chás funcionais', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Dermocosméticos', 'stress-dermocosmeticos', 'Cuidados com pele e cabelo', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Higiene Natural', 'stress-higiene-natural', 'Higiene com ingredientes naturais', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Aromaterapia', 'stress-aromaterapia', 'Óleos essenciais e difusores', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Manipulados', 'stress-manipulados', 'Fórmulas magistrais', 1);
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Infantil Natural', 'stress-infantil-natural', 'Linha pediátrica natural', 1);

-- Endereços reais (Brasil)
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Siqueira Campos', '100', 'Sala 100', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010010');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Manoel Goulart', '117', NULL, 'Vila Nova', 'Presidente Prudente', 'SP', 'Brasil', '19020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Tenente Nicolau Mascarenhas', '134', NULL, 'Jardim Paulista', 'Presidente Prudente', 'SP', 'Brasil', '19023450');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Coronel José Soares Marcondes', '151', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua José Bonifácio', '168', 'Sala 104', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010020');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Duque de Caxias', '185', NULL, 'Centro', 'São Paulo', 'SP', 'Brasil', '01025000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Paulista', '202', NULL, 'Bela Vista', 'São Paulo', 'SP', 'Brasil', '01311000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Augusta', '219', NULL, 'Consolação', 'São Paulo', 'SP', 'Brasil', '01305000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua XV de Novembro', '236', 'Sala 108', 'Centro', 'Campinas', 'SP', 'Brasil', '13010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Francisco Glicério', '253', NULL, 'Centro', 'Campinas', 'SP', 'Brasil', '13012000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua das Palmeiras', '270', NULL, 'Jardim América', 'Ribeirão Preto', 'SP', 'Brasil', '14020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Nove de Julho', '287', NULL, 'Centro', 'Ribeirão Preto', 'SP', 'Brasil', '14015000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Sete de Setembro', '304', 'Sala 112', 'Centro', 'Bauru', 'SP', 'Brasil', '17010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Nações Unidas', '321', NULL, 'Pinheiros', 'São Paulo', 'SP', 'Brasil', '04578910');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Oscar Freire', '338', NULL, 'Jardins', 'São Paulo', 'SP', 'Brasil', '01426001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Siqueira Campos', '355', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010010');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Manoel Goulart', '372', 'Sala 116', 'Vila Nova', 'Presidente Prudente', 'SP', 'Brasil', '19020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Tenente Nicolau Mascarenhas', '389', NULL, 'Jardim Paulista', 'Presidente Prudente', 'SP', 'Brasil', '19023450');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Coronel José Soares Marcondes', '406', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua José Bonifácio', '423', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010020');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Duque de Caxias', '440', 'Sala 120', 'Centro', 'São Paulo', 'SP', 'Brasil', '01025000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Paulista', '457', NULL, 'Bela Vista', 'São Paulo', 'SP', 'Brasil', '01311000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Augusta', '474', NULL, 'Consolação', 'São Paulo', 'SP', 'Brasil', '01305000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua XV de Novembro', '491', NULL, 'Centro', 'Campinas', 'SP', 'Brasil', '13010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Francisco Glicério', '508', 'Sala 124', 'Centro', 'Campinas', 'SP', 'Brasil', '13012000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua das Palmeiras', '525', NULL, 'Jardim América', 'Ribeirão Preto', 'SP', 'Brasil', '14020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Nove de Julho', '542', NULL, 'Centro', 'Ribeirão Preto', 'SP', 'Brasil', '14015000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Sete de Setembro', '559', NULL, 'Centro', 'Bauru', 'SP', 'Brasil', '17010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Avenida Nações Unidas', '576', 'Sala 128', 'Pinheiros', 'São Paulo', 'SP', 'Brasil', '04578910');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Stress Seed Rua Oscar Freire', '593', NULL, 'Jardins', 'São Paulo', 'SP', 'Brasil', '01426001');

SET @addr_base := (SELECT MIN(id) FROM addresses WHERE street LIKE 'Stress Seed %');

-- Laboratórios
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Stress Lab Herbarium Laboratório Botânico', '20000000000018', 'herbarium+0@lab.com.br', '1899001000', @addr_base + 0, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Stress Lab Apsen Farmacêutica', '20000000111197', 'contato+1@apsen.com.br', '1899001001', @addr_base + 1, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Stress Lab Aché Laboratórios Farmacêuticos', '20000000222266', 'sac+2@ache.com.br', '1899001002', @addr_base + 2, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Stress Lab Legrand Pharma', '20000000333335', 'atendimento+3@legrand.com.br', '1899001003', @addr_base + 3, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Stress Lab Natulab Laboratório Natural', '20000000444404', 'lab+4@natulab.com.br', '1899001004', @addr_base + 4, 1);

-- Fornecedores
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Distribuidora Fitonatural Ltda', 'Stress Fitonatural', '30000000000071', 'compras+0@fitonatural.com.br', '1899102000', @addr_base + 5, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Ervas do Campo Comercial ME', 'Stress Ervas do Campo', '30000000222210', 'vendas+1@ervasdocampo.com.br', '1899102001', @addr_base + 6, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Verde Vida Distribuição SA', 'Stress Verde Vida', '30000000444468', 'logistica+2@verdevida.com.br', '1899102002', @addr_base + 7, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Botica Popular Atacado Ltda', 'Stress Botica Popular', '30000000666606', 'atacado+3@boticapopular.com.br', '1899102003', @addr_base + 8, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Pharma Nativa Supply Ltda', 'Stress Pharma Nativa', '30000000888854', 'supply+4@pharmanativa.com.br', '1899102004', @addr_base + 9, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Central de Insumos Naturais EPP', 'Stress Central Naturais', '30000001111004', 'pedidos+5@centralnaturais.com.br', '1899102005', @addr_base + 10, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('MaxFito Distribuidora Ltda', 'Stress MaxFito', '30000001333252', 'comercial+6@maxfito.com.br', '1899102006', @addr_base + 11, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Organica Trade Importadora SA', 'Stress Organica Trade', '30000001555409', 'trade+7@organica.com.br', '1899102007', @addr_base + 12, 0);
SET @lab_id := (SELECT id FROM labs WHERE name LIKE 'Stress Lab %' ORDER BY id LIMIT 1);
SET @supplier_id := (SELECT id FROM suppliers WHERE trade_name LIKE 'Stress %' ORDER BY id LIMIT 1);
SET @type_fit := (SELECT id FROM product_types WHERE slug = 'stress-fitoterapico' LIMIT 1);
SET @type_sup := (SELECT id FROM product_types WHERE slug = 'stress-suplemento-alimentar' LIMIT 1);
SET @cat_fito := (SELECT id FROM categories WHERE slug = 'stress-fitoterapicos' LIMIT 1);
SET @cat_sup := (SELECT id FROM categories WHERE slug = 'stress-suplementos' LIMIT 1);

-- Funcionários / perfis de acesso (RF_B1)
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Marcos Antônio Ribeiro', 'stress.seed.admin@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '90000000094', '1899700100', '1985-06-15', 1 FROM roles r WHERE r.name='ADMIN' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 8500, 'Gerente Geral' FROM users u WHERE u.email='stress.seed.admin@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Eliane Souza Moraes', 'stress.seed.funcionario@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '90000000175', '1899700101', '1985-06-15', 1 FROM roles r WHERE r.name='FUNCIONARIO' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 3200, 'Atendente Farmácia' FROM users u WHERE u.email='stress.seed.funcionario@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Robson Pereira Lima', 'stress.seed.estoquista@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '90000000256', '1899700102', '1985-06-15', 1 FROM roles r WHERE r.name='ESTOQUISTA' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 2800, 'Estoquista' FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1;

-- Clientes (PF e PJ para relatórios RF_S3)
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Ana Beatriz Ferreira', 'stress.seed.cliente01@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000108', '1799600100', '1970-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 0, 0 FROM users u WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 0, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Carlos Eduardo Souza', 'stress.seed.cliente02@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000280', '1799600101', '1971-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 1, 17 FROM users u WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 1, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Mariana Oliveira Lima', 'stress.seed.cliente03@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000361', '1799600102', '1972-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 2, 34 FROM users u WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 2, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'João Pedro Almeida', 'stress.seed.cliente04@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000442', '1799600103', '1973-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 3, 51 FROM users u WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 3, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Fernanda Rocha Martins', 'stress.seed.cliente05@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000523', '1799600104', '1974-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 4, 68 FROM users u WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 4, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Ricardo Henrique Dias', 'stress.seed.cliente06@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000604', '1799600105', '1975-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 5, 85 FROM users u WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 5, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Juliana Costa Pereira', 'stress.seed.cliente07@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000795', '1799600106', '1976-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 6, 102 FROM users u WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 6, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Lucas Gabriel Santos', 'stress.seed.cliente08@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000876', '1799600107', '1977-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 7, 119 FROM users u WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 7, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Patrícia Mendes Barbosa', 'stress.seed.cliente09@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000000957', '1799600108', '1978-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 8, 136 FROM users u WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 8, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Roberto Carlos Nunes', 'stress.seed.cliente10@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001090', '1799600109', '1979-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 9, 153 FROM users u WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 9, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Camila Duarte Freitas', 'stress.seed.cliente11@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001171', '1799600110', '1980-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 10, 170 FROM users u WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 10, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Bruno Henrique Castro', 'stress.seed.cliente12@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001252', '1799600111', '1981-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 11, 187 FROM users u WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 11, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Larissa Aparecida Melo', 'stress.seed.cliente13@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001333', '1799600112', '1982-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 12, 204 FROM users u WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 12, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Diego Augusto Ribeiro', 'stress.seed.cliente14@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001414', '1799600113', '1983-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 13, 221 FROM users u WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 13, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Amanda Cristina Gomes', 'stress.seed.cliente15@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001503', '1799600114', '1984-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 14, 238 FROM users u WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 14, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Felipe Andrade Teixeira', 'stress.seed.cliente16@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001686', '1799600115', '1985-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 15, 255 FROM users u WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 15, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Bianca Luiza Carvalho', 'stress.seed.cliente17@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001767', '1799600116', '1986-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 16, 272 FROM users u WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 16, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Thiago Rafael Pinto', 'stress.seed.cliente18@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001848', '1799600117', '1987-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 17, 289 FROM users u WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 17, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Gabriela Moura Azevedo', 'stress.seed.cliente19@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000001929', '1799600118', '1988-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 18, 306 FROM users u WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 18, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Vinícius Luís Correia', 'stress.seed.cliente20@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002062', '1799600119', '1989-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 19, 323 FROM users u WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 19, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Helena Vitória Cardoso', 'stress.seed.cliente21@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002143', '1799600120', '1990-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 20, 340 FROM users u WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 20, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Matheus Antônio Lopes', 'stress.seed.cliente22@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002224', '1799600121', '1991-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 21, 357 FROM users u WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 21, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Isabela Fernanda Vieira', 'stress.seed.cliente23@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002305', '1799600122', '1992-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 22, 374 FROM users u WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 22, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Guilherme Augusto Ramos', 'stress.seed.cliente24@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002496', '1799600123', '1993-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 23, 391 FROM users u WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 23, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Beatriz Helena Monteiro', 'stress.seed.cliente25@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002577', '1799600124', '1994-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 24, 408 FROM users u WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 24, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rafaela Cristiane Farias', 'stress.seed.cliente26@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002658', '1799600125', '1995-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 25, 425 FROM users u WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 25, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Daniel Augusto Borges', 'stress.seed.cliente27@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002739', '1799600126', '1996-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 26, 442 FROM users u WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 26, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Natália Souza Rezende', 'stress.seed.cliente28@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002810', '1799600127', '1997-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 27, 459 FROM users u WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 27, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Eduardo Luiz Cavalcanti', 'stress.seed.cliente29@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000002909', '1799600128', '1998-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 28, 476 FROM users u WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 28, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Aline Rodrigues Nascimento', 'stress.seed.cliente30@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003034', '1799600129', '1999-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 29, 493 FROM users u WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 29, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Paulo Sérgio Machado', 'stress.seed.cliente31@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003115', '1799600130', '1970-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 0, 10 FROM users u WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 0, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Renata Aparecida Brito', 'stress.seed.cliente32@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003204', '1799600131', '1971-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 1, 27 FROM users u WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 1, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Gustavo Henrique Peixoto', 'stress.seed.cliente33@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003387', '1799600132', '1972-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 2, 44 FROM users u WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 2, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Tatiane Silva Guimarães', 'stress.seed.cliente34@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003468', '1799600133', '1973-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 3, 61 FROM users u WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 3, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rodrigo Martins Coelho', 'stress.seed.cliente35@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003549', '1799600134', '1974-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 4, 78 FROM users u WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 4, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Vanessa Lima Prado', 'stress.seed.cliente36@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003620', '1799600135', '1975-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 5, 95 FROM users u WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 5, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'André Luiz Tavares', 'stress.seed.cliente37@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003700', '1799600136', '1976-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 6, 112 FROM users u WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 6, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Priscila Oliveira Cunha', 'stress.seed.cliente38@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003891', '1799600137', '1977-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 7, 129 FROM users u WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 7, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Marcelo Henrique Barros', 'stress.seed.cliente39@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000003972', '1799600138', '1978-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 8, 146 FROM users u WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 8, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Simone Aparecida Paiva', 'stress.seed.cliente40@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004006', '1799600139', '1979-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 9, 163 FROM users u WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 9, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Leandro Costa Miranda', 'stress.seed.cliente41@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004197', '1799600140', '1980-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 10, 180 FROM users u WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 10, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Eliane Rodrigues Pires', 'stress.seed.cliente42@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004278', '1799600141', '1981-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 11, 197 FROM users u WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 11, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Fábio José Santana', 'stress.seed.cliente43@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004359', '1799600142', '1982-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 12, 214 FROM users u WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 12, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Cristiane Alves Moreira', 'stress.seed.cliente44@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004430', '1799600143', '1983-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 13, 231 FROM users u WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 13, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Henrique Moraes Batista', 'stress.seed.cliente45@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004510', '1799600144', '1984-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 14, 248 FROM users u WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 14, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Luciana Pereira Fonseca', 'stress.seed.cliente46@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004600', '1799600145', '1985-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 15, 265 FROM users u WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 15, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Sérgio Ricardo Campos', 'stress.seed.cliente47@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004782', '1799600146', '1986-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 16, 282 FROM users u WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 16, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Adriana Luiza Matos', 'stress.seed.cliente48@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004863', '1799600147', '1987-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 17, 299 FROM users u WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 17, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Otávio César Aguiar', 'stress.seed.cliente49@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000004944', '1799600148', '1988-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 18, 316 FROM users u WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 18, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Michele Cristina Duarte', 'stress.seed.cliente50@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005088', '1799600149', '1989-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 19, 333 FROM users u WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 19, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Cláudio Henrique Assis', 'stress.seed.cliente51@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005169', '1799600150', '1990-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 20, 350 FROM users u WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 20, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rosana Ferreira Bueno', 'stress.seed.cliente52@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005240', '1799600151', '1991-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 21, 367 FROM users u WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 21, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Igor Samuel Valente', 'stress.seed.cliente53@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005320', '1799600152', '1992-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 22, 384 FROM users u WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 22, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Denise Aparecida Neves', 'stress.seed.cliente54@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005401', '1799600153', '1993-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 23, 401 FROM users u WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 23, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Caio Eduardo Xavier', 'stress.seed.cliente55@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '10000005592', '1799600154', '1994-07-15', 0 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 24, 418 FROM users u WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 24, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Clínica Bem Viver Ltda', 'stress.seed.pj01@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '40000000000025', '1135500100', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 25, 100 FROM users u WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 25, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Distribuidora Fitonatural ME', 'stress.seed.pj02@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '40000000333342', '1135500101', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 26, 150 FROM users u WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 26, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Laboratório Verde Vida SA', 'stress.seed.pj03@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '40000000666660', '1135500102', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 27, 200 FROM users u WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 27, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rede Saúde Integrada Ltda', 'stress.seed.pj04@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '40000000999987', '1135500103', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 28, 250 FROM users u WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 28, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Comercial Ervas do Campo EPP', 'stress.seed.pj05@neofarma.com', '$2b$10$JEiOjdLTNOGw21vD1IZeGOUeAUvptb2wGaV2hvzTpc3p3z0iIfbde', '40000001333206', '1135500104', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 29, 300 FROM users u WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 29, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;

-- Produtos (RF_B2) — mix de status e promoções
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Chá de Camomila NeoHerbs 20g', 'stress-prod-001', 'SKU-STRESS-0001', '7891000000000', 'Produto seed Chá de Camomila NeoHerbs 20g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 12.90, 10.96, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(0 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Extrato Seco de Valeriana 60 cápsulas', 'stress-prod-002', 'SKU-STRESS-0002', '7891000000001', 'Produto seed Extrato Seco de Valeriana 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 16.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(1 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Óleo de Melaleuca 30ml', 'stress-prod-003', 'SKU-STRESS-0003', '7891000000002', 'Produto seed Óleo de Melaleuca 30ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 19.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(2 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Própolis Verde Spray 30ml', 'stress-prod-004', 'SKU-STRESS-0004', '7891000000003', 'Produto seed Própolis Verde Spray 30ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 23.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(3 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Mel de Manuka UMF 10+ 250g', 'stress-prod-005', 'SKU-STRESS-0005', '7891000000004', 'Produto seed Mel de Manuka UMF 10+ 250g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 26.90, 22.86, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(4 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Shampoo de Alecrim 300ml', 'stress-prod-006', 'SKU-STRESS-0006', '7891000000005', 'Produto seed Shampoo de Alecrim 300ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 30.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(5 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Sabonete de Calêndula 90g', 'stress-prod-007', 'SKU-STRESS-0007', '7891000000006', 'Produto seed Sabonete de Calêndula 90g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 33.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(6 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Complexo B Natural 60 comprimidos', 'stress-prod-008', 'SKU-STRESS-0008', '7891000000007', 'Produto seed Complexo B Natural 60 comprimidos para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 37.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(7 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Vitamina D3 2000UI 60 cápsulas', 'stress-prod-009', 'SKU-STRESS-0009', '7891000000008', 'Produto seed Vitamina D3 2000UI 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 40.90, 34.77, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(8 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Magnésio Quelato 120 cápsulas', 'stress-prod-010', 'SKU-STRESS-0010', '7891000000009', 'Produto seed Magnésio Quelato 120 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 44.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(9 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Gel de Arnica Montana 100g', 'stress-prod-011', 'SKU-STRESS-0011', '7891000000010', 'Produto seed Gel de Arnica Montana 100g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 47.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(10 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Pomada de Propolis 30g', 'stress-prod-012', 'SKU-STRESS-0012', '7891000000011', 'Produto seed Pomada de Propolis 30g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 51.40, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(11 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Óleo Essencial de Lavanda 10ml', 'stress-prod-013', 'SKU-STRESS-0013', '7891000000012', 'Produto seed Óleo Essencial de Lavanda 10ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 54.90, 46.66, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(12 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Óleo Essencial de Eucalipto 10ml', 'stress-prod-014', 'SKU-STRESS-0014', '7891000000013', 'Produto seed Óleo Essencial de Eucalipto 10ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 58.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(13 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Chá de Erva-Doce 50g', 'stress-prod-015', 'SKU-STRESS-0015', '7891000000014', 'Produto seed Chá de Erva-Doce 50g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 61.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(14 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Chá de Hibisco com Gengibre 40g', 'stress-prod-016', 'SKU-STRESS-0016', '7891000000015', 'Produto seed Chá de Hibisco com Gengibre 40g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 65.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(15 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Colágeno Hidrolisado 300g', 'stress-prod-017', 'SKU-STRESS-0017', '7891000000016', 'Produto seed Colágeno Hidrolisado 300g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 68.90, 58.57, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(16 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Ômega 3 EPA/DHA 120 cápsulas', 'stress-prod-018', 'SKU-STRESS-0018', '7891000000017', 'Produto seed Ômega 3 EPA/DHA 120 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 72.40, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(17 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Probiótico 10 cepas 30 cápsulas', 'stress-prod-019', 'SKU-STRESS-0019', '7891000000018', 'Produto seed Probiótico 10 cepas 30 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 75.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(18 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Cúrcuma com Piperina 60 cápsulas', 'stress-prod-020', 'SKU-STRESS-0020', '7891000000019', 'Produto seed Cúrcuma com Piperina 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 79.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(19 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Ginkgo Biloba 80mg 60 cápsulas', 'stress-prod-021', 'SKU-STRESS-0021', '7891000000020', 'Produto seed Ginkgo Biloba 80mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 12.90, 10.96, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(20 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Passiflora Incarnata 500mg 60 cápsulas', 'stress-prod-022', 'SKU-STRESS-0022', '7891000000021', 'Produto seed Passiflora Incarnata 500mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 16.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(21 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Crataegus Oxyacantha 60 cápsulas', 'stress-prod-023', 'SKU-STRESS-0023', '7891000000022', 'Produto seed Crataegus Oxyacantha 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 19.90, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(22 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Gel Hidratante de Aloe Vera 200g', 'stress-prod-024', 'SKU-STRESS-0024', '7891000000023', 'Produto seed Gel Hidratante de Aloe Vera 200g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 23.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(23 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Repelente Natural Citronela 100ml', 'stress-prod-025', 'SKU-STRESS-0025', '7891000000024', 'Produto seed Repelente Natural Citronela 100ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 26.90, 22.86, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(24 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Desodorante Crystal Natural 80g', 'stress-prod-026', 'SKU-STRESS-0026', '7891000000025', 'Produto seed Desodorante Crystal Natural 80g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 30.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(25 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Creme Dental Sem Flúor 90g', 'stress-prod-027', 'SKU-STRESS-0027', '7891000000026', 'Produto seed Creme Dental Sem Flúor 90g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 33.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(26 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Enxaguante Bucal de Própolis 250ml', 'stress-prod-028', 'SKU-STRESS-0028', '7891000000027', 'Produto seed Enxaguante Bucal de Própolis 250ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 37.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(27 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Loção Capilar de Jaborandi 200ml', 'stress-prod-029', 'SKU-STRESS-0029', '7891000000028', 'Produto seed Loção Capilar de Jaborandi 200ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 40.90, 34.77, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(28 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Óleo de Rosa Mosqueta 30ml', 'stress-prod-030', 'SKU-STRESS-0030', '7891000000029', 'Produto seed Óleo de Rosa Mosqueta 30ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 44.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(29 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Sérum Facial Vitamina C 30ml', 'stress-prod-031', 'SKU-STRESS-0031', '7891000000030', 'Produto seed Sérum Facial Vitamina C 30ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 47.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(30 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Máscara de Argila Verde 100g', 'stress-prod-032', 'SKU-STRESS-0032', '7891000000031', 'Produto seed Máscara de Argila Verde 100g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 51.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(31 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Echinacea Purpurea 60 cápsulas', 'stress-prod-033', 'SKU-STRESS-0033', '7891000000032', 'Produto seed Echinacea Purpurea 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 54.90, 46.66, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(32 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Guaraná em Pó 100g', 'stress-prod-034', 'SKU-STRESS-0034', '7891000000033', 'Produto seed Guaraná em Pó 100g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 58.40, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(33 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Maca Peruana 500mg 60 cápsulas', 'stress-prod-035', 'SKU-STRESS-0035', '7891000000034', 'Produto seed Maca Peruana 500mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 61.90, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(34 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Spirulina 500mg 120 comprimidos', 'stress-prod-036', 'SKU-STRESS-0036', '7891000000035', 'Produto seed Spirulina 500mg 120 comprimidos para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 65.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(35 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Clorella 500mg 120 comprimidos', 'stress-prod-037', 'SKU-STRESS-0037', '7891000000036', 'Produto seed Clorella 500mg 120 comprimidos para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 68.90, 58.57, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(36 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Psyllium 500mg 120 cápsulas', 'stress-prod-038', 'SKU-STRESS-0038', '7891000000037', 'Produto seed Psyllium 500mg 120 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 72.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(37 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Melatonina 3mg 60 cápsulas', 'stress-prod-039', 'SKU-STRESS-0039', '7891000000038', 'Produto seed Melatonina 3mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 75.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(38 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Ashwagandha 300mg 60 cápsulas', 'stress-prod-040', 'SKU-STRESS-0040', '7891000000039', 'Produto seed Ashwagandha 300mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 79.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(39 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Rhodiola Rosea 300mg 60 cápsulas', 'stress-prod-041', 'SKU-STRESS-0041', '7891000000040', 'Produto seed Rhodiola Rosea 300mg 60 cápsulas para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 12.90, 10.96, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(40 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Calendula Officinalis Tintura 50ml', 'stress-prod-042', 'SKU-STRESS-0042', '7891000000041', 'Produto seed Calendula Officinalis Tintura 50ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 16.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(41 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Hamamelis Virginiana Tônico 200ml', 'stress-prod-043', 'SKU-STRESS-0043', '7891000000042', 'Produto seed Hamamelis Virginiana Tônico 200ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 19.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(42 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Calêndula Pomada Infantil 50g', 'stress-prod-044', 'SKU-STRESS-0044', '7891000000043', 'Produto seed Calêndula Pomada Infantil 50g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 23.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(43 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Óleo de Copaíba 30ml', 'stress-prod-045', 'SKU-STRESS-0045', '7891000000044', 'Produto seed Óleo de Copaíba 30ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 26.90, 22.86, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(44 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Spray Nasal Sal Marinho 50ml', 'stress-prod-046', 'SKU-STRESS-0046', '7891000000045', 'Produto seed Spray Nasal Sal Marinho 50ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 1, 30.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(45 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-1.webp', 0 FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Xarope de Própolis Infantil 100ml', 'stress-prod-047', 'SKU-STRESS-0047', '7891000000046', 'Produto seed Xarope de Própolis Infantil 100ml para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 33.90, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(46 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-2.webp', 0 FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Fórmula Magistral Base Creme 100g', 'stress-prod-048', 'SKU-STRESS-0048', '7891000000047', 'Produto seed Fórmula Magistral Base Creme 100g para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 37.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(47 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-3.webp', 0 FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_fit, 'Homeopatia Ignatia 30CH', 'stress-prod-049', 'SKU-STRESS-0049', '7891000000048', 'Produto seed Homeopatia Ignatia 30CH para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 40.90, 34.77, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(48 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-4.webp', 0 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_sup, 'Homeopatia Arnica 6CH', 'stress-prod-050', 'SKU-STRESS-0050', '7891000000049', 'Produto seed Homeopatia Arnica 6CH para testes NeoFarma.', 'Composição conforme rótulo.', 'Seguir orientação farmacêutica.', 0, 44.40, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(49 % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-5.webp', 0 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;

-- Lotes FEFO: vencidos, próximos e válidos
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-1', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-1', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 80 FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-1', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 180 DAY), 150 FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-2', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-2', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 83 FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-2', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 181 DAY), 155 FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-3', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-3', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 86 FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-3', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 182 DAY), 160 FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-4', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-4', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 89 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-4', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 183 DAY), 165 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-5', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-5', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 92 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-5', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 184 DAY), 170 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-6', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-6', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 95 FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-6', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 185 DAY), 175 FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-7', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-7', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 98 FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-7', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 186 DAY), 180 FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-8', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-8', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 101 FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-8', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 187 DAY), 185 FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-9', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-9', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 104 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-9', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 188 DAY), 190 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-10', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-10', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 107 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-10', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 189 DAY), 195 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-11', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-11', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 110 FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-11', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 190 DAY), 200 FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-12', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-12', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 113 FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-12', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 191 DAY), 205 FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-13', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-13', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 116 FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-13', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 192 DAY), 210 FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-14', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-14', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 119 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-14', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 193 DAY), 215 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-15', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-15', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 122 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-15', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 194 DAY), 220 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-16', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-16', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 125 FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-16', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 195 DAY), 225 FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-17', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-17', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 128 FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-17', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 196 DAY), 230 FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-18', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-18', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 131 FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-18', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 197 DAY), 235 FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-19', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-19', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 134 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-19', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 198 DAY), 240 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-20', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-20', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 137 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-20', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 199 DAY), 245 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-21', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-21', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 140 FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-21', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 200 DAY), 250 FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-22', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-22', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 143 FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-22', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 201 DAY), 255 FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-23', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-23', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 146 FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-23', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 202 DAY), 260 FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-24', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-24', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 149 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-24', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 203 DAY), 265 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-25', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-25', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 152 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-25', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 204 DAY), 270 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-26', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-26', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 155 FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-26', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 205 DAY), 275 FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-27', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-27', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 158 FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-27', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 206 DAY), 280 FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-28', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-28', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 161 FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-28', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 207 DAY), 285 FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-29', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-29', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 164 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-29', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 208 DAY), 290 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-30', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-30', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 167 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-30', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 209 DAY), 295 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-31', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-31', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 170 FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-31', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 210 DAY), 300 FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-32', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-32', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 173 FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-32', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 211 DAY), 305 FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-33', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-33', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 176 FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-33', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 212 DAY), 310 FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-34', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-34', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 179 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-34', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 213 DAY), 315 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-35', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-35', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 182 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-35', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 214 DAY), 320 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-36', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-36', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 185 FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-36', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 215 DAY), 325 FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-37', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-37', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 188 FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-37', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 216 DAY), 330 FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-38', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-38', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 191 FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-38', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 217 DAY), 335 FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-39', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-39', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 194 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-39', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 218 DAY), 340 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-40', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-40', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 197 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-40', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 219 DAY), 345 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-41', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-41', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 200 FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-41', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 220 DAY), 350 FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-42', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-42', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 203 FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-42', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 221 DAY), 355 FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-43', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-43', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 206 FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-43', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 222 DAY), 360 FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-44', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-44', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 209 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-44', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 223 DAY), 365 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-45', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-45', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 212 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-45', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 224 DAY), 370 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-46', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-46', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 215 FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-46', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 225 DAY), 375 FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-47', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-47', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 218 FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-47', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 226 DAY), 380 FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-48', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-48', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 221 FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-48', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 227 DAY), 385 FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-49', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-49', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 224 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-49', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 228 DAY), 390 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-A-50', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-B-50', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 227 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'STRESS-C-50', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 229 DAY), 395 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;

-- Compras (RF_F3) — todos os status
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 0 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY), 'DRAFT', 'PENDING', NULL, 160.00, 'stress pedido compra #1';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 20, 0, NULL, NULL, 8.00, 160.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #1' AND pr.slug='stress-prod-001' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 8 DAY), 'DRAFT', 'PENDING', 'PIX', 198.00, 'stress pedido compra #2';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 22, 0, NULL, NULL, 9.00, 198.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #2' AND pr.slug='stress-prod-002' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_ADD(NOW(), INTERVAL 9 DAY), 'AWAITING_DELIVERY', 'PAID', 'PIX', 240.00, 'stress pedido compra #3';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 24, 0, NULL, NULL, 10.00, 240.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #3' AND pr.slug='stress-prod-003' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 'AWAITING_DELIVERY', 'PAID', 'TRANSFER', 286.00, 'stress pedido compra #4';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 26, 0, NULL, NULL, 11.00, 286.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #4' AND pr.slug='stress-prod-004' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_ADD(NOW(), INTERVAL 11 DAY), 'RECEIVED', 'PAID', 'BOLETO', 336.00, 'stress pedido compra #5';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 28, 28, 'STRESS-RCV-5', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 12.00, 336.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #5' AND pr.slug='stress-prod-005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-5', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 28
FROM products pr WHERE pr.slug='stress-prod-005' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-5'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #5';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_ADD(NOW(), INTERVAL 12 DAY), 'RECEIVED', 'PAID', 'CASH', 390.00, 'stress pedido compra #6';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 30, 30, 'STRESS-RCV-6', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 13.00, 390.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #6' AND pr.slug='stress-prod-006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-6', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 30
FROM products pr WHERE pr.slug='stress-prod-006' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-6'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #6';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_ADD(NOW(), INTERVAL 13 DAY), 'CANCELLED', 'FAILED', 'PIX', 448.00, 'stress pedido compra #7';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 32, 0, NULL, NULL, 14.00, 448.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #7' AND pr.slug='stress-prod-007' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 21 DAY), DATE_ADD(NOW(), INTERVAL 14 DAY), 'DRAFT', 'PENDING', NULL, 510.00, 'stress pedido compra #8';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 34, 0, NULL, NULL, 15.00, 510.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #8' AND pr.slug='stress-prod-008' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 24 DAY), DATE_ADD(NOW(), INTERVAL 15 DAY), 'DRAFT', 'PENDING', 'PIX', 576.00, 'stress pedido compra #9';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 36, 0, NULL, NULL, 16.00, 576.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #9' AND pr.slug='stress-prod-009' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 27 DAY), DATE_ADD(NOW(), INTERVAL 16 DAY), 'AWAITING_DELIVERY', 'PAID', 'PIX', 646.00, 'stress pedido compra #10';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 38, 0, NULL, NULL, 17.00, 646.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #10' AND pr.slug='stress-prod-010' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_ADD(NOW(), INTERVAL 17 DAY), 'AWAITING_DELIVERY', 'PAID', 'TRANSFER', 320.00, 'stress pedido compra #11';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 40, 0, NULL, NULL, 8.00, 320.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #11' AND pr.slug='stress-prod-011' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 33 DAY), DATE_ADD(NOW(), INTERVAL 18 DAY), 'RECEIVED', 'PAID', 'BOLETO', 378.00, 'stress pedido compra #12';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 42, 42, 'STRESS-RCV-12', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 9.00, 378.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #12' AND pr.slug='stress-prod-012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-12', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 42
FROM products pr WHERE pr.slug='stress-prod-012' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-12'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #12';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 36 DAY), DATE_ADD(NOW(), INTERVAL 19 DAY), 'RECEIVED', 'PAID', 'CASH', 440.00, 'stress pedido compra #13';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 44, 44, 'STRESS-RCV-13', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 10.00, 440.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #13' AND pr.slug='stress-prod-013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-13', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 44
FROM products pr WHERE pr.slug='stress-prod-013' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-13'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #13';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 39 DAY), DATE_ADD(NOW(), INTERVAL 20 DAY), 'CANCELLED', 'FAILED', 'PIX', 506.00, 'stress pedido compra #14';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 46, 0, NULL, NULL, 11.00, 506.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #14' AND pr.slug='stress-prod-014' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 42 DAY), DATE_ADD(NOW(), INTERVAL 21 DAY), 'DRAFT', 'PENDING', NULL, 576.00, 'stress pedido compra #15';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 48, 0, NULL, NULL, 12.00, 576.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #15' AND pr.slug='stress-prod-015' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 45 DAY), DATE_ADD(NOW(), INTERVAL 22 DAY), 'DRAFT', 'PENDING', 'PIX', 650.00, 'stress pedido compra #16';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 50, 0, NULL, NULL, 13.00, 650.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #16' AND pr.slug='stress-prod-016' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 48 DAY), DATE_ADD(NOW(), INTERVAL 23 DAY), 'AWAITING_DELIVERY', 'PAID', 'PIX', 728.00, 'stress pedido compra #17';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 52, 0, NULL, NULL, 14.00, 728.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #17' AND pr.slug='stress-prod-017' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 51 DAY), DATE_ADD(NOW(), INTERVAL 24 DAY), 'AWAITING_DELIVERY', 'PAID', 'TRANSFER', 810.00, 'stress pedido compra #18';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 54, 0, NULL, NULL, 15.00, 810.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #18' AND pr.slug='stress-prod-018' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 54 DAY), DATE_ADD(NOW(), INTERVAL 25 DAY), 'RECEIVED', 'PAID', 'BOLETO', 896.00, 'stress pedido compra #19';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 56, 56, 'STRESS-RCV-19', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 16.00, 896.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #19' AND pr.slug='stress-prod-019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-19', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 56
FROM products pr WHERE pr.slug='stress-prod-019' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-19'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #19';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 57 DAY), DATE_ADD(NOW(), INTERVAL 26 DAY), 'RECEIVED', 'PAID', 'CASH', 986.00, 'stress pedido compra #20';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 58, 58, 'STRESS-RCV-20', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 17.00, 986.00
FROM purchase_orders po, products pr WHERE po.notes='stress pedido compra #20' AND pr.slug='stress-prod-020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'STRESS-RCV-20', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 58
FROM products pr WHERE pr.slug='stress-prod-020' LIMIT 1;
UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'STRESS-RCV-20'
SET poi.batch_id = ib.id
WHERE po.notes = 'stress pedido compra #20';

-- Pedidos e pagamentos (RF_F2 / RF_F8) — paginação e inadimplência
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-0', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000001', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1002', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-3', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000004', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1005', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-6', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000007', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1008', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-9', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000010', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1011', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-12', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000013', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1014', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-15', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000016', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1017', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-18', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000019', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1020', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-21', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000022', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1023', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-24', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000025', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1026', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-27', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000028', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1029', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-30', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000031', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1032', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-33', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000034', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1035', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-36', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000037', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1038', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-39', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000040', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1041', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-42', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000043', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1044', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-45', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000046', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1047', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-48', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000049', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1050', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-51', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000052', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1053', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-54', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000055', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1056', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-57', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000058', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1059', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-60', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 61 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000061', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 62 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1062', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 63 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-63', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 64 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000064', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 65 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1065', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 66 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-66', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 67 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000067', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 68 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1068', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 69 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-69', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 70 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000070', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 71 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1071', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 72 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-72', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 73 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000073', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 74 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1074', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 75 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-75', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 76 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000076', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 77 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1077', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 78 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-78', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 79 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000079', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 80 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1080', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 81 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-81', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 82 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000082', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 83 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1083', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 84 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-84', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 85 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000085', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 86 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1086', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 87 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-87', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 88 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000088', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 89 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1089', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 90 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-90', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 91 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000091', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 92 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1092', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 93 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-93', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 94 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000094', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 95 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1095', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 96 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-96', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 97 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000097', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 98 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1098', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 99 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-99', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 100 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000100', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 101 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1101', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 102 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-102', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 103 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000103', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 104 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1104', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 105 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-105', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 106 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000106', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 107 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1107', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 108 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-108', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 109 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000109', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 110 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1110', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 111 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-111', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 112 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000112', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 113 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1113', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 114 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-114', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 115 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000115', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 116 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1116', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 117 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-117', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 118 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000118', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 119 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1119', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-120', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000121', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1122', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-123', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000124', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1125', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-126', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000127', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1128', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-129', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000130', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1131', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-132', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000133', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1134', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-135', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000136', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1137', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-138', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000139', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1140', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-141', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000142', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1143', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-144', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000145', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1146', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-147', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000148', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1149', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-150', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000151', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1152', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-153', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000154', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1155', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-156', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000157', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1158', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-159', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000160', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1161', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-162', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000163', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1164', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-165', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000166', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1167', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-168', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000169', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1170', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-171', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000172', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1173', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-174', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000175', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1176', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-177', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000178', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1179', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-180', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 61 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000181', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 62 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1182', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 63 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-183', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 64 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000184', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 65 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1185', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 66 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-186', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 67 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000187', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 68 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1188', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 69 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-189', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 70 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000190', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 71 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1191', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 72 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-192', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 73 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000193', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 74 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1194', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 75 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-195', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 76 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000196', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 77 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1197', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 78 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-198', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 79 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000199', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 80 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1200', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 81 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-201', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 82 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000202', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 83 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1203', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 84 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-204', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 85 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000205', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 86 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1206', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 87 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-207', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 88 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000208', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 89 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1209', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 90 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-210', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 91 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000211', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 92 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1212', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 93 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-213', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 94 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000214', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 95 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1215', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 96 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-216', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 97 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000217', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 98 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1218', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 99 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-219', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 100 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000220', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 101 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1221', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 102 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-222', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 103 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000223', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 104 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1224', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 105 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-225', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 106 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000226', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 107 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1227', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 108 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-228', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 109 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000229', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 110 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1230', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 111 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-231', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 112 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000232', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 113 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1233', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 114 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-234', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 115 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000235', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 116 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1236', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 117 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-237', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 118 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000238', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 119 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1239', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-240', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000241', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1242', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-243', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000244', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1245', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-246', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000247', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1248', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-249', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000250', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1251', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-252', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000253', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1254', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-255', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000256', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1257', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-258', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000259', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1260', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-261', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000262', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1263', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-264', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000265', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1266', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-267', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000268', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1269', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-270', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000271', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1272', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-273', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000274', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1275', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-276', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000277', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1278', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-279', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000280', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1281', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-282', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000283', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1284', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-285', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000286', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1287', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-288', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000289', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1290', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-291', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000292', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1293', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-294', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000295', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1296', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-297', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000298', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1299', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-300', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 61 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000301', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 62 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1302', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 63 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-303', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 64 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000304', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 65 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1305', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 66 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-306', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 67 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000307', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 68 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1308', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 69 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-309', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 70 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000310', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 71 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1311', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 72 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-312', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 73 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000313', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 74 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1314', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 75 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-315', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 76 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000316', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 77 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1317', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 78 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-318', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 79 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000319', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 80 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1320', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 81 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-321', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 82 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000322', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 83 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1323', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 84 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-324', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 85 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000325', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 86 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1326', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 87 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-327', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 88 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000328', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 89 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1329', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 90 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-330', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 91 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000331', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 92 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1332', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 93 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-333', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 94 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000334', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 95 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1335', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 96 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-336', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 97 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000337', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 98 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1338', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 99 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-339', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 100 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000340', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 101 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1341', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 102 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-342', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 103 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000343', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 104 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1344', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 105 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-345', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 106 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000346', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 107 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1347', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 108 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-348', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 109 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000349', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 110 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1350', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 111 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-351', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 112 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000352', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 113 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1353', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 114 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-354', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 115 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000355', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 116 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1356', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 117 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-357', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 118 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000358', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 119 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1359', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 0.00, 17.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-360', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 52.90, NULL, '23793.0000000361', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 80.40, NULL, NULL, '1362', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 0.00, 100.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 100.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-363', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 40.40, NULL, '23793.0000000364', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1365', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 0.00, 97.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 97.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-366', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 152.90, NULL, '23793.0000000367', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 37.50, 37.50
FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 50.40, NULL, NULL, '1368', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 0.00, 30.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 30.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-369', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 65.40, NULL, '23793.0000000370', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 92.90, NULL, NULL, '1371', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 0.00, 22.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 22.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-372', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 62.90, NULL, '23793.0000000373', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 27.50, 82.50
FROM products p WHERE p.slug='stress-prod-025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 95.40, NULL, NULL, '1374', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 0.00, 120.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 120.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-375', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 45.40, NULL, '23793.0000000376', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 82.90, NULL, NULL, '1377', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 0.00, 112.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 112.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-378', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 72.90, NULL, '23793.0000000379', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 30.40, NULL, NULL, '1380', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 0.00, 40.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 40.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-381', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 12.90, 80.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 80.40, NULL, '23793.0000000382', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 25.00, 100.00
FROM products p WHERE p.slug='stress-prod-034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 112.90, NULL, NULL, '1383', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 0.00, 27.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 27.50, 27.50 FROM products p WHERE p.slug='stress-prod-035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 27.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-384', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 12.90, 72.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 72.90, NULL, '23793.0000000385', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.40, NULL, NULL, '1386', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 0.00, 140.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 140.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-387', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 12.90, 50.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 50.40, NULL, '23793.0000000388', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 15.00, 30.00
FROM products p WHERE p.slug='stress-prod-040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 42.90, NULL, NULL, '1389', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 0.00, 52.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 52.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-390', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 12.90, 92.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 92.90, NULL, '23793.0000000391', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 35.40, NULL, NULL, '1392', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 0.00, 50.00, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 25.00, 50.00 FROM products p WHERE p.slug='stress-prod-044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 50.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-393', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 12.90, 95.40, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 95.40, NULL, '23793.0000000394', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 132.90, NULL, NULL, '1395', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 0.00, 32.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 32.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-396', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 12.90, 82.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 82.90, NULL, '23793.0000000397', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 37.50, 112.50
FROM products p WHERE p.slug='stress-prod-049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 125.40, NULL, NULL, '1398', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 0.00, 60.00, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 15.00, 60.00 FROM products p WHERE p.slug='stress-prod-050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-399', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.50, 12.90, 30.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.50, 17.50
FROM products p WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 30.40, NULL, '23793.0000000400', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 40.00, 12.90, 52.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.00, 40.00
FROM products p WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 52.90, NULL, NULL, '1401', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 67.50, 0.00, 67.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 22.50, 67.50
FROM products p WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 67.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-402', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 100.00, 12.90, 112.90, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 4, 25.00, 100.00 FROM products p WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 112.90, NULL, '23793.0000000403', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 27.50, 12.90, 40.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 27.50, 27.50
FROM products p WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 40.40, NULL, NULL, '1404', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 60.00, 0.00, 60.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 30.00, 60.00
FROM products p WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 60.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-405', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 97.50, 12.90, 110.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 32.50, 97.50
FROM products p WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 110.40, NULL, '23793.0000000406', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 140.00, 12.90, 152.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 35.00, 140.00
FROM products p WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 152.90, NULL, NULL, '1407', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 37.50, 0.00, 37.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 37.50, 37.50 FROM products p WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 37.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-408', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 30.00, 12.90, 42.90, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 15.00, 30.00 FROM products p WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 42.90, NULL, '23793.0000000409', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 52.50, 12.90, 65.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 17.50, 52.50
FROM products p WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 65.40, NULL, NULL, '1410', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 80.00, 0.00, 80.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 20.00, 80.00
FROM products p WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 80.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-411', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 22.50, 12.90, 35.40, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 22.50, 22.50
FROM products p WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 35.40, NULL, '23793.0000000412', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 50.00, 12.90, 62.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 25.00, 50.00
FROM products p WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 62.90, NULL, NULL, '1413', 6);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 82.50, 0.00, 82.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 27.50, 82.50 FROM products p WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 82.50, '00020126580014BR.GOV.BCB.PIX0136stress-pix-414', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.00, 12.90, 132.90, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj01@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 30.00, 120.00
FROM products p WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 132.90, NULL, '23793.0000000415', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 32.50, 12.90, 45.40, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj02@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 32.50, 32.50
FROM products p WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 45.40, NULL, NULL, '1416', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.00, 0.00, 70.00, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj03@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 35.00, 70.00
FROM products p WHERE p.slug='stress-prod-018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 70.00, '00020126580014BR.GOV.BCB.PIX0136stress-pix-417', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 112.50, 12.90, 125.40, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj04@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 3, 37.50, 112.50 FROM products p WHERE p.slug='stress-prod-019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 125.40, NULL, '23793.0000000418', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 60.00, 12.90, 72.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.pj05@neofarma.com' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 4, 15.00, 60.00
FROM products p WHERE p.slug='stress-prod-020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 72.90, NULL, NULL, '1419', 6);

-- Descartes (RF_F5) — lotes A vencidos, parcial ou total
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Produto vencido em conferência', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-1' WHERE p.slug='stress-prod-001' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Embalagem avariada', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-2' WHERE p.slug='stress-prod-002' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Quebra operacional', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-3' WHERE p.slug='stress-prod-003' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Contaminação visual', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-4' WHERE p.slug='stress-prod-004' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Produto vencido em conferência', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-5' WHERE p.slug='stress-prod-005' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Embalagem avariada', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-6' WHERE p.slug='stress-prod-006' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Quebra operacional', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-7' WHERE p.slug='stress-prod-007' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Contaminação visual', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-8' WHERE p.slug='stress-prod-008' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Produto vencido em conferência', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-9' WHERE p.slug='stress-prod-009' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Embalagem avariada', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-10' WHERE p.slug='stress-prod-010' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Quebra operacional', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-11' WHERE p.slug='stress-prod-011' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Contaminação visual', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-12' WHERE p.slug='stress-prod-012' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Produto vencido em conferência', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-13' WHERE p.slug='stress-prod-013' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Embalagem avariada', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 65 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-14' WHERE p.slug='stress-prod-014' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Quebra operacional', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 70 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-15' WHERE p.slug='stress-prod-015' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Contaminação visual', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 75 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-16' WHERE p.slug='stress-prod-016' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Produto vencido em conferência', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 80 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-17' WHERE p.slug='stress-prod-017' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Embalagem avariada', (SELECT u.id FROM users u WHERE u.email='stress.seed.estoquista@neofarma.com' LIMIT 1), DATE_SUB(NOW(), INTERVAL 85 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='STRESS-A-18' WHERE p.slug='stress-prod-018' LIMIT 1;

-- Coerência de dados (estoque, compras e integridade)
UPDATE purchase_orders po
SET po.total_amount = (
  SELECT COALESCE(SUM(poi.total_cost), 0)
  FROM purchase_order_items poi
  WHERE poi.purchase_order_id = po.id
)
WHERE po.notes LIKE 'stress%';
UPDATE inventory_batches ib
INNER JOIN (
  SELECT oi.batch_id, SUM(oi.quantity) AS sold_qty
  FROM order_items oi
  INNER JOIN orders o ON o.id = oi.order_id
  INNER JOIN customers c ON c.id = o.customer_id
  INNER JOIN users u ON u.id = c.user_id
  WHERE u.email LIKE 'stress.seed%' AND o.payment_status = 'PAID'
  GROUP BY oi.batch_id
) s ON s.batch_id = ib.id
SET ib.quantity = ib.quantity - s.sold_qty;
UPDATE inventory_batches ib
INNER JOIN (
  SELECT d.batch_id, SUM(d.quantity) AS disposed_qty
  FROM inventory_disposals d
  INNER JOIN products p ON p.id = d.product_id
  WHERE p.slug LIKE 'stress-%'
  GROUP BY d.batch_id
) x ON x.batch_id = ib.id
SET ib.quantity = ib.quantity - x.disposed_qty;

-- Validação pós-seed (esperado: 0 em todas as linhas)
SELECT 'lotes_quantidade_negativa' AS check_name, COUNT(*) AS problemas
FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id
WHERE p.slug LIKE 'stress-%' AND ib.quantity < 0
UNION ALL SELECT 'descarte_maior_que_saldo_atual', COUNT(*)
FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id
INNER JOIN (
  SELECT batch_id, SUM(quantity) AS disposed_qty
  FROM inventory_disposals
  GROUP BY batch_id
) d ON d.batch_id = ib.id
WHERE p.slug LIKE 'stress-%'
  AND d.disposed_qty > ib.quantity + (
    SELECT COALESCE(SUM(oi.quantity), 0)
    FROM order_items oi
    INNER JOIN orders o ON o.id = oi.order_id
    WHERE oi.batch_id = ib.id AND o.payment_status = 'PAID'
  )
UNION ALL SELECT 'pedido_pago_sem_itens', COUNT(*)
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE 'stress.seed%'
  AND o.payment_status = 'PAID'
  AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
UNION ALL SELECT 'pedido_pendente_com_itens', COUNT(*)
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE 'stress.seed%'
  AND o.payment_status <> 'PAID'
  AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
UNION ALL SELECT 'compra_recebida_sem_lote', COUNT(*)
FROM purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
WHERE po.notes LIKE 'stress%'
  AND po.status = 'RECEIVED'
  AND poi.quantity_received > 0
  AND poi.batch_id IS NULL
UNION ALL SELECT 'total_compra_divergente', COUNT(*)
FROM purchase_orders po
WHERE po.notes LIKE 'stress%'
  AND po.total_amount <> (
    SELECT COALESCE(SUM(poi.total_cost), 0)
    FROM purchase_order_items poi
    WHERE poi.purchase_order_id = po.id
  );

-- Profissionais e agenda (RF_F6/F7)
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dra. Helena Martins', 'FARMACEUTICO', 'stress.seed.pro1@neofarma.com', '1899800100', 'CRF', 'SP', '45678', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Paulo Ricardo Dias', 'ENFERMEIRO', 'stress.seed.pro2@neofarma.com', '1899800101', 'COREN', 'SP', '123456', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dra. Camila Rocha', 'FARMACEUTICO', 'stress.seed.pro3@neofarma.com', '1899800102', 'CRF', 'SP', '78901', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Juliana Freitas', 'ENFERMEIRO', 'stress.seed.pro4@neofarma.com', '1899800103', 'COREN', 'SP', '654321', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dr. Roberto Alves', 'FARMACEUTICO', 'stress.seed.pro5@neofarma.com', '1899800104', 'CRF', 'SP', '23456', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Marcos Vinícius', 'ENFERMEIRO', 'stress.seed.pro6@neofarma.com', '1899800105', 'COREN', 'SP', '987654', 0);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro6@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro6@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro6@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro6@neofarma.com' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='stress.seed.pro6@neofarma.com' LIMIT 1;
INSERT INTO service_holidays (holiday_date, name, is_active) VALUES (DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Feriado seed teste', 1) ON DUPLICATE KEY UPDATE name=VALUES(name);
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(0 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -60 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -60 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(0 % 3 = 0, 'PIX', 'CASH'), IF(0 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -60 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(1 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -59 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -59 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(1 % 3 = 0, 'PIX', 'CASH'), IF(1 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(2 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -58 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -58 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(2 % 3 = 0, 'PIX', 'CASH'), IF(2 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(3 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -57 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -57 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(3 % 3 = 0, 'PIX', 'CASH'), IF(3 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(4 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -56 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -56 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(4 % 3 = 0, 'PIX', 'CASH'), IF(4 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(5 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -55 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -55 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(5 % 3 = 0, 'PIX', 'CASH'), IF(5 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(6 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -54 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -54 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(6 % 3 = 0, 'PIX', 'CASH'), IF(6 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(7 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -53 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -53 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(7 % 3 = 0, 'PIX', 'CASH'), IF(7 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(8 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -52 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -52 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(8 % 3 = 0, 'PIX', 'CASH'), IF(8 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -52 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(9 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -51 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -51 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(9 % 3 = 0, 'PIX', 'CASH'), IF(9 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(10 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -50 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -50 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(10 % 3 = 0, 'PIX', 'CASH'), IF(10 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(11 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -49 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -49 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(11 % 3 = 0, 'PIX', 'CASH'), IF(11 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(12 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -48 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -48 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(12 % 3 = 0, 'PIX', 'CASH'), IF(12 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(13 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -47 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -47 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(13 % 3 = 0, 'PIX', 'CASH'), IF(13 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(14 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -46 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -46 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(14 % 3 = 0, 'PIX', 'CASH'), IF(14 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(15 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(15 % 3 = 0, 'PIX', 'CASH'), IF(15 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(16 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(16 % 3 = 0, 'PIX', 'CASH'), IF(16 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(17 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(17 % 3 = 0, 'PIX', 'CASH'), IF(17 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(18 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(18 % 3 = 0, 'PIX', 'CASH'), IF(18 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(19 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(19 % 3 = 0, 'PIX', 'CASH'), IF(19 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(20 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(20 % 3 = 0, 'PIX', 'CASH'), IF(20 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(21 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(21 % 3 = 0, 'PIX', 'CASH'), IF(21 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(22 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(22 % 3 = 0, 'PIX', 'CASH'), IF(22 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(23 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(23 % 3 = 0, 'PIX', 'CASH'), IF(23 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(24 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(24 % 3 = 0, 'PIX', 'CASH'), IF(24 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(25 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(25 % 3 = 0, 'PIX', 'CASH'), IF(25 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(26 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(26 % 3 = 0, 'PIX', 'CASH'), IF(26 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(27 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(27 % 3 = 0, 'PIX', 'CASH'), IF(27 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(28 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(28 % 3 = 0, 'PIX', 'CASH'), IF(28 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(29 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(29 % 3 = 0, 'PIX', 'CASH'), IF(29 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(30 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(30 % 3 = 0, 'PIX', 'CASH'), IF(30 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(31 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(31 % 3 = 0, 'PIX', 'CASH'), IF(31 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(32 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(32 % 3 = 0, 'PIX', 'CASH'), IF(32 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(33 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(33 % 3 = 0, 'PIX', 'CASH'), IF(33 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(34 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(34 % 3 = 0, 'PIX', 'CASH'), IF(34 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(35 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(35 % 3 = 0, 'PIX', 'CASH'), IF(35 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(36 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(36 % 3 = 0, 'PIX', 'CASH'), IF(36 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(37 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(37 % 3 = 0, 'PIX', 'CASH'), IF(37 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(38 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(38 % 3 = 0, 'PIX', 'CASH'), IF(38 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(39 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(39 % 3 = 0, 'PIX', 'CASH'), IF(39 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(40 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -20 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -20 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(40 % 3 = 0, 'PIX', 'CASH'), IF(40 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -20 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(41 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -19 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -19 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(41 % 3 = 0, 'PIX', 'CASH'), IF(41 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(42 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -18 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -18 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(42 % 3 = 0, 'PIX', 'CASH'), IF(42 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(43 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -17 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -17 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(43 % 3 = 0, 'PIX', 'CASH'), IF(43 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(44 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -16 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -16 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(44 % 3 = 0, 'PIX', 'CASH'), IF(44 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(45 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -15 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -15 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(45 % 3 = 0, 'PIX', 'CASH'), IF(45 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(46 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -14 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -14 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(46 % 3 = 0, 'PIX', 'CASH'), IF(46 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(47 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -13 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -13 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(47 % 3 = 0, 'PIX', 'CASH'), IF(47 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(48 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -12 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -12 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(48 % 3 = 0, 'PIX', 'CASH'), IF(48 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -12 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(49 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -11 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -11 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(49 % 3 = 0, 'PIX', 'CASH'), IF(49 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(50 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -10 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -10 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(50 % 3 = 0, 'PIX', 'CASH'), IF(50 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(51 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -9 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -9 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(51 % 3 = 0, 'PIX', 'CASH'), IF(51 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(52 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -8 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -8 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(52 % 3 = 0, 'PIX', 'CASH'), IF(52 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(53 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -7 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -7 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(53 % 3 = 0, 'PIX', 'CASH'), IF(53 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(54 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -6 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -6 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(54 % 3 = 0, 'PIX', 'CASH'), IF(54 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(55 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -5 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -5 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(55 % 3 = 0, 'PIX', 'CASH'), IF(55 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(56 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -4 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -4 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(56 % 3 = 0, 'PIX', 'CASH'), IF(56 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -4 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(57 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -3 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -3 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(57 % 3 = 0, 'PIX', 'CASH'), IF(57 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(58 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -2 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -2 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(58 % 3 = 0, 'PIX', 'CASH'), IF(58 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(59 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -1 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -1 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(59 % 3 = 0, 'PIX', 'CASH'), IF(59 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(60 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 0 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 0 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(60 % 3 = 0, 'PIX', 'CASH'), IF(60 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(61 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 1 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 1 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(61 % 3 = 0, 'PIX', 'CASH'), IF(61 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(62 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 2 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 2 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(62 % 3 = 0, 'PIX', 'CASH'), IF(62 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(63 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(63 % 3 = 0, 'PIX', 'CASH'), IF(63 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(64 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 4 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 4 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(64 % 3 = 0, 'PIX', 'CASH'), IF(64 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL 4 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(65 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 5 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 5 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(65 % 3 = 0, 'PIX', 'CASH'), IF(65 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(66 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 6 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 6 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(66 % 3 = 0, 'PIX', 'CASH'), IF(66 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(67 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 7 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 7 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(67 % 3 = 0, 'PIX', 'CASH'), IF(67 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(68 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 8 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 8 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(68 % 3 = 0, 'PIX', 'CASH'), IF(68 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(69 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 9 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 9 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(69 % 3 = 0, 'PIX', 'CASH'), IF(69 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(70 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 10 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 10 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(70 % 3 = 0, 'PIX', 'CASH'), IF(70 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(71 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 11 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 11 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(71 % 3 = 0, 'PIX', 'CASH'), IF(71 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(72 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 12 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 12 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(72 % 3 = 0, 'PIX', 'CASH'), IF(72 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL 12 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(73 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 13 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 13 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(73 % 3 = 0, 'PIX', 'CASH'), IF(73 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(74 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 14 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 14 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(74 % 3 = 0, 'PIX', 'CASH'), IF(74 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(75 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 15 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 15 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(75 % 3 = 0, 'PIX', 'CASH'), IF(75 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente21@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(76 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 16 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 16 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(76 % 3 = 0, 'PIX', 'CASH'), IF(76 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente22@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(77 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 17 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 17 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(77 % 3 = 0, 'PIX', 'CASH'), IF(77 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente23@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(78 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 18 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 18 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(78 % 3 = 0, 'PIX', 'CASH'), IF(78 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente24@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(79 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 19 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 19 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(79 % 3 = 0, 'PIX', 'CASH'), IF(79 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente25@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(80 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 20 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 20 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(80 % 3 = 0, 'PIX', 'CASH'), IF(80 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL 20 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente26@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(81 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 21 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 21 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(81 % 3 = 0, 'PIX', 'CASH'), IF(81 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente27@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(82 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 22 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 22 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(82 % 3 = 0, 'PIX', 'CASH'), IF(82 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente28@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(83 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 23 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 23 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(83 % 3 = 0, 'PIX', 'CASH'), IF(83 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente29@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(84 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 24 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 24 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(84 % 3 = 0, 'PIX', 'CASH'), IF(84 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente30@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(85 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 25 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 25 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(85 % 3 = 0, 'PIX', 'CASH'), IF(85 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente31@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(86 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 26 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 26 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(86 % 3 = 0, 'PIX', 'CASH'), IF(86 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente32@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(87 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 27 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 27 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(87 % 3 = 0, 'PIX', 'CASH'), IF(87 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente33@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(88 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 28 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 28 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(88 % 3 = 0, 'PIX', 'CASH'), IF(88 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL 28 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente34@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(89 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL 29 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL 29 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(89 % 3 = 0, 'PIX', 'CASH'), IF(89 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente35@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(90 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -60 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -60 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(90 % 3 = 0, 'PIX', 'CASH'), IF(90 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente36@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(91 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -59 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -59 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(91 % 3 = 0, 'PIX', 'CASH'), IF(91 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente37@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(92 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -58 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -58 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(92 % 3 = 0, 'PIX', 'CASH'), IF(92 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente38@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(93 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -57 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -57 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(93 % 3 = 0, 'PIX', 'CASH'), IF(93 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente39@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(94 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -56 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -56 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(94 % 3 = 0, 'PIX', 'CASH'), IF(94 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente40@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(95 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -55 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -55 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(95 % 3 = 0, 'PIX', 'CASH'), IF(95 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente41@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(96 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -54 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -54 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(96 % 3 = 0, 'PIX', 'CASH'), IF(96 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -54 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente42@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(97 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -53 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -53 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(97 % 3 = 0, 'PIX', 'CASH'), IF(97 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente43@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(98 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -52 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -52 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(98 % 3 = 0, 'PIX', 'CASH'), IF(98 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente44@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(99 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -51 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -51 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(99 % 3 = 0, 'PIX', 'CASH'), IF(99 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente45@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(100 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -50 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -50 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(100 % 3 = 0, 'PIX', 'CASH'), IF(100 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente46@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(101 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -49 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -49 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(101 % 3 = 0, 'PIX', 'CASH'), IF(101 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente47@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(102 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -48 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -48 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(102 % 3 = 0, 'PIX', 'CASH'), IF(102 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente48@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(103 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -47 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -47 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(103 % 3 = 0, 'PIX', 'CASH'), IF(103 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente49@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(104 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -46 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -46 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(104 % 3 = 0, 'PIX', 'CASH'), IF(104 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -46 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente50@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(105 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(105 % 3 = 0, 'PIX', 'CASH'), IF(105 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente51@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(106 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(106 % 3 = 0, 'PIX', 'CASH'), IF(106 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente52@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(107 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(107 % 3 = 0, 'PIX', 'CASH'), IF(107 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente53@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(108 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(108 % 3 = 0, 'PIX', 'CASH'), IF(108 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente54@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(109 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(109 % 3 = 0, 'PIX', 'CASH'), IF(109 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente55@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(110 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(110 % 3 = 0, 'PIX', 'CASH'), IF(110 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(111 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(111 % 3 = 0, 'PIX', 'CASH'), IF(111 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(112 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(112 % 3 = 0, 'PIX', 'CASH'), IF(112 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(113 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(113 % 3 = 0, 'PIX', 'CASH'), IF(113 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(114 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(114 % 3 = 0, 'PIX', 'CASH'), IF(114 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(115 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(115 % 3 = 0, 'PIX', 'CASH'), IF(115 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(116 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(116 % 3 = 0, 'PIX', 'CASH'), IF(116 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(117 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(117 % 3 = 0, 'PIX', 'CASH'), IF(117 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(118 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(118 % 3 = 0, 'PIX', 'CASH'), IF(118 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(119 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(119 % 3 = 0, 'PIX', 'CASH'), IF(119 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(120 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(120 % 3 = 0, 'PIX', 'CASH'), IF(120 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(121 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(121 % 3 = 0, 'PIX', 'CASH'), IF(121 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(122 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(122 % 3 = 0, 'PIX', 'CASH'), IF(122 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente13@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(123 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(123 % 3 = 0, 'PIX', 'CASH'), IF(123 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente14@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(124 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(124 % 3 = 0, 'PIX', 'CASH'), IF(124 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente15@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='stress.seed.pro1@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(125 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(125 % 3 = 0, 'PIX', 'CASH'), IF(125 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente16@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='stress.seed.pro2@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(126 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(126 % 3 = 0, 'PIX', 'CASH'), IF(126 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente17@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='stress.seed.pro3@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(127 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(127 % 3 = 0, 'PIX', 'CASH'), IF(127 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente18@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='stress.seed.pro4@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(128 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(128 % 3 = 0, 'PIX', 'CASH'), IF(128 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo farmacêutico.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente19@neofarma.com' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='stress.seed.pro5@neofarma.com' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(129 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(129 % 3 = 0, 'PIX', 'CASH'), IF(129 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente20@neofarma.com' LIMIT 1;

-- Receitas
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 1', 'CRM-SP 100000', DATE_SUB(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'stress receita teste #1'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente01@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #1' AND p.slug='stress-prod-001' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 2', 'CRM-SP 100001', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 89 DAY), 'stress receita teste #2'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente02@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #2' AND p.slug='stress-prod-002' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 3', 'CRM-SP 100002', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 88 DAY), 'stress receita teste #3'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente03@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #3' AND p.slug='stress-prod-003' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 4', 'CRM-SP 100003', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 87 DAY), 'stress receita teste #4'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente04@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #4' AND p.slug='stress-prod-004' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 5', 'CRM-SP 100004', DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_ADD(CURDATE(), INTERVAL 86 DAY), 'stress receita teste #5'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente05@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #5' AND p.slug='stress-prod-005' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 6', 'CRM-SP 100005', DATE_SUB(CURDATE(), INTERVAL 50 DAY), DATE_ADD(CURDATE(), INTERVAL 85 DAY), 'stress receita teste #6'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente06@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #6' AND p.slug='stress-prod-006' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 7', 'CRM-SP 100006', DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_ADD(CURDATE(), INTERVAL 84 DAY), 'stress receita teste #7'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente07@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #7' AND p.slug='stress-prod-007' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 8', 'CRM-SP 100007', DATE_SUB(CURDATE(), INTERVAL 70 DAY), DATE_ADD(CURDATE(), INTERVAL 83 DAY), 'stress receita teste #8'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente08@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #8' AND p.slug='stress-prod-008' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 9', 'CRM-SP 100008', DATE_SUB(CURDATE(), INTERVAL 80 DAY), DATE_ADD(CURDATE(), INTERVAL 82 DAY), 'stress receita teste #9'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente09@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #9' AND p.slug='stress-prod-009' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 10', 'CRM-SP 100009', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 81 DAY), 'stress receita teste #10'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente10@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #10' AND p.slug='stress-prod-010' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 11', 'CRM-SP 100010', DATE_SUB(CURDATE(), INTERVAL 100 DAY), DATE_ADD(CURDATE(), INTERVAL 80 DAY), 'stress receita teste #11'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente11@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #11' AND p.slug='stress-prod-011' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Médico Seed 12', 'CRM-SP 100011', DATE_SUB(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 79 DAY), 'stress receita teste #12'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='stress.seed.cliente12@neofarma.com' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='stress receita teste #12' AND p.slug='stress-prod-012' LIMIT 1;

-- Resumo
SELECT 'Usuários stress' AS item, COUNT(*) AS qtd FROM users WHERE email LIKE 'stress.seed%'
UNION ALL SELECT 'Produtos stress', COUNT(*) FROM products WHERE slug LIKE 'stress-%'
UNION ALL SELECT 'Pedidos stress', COUNT(*) FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE 'stress.seed%')
UNION ALL SELECT 'Agendamentos stress', COUNT(*) FROM service_appointments WHERE customer_email LIKE 'stress.seed%'
;

-- Logins de teste (senha: 123456)
-- Admin:     stress.seed.admin@neofarma.com
-- Func.:     stress.seed.funcionario@neofarma.com
-- Estoq.:    stress.seed.estoquista@neofarma.com
-- Cliente:   stress.seed.cliente01@neofarma.com
-- Cliente PJ: stress.seed.pj01@neofarma.com