-- ============================================================
-- NEOFARMA — Base de demonstração operacional
-- Gerado por: node scripts/old/generate_demo_brasil.js
-- Imagens: public/assets/img/product-farma/ (22 arquivos)
-- Pré-requisito: scripts/DB_Neofarma_clean.sql
-- Senha dos usuários @loja.neofarma.com.br: NeoFarma@2026
-- Admin original do schema: admin@neofarma.com / Admin@123
-- ============================================================

USE neofarma;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Limpeza de execução anterior
DELETE FROM inventory_disposals WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%');
DELETE FROM order_pending_items WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br');
DELETE FROM order_items WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br');
DELETE FROM payments WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br');
DELETE FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br');
DELETE FROM purchase_order_items WHERE purchase_order_id IN (SELECT id FROM purchase_orders WHERE notes LIKE 'OC-2024-%');
DELETE FROM purchase_orders WHERE notes LIKE 'OC-2024-%';
DELETE FROM service_appointments WHERE customer_email LIKE '%@loja.neofarma.com.br';
DELETE FROM service_professional_availability WHERE professional_id IN (SELECT id FROM service_professionals WHERE email LIKE '%@loja.neofarma.com.br');
DELETE FROM service_professionals WHERE email LIKE '%@loja.neofarma.com.br';
DELETE FROM prescription_items WHERE prescription_id IN (SELECT id FROM prescriptions WHERE notes LIKE 'Receita %');
DELETE FROM prescriptions WHERE notes LIKE 'Receita %';
DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%');
DELETE FROM product_categories WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%');
DELETE FROM inventory_batches WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%');
DELETE FROM products WHERE sku LIKE 'NF-%';
DELETE FROM customer_addresses WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br');
DELETE FROM customers WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%@loja.neofarma.com.br');
DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%@loja.neofarma.com.br');
DELETE FROM users WHERE email LIKE '%@loja.neofarma.com.br';
DELETE FROM suppliers WHERE cnpj LIKE '30%' AND corporate_name IN ('Distribuidora Fitonatural Ltda', 'Ervas do Campo Comercial ME', 'Verde Vida Distribuição SA', 'Botica Popular Atacado Ltda', 'Pharma Nativa Supply Ltda', 'Central de Insumos Naturais EPP', 'MaxFito Distribuidora Ltda', 'Organica Trade Importadora SA');
DELETE FROM labs WHERE name IN ('Herbarium Laboratório Botânico', 'Apsen Farmacêutica', 'Aché Laboratórios Farmacêuticos', 'Legrand Pharma', 'Natulab Laboratório Natural', 'Medley Farmacêutica');
DELETE FROM categories WHERE slug IN ('oleos-essenciais', 'oleos-vegetais', 'blends-aromaticos', 'chas-medicinais', 'chas-digestivos', 'infusoes-funcionais', 'vitaminas-minerais', 'probioticos-enzimas', 'oleos-omegas', 'extratos-secos', 'tinturas-fluidos', 'xaropes-solucoes', 'cuidados-corporais', 'cuidados-faciais', 'higiene-bucal-natural', 'higiene-pessoal');
DELETE FROM categories WHERE slug IN ('aromaterapia', 'chas-infusiones', 'suplementacao', 'fitoterapicos', 'dermocosmetica-natural', 'higiene-bem-estar', 'fitoterapicos', 'suplementos', 'dermocosmeticos', 'higiene-natural', 'manipulados', 'infantil-natural', 'oleos-essenciais-legacy', 'fitoterapico-legacy');
DELETE FROM product_types WHERE slug IN ('capsulas', 'comprimidos', 'gotas', 'tintura', 'xarope', 'ervas-a-granel', 'roll-on', 'creme-gel', 'spray', 'oleo-fracionado', 'fitoterapico', 'suplemento-alimentar', 'higiene-pessoal', 'cosmetico-natural', 'cha-medicinal', 'oleo-essencial', 'homeopatia', 'produto-manipulado');
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO roles (name, description) VALUES
('ADMIN','Administrador'),('FUNCIONARIO','Funcionário'),('ESTOQUISTA','Estoquista'),('CLIENTE','Cliente')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Apresentações físicas (independentes da categoria departamental)
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Cápsulas', 'capsulas', 'Produtos encapsulados de uso oral', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Comprimidos', 'comprimidos', 'Comprimidos sólidos de uso oral', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Gotas', 'gotas', 'Soluções orais em gotas', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Tintura', 'tintura', 'Extratos hidroalcoólicos', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Xarope', 'xarope', 'Soluções viscosas orais', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Ervas a Granel', 'ervas-a-granel', 'Plantas medicinais a granel para infusão', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Roll-on', 'roll-on', 'Aplicador roll-on para uso tópico/aromático', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Creme / Gel', 'creme-gel', 'Emulsões e géis para uso tópico', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Spray', 'spray', 'Soluções em spray', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO product_types (name, slug, description, is_active) VALUES ('Óleo fracionado', 'oleo-fracionado', 'Óleos essenciais, vegetais ou blends fracionados', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);

-- Categorias pai (macro-departamentos — parent_id NULL)
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Aromaterapia', 'aromaterapia', 'Óleos essenciais, vegetais e blends para bem-estar olfativo', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Chás e Infusões', 'chas-infusiones', 'Chás funcionais, digestivos e infusões medicinais', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Suplementação', 'suplementacao', 'Vitaminas, minerais, ômegas e probióticos', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Fitoterápicos', 'fitoterapicos', 'Medicamentos e insumos de origem vegetal', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Dermocosmética Natural', 'dermocosmetica-natural', 'Cuidados naturais para pele e corpo', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;
INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, 'Higiene e Bem-estar', 'higiene-bem-estar', 'Higiene pessoal e autocuidado natural', 1) ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description), parent_id=NULL;

-- Categorias filhas (sub-departamentos — parent_id aponta para a categoria pai)
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Óleos Essenciais', 'oleos-essenciais', 'Óleos essenciais puros e naturais', 1
FROM categories p WHERE p.slug = 'aromaterapia' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Óleos Vegetais', 'oleos-vegetais', 'Carreadores vegetais para diluição', 1
FROM categories p WHERE p.slug = 'aromaterapia' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Blends Aromáticos', 'blends-aromaticos', 'Misturas prontas para aromaterapia', 1
FROM categories p WHERE p.slug = 'aromaterapia' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Chás Medicinais', 'chas-medicinais', 'Chás de plantas medicinais', 1
FROM categories p WHERE p.slug = 'chas-infusiones' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Chás Digestivos', 'chas-digestivos', 'Blends para conforto digestivo', 1
FROM categories p WHERE p.slug = 'chas-infusiones' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Infusões Funcionais', 'infusoes-funcionais', 'Infusões para rotina de bem-estar', 1
FROM categories p WHERE p.slug = 'chas-infusiones' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Vitaminas e Minerais', 'vitaminas-minerais', 'Suplementação vitamínica e mineral', 1
FROM categories p WHERE p.slug = 'suplementacao' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Probióticos e Enzimas', 'probioticos-enzimas', 'Suporte à microbiota e digestão', 1
FROM categories p WHERE p.slug = 'suplementacao' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Óleos e Ômegas', 'oleos-omegas', 'Ácidos graxos essenciais e óleos funcionais', 1
FROM categories p WHERE p.slug = 'suplementacao' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Extratos Secos', 'extratos-secos', 'Extratos vegetais padronizados', 1
FROM categories p WHERE p.slug = 'fitoterapicos' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Tinturas e Fluidos', 'tinturas-fluidos', 'Tinturas, soluções e fluidos fitoterápicos', 1
FROM categories p WHERE p.slug = 'fitoterapicos' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Xaropes e Soluções', 'xaropes-solucoes', 'Xaropes e soluções orais fitoterápicas', 1
FROM categories p WHERE p.slug = 'fitoterapicos' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Cuidados Corporais', 'cuidados-corporais', 'Hidratantes, géis e óleos corporais', 1
FROM categories p WHERE p.slug = 'dermocosmetica-natural' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Cuidados Faciais', 'cuidados-faciais', 'Sérums, cremes e tratamentos faciais', 1
FROM categories p WHERE p.slug = 'dermocosmetica-natural' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Higiene Bucal Natural', 'higiene-bucal-natural', 'Pastas, enxaguantes e sprays bucais naturais', 1
FROM categories p WHERE p.slug = 'higiene-bem-estar' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);
INSERT INTO categories (parent_id, name, slug, description, is_active)
SELECT p.id, 'Higiene Pessoal', 'higiene-pessoal', 'Sabonetes, shampoos e desodorantes naturais', 1
FROM categories p WHERE p.slug = 'higiene-bem-estar' LIMIT 1
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);

-- Endereços
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Siqueira Campos', '100', 'Sala 100', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010010');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Manoel Goulart', '117', NULL, 'Vila Nova', 'Presidente Prudente', 'SP', 'Brasil', '19020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Tenente Nicolau Mascarenhas', '134', NULL, 'Jardim Paulista', 'Presidente Prudente', 'SP', 'Brasil', '19023450');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Coronel José Soares Marcondes', '151', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua José Bonifácio', '168', 'Sala 104', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010020');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Duque de Caxias', '185', NULL, 'Centro', 'São Paulo', 'SP', 'Brasil', '01025000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Paulista', '202', NULL, 'Bela Vista', 'São Paulo', 'SP', 'Brasil', '01311000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Augusta', '219', NULL, 'Consolação', 'São Paulo', 'SP', 'Brasil', '01305000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua XV de Novembro', '236', 'Sala 108', 'Centro', 'Campinas', 'SP', 'Brasil', '13010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Francisco Glicério', '253', NULL, 'Centro', 'Campinas', 'SP', 'Brasil', '13012000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua das Palmeiras', '270', NULL, 'Jardim América', 'Ribeirão Preto', 'SP', 'Brasil', '14020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Nove de Julho', '287', NULL, 'Centro', 'Ribeirão Preto', 'SP', 'Brasil', '14015000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Siqueira Campos', '304', 'Sala 112', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010010');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Manoel Goulart', '321', NULL, 'Vila Nova', 'Presidente Prudente', 'SP', 'Brasil', '19020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Tenente Nicolau Mascarenhas', '338', NULL, 'Jardim Paulista', 'Presidente Prudente', 'SP', 'Brasil', '19023450');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Coronel José Soares Marcondes', '355', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua José Bonifácio', '372', 'Sala 116', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010020');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Duque de Caxias', '389', NULL, 'Centro', 'São Paulo', 'SP', 'Brasil', '01025000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Paulista', '406', NULL, 'Bela Vista', 'São Paulo', 'SP', 'Brasil', '01311000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Augusta', '423', NULL, 'Consolação', 'São Paulo', 'SP', 'Brasil', '01305000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua XV de Novembro', '440', 'Sala 120', 'Centro', 'Campinas', 'SP', 'Brasil', '13010000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Francisco Glicério', '457', NULL, 'Centro', 'Campinas', 'SP', 'Brasil', '13012000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua das Palmeiras', '474', NULL, 'Jardim América', 'Ribeirão Preto', 'SP', 'Brasil', '14020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Nove de Julho', '491', NULL, 'Centro', 'Ribeirão Preto', 'SP', 'Brasil', '14015000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Siqueira Campos', '508', 'Sala 124', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010010');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Manoel Goulart', '525', NULL, 'Vila Nova', 'Presidente Prudente', 'SP', 'Brasil', '19020000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Tenente Nicolau Mascarenhas', '542', NULL, 'Jardim Paulista', 'Presidente Prudente', 'SP', 'Brasil', '19023450');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Coronel José Soares Marcondes', '559', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010001');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua José Bonifácio', '576', 'Sala 128', 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19010020');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Duque de Caxias', '593', NULL, 'Centro', 'São Paulo', 'SP', 'Brasil', '01025000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Avenida Paulista', '610', NULL, 'Bela Vista', 'São Paulo', 'SP', 'Brasil', '01311000');
INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES ('Rua Augusta', '627', NULL, 'Consolação', 'São Paulo', 'SP', 'Brasil', '01305000');
SET @addr_base := (SELECT MIN(id) FROM (SELECT id FROM addresses ORDER BY id DESC LIMIT 32) AS recent_addrs);

-- Laboratórios e fornecedores
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Herbarium Laboratório Botânico', '20000000000018', 'contato@herbarium.com.br', '1899001000', @addr_base + 0, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Apsen Farmacêutica', '20000000111197', 'sac@apsen.com.br', '1899001001', @addr_base + 1, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Aché Laboratórios Farmacêuticos', '20000000222266', 'sac@ache.com.br', '1899001002', @addr_base + 2, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Legrand Pharma', '20000000333335', 'atendimento@legrand.com.br', '1899001003', @addr_base + 3, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Natulab Laboratório Natural', '20000000444404', 'comercial@natulab.com.br', '1899001004', @addr_base + 4, 1);
INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES ('Medley Farmacêutica', '20000000555583', 'atendimento@medley.com.br', '1899001005', @addr_base + 5, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Distribuidora Fitonatural Ltda', 'Fitonatural', '30000000000071', 'compras@fitonatural.com.br', '1899102000', @addr_base + 5, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Ervas do Campo Comercial ME', 'Ervas do Campo', '30000000222210', 'vendas@ervasdocampo.com.br', '1899102001', @addr_base + 6, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Verde Vida Distribuição SA', 'Verde Vida', '30000000444468', 'logistica@verdevida.com.br', '1899102002', @addr_base + 7, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Botica Popular Atacado Ltda', 'Botica Popular', '30000000666606', 'atacado@boticapopular.com.br', '1899102003', @addr_base + 8, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Pharma Nativa Supply Ltda', 'Pharma Nativa', '30000000888854', 'supply@pharmanativa.com.br', '1899102004', @addr_base + 9, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Central de Insumos Naturais EPP', 'Central Naturais', '30000001111004', 'pedidos@centralnaturais.com.br', '1899102005', @addr_base + 10, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('MaxFito Distribuidora Ltda', 'MaxFito', '30000001333252', 'comercial@maxfito.com.br', '1899102006', @addr_base + 11, 1);
INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES ('Organica Trade Importadora SA', 'Organica Trade', '30000001555409', 'trade@organica.com.br', '1899102007', @addr_base + 12, 0);
SET @lab_id := (SELECT id FROM labs WHERE name = 'Herbarium Laboratório Botânico' LIMIT 1);
SET @supplier_id := (SELECT id FROM suppliers WHERE trade_name = 'Fitonatural' LIMIT 1);
SET @cat_aromaterapia := (SELECT id FROM categories WHERE slug = 'aromaterapia' LIMIT 1);
SET @cat_oleos_essenciais := (SELECT id FROM categories WHERE slug = 'oleos-essenciais' LIMIT 1);
SET @cat_oleos_vegetais := (SELECT id FROM categories WHERE slug = 'oleos-vegetais' LIMIT 1);
SET @cat_blends_aromaticos := (SELECT id FROM categories WHERE slug = 'blends-aromaticos' LIMIT 1);
SET @cat_chas_infusiones := (SELECT id FROM categories WHERE slug = 'chas-infusiones' LIMIT 1);
SET @cat_chas_medicinais := (SELECT id FROM categories WHERE slug = 'chas-medicinais' LIMIT 1);
SET @cat_chas_digestivos := (SELECT id FROM categories WHERE slug = 'chas-digestivos' LIMIT 1);
SET @cat_infusoes_funcionais := (SELECT id FROM categories WHERE slug = 'infusoes-funcionais' LIMIT 1);
SET @cat_suplementacao := (SELECT id FROM categories WHERE slug = 'suplementacao' LIMIT 1);
SET @cat_vitaminas_minerais := (SELECT id FROM categories WHERE slug = 'vitaminas-minerais' LIMIT 1);
SET @cat_probioticos_enzimas := (SELECT id FROM categories WHERE slug = 'probioticos-enzimas' LIMIT 1);
SET @cat_oleos_omegas := (SELECT id FROM categories WHERE slug = 'oleos-omegas' LIMIT 1);
SET @cat_fitoterapicos := (SELECT id FROM categories WHERE slug = 'fitoterapicos' LIMIT 1);
SET @cat_extratos_secos := (SELECT id FROM categories WHERE slug = 'extratos-secos' LIMIT 1);
SET @cat_tinturas_fluidos := (SELECT id FROM categories WHERE slug = 'tinturas-fluidos' LIMIT 1);
SET @cat_xaropes_solucoes := (SELECT id FROM categories WHERE slug = 'xaropes-solucoes' LIMIT 1);
SET @cat_dermocosmetica_natural := (SELECT id FROM categories WHERE slug = 'dermocosmetica-natural' LIMIT 1);
SET @cat_cuidados_corporais := (SELECT id FROM categories WHERE slug = 'cuidados-corporais' LIMIT 1);
SET @cat_cuidados_faciais := (SELECT id FROM categories WHERE slug = 'cuidados-faciais' LIMIT 1);
SET @cat_higiene_bem_estar := (SELECT id FROM categories WHERE slug = 'higiene-bem-estar' LIMIT 1);
SET @cat_higiene_bucal_natural := (SELECT id FROM categories WHERE slug = 'higiene-bucal-natural' LIMIT 1);
SET @cat_higiene_pessoal := (SELECT id FROM categories WHERE slug = 'higiene-pessoal' LIMIT 1);
SET @cat_suplementos := (SELECT id FROM categories WHERE slug = 'suplementos' LIMIT 1);
SET @cat_dermocosmeticos := (SELECT id FROM categories WHERE slug = 'dermocosmeticos' LIMIT 1);
SET @cat_higiene_natural := (SELECT id FROM categories WHERE slug = 'higiene-natural' LIMIT 1);
SET @cat_manipulados := (SELECT id FROM categories WHERE slug = 'manipulados' LIMIT 1);
SET @cat_infantil_natural := (SELECT id FROM categories WHERE slug = 'infantil-natural' LIMIT 1);
SET @cat_oleos_essenciais_legacy := (SELECT id FROM categories WHERE slug = 'oleos-essenciais-legacy' LIMIT 1);
SET @cat_fitoterapico_legacy := (SELECT id FROM categories WHERE slug = 'fitoterapico-legacy' LIMIT 1);
SET @type_capsulas := (SELECT id FROM product_types WHERE slug = 'capsulas' LIMIT 1);
SET @type_comprimidos := (SELECT id FROM product_types WHERE slug = 'comprimidos' LIMIT 1);
SET @type_gotas := (SELECT id FROM product_types WHERE slug = 'gotas' LIMIT 1);
SET @type_tintura := (SELECT id FROM product_types WHERE slug = 'tintura' LIMIT 1);
SET @type_xarope := (SELECT id FROM product_types WHERE slug = 'xarope' LIMIT 1);
SET @type_ervas_a_granel := (SELECT id FROM product_types WHERE slug = 'ervas-a-granel' LIMIT 1);
SET @type_roll_on := (SELECT id FROM product_types WHERE slug = 'roll-on' LIMIT 1);
SET @type_creme_gel := (SELECT id FROM product_types WHERE slug = 'creme-gel' LIMIT 1);
SET @type_spray := (SELECT id FROM product_types WHERE slug = 'spray' LIMIT 1);
SET @type_oleo_fracionado := (SELECT id FROM product_types WHERE slug = 'oleo-fracionado' LIMIT 1);

-- Equipe
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Eliane Souza Moraes', 'eliane.moraes@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '90000000094', '1899700100', '1985-06-15', 1 FROM roles r WHERE r.name='FUNCIONARIO' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 3200, 'Atendente de Balcão' FROM users u WHERE u.email='eliane.moraes@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Robson Pereira Lima', 'robson.lima@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '90000000175', '1899700101', '1985-06-15', 1 FROM roles r WHERE r.name='ESTOQUISTA' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 2800, 'Estoquista' FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Marcos Antônio Ribeiro', 'marcos.ribeiro@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '90000000256', '1899700102', '1985-06-15', 1 FROM roles r WHERE r.name='ADMIN' LIMIT 1;
INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', 8500, 'Gerente Operacional' FROM users u WHERE u.email='marcos.ribeiro@loja.neofarma.com.br' LIMIT 1;

-- Clientes PF
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Ana Beatriz Ferreira', 'ana.beatriz@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000108', '1799600100', '1970-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 0, 0 FROM users u WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 0, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Carlos Eduardo Souza', 'carlos.eduardo2@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000280', '1799600101', '1971-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 1, 17 FROM users u WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 1, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Mariana Oliveira Lima', 'mariana.oliveira3@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000361', '1799600102', '1972-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 2, 34 FROM users u WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 2, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'João Pedro Almeida', 'joao.pedro4@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000442', '1799600103', '1973-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 3, 51 FROM users u WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 3, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Fernanda Rocha Martins', 'fernanda.rocha5@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000523', '1799600104', '1974-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 4, 68 FROM users u WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 4, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Ricardo Henrique Dias', 'ricardo.henrique6@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000604', '1799600105', '1975-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 5, 85 FROM users u WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 5, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Juliana Costa Pereira', 'juliana.costa7@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000795', '1799600106', '1976-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 6, 102 FROM users u WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 6, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Lucas Gabriel Santos', 'lucas.gabriel8@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000876', '1799600107', '1977-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 7, 119 FROM users u WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 7, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Patrícia Mendes Barbosa', 'patricia.mendes9@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000000957', '1799600108', '1978-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 8, 136 FROM users u WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 8, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Roberto Carlos Nunes', 'roberto.carlos10@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001090', '1799600109', '1979-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 9, 153 FROM users u WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 9, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Camila Duarte Freitas', 'camila.duarte11@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001171', '1799600110', '1980-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 10, 170 FROM users u WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 10, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Bruno Henrique Castro', 'bruno.henrique12@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001252', '1799600111', '1981-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 11, 187 FROM users u WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 11, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Larissa Aparecida Melo', 'larissa.aparecida13@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001333', '1799600112', '1982-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 12, 204 FROM users u WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 12, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Diego Augusto Ribeiro', 'diego.augusto14@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001414', '1799600113', '1983-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 13, 221 FROM users u WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 13, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Amanda Cristina Gomes', 'amanda.cristina15@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001503', '1799600114', '1984-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 14, 238 FROM users u WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 14, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Felipe Andrade Teixeira', 'felipe.andrade16@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001686', '1799600115', '1985-04-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 15, 255 FROM users u WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 15, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Bianca Luiza Carvalho', 'bianca.luiza17@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001767', '1799600116', '1986-05-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 16, 272 FROM users u WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 16, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Thiago Rafael Pinto', 'thiago.rafael18@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001848', '1799600117', '1987-06-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 17, 289 FROM users u WHERE u.email='thiago.rafael18@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 17, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='thiago.rafael18@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Gabriela Moura Azevedo', 'gabriela.moura19@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000001929', '1799600118', '1988-07-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 18, 306 FROM users u WHERE u.email='gabriela.moura19@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 18, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='gabriela.moura19@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Vinícius Luís Correia', 'vinicius.luis20@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002062', '1799600119', '1989-08-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 19, 323 FROM users u WHERE u.email='vinicius.luis20@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 19, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='vinicius.luis20@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Helena Vitória Cardoso', 'helena.vitoria21@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002143', '1799600120', '1990-09-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 20, 340 FROM users u WHERE u.email='helena.vitoria21@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 20, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='helena.vitoria21@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Matheus Antônio Lopes', 'matheus.antonio22@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002224', '1799600121', '1991-10-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 21, 357 FROM users u WHERE u.email='matheus.antonio22@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 21, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='matheus.antonio22@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Isabela Fernanda Vieira', 'isabela.fernanda23@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002305', '1799600122', '1992-11-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 22, 374 FROM users u WHERE u.email='isabela.fernanda23@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 22, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='isabela.fernanda23@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Guilherme Augusto Ramos', 'guilherme.augusto24@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002496', '1799600123', '1993-12-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 23, 391 FROM users u WHERE u.email='guilherme.augusto24@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 23, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='guilherme.augusto24@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Beatriz Helena Monteiro', 'beatriz.helena25@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002577', '1799600124', '1994-01-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 24, 408 FROM users u WHERE u.email='beatriz.helena25@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 24, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='beatriz.helena25@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rafaela Cristiane Farias', 'rafaela.cristiane26@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002658', '1799600125', '1995-02-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 25, 425 FROM users u WHERE u.email='rafaela.cristiane26@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 25, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='rafaela.cristiane26@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Daniel Augusto Borges', 'daniel.augusto27@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002739', '1799600126', '1996-03-15', 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 26, 442 FROM users u WHERE u.email='daniel.augusto27@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 26, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='daniel.augusto27@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Natália Souza Rezende', 'natalia.souza28@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '10000002810', '1799600127', '1997-04-15', 0 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 27, 459 FROM users u WHERE u.email='natalia.souza28@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 27, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='natalia.souza28@loja.neofarma.com.br' LIMIT 1;

-- Clientes PJ
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Clínica Bem Viver Ltda', 'empresa.clinica-bem-viver-lt@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '40000000000025', '1135500100', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 28, 100 FROM users u WHERE u.email='empresa.clinica-bem-viver-lt@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 28, 'Matriz', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.clinica-bem-viver-lt@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Distribuidora Fitonatural ME', 'empresa.distribuidora-fitona@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '40000000333342', '1135500101', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 29, 150 FROM users u WHERE u.email='empresa.distribuidora-fitona@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 29, 'Matriz', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.distribuidora-fitona@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Laboratório Verde Vida SA', 'empresa.laboratorio-verde-vi@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '40000000666660', '1135500102', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 30, 200 FROM users u WHERE u.email='empresa.laboratorio-verde-vi@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 30, 'Matriz', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.laboratorio-verde-vi@loja.neofarma.com.br' LIMIT 1;
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, 'Rede Saúde Integrada Ltda', 'empresa.rede-saude-integrada@loja.neofarma.com.br', '$2b$10$Y1AI4ffGhFQ3T1M5C9x3eeJv5CVKVZSoFHGczfXaxsG7jXIBKWE9O', '40000000999987', '1135500103', NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;
INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + 31, 250 FROM users u WHERE u.email='empresa.rede-saude-integrada@loja.neofarma.com.br' LIMIT 1;
INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + 31, 'Matriz', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.rede-saude-integrada@loja.neofarma.com.br' LIMIT 1;

-- Produtos (categoria departamental + apresentação física)
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Valeriana Officinalis 500mg', 'valeriana-officinalis-500mg', 'NF-0001', '7891000000014', 'Valeriana Officinalis 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 12.90, 11.35, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtiFlex%20400mg.png', 0 FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Passiflora Incarnata 400mg', 'passiflora-incarnata-400mg', 'NF-0002', '7891000000021', 'Passiflora Incarnata 400mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 16.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtroFlex%20%E2%80%93%20Fitoter%C3%A1pico%20para%20Articula%C3%A7%C3%B5es%20500mg.png', 0 FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'ArtroFlex Articulações 500mg', 'artroflex-articulacoes-500mg', 'NF-0003', '7891000000038', 'ArtroFlex Articulações 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 19.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/BioErvas%20Imunidade%20400mg.png', 0 FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'CalmErvas 300mg', 'calmervas-300mg', 'NF-0004', '7891000000045', 'CalmErvas 300mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 22.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CalmErvas%20300mg.png', 0 FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'CardioErvas 350mg', 'cardioervas-350mg', 'NF-0005', '7891000000052', 'CardioErvas 350mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 25.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioErvas%20350mg.png', 0 FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'BioErvas Imunidade 400mg', 'bioervas-imunidade-400mg', 'NF-0006', '7891000000069', 'BioErvas Imunidade 400mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 28.90, 25.43, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioVerde%20%E2%80%93%20C%C3%A1psulas%20para%20Sa%C3%BAde%20do%20Cora%C3%A7%C3%A3o%20350mg.png', 0 FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'DepuraVida 500mg', 'depuravida-500mg', 'NF-0007', '7891000000076', 'DepuraVida 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 32.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/DepuraVida%20500mg.png', 0 FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Fitocaps Relax 500mg', 'fitocaps-relax-500mg', 'NF-0008', '7891000000083', 'Fitocaps Relax 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 35.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Dermaverde%20%E2%80%93%20Creme%20Fitoter%C3%A1pico%20para%20Pele%2060g.png', 0 FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Fitolife Energy 450mg', 'fitolife-energy-450mg', 'NF-0009', '7891000000090', 'Fitolife Energy 450mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 38.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitocaps%20Relax%20500mg.png', 0 FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'SonoNatural 300mg', 'sononatural-300mg', 'NF-0010', '7891000000106', 'SonoNatural 300mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 41.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitolife%20Energy%20450mg.png', 0 FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'VitalFemme 300mg', 'vitalfemme-300mg', 'NF-0011', '7891000000113', 'VitalFemme 300mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 44.90, 39.51, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais%20500mg.png', 0 FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Ginkgo Biloba 80mg', 'ginkgo-biloba-80mg', 'NF-0012', '7891000000120', 'Ginkgo Biloba 80mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 48.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais.png', 0 FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Cúrcuma com Piperina 500mg', 'curcuma-com-piperina-500mg', 'NF-0013', '7891000000137', 'Cúrcuma com Piperina 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 51.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax.png', 0 FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_tintura, 'Tintura de Hypericum perforatum', 'tintura-de-hypericum-perforatum', 'NF-0014', '7891000000144', 'Tintura de Hypericum perforatum. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 54.50, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_tinturas_fluidos FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/HepatoClean%20%E2%80%93%20Xarope%20Fitoter%C3%A1pico%20Hep%C3%A1tico%20150ml.png', 0 FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_tintura, 'Tintura de Passiflora incarnata', 'tintura-de-passiflora-incarnata', 'NF-0015', '7891000000151', 'Tintura de Passiflora incarnata. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 57.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_tinturas_fluidos FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ImunoKids%20%E2%80%93%20Xarope%20Infantil%20Fitoter%C3%A1pico%20120ml.png', 0 FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_gotas, 'Gotas de Melatonina 3mg/ml', 'gotas-de-melatonina-3mg-ml', 'NF-0016', '7891000000168', 'Gotas de Melatonina 3mg/ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 60.90, 53.59, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_tinturas_fluidos FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Naturalis%20Digest%20350mg.png', 0 FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_gotas, 'Valeriana Gotas 20ml', 'valeriana-gotas-20ml', 'NF-0017', '7891000000175', 'Valeriana Gotas 20ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 64.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_tinturas_fluidos FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoErvas%20Digest%20%E2%80%93%20Ch%C3%A1%20Fitoter%C3%A1pico.png', 0 FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_gotas, 'Passiflora Gotas 20ml', 'passiflora-gotas-20ml', 'NF-0018', '7891000000182', 'Passiflora Gotas 20ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 67.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_tinturas_fluidos FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoHerbal%20Detox%20300mg.png', 0 FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_xarope, 'HepatoClean Xarope Hepático 150ml', 'hepatoclean-xarope-hepatico-150ml', 'NF-0019', '7891000000199', 'HepatoClean Xarope Hepático 150ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 70.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_xaropes_solucoes FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/RespiraBem%20%E2%80%93%20Inalador%20Fitoter%C3%A1pico%20Nasal.png', 0 FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_xarope, 'ImunoKids Xarope Infantil 120ml', 'imunokids-xarope-infantil-120ml', 'NF-0020', '7891000000205', 'ImunoKids Xarope Infantil 120ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 73.70, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_xaropes_solucoes FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonoNatural%20%E2%80%93%20C%C3%A1psulas%20para%20Relaxamento%20300mg.png', 0 FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_xarope, 'Xarope de Própolis Verde 100ml', 'xarope-de-propolis-verde-100ml', 'NF-0021', '7891000000212', 'Xarope de Própolis Verde 100ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 76.90, 67.67, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_xaropes_solucoes FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonosFit%20250mg.png', 0 FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Camomila Matricaria 20g', 'cha-de-camomila-matricaria-20g', 'NF-0022', '7891000000229', 'Chá de Camomila Matricaria 20g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 80.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_medicinais FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/VitalFemme%20%E2%80%93%20Suplemento%20Fitoter%C3%A1pico%20Feminino%20300mg.png', 0 FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Erva-Doce 50g', 'cha-de-erva-doce-50g', 'NF-0023', '7891000000236', 'Chá de Erva-Doce 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 83.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_medicinais FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtiFlex%20400mg.png', 0 FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Espinheira-Santa 50g', 'cha-de-espinheira-santa-50g', 'NF-0024', '7891000000243', 'Chá de Espinheira-Santa 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 86.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_medicinais FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtroFlex%20%E2%80%93%20Fitoter%C3%A1pico%20para%20Articula%C3%A7%C3%B5es%20500mg.png', 0 FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'NeoErvas Digest Chá Fitoterápico', 'neoervas-digest-cha-fitoterapico', 'NF-0025', '7891000000250', 'NeoErvas Digest Chá Fitoterápico. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 89.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_digestivos FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/BioErvas%20Imunidade%20400mg.png', 0 FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Boldo do Chile 40g', 'cha-de-boldo-do-chile-40g', 'NF-0026', '7891000000267', 'Chá de Boldo do Chile 40g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 12.90, 11.35, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_digestivos FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CalmErvas%20300mg.png', 0 FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Carqueja 50g', 'cha-de-carqueja-50g', 'NF-0027', '7891000000274', 'Chá de Carqueja 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 16.10, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_digestivos FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioErvas%20350mg.png', 0 FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Infusão Noite Tranquila 30g', 'infusao-noite-tranquila-30g', 'NF-0028', '7891000000281', 'Infusão Noite Tranquila 30g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 19.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_infusoes_funcionais FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioVerde%20%E2%80%93%20C%C3%A1psulas%20para%20Sa%C3%BAde%20do%20Cora%C3%A7%C3%A3o%20350mg.png', 0 FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Hibisco com Gengibre 40g', 'cha-de-hibisco-com-gengibre-40g', 'NF-0029', '7891000000298', 'Chá de Hibisco com Gengibre 40g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 22.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_infusoes_funcionais FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/DepuraVida%20500mg.png', 0 FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Chá de Maracujá 50g', 'cha-de-maracuja-50g', 'NF-0030', '7891000000304', 'Chá de Maracujá 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 25.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_infusoes_funcionais FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Dermaverde%20%E2%80%93%20Creme%20Fitoter%C3%A1pico%20para%20Pele%2060g.png', 0 FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Essencial Lavanda Angustifolia 10ml', 'oleo-essencial-lavanda-angustifolia-10ml', 'NF-0031', '7891000000311', 'Óleo Essencial Lavanda Angustifolia 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 28.90, 25.43, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_essenciais FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitocaps%20Relax%20500mg.png', 0 FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Essencial Melaleuca 30ml', 'oleo-essencial-melaleuca-30ml', 'NF-0032', '7891000000328', 'Óleo Essencial Melaleuca 30ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 32.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_essenciais FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitolife%20Energy%20450mg.png', 0 FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Essencial Eucalipto 10ml', 'oleo-essencial-eucalipto-10ml', 'NF-0033', '7891000000335', 'Óleo Essencial Eucalipto 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 35.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_essenciais FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais%20500mg.png', 0 FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Essencial Tea Tree 10ml', 'oleo-essencial-tea-tree-10ml', 'NF-0034', '7891000000342', 'Óleo Essencial Tea Tree 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 38.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_essenciais FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais.png', 0 FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Essencial Hortelã-Pimenta 10ml', 'oleo-essencial-hortela-pimenta-10ml', 'NF-0035', '7891000000359', 'Óleo Essencial Hortelã-Pimenta 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 41.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_essenciais FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax.png', 0 FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Blend Aromático Breathe 10ml', 'blend-aromatico-breathe-10ml', 'NF-0036', '7891000000366', 'Blend Aromático Breathe 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 44.90, 39.51, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_blends_aromaticos FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/HepatoClean%20%E2%80%93%20Xarope%20Fitoter%C3%A1pico%20Hep%C3%A1tico%20150ml.png', 0 FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Blend Calm Night 10ml', 'blend-calm-night-10ml', 'NF-0037', '7891000000373', 'Blend Calm Night 10ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 48.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_blends_aromaticos FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ImunoKids%20%E2%80%93%20Xarope%20Infantil%20Fitoter%C3%A1pico%20120ml.png', 0 FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_roll_on, 'Roll-on Calm Essence Lavanda', 'roll-on-calm-essence-lavanda', 'NF-0038', '7891000000380', 'Roll-on Calm Essence Lavanda. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 51.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_blends_aromaticos FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Naturalis%20Digest%20350mg.png', 0 FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_roll_on, 'Roll-on Focus Menthol', 'roll-on-focus-menthol', 'NF-0039', '7891000000397', 'Roll-on Focus Menthol. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 54.50, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_blends_aromaticos FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoErvas%20Digest%20%E2%80%93%20Ch%C3%A1%20Fitoter%C3%A1pico.png', 0 FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo Vegetal de Amêndoas Doces 100ml', 'oleo-vegetal-de-amendoas-doces-100ml', 'NF-0040', '7891000000403', 'Óleo Vegetal de Amêndoas Doces 100ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 57.70, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_vegetais FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoHerbal%20Detox%20300mg.png', 0 FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo de Rosa Mosqueta Puro 30ml', 'oleo-de-rosa-mosqueta-puro-30ml', 'NF-0041', '7891000000410', 'Óleo de Rosa Mosqueta Puro 30ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 60.90, 53.59, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_vegetais FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/RespiraBem%20%E2%80%93%20Inalador%20Fitoter%C3%A1pico%20Nasal.png', 0 FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo de Coco Extra Virgem 200ml', 'oleo-de-coco-extra-virgem-200ml', 'NF-0042', '7891000000427', 'Óleo de Coco Extra Virgem 200ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 64.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_vegetais FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonoNatural%20%E2%80%93%20C%C3%A1psulas%20para%20Relaxamento%20300mg.png', 0 FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Kit Aromaterapia — difusor + blend', 'kit-aromaterapia-difusor-blend', 'NF-0043', '7891000000434', 'Kit Aromaterapia — difusor + blend. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 67.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_aromaterapia FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonosFit%20250mg.png', 0 FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Vitamina D3 2000 UI', 'vitamina-d3-2000-ui', 'NF-0044', '7891000000441', 'Vitamina D3 2000 UI. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 70.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/VitalFemme%20%E2%80%93%20Suplemento%20Fitoter%C3%A1pico%20Feminino%20300mg.png', 0 FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Magnésio Quelato 200mg', 'magnesio-quelato-200mg', 'NF-0045', '7891000000458', 'Magnésio Quelato 200mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 73.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtiFlex%20400mg.png', 0 FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Vitamina C 1000mg', 'vitamina-c-1000mg', 'NF-0046', '7891000000465', 'Vitamina C 1000mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 76.90, 67.67, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtroFlex%20%E2%80%93%20Fitoter%C3%A1pico%20para%20Articula%C3%A7%C3%B5es%20500mg.png', 0 FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Complexo B Natural', 'complexo-b-natural', 'NF-0047', '7891000000472', 'Complexo B Natural. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 80.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/BioErvas%20Imunidade%20400mg.png', 0 FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Zinco Quelato 30mg', 'zinco-quelato-30mg', 'NF-0048', '7891000000489', 'Zinco Quelato 30mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 83.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CalmErvas%20300mg.png', 0 FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Ferro Quelato 30mg', 'ferro-quelato-30mg', 'NF-0049', '7891000000496', 'Ferro Quelato 30mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 86.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioErvas%20350mg.png', 0 FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Multivitamínico Mulher', 'multivitaminico-mulher', 'NF-0050', '7891000000502', 'Multivitamínico Mulher. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 89.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioVerde%20%E2%80%93%20C%C3%A1psulas%20para%20Sa%C3%BAde%20do%20Cora%C3%A7%C3%A3o%20350mg.png', 0 FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Ômega 3 EPA/DHA 120 cápsulas', 'omega-3-epa-dha-120-capsulas', 'NF-0051', '7891000000519', 'Ômega 3 EPA/DHA 120 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 12.90, 11.35, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_omegas FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/DepuraVida%20500mg.png', 0 FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Óleo de Prímula 1000mg', 'oleo-de-primula-1000mg', 'NF-0052', '7891000000526', 'Óleo de Prímula 1000mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 16.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_omegas FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Dermaverde%20%E2%80%93%20Creme%20Fitoter%C3%A1pico%20para%20Pele%2060g.png', 0 FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Probiótico 10 cepas 30 cápsulas', 'probiotico-10-cepas-30-capsulas', 'NF-0053', '7891000000533', 'Probiótico 10 cepas 30 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 19.30, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_probioticos_enzimas FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitocaps%20Relax%20500mg.png', 0 FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Psyllium 500mg', 'psyllium-500mg', 'NF-0054', '7891000000540', 'Psyllium 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 22.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_probioticos_enzimas FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitolife%20Energy%20450mg.png', 0 FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Colágeno Hidrolisado 300g', 'colageno-hidrolisado-300g', 'NF-0055', '7891000000557', 'Colágeno Hidrolisado 300g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 25.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais%20500mg.png', 0 FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Spirulina 500mg', 'spirulina-500mg', 'NF-0056', '7891000000564', 'Spirulina 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 28.90, 25.43, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais.png', 0 FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Maca Peruana 500mg', 'maca-peruana-500mg', 'NF-0057', '7891000000571', 'Maca Peruana 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 32.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax.png', 0 FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Dermaverde Creme Fitoterápico Pele 60g', 'dermaverde-creme-fitoterapico-pele-60g', 'NF-0058', '7891000000588', 'Dermaverde Creme Fitoterápico Pele 60g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 35.30, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/HepatoClean%20%E2%80%93%20Xarope%20Fitoter%C3%A1pico%20Hep%C3%A1tico%20150ml.png', 0 FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Gel de Arnica Montana 100g', 'gel-de-arnica-montana-100g', 'NF-0059', '7891000000595', 'Gel de Arnica Montana 100g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 38.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ImunoKids%20%E2%80%93%20Xarope%20Infantil%20Fitoter%C3%A1pico%20120ml.png', 0 FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Gel Hidratante Aloe Vera 200g', 'gel-hidratante-aloe-vera-200g', 'NF-0060', '7891000000601', 'Gel Hidratante Aloe Vera 200g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 41.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Naturalis%20Digest%20350mg.png', 0 FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Hidratante Corporal Urucum 200ml', 'hidratante-corporal-urucum-200ml', 'NF-0061', '7891000000618', 'Hidratante Corporal Urucum 200ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 44.90, 39.51, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoErvas%20Digest%20%E2%80%93%20Ch%C3%A1%20Fitoter%C3%A1pico.png', 0 FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Pomada de Própolis 30g', 'pomada-de-propolis-30g', 'NF-0062', '7891000000625', 'Pomada de Própolis 30g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 48.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoHerbal%20Detox%20300mg.png', 0 FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Sérum Facial Vitamina C 30ml', 'serum-facial-vitamina-c-30ml', 'NF-0063', '7891000000632', 'Sérum Facial Vitamina C 30ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 51.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_faciais FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/RespiraBem%20%E2%80%93%20Inalador%20Fitoter%C3%A1pico%20Nasal.png', 0 FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Máscara de Argila Verde 100g', 'mascara-de-argila-verde-100g', 'NF-0064', '7891000000649', 'Máscara de Argila Verde 100g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 54.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_faciais FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonoNatural%20%E2%80%93%20C%C3%A1psulas%20para%20Relaxamento%20300mg.png', 0 FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Creme Calêndula Facial 50g', 'creme-calendula-facial-50g', 'NF-0065', '7891000000656', 'Creme Calêndula Facial 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 57.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_faciais FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonosFit%20250mg.png', 0 FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Sabonete Líquido Neutro 500ml', 'sabonete-liquido-neutro-500ml', 'NF-0066', '7891000000663', 'Sabonete Líquido Neutro 500ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 60.90, 53.59, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/VitalFemme%20%E2%80%93%20Suplemento%20Fitoter%C3%A1pico%20Feminino%20300mg.png', 0 FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Shampoo de Alecrim 300ml', 'shampoo-de-alecrim-300ml', 'NF-0067', '7891000000670', 'Shampoo de Alecrim 300ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 64.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtiFlex%20400mg.png', 0 FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Desodorante Crystal Natural 80g', 'desodorante-crystal-natural-80g', 'NF-0068', '7891000000687', 'Desodorante Crystal Natural 80g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 67.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtroFlex%20%E2%80%93%20Fitoter%C3%A1pico%20para%20Articula%C3%A7%C3%B5es%20500mg.png', 0 FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Repelente Natural Citronela 100ml', 'repelente-natural-citronela-100ml', 'NF-0069', '7891000000694', 'Repelente Natural Citronela 100ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 70.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_bem_estar FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/BioErvas%20Imunidade%20400mg.png', 0 FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Creme Dental Sem Flúor 90g', 'creme-dental-sem-fluor-90g', 'NF-0070', '7891000000700', 'Creme Dental Sem Flúor 90g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 73.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_bucal_natural FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CalmErvas%20300mg.png', 0 FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Enxaguante Bucal de Própolis 250ml', 'enxaguante-bucal-de-propolis-250ml', 'NF-0071', '7891000000717', 'Enxaguante Bucal de Própolis 250ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 76.90, 67.67, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_bucal_natural FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioErvas%20350mg.png', 0 FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Própolis Verde Spray 30ml', 'propolis-verde-spray-30ml', 'NF-0072', '7891000000724', 'Própolis Verde Spray 30ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 80.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_bucal_natural FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioVerde%20%E2%80%93%20C%C3%A1psulas%20para%20Sa%C3%BAde%20do%20Cora%C3%A7%C3%A3o%20350mg.png', 0 FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'RespiraBem Inalador Fitoterápico Nasal', 'respirabem-inalador-fitoterapico-nasal', 'NF-0073', '7891000000731', 'RespiraBem Inalador Fitoterápico Nasal. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 83.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_fitoterapicos FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/DepuraVida%20500mg.png', 0 FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Spray Nasal Sal Marinho 50ml', 'spray-nasal-sal-marinho-50ml', 'NF-0074', '7891000000748', 'Spray Nasal Sal Marinho 50ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 86.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_fitoterapicos FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Dermaverde%20%E2%80%93%20Creme%20Fitoter%C3%A1pico%20para%20Pele%2060g.png', 0 FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Mel de Manuka UMF 10+ 250g', 'mel-de-manuka-umf-10-250g', 'NF-0075', '7891000000755', 'Mel de Manuka UMF 10+ 250g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 89.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_infusiones FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitocaps%20Relax%20500mg.png', 0 FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Guaraná em Pó 100g', 'guarana-em-po-100g', 'NF-0076', '7891000000762', 'Guaraná em Pó 100g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 12.90, 11.35, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_infusoes_funcionais FROM products p WHERE p.sku='NF-0076' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitolife%20Energy%20450mg.png', 0 FROM products p WHERE p.sku='NF-0076' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Ashwagandha 300mg', 'ashwagandha-300mg', 'NF-0077', '7891000000779', 'Ashwagandha 300mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 16.10, NULL, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0077' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais%20500mg.png', 0 FROM products p WHERE p.sku='NF-0077' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Rhodiola Rosea 300mg', 'rhodiola-rosea-300mg', 'NF-0078', '7891000000786', 'Rhodiola Rosea 300mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 19.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0078' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais.png', 0 FROM products p WHERE p.sku='NF-0078' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Melatonina 3mg', 'melatonina-3mg', 'NF-0079', '7891000000793', 'Melatonina 3mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 22.50, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0079' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax.png', 0 FROM products p WHERE p.sku='NF-0079' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Equinácea + Vitamina C', 'equinacea-vitamina-c', 'NF-0080', '7891000000809', 'Equinácea + Vitamina C. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 25.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0080' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/HepatoClean%20%E2%80%93%20Xarope%20Fitoter%C3%A1pico%20Hep%C3%A1tico%20150ml.png', 0 FROM products p WHERE p.sku='NF-0080' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Berberina 500mg', 'berberina-500mg', 'NF-0081', '7891000000816', 'Berberina 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 28.90, 25.43, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0081' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ImunoKids%20%E2%80%93%20Xarope%20Infantil%20Fitoter%C3%A1pico%20120ml.png', 0 FROM products p WHERE p.sku='NF-0081' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Coenzima Q10 100mg', 'coenzima-q10-100mg', 'NF-0082', '7891000000823', 'Coenzima Q10 100mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 32.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0082' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Naturalis%20Digest%20350mg.png', 0 FROM products p WHERE p.sku='NF-0082' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Hyaluronic Acid 50mg', 'hyaluronic-acid-50mg', 'NF-0083', '7891000000830', 'Hyaluronic Acid 50mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 35.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_faciais FROM products p WHERE p.sku='NF-0083' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoErvas%20Digest%20%E2%80%93%20Ch%C3%A1%20Fitoter%C3%A1pico.png', 0 FROM products p WHERE p.sku='NF-0083' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Loção Capilar Jaborandi 200ml', 'locao-capilar-jaborandi-200ml', 'NF-0084', '7891000000847', 'Loção Capilar Jaborandi 200ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 38.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0084' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoHerbal%20Detox%20300mg.png', 0 FROM products p WHERE p.sku='NF-0084' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Condicionador de Babosa 300ml', 'condicionador-de-babosa-300ml', 'NF-0085', '7891000000854', 'Condicionador de Babosa 300ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 41.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0085' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/RespiraBem%20%E2%80%93%20Inalador%20Fitoter%C3%A1pico%20Nasal.png', 0 FROM products p WHERE p.sku='NF-0085' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Sabonete de Calêndula 90g', 'sabonete-de-calendula-90g', 'NF-0086', '7891000000861', 'Sabonete de Calêndula 90g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 44.90, 39.51, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_higiene_pessoal FROM products p WHERE p.sku='NF-0086' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonoNatural%20%E2%80%93%20C%C3%A1psulas%20para%20Relaxamento%20300mg.png', 0 FROM products p WHERE p.sku='NF-0086' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_oleo_fracionado, 'Óleo de Copaíba 30ml', 'oleo-de-copaiba-30ml', 'NF-0087', '7891000000878', 'Óleo de Copaíba 30ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 48.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_vegetais FROM products p WHERE p.sku='NF-0087' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonosFit%20250mg.png', 0 FROM products p WHERE p.sku='NF-0087' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_spray, 'Hamamelis Virginiana Tônico 200ml', 'hamamelis-virginiana-tonico-200ml', 'NF-0088', '7891000000885', 'Hamamelis Virginiana Tônico 200ml. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 51.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_faciais FROM products p WHERE p.sku='NF-0088' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/VitalFemme%20%E2%80%93%20Suplemento%20Fitoter%C3%A1pico%20Feminino%20300mg.png', 0 FROM products p WHERE p.sku='NF-0088' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_creme_gel, 'Calêndula Pomada Infantil 50g', 'calendula-pomada-infantil-50g', 'NF-0089', '7891000000892', 'Calêndula Pomada Infantil 50g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 54.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_cuidados_corporais FROM products p WHERE p.sku='NF-0089' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtiFlex%20400mg.png', 0 FROM products p WHERE p.sku='NF-0089' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Whey Protein Natural 900g', 'whey-protein-natural-900g', 'NF-0090', '7891000000908', 'Whey Protein Natural 900g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 57.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0090' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ArtroFlex%20%E2%80%93%20Fitoter%C3%A1pico%20para%20Articula%C3%A7%C3%B5es%20500mg.png', 0 FROM products p WHERE p.sku='NF-0090' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Creatina Monoidratada 300g', 'creatina-monoidratada-300g', 'NF-0091', '7891000000915', 'Creatina Monoidratada 300g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 60.90, 53.59, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0091' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/BioErvas%20Imunidade%20400mg.png', 0 FROM products p WHERE p.sku='NF-0091' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'BCAA 2:1:1', 'bcaa-2-1-1', 'NF-0092', '7891000000922', 'BCAA 2:1:1. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 64.10, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0092' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CalmErvas%20300mg.png', 0 FROM products p WHERE p.sku='NF-0092' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Glucosamina + Condroitina', 'glucosamina-condroitina', 'NF-0093', '7891000000939', 'Glucosamina + Condroitina. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 67.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_oleos_omegas FROM products p WHERE p.sku='NF-0093' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioErvas%20350mg.png', 0 FROM products p WHERE p.sku='NF-0093' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Colágeno Tipo II', 'colageno-tipo-ii', 'NF-0094', '7891000000946', 'Colágeno Tipo II. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 70.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0094' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/CardioVerde%20%E2%80%93%20C%C3%A1psulas%20para%20Sa%C3%BAde%20do%20Cora%C3%A7%C3%A3o%20350mg.png', 0 FROM products p WHERE p.sku='NF-0094' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Resveratrol 200mg', 'resveratrol-200mg', 'NF-0095', '7891000000953', 'Resveratrol 200mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 73.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_vitaminas_minerais FROM products p WHERE p.sku='NF-0095' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/DepuraVida%20500mg.png', 0 FROM products p WHERE p.sku='NF-0095' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_comprimidos, 'Clorella 500mg', 'clorella-500mg', 'NF-0096', '7891000000960', 'Clorella 500mg. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 76.90, 67.67, 'DISCONTINUED');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0096' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Dermaverde%20%E2%80%93%20Creme%20Fitoter%C3%A1pico%20para%20Pele%2060g.png', 0 FROM products p WHERE p.sku='NF-0096' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Própolis Verde 60 cápsulas', 'propolis-verde-60-capsulas', 'NF-0097', '7891000000977', 'Própolis Verde 60 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 80.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_fitoterapicos FROM products p WHERE p.sku='NF-0097' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitocaps%20Relax%20500mg.png', 0 FROM products p WHERE p.sku='NF-0097' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Boldo do Chile 60 cápsulas', 'boldo-do-chile-60-capsulas', 'NF-0098', '7891000000984', 'Boldo do Chile 60 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 83.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0098' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitolife%20Energy%20450mg.png', 0 FROM products p WHERE p.sku='NF-0098' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Artichoke 60 cápsulas', 'artichoke-60-capsulas', 'NF-0099', '7891000000991', 'Artichoke 60 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 86.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0099' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais%20500mg.png', 0 FROM products p WHERE p.sku='NF-0099' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Milk Thistle 60 cápsulas', 'milk-thistle-60-capsulas', 'NF-0100', '7891000001004', 'Milk Thistle 60 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 1, 89.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0100' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax%20%E2%80%93%20C%C3%A1psulas%20Calmantes%20Naturais.png', 0 FROM products p WHERE p.sku='NF-0100' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Saw Palmetto 60 cápsulas', 'saw-palmetto-60-capsulas', 'NF-0101', '7891000001011', 'Saw Palmetto 60 cápsulas. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 12.90, 11.35, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0101' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Fitorelax.png', 0 FROM products p WHERE p.sku='NF-0101' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Açúcar de Coco 300g', 'acucar-de-coco-300g', 'NF-0102', '7891000001028', 'Açúcar de Coco 300g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 16.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_chas_infusiones FROM products p WHERE p.sku='NF-0102' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/HepatoClean%20%E2%80%93%20Xarope%20Fitoter%C3%A1pico%20Hep%C3%A1tico%20150ml.png', 0 FROM products p WHERE p.sku='NF-0102' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_ervas_a_granel, 'Farinha de Amêndoas 200g', 'farinha-de-amendoas-200g', 'NF-0103', '7891000001035', 'Farinha de Amêndoas 200g. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 19.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_suplementacao FROM products p WHERE p.sku='NF-0103' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/ImunoKids%20%E2%80%93%20Xarope%20Infantil%20Fitoter%C3%A1pico%20120ml.png', 0 FROM products p WHERE p.sku='NF-0103' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Valeriana Officinalis 500mg — ref. 2', 'valeriana-officinalis-500mg-ref-2', 'NF-0104', '7891000001042', 'Valeriana Officinalis 500mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 22.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0104' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/Naturalis%20Digest%20350mg.png', 0 FROM products p WHERE p.sku='NF-0104' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'Passiflora Incarnata 400mg — ref. 2', 'passiflora-incarnata-400mg-ref-2', 'NF-0105', '7891000001059', 'Passiflora Incarnata 400mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 25.70, NULL, 'INACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0105' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoErvas%20Digest%20%E2%80%93%20Ch%C3%A1%20Fitoter%C3%A1pico.png', 0 FROM products p WHERE p.sku='NF-0105' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'ArtroFlex Articulações 500mg — ref. 2', 'artroflex-articulacoes-500mg-ref-2', 'NF-0106', '7891000001066', 'ArtroFlex Articulações 500mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 28.90, 25.43, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0106' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/NeoHerbal%20Detox%20300mg.png', 0 FROM products p WHERE p.sku='NF-0106' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'CalmErvas 300mg — ref. 2', 'calmervas-300mg-ref-2', 'NF-0107', '7891000001073', 'CalmErvas 300mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 32.10, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0107' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/RespiraBem%20%E2%80%93%20Inalador%20Fitoter%C3%A1pico%20Nasal.png', 0 FROM products p WHERE p.sku='NF-0107' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'CardioErvas 350mg — ref. 2', 'cardioervas-350mg-ref-2', 'NF-0108', '7891000001080', 'CardioErvas 350mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 35.30, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0108' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonoNatural%20%E2%80%93%20C%C3%A1psulas%20para%20Relaxamento%20300mg.png', 0 FROM products p WHERE p.sku='NF-0108' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'BioErvas Imunidade 400mg — ref. 2', 'bioervas-imunidade-400mg-ref-2', 'NF-0109', '7891000001097', 'BioErvas Imunidade 400mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 38.50, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0109' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/SonosFit%20250mg.png', 0 FROM products p WHERE p.sku='NF-0109' LIMIT 1;
INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, @type_capsulas, 'DepuraVida 500mg — ref. 2', 'depuravida-500mg-ref-2', 'NF-0110', '7891000001103', 'DepuraVida 500mg — ref. 2. Produto fitoterápico comercializado pela NeoFarma.', 'Composição conforme rótulo e bula.', 'Uso conforme orientação farmacêutica ou bula.', 0, 41.70, NULL, 'ACTIVE');
INSERT INTO product_categories (product_id, category_id) SELECT p.id, @cat_extratos_secos FROM products p WHERE p.sku='NF-0110' LIMIT 1;
INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product-farma/VitalFemme%20%E2%80%93%20Suplemento%20Fitoter%C3%A1pico%20Feminino%20300mg.png', 0 FROM products p WHERE p.sku='NF-0110' LIMIT 1;

-- Lotes (FEFO: vencido, próximo, válido)
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-001', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-001', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 80 FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-001', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 180 DAY), 150 FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-002', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-002', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 83 FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-002', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 181 DAY), 155 FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-003', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-003', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 86 FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-003', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 182 DAY), 160 FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-004', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-004', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 89 FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-004', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 183 DAY), 165 FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-005', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-005', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 92 FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-005', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 184 DAY), 170 FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-006', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-006', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 95 FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-006', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 185 DAY), 175 FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-007', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-007', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 98 FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-007', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 186 DAY), 180 FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-008', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-008', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 101 FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-008', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 187 DAY), 185 FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-009', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-009', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 104 FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-009', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 188 DAY), 190 FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-010', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-010', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 107 FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-010', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 189 DAY), 195 FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-011', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-011', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 110 FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-011', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 190 DAY), 200 FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-012', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-012', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 113 FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-012', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 191 DAY), 205 FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-013', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-013', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 116 FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-013', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 192 DAY), 210 FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-014', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-014', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 119 FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-014', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 193 DAY), 215 FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-015', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-015', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 122 FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-015', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 194 DAY), 220 FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-016', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-016', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 125 FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-016', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 195 DAY), 225 FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-017', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-017', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 128 FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-017', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 196 DAY), 230 FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-018', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-018', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 131 FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-018', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 197 DAY), 235 FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-019', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-019', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 134 FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-019', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 198 DAY), 240 FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-020', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-020', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 137 FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-020', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 199 DAY), 245 FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-021', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-021', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 140 FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-021', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 200 DAY), 250 FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-022', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-022', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 143 FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-022', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 201 DAY), 255 FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-023', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-023', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 146 FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-023', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 202 DAY), 260 FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-024', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-024', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 149 FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-024', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 203 DAY), 265 FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-025', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-025', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 152 FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-025', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 204 DAY), 270 FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-026', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-026', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 155 FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-026', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 205 DAY), 275 FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-027', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-027', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 158 FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-027', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 206 DAY), 280 FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-028', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-028', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 161 FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-028', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 207 DAY), 285 FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-029', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-029', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 164 FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-029', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 208 DAY), 290 FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-030', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-030', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 167 FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-030', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 209 DAY), 295 FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-031', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-031', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 170 FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-031', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 210 DAY), 300 FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-032', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-032', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 173 FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-032', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 211 DAY), 305 FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-033', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-033', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 176 FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-033', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 212 DAY), 310 FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-034', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-034', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 179 FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-034', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 213 DAY), 315 FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-035', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-035', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 182 FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-035', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 214 DAY), 320 FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-036', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-036', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 185 FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-036', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 215 DAY), 325 FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-037', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-037', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 188 FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-037', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 216 DAY), 330 FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-038', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-038', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 191 FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-038', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 217 DAY), 335 FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-039', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-039', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 194 FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-039', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 218 DAY), 340 FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-040', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-040', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 197 FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-040', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 219 DAY), 345 FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-041', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-041', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 200 FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-041', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 220 DAY), 350 FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-042', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-042', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 203 FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-042', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 221 DAY), 355 FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-043', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-043', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 206 FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-043', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 222 DAY), 360 FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-044', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-044', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 209 FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-044', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 223 DAY), 365 FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-045', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-045', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 212 FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-045', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 224 DAY), 370 FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-046', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-046', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 215 FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-046', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 225 DAY), 375 FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-047', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-047', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 218 FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-047', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 226 DAY), 380 FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-048', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-048', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 221 FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-048', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 227 DAY), 385 FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-049', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-049', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 224 FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-049', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 228 DAY), 390 FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-050', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-050', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 227 FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-050', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 229 DAY), 395 FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-051', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-051', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 230 FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-051', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 230 DAY), 400 FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-052', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-052', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 233 FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-052', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 231 DAY), 405 FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-053', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-053', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 236 FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-053', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 232 DAY), 410 FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-054', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-054', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 239 FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-054', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 233 DAY), 415 FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-055', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-055', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 242 FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-055', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 234 DAY), 420 FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-056', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-056', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 245 FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-056', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 235 DAY), 425 FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-057', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-057', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 248 FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-057', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 236 DAY), 430 FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-058', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-058', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 251 FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-058', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 237 DAY), 435 FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-059', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-059', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 254 FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-059', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 238 DAY), 440 FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-060', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-060', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 257 FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-060', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 239 DAY), 445 FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-061', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-061', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 260 FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-061', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 240 DAY), 150 FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-062', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-062', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 263 FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-062', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 241 DAY), 155 FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-063', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-063', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 266 FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-063', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 242 DAY), 160 FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-064', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-064', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 269 FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-064', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 243 DAY), 165 FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-065', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-065', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 272 FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-065', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 244 DAY), 170 FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-066', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-066', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 275 FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-066', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 245 DAY), 175 FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-067', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-067', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 278 FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-067', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 246 DAY), 180 FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-068', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-068', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 81 FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-068', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 247 DAY), 185 FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-069', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-069', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 84 FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-069', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 248 DAY), 190 FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-070', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-070', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 87 FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-070', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 249 DAY), 195 FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-071', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-071', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 90 FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-071', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 250 DAY), 200 FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-072', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-072', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 93 FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-072', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 251 DAY), 205 FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-073', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-073', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 96 FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-073', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 252 DAY), 210 FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-074', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-074', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 99 FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-074', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 253 DAY), 215 FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-075', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-075', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 102 FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-075', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 254 DAY), 220 FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-076', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0076' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-076', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 105 FROM products p WHERE p.sku='NF-0076' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-076', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 255 DAY), 225 FROM products p WHERE p.sku='NF-0076' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-077', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0077' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-077', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 108 FROM products p WHERE p.sku='NF-0077' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-077', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 256 DAY), 230 FROM products p WHERE p.sku='NF-0077' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-078', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0078' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-078', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 111 FROM products p WHERE p.sku='NF-0078' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-078', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 257 DAY), 235 FROM products p WHERE p.sku='NF-0078' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-079', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0079' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-079', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 114 FROM products p WHERE p.sku='NF-0079' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-079', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 258 DAY), 240 FROM products p WHERE p.sku='NF-0079' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-080', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0080' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-080', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 117 FROM products p WHERE p.sku='NF-0080' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-080', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 259 DAY), 245 FROM products p WHERE p.sku='NF-0080' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-081', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0081' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-081', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 120 FROM products p WHERE p.sku='NF-0081' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-081', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 260 DAY), 250 FROM products p WHERE p.sku='NF-0081' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-082', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0082' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-082', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 123 FROM products p WHERE p.sku='NF-0082' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-082', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 261 DAY), 255 FROM products p WHERE p.sku='NF-0082' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-083', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0083' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-083', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 126 FROM products p WHERE p.sku='NF-0083' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-083', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 262 DAY), 260 FROM products p WHERE p.sku='NF-0083' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-084', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0084' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-084', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 129 FROM products p WHERE p.sku='NF-0084' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-084', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 263 DAY), 265 FROM products p WHERE p.sku='NF-0084' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-085', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0085' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-085', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 132 FROM products p WHERE p.sku='NF-0085' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-085', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 264 DAY), 270 FROM products p WHERE p.sku='NF-0085' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-086', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0086' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-086', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 135 FROM products p WHERE p.sku='NF-0086' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-086', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 265 DAY), 275 FROM products p WHERE p.sku='NF-0086' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-087', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0087' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-087', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 31 DAY), 138 FROM products p WHERE p.sku='NF-0087' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-087', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 266 DAY), 280 FROM products p WHERE p.sku='NF-0087' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-088', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0088' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-088', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 32 DAY), 141 FROM products p WHERE p.sku='NF-0088' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-088', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 267 DAY), 285 FROM products p WHERE p.sku='NF-0088' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-089', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0089' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-089', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 144 FROM products p WHERE p.sku='NF-0089' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-089', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 268 DAY), 290 FROM products p WHERE p.sku='NF-0089' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-090', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0090' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-090', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 34 DAY), 147 FROM products p WHERE p.sku='NF-0090' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-090', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 269 DAY), 295 FROM products p WHERE p.sku='NF-0090' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-091', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0091' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-091', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 150 FROM products p WHERE p.sku='NF-0091' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-091', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 270 DAY), 300 FROM products p WHERE p.sku='NF-0091' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-092', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0092' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-092', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 36 DAY), 153 FROM products p WHERE p.sku='NF-0092' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-092', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 271 DAY), 305 FROM products p WHERE p.sku='NF-0092' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-093', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0093' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-093', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 156 FROM products p WHERE p.sku='NF-0093' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-093', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 272 DAY), 310 FROM products p WHERE p.sku='NF-0093' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-094', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0094' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-094', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 38 DAY), 159 FROM products p WHERE p.sku='NF-0094' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-094', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 273 DAY), 315 FROM products p WHERE p.sku='NF-0094' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-095', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0095' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-095', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 39 DAY), 162 FROM products p WHERE p.sku='NF-0095' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-095', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 274 DAY), 320 FROM products p WHERE p.sku='NF-0095' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-096', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0096' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-096', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 40 DAY), 165 FROM products p WHERE p.sku='NF-0096' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-096', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 275 DAY), 325 FROM products p WHERE p.sku='NF-0096' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-097', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0097' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-097', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 41 DAY), 168 FROM products p WHERE p.sku='NF-0097' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-097', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 276 DAY), 330 FROM products p WHERE p.sku='NF-0097' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-098', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0098' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-098', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 42 DAY), 171 FROM products p WHERE p.sku='NF-0098' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-098', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 277 DAY), 335 FROM products p WHERE p.sku='NF-0098' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-099', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0099' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-099', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 43 DAY), 174 FROM products p WHERE p.sku='NF-0099' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-099', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 278 DAY), 340 FROM products p WHERE p.sku='NF-0099' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-100', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0100' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-100', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 44 DAY), 177 FROM products p WHERE p.sku='NF-0100' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-100', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 279 DAY), 345 FROM products p WHERE p.sku='NF-0100' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-101', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 5 FROM products p WHERE p.sku='NF-0101' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-101', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 180 FROM products p WHERE p.sku='NF-0101' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-101', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 280 DAY), 350 FROM products p WHERE p.sku='NF-0101' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-102', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 6 FROM products p WHERE p.sku='NF-0102' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-102', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 21 DAY), 183 FROM products p WHERE p.sku='NF-0102' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-102', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 281 DAY), 355 FROM products p WHERE p.sku='NF-0102' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-103', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 7 FROM products p WHERE p.sku='NF-0103' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-103', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 22 DAY), 186 FROM products p WHERE p.sku='NF-0103' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-103', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 282 DAY), 360 FROM products p WHERE p.sku='NF-0103' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-104', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 8 FROM products p WHERE p.sku='NF-0104' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-104', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 23 DAY), 189 FROM products p WHERE p.sku='NF-0104' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-104', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 283 DAY), 365 FROM products p WHERE p.sku='NF-0104' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-105', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 9 FROM products p WHERE p.sku='NF-0105' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-105', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 24 DAY), 192 FROM products p WHERE p.sku='NF-0105' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-105', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 284 DAY), 370 FROM products p WHERE p.sku='NF-0105' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-106', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 10 FROM products p WHERE p.sku='NF-0106' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-106', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 195 FROM products p WHERE p.sku='NF-0106' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-106', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 285 DAY), 375 FROM products p WHERE p.sku='NF-0106' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-107', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 11 FROM products p WHERE p.sku='NF-0107' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-107', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 26 DAY), 198 FROM products p WHERE p.sku='NF-0107' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-107', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 286 DAY), 380 FROM products p WHERE p.sku='NF-0107' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-108', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 12 FROM products p WHERE p.sku='NF-0108' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-108', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 27 DAY), 201 FROM products p WHERE p.sku='NF-0108' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-108', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 287 DAY), 385 FROM products p WHERE p.sku='NF-0108' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-109', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 13 FROM products p WHERE p.sku='NF-0109' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-109', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 204 FROM products p WHERE p.sku='NF-0109' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-109', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 288 DAY), 390 FROM products p WHERE p.sku='NF-0109' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-A-110', DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 14 FROM products p WHERE p.sku='NF-0110' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-B-110', DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL 29 DAY), 207 FROM products p WHERE p.sku='NF-0110' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, 'L24-C-110', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 289 DAY), 395 FROM products p WHERE p.sku='NF-0110' LIMIT 1;

-- Compras a fornecedores
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 0 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY), 'DRAFT', 'PENDING', NULL, 170.00, 'OC-2024-0001';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 20, 0, NULL, NULL, 8.50, 170.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0001' AND pr.sku='NF-0001' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL 8 DAY), 'DRAFT', 'PENDING', 'PIX', 218.50, 'OC-2024-0002';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 23, 0, NULL, NULL, 9.50, 218.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0002' AND pr.sku='NF-0002' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_ADD(NOW(), INTERVAL 9 DAY), 'AWAITING_DELIVERY', 'PAID', 'PIX', 273.00, 'OC-2024-0003';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 26, 0, NULL, NULL, 10.50, 273.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0003' AND pr.sku='NF-0003' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 'AWAITING_DELIVERY', 'PAID', 'TRANSFER', 333.50, 'OC-2024-0004';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 29, 0, NULL, NULL, 11.50, 333.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0004' AND pr.sku='NF-0004' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_ADD(NOW(), INTERVAL 11 DAY), 'RECEIVED', 'PAID', 'BOLETO', 400.00, 'OC-2024-0005';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 32, 32, 'L24-R-005', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 12.50, 400.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0005' AND pr.sku='NF-0005' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'L24-R-005', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 32 FROM products pr WHERE pr.sku='NF-0005' LIMIT 1;
UPDATE purchase_order_items poi INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'L24-R-005'
SET poi.batch_id = ib.id WHERE po.notes = 'OC-2024-0005';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_ADD(NOW(), INTERVAL 12 DAY), 'RECEIVED', 'PAID', 'CASH', 472.50, 'OC-2024-0006';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 35, 35, 'L24-R-006', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 13.50, 472.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0006' AND pr.sku='NF-0006' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'L24-R-006', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 35 FROM products pr WHERE pr.sku='NF-0006' LIMIT 1;
UPDATE purchase_order_items poi INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'L24-R-006'
SET poi.batch_id = ib.id WHERE po.notes = 'OC-2024-0006';
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 24 DAY), DATE_ADD(NOW(), INTERVAL 13 DAY), 'CANCELLED', 'FAILED', 'PIX', 551.00, 'OC-2024-0007';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 38, 0, NULL, NULL, 14.50, 551.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0007' AND pr.sku='NF-0007' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 28 DAY), DATE_ADD(NOW(), INTERVAL 14 DAY), 'DRAFT', 'PENDING', NULL, 635.50, 'OC-2024-0008';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 41, 0, NULL, NULL, 15.50, 635.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0008' AND pr.sku='NF-0008' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 32 DAY), DATE_ADD(NOW(), INTERVAL 15 DAY), 'DRAFT', 'PENDING', 'PIX', 726.00, 'OC-2024-0009';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 44, 0, NULL, NULL, 16.50, 726.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0009' AND pr.sku='NF-0009' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 36 DAY), DATE_ADD(NOW(), INTERVAL 16 DAY), 'AWAITING_DELIVERY', 'PAID', 'PIX', 822.50, 'OC-2024-0010';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 47, 0, NULL, NULL, 17.50, 822.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0010' AND pr.sku='NF-0010' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_ADD(NOW(), INTERVAL 17 DAY), 'AWAITING_DELIVERY', 'PAID', 'TRANSFER', 925.00, 'OC-2024-0011';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 50, 0, NULL, NULL, 18.50, 925.00
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0011' AND pr.sku='NF-0011' LIMIT 1;
INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL 44 DAY), DATE_ADD(NOW(), INTERVAL 18 DAY), 'RECEIVED', 'PAID', 'BOLETO', 1033.50, 'OC-2024-0012';
INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, 53, 53, 'L24-R-012', DATE_ADD(CURDATE(), INTERVAL 365 DAY), 19.50, 1033.50
FROM purchase_orders po, products pr WHERE po.notes='OC-2024-0012' AND pr.sku='NF-0012' LIMIT 1;
INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, 'L24-R-012', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 53 FROM products pr WHERE pr.sku='NF-0012' LIMIT 1;
UPDATE purchase_order_items poi INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = 'L24-R-012'
SET poi.batch_id = ib.id WHERE po.notes = 'OC-2024-0012';

-- Pedidos de clientes
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.80, 0.00, 17.80, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.80, 17.80
FROM products p WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740000', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 41.20, 14.90, 56.10, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.60, 41.20
FROM products p WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 56.10, NULL, '23793.1000000001', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1002', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 26.20, 14.90, 41.10, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 26.20, 26.20 FROM products p WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740003', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 58.00, 0.00, 58.00, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 29.00, 58.00 FROM products p WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 58.00, NULL, '23793.1000000004', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1005', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 34.60, 14.90, 49.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 34.60, 34.60
FROM products p WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740006', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 74.80, 14.90, 89.70, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 37.40, 74.80
FROM products p WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 89.70, NULL, '23793.1000000007', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1008', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 43.00, 14.90, 57.90, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 43.00, 43.00 FROM products p WHERE p.sku='NF-0010' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740009', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 91.60, 14.90, 106.50, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 45.80, 91.60
FROM products p WHERE p.sku='NF-0011' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 106.50, NULL, '23793.1000000010', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0012' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1011', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 17.80, 0.00, 17.80, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.80, 17.80
FROM products p WHERE p.sku='NF-0013' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400012', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 41.20, 14.90, 56.10, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 20.60, 41.20 FROM products p WHERE p.sku='NF-0014' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 56.10, NULL, '23793.1000000013', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0015' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1014', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 26.20, 14.90, 41.10, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 26.20, 26.20
FROM products p WHERE p.sku='NF-0016' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400015', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 58.00, 0.00, 58.00, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 29.00, 58.00
FROM products p WHERE p.sku='NF-0017' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 58.00, NULL, '23793.1000000016', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='thiago.rafael18@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0018' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1017', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 34.60, 14.90, 49.50, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='gabriela.moura19@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 34.60, 34.60 FROM products p WHERE p.sku='NF-0019' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400018', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 74.80, 14.90, 89.70, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='vinicius.luis20@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 37.40, 74.80 FROM products p WHERE p.sku='NF-0020' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 89.70, NULL, '23793.1000000019', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='helena.vitoria21@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0021' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1020', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 43.00, 14.90, 57.90, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='matheus.antonio22@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 43.00, 43.00
FROM products p WHERE p.sku='NF-0022' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400021', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 91.60, 14.90, 106.50, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='isabela.fernanda23@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 45.80, 91.60
FROM products p WHERE p.sku='NF-0023' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 106.50, NULL, '23793.1000000022', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='guilherme.augusto24@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0024' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1023', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 17.80, 0.00, 17.80, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='beatriz.helena25@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 17.80, 17.80 FROM products p WHERE p.sku='NF-0025' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400024', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 41.20, 14.90, 56.10, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='rafaela.cristiane26@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.60, 41.20
FROM products p WHERE p.sku='NF-0026' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 56.10, NULL, '23793.1000000025', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='daniel.augusto27@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0027' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1026', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 26.20, 14.90, 41.10, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='natalia.souza28@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 26.20, 26.20
FROM products p WHERE p.sku='NF-0028' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400027', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 58.00, 0.00, 58.00, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.clinica-bem-viver-lt@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 29.00, 58.00 FROM products p WHERE p.sku='NF-0029' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 58.00, NULL, '23793.1000000028', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.distribuidora-fitona@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0030' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1029', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 34.60, 14.90, 49.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.laboratorio-verde-vi@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 34.60, 34.60
FROM products p WHERE p.sku='NF-0031' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400030', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 74.80, 14.90, 89.70, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.rede-saude-integrada@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 37.40, 74.80
FROM products p WHERE p.sku='NF-0032' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 89.70, NULL, '23793.1000000031', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0033' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1032', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 43.00, 14.90, 57.90, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 43.00, 43.00 FROM products p WHERE p.sku='NF-0034' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400033', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 91.60, 14.90, 106.50, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 45.80, 91.60 FROM products p WHERE p.sku='NF-0035' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 106.50, NULL, '23793.1000000034', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0036' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1035', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 17.80, 0.00, 17.80, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.80, 17.80
FROM products p WHERE p.sku='NF-0037' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400036', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 41.20, 14.90, 56.10, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.60, 41.20
FROM products p WHERE p.sku='NF-0038' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 56.10, NULL, '23793.1000000037', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0039' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1038', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 26.20, 14.90, 41.10, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 26.20, 26.20 FROM products p WHERE p.sku='NF-0040' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400039', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 58.00, 0.00, 58.00, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 29.00, 58.00
FROM products p WHERE p.sku='NF-0041' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 58.00, NULL, '23793.1000000040', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0042' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1041', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 34.60, 14.90, 49.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 34.60, 34.60
FROM products p WHERE p.sku='NF-0043' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400042', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 74.80, 14.90, 89.70, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 37.40, 74.80 FROM products p WHERE p.sku='NF-0044' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 89.70, NULL, '23793.1000000043', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0045' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1044', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 43.00, 14.90, 57.90, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 43.00, 43.00
FROM products p WHERE p.sku='NF-0046' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400045', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 91.60, 14.90, 106.50, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 46 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 45.80, 91.60
FROM products p WHERE p.sku='NF-0047' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 106.50, NULL, '23793.1000000046', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 47 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0048' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1047', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 17.80, 0.00, 17.80, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 17.80, 17.80 FROM products p WHERE p.sku='NF-0049' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400048', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 41.20, 14.90, 56.10, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 49 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='thiago.rafael18@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 20.60, 41.20 FROM products p WHERE p.sku='NF-0050' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 56.10, NULL, '23793.1000000049', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 50 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='gabriela.moura19@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0051' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1050', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 26.20, 14.90, 41.10, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 51 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='vinicius.luis20@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 26.20, 26.20
FROM products p WHERE p.sku='NF-0052' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400051', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 58.00, 0.00, 58.00, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 52 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='helena.vitoria21@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 29.00, 58.00
FROM products p WHERE p.sku='NF-0053' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 58.00, NULL, '23793.1000000052', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 53 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='matheus.antonio22@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0054' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1053', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 34.60, 14.90, 49.50, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='isabela.fernanda23@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 34.60, 34.60 FROM products p WHERE p.sku='NF-0055' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400054', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 74.80, 14.90, 89.70, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 55 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='guilherme.augusto24@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 37.40, 74.80
FROM products p WHERE p.sku='NF-0056' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 89.70, NULL, '23793.1000000055', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 56 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='beatriz.helena25@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0057' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1056', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 43.00, 14.90, 57.90, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 57 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='rafaela.cristiane26@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 43.00, 43.00
FROM products p WHERE p.sku='NF-0058' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400057', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 91.60, 14.90, 106.50, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 58 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='daniel.augusto27@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 45.80, 91.60 FROM products p WHERE p.sku='NF-0059' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 106.50, NULL, '23793.1000000058', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 59 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='natalia.souza28@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0060' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1059', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 17.80, 0.00, 17.80, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 60 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.clinica-bem-viver-lt@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.80, 17.80
FROM products p WHERE p.sku='NF-0061' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400060', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 41.20, 14.90, 56.10, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 61 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.distribuidora-fitona@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 20.60, 41.20
FROM products p WHERE p.sku='NF-0062' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 56.10, NULL, '23793.1000000061', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 62 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.laboratorio-verde-vi@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0063' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1062', 3);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 26.20, 14.90, 41.10, 'PIX', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 63 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='empresa.rede-saude-integrada@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 26.20, 26.20 FROM products p WHERE p.sku='NF-0064' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PENDING', 41.10, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400063', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 58.00, 0.00, 58.00, 'BOLETO', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 64 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 29.00, 58.00 FROM products p WHERE p.sku='NF-0065' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'FAILED', 58.00, NULL, '23793.1000000064', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 95.40, 14.90, 110.30, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 65 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 31.80, 95.40
FROM products p WHERE p.sku='NF-0066' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 110.30, NULL, NULL, '1065', 2);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 34.60, 14.90, 49.50, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 66 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 34.60, 34.60
FROM products p WHERE p.sku='NF-0067' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 49.50, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400066', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 74.80, 14.90, 89.70, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 67 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 37.40, 74.80
FROM products p WHERE p.sku='NF-0068' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 89.70, NULL, '23793.1000000067', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 120.60, 0.00, 120.60, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 68 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 40.20, 120.60
FROM products p WHERE p.sku='NF-0069' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 120.60, NULL, NULL, '1068', 1);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 43.00, 14.90, 57.90, 'PIX', 'FAILED', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 69 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 1, 43.00, 43.00 FROM products p WHERE p.sku='NF-0070' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'FAILED', 57.90, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400069', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'DELIVERED', 91.60, 14.90, 106.50, 'BOLETO', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 70 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 2, 45.80, 91.60
FROM products p WHERE p.sku='NF-0071' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PAID', 106.50, NULL, '23793.1000000070', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'SHIPPED', 45.00, 14.90, 59.90, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 71 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 15.00, 45.00
FROM products p WHERE p.sku='NF-0072' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 59.90, NULL, NULL, '1071', 4);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'PROCESSING', 17.80, 0.00, 17.80, 'PIX', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 72 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 1, 17.80, 17.80
FROM products p WHERE p.sku='NF-0073' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'PIX', 'PAID', 17.80, '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-42661417400072', NULL, NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CONFIRMED', 41.20, 14.90, 56.10, 'BOLETO', 'PENDING', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 73 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, 2, 20.60, 41.20 FROM products p WHERE p.sku='NF-0074' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'BOLETO', 'PENDING', 56.10, NULL, '23793.1000000073', NULL, NULL);
INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, 'CANCELLED', 70.20, 14.90, 85.10, 'CREDIT_CARD', 'PAID', '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL 74 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
SET @last_order := LAST_INSERT_ID();
INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), 3, 23.40, 70.20
FROM products p WHERE p.sku='NF-0075' LIMIT 1;
INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, 'CREDIT_CARD', 'PAID', 85.10, NULL, NULL, '1074', 3);

-- Descartes de lotes vencidos
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Produto vencido em conferência de estoque', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 0 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-001' WHERE p.sku='NF-0001' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Embalagem danificada na movimentação', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-002' WHERE p.sku='NF-0002' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Quebra operacional no balcão', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-003' WHERE p.sku='NF-0003' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Contaminação visual identificada na inspeção', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-004' WHERE p.sku='NF-0004' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Produto vencido em conferência de estoque', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-005' WHERE p.sku='NF-0005' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Embalagem danificada na movimentação', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-006' WHERE p.sku='NF-0006' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Quebra operacional no balcão', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-007' WHERE p.sku='NF-0007' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 2, 'Contaminação visual identificada na inspeção', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-008' WHERE p.sku='NF-0008' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 3, 'Produto vencido em conferência de estoque', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 48 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-009' WHERE p.sku='NF-0009' LIMIT 1;
INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, 1, 'Embalagem danificada na movimentação', (SELECT u.id FROM users u WHERE u.email='robson.lima@loja.neofarma.com.br' LIMIT 1), DATE_SUB(NOW(), INTERVAL 54 DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code='L24-A-010' WHERE p.sku='NF-0010' LIMIT 1;

-- Coerência: totais de compra, baixa de estoque e descartes
UPDATE purchase_orders po
SET po.total_amount = (
  SELECT COALESCE(SUM(poi.total_cost), 0) FROM purchase_order_items poi WHERE poi.purchase_order_id = po.id
)
WHERE po.notes LIKE 'OC-2024-%';
UPDATE inventory_batches ib
INNER JOIN (
  SELECT oi.batch_id, SUM(oi.quantity) AS sold_qty
  FROM order_items oi
  INNER JOIN orders o ON o.id = oi.order_id
  INNER JOIN customers c ON c.id = o.customer_id
  INNER JOIN users u ON u.id = c.user_id
  WHERE u.email LIKE '%@loja.neofarma.com.br' AND o.payment_status = 'PAID'
  GROUP BY oi.batch_id
) s ON s.batch_id = ib.id
SET ib.quantity = ib.quantity - s.sold_qty;
UPDATE inventory_batches ib
INNER JOIN (
  SELECT d.batch_id, SUM(d.quantity) AS disposed_qty
  FROM inventory_disposals d
  INNER JOIN products p ON p.id = d.product_id
  WHERE p.sku LIKE 'NF-%'
  GROUP BY d.batch_id
) x ON x.batch_id = ib.id
SET ib.quantity = ib.quantity - x.disposed_qty;

-- Validação (esperado: 0 problemas)
SELECT 'lotes_negativos' AS check_name, COUNT(*) AS problemas FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id WHERE p.sku LIKE 'NF-%' AND ib.quantity < 0
UNION ALL SELECT 'pedido_pago_sem_itens', COUNT(*) FROM orders o
INNER JOIN customers c ON c.id = o.customer_id INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE '%@loja.neofarma.com.br' AND o.payment_status = 'PAID'
AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)
UNION ALL SELECT 'compra_recebida_sem_lote', COUNT(*) FROM purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
WHERE po.notes LIKE 'OC-2024-%' AND po.status = 'RECEIVED' AND poi.quantity_received > 0 AND poi.batch_id IS NULL;

-- Profissionais de saúde e agenda
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dra. Helena Martins', 'FARMACEUTICO', 'helena.martins@loja.neofarma.com.br', '1899800100', 'CRF', 'SP', '45678', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Paulo Ricardo Dias', 'ENFERMEIRO', 'paulo.dias@loja.neofarma.com.br', '1899800101', 'COREN', 'SP', '123456', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dra. Camila Rocha', 'FARMACEUTICO', 'camila.rocha@loja.neofarma.com.br', '1899800102', 'CRF', 'SP', '78901', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Juliana Freitas', 'ENFERMEIRO', 'juliana.freitas@loja.neofarma.com.br', '1899800103', 'COREN', 'SP', '654321', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Dr. Roberto Alves', 'FARMACEUTICO', 'roberto.alves@loja.neofarma.com.br', '1899800104', 'CRF', 'SP', '23456', 1);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES ('Enf. Marcos Vinícius', 'ENFERMEIRO', 'marcos.vinicius@loja.neofarma.com.br', '1899800105', 'COREN', 'SP', '987654', 0);
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 1, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='marcos.vinicius@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 2, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='marcos.vinicius@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 3, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='marcos.vinicius@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 4, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='marcos.vinicius@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, 5, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email='marcos.vinicius@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_holidays (holiday_date, name, is_active) VALUES
(DATE_ADD(CURDATE(), INTERVAL 45 DAY), 'Corpus Christi', 1),
(DATE_ADD(CURDATE(), INTERVAL 120 DAY), 'Emenda Feriado Municipal', 1)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Agendamentos de serviços
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(0 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(0 % 3 = 0, 'PIX', IF(0 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(0 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -45 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 45 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(1 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -44 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(1 % 3 = 0, 'PIX', IF(1 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(1 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 44 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(2 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -43 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(2 % 3 = 0, 'PIX', IF(2 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(2 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 43 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(3 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -42 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(3 % 3 = 0, 'PIX', IF(3 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(3 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 42 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(4 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -41 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(4 % 3 = 0, 'PIX', IF(4 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(4 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 41 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(5 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -40 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(5 % 3 = 0, 'PIX', IF(5 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(5 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 40 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(6 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -39 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(6 % 3 = 0, 'PIX', IF(6 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(6 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 39 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(7 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -38 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(7 % 3 = 0, 'PIX', IF(7 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(7 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 38 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(8 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(8 % 3 = 0, 'PIX', IF(8 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(8 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -37 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 37 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(9 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -36 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(9 % 3 = 0, 'PIX', IF(9 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(9 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 36 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(10 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -35 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(10 % 3 = 0, 'PIX', IF(10 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(10 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 35 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(11 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -34 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(11 % 3 = 0, 'PIX', IF(11 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(11 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 34 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(12 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -33 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(12 % 3 = 0, 'PIX', IF(12 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(12 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 33 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(13 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -32 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(13 % 3 = 0, 'PIX', IF(13 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(13 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 32 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(14 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -31 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(14 % 3 = 0, 'PIX', IF(14 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(14 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 31 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(15 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -30 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(15 % 3 = 0, 'PIX', IF(15 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(15 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 30 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(16 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(16 % 3 = 0, 'PIX', IF(16 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(16 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -29 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 29 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(17 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -28 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(17 % 3 = 0, 'PIX', IF(17 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(17 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 28 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='thiago.rafael18@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(18 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -27 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(18 % 3 = 0, 'PIX', IF(18 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(18 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 27 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='gabriela.moura19@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(19 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -26 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(19 % 3 = 0, 'PIX', IF(19 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(19 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 26 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='vinicius.luis20@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(20 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -25 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(20 % 3 = 0, 'PIX', IF(20 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(20 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 25 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='helena.vitoria21@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(21 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -24 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(21 % 3 = 0, 'PIX', IF(21 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(21 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 24 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='matheus.antonio22@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(22 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -23 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(22 % 3 = 0, 'PIX', IF(22 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(22 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 23 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='isabela.fernanda23@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(23 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -22 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(23 % 3 = 0, 'PIX', IF(23 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(23 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 22 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='guilherme.augusto24@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(24 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(24 % 3 = 0, 'PIX', IF(24 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(24 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -21 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 21 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='beatriz.helena25@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(25 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -20 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -20 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(25 % 3 = 0, 'PIX', IF(25 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(25 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 20 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='rafaela.cristiane26@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(26 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -19 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -19 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(26 % 3 = 0, 'PIX', IF(26 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(26 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 19 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='daniel.augusto27@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(27 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -18 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -18 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(27 % 3 = 0, 'PIX', IF(27 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(27 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 18 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='natalia.souza28@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(28 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -17 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -17 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(28 % 3 = 0, 'PIX', IF(28 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(28 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 17 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(29 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -16 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -16 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(29 % 3 = 0, 'PIX', IF(29 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(29 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 16 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(30 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -15 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -15 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(30 % 3 = 0, 'PIX', IF(30 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(30 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 15 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(31 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -14 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -14 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(31 % 3 = 0, 'PIX', IF(31 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(31 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 14 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(32 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -13 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -13 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(32 % 3 = 0, 'PIX', IF(32 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(32 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -13 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 13 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(33 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -12 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -12 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(33 % 3 = 0, 'PIX', IF(33 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(33 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 12 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(34 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -11 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -11 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(34 % 3 = 0, 'PIX', IF(34 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(34 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 11 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 6, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(35 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=6 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -10 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -10 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(35 % 3 = 0, 'PIX', IF(35 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(35 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 10 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 7, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(36 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=7 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -9 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -9 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(36 % 3 = 0, 'PIX', IF(36 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(36 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 9 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 8, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(37 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=8 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -8 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -8 DAY) + INTERVAL 10 HOUR,
  'INCOMPLETE', 'REFUNDED_PARTIAL', IF(37 % 3 = 0, 'PIX', IF(37 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(37 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  24.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 8 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 9, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(38 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=9 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -7 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -7 DAY) + INTERVAL 10 HOUR,
  'CANCELLED', 'PENDING', IF(38 % 3 = 0, 'PIX', IF(38 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(38 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 7 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='camila.duarte11@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 10, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(39 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=10 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -6 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -6 DAY) + INTERVAL 10 HOUR,
  'PAYMENT_FAILED', 'FAILED', IF(39 % 3 = 0, 'PIX', IF(39 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(39 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 6 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bruno.henrique12@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 1, (SELECT id FROM service_professionals WHERE email='helena.martins@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(40 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=1 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -5 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -5 DAY) + INTERVAL 10 HOUR,
  'COMPLETED', 'PAID', IF(40 % 3 = 0, 'PIX', IF(40 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(40 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  'Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.',
  NULL,
  DATE_ADD(NOW(), INTERVAL -5 DAY) + INTERVAL 10 HOUR,
  DATE_SUB(NOW(), INTERVAL 5 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='larissa.aparecida13@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 2, (SELECT id FROM service_professionals WHERE email='paulo.dias@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(41 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=2 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -4 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -4 DAY) + INTERVAL 10 HOUR,
  'CONFIRMED', 'PAID', IF(41 % 3 = 0, 'PIX', IF(41 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(41 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='diego.augusto14@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 3, (SELECT id FROM service_professionals WHERE email='camila.rocha@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(42 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=3 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -3 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -3 DAY) + INTERVAL 10 HOUR,
  'IN_PROGRESS', 'PAID', IF(42 % 3 = 0, 'PIX', IF(42 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(42 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 3 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='amanda.cristina15@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 4, (SELECT id FROM service_professionals WHERE email='juliana.freitas@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(43 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=4 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -2 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -2 DAY) + INTERVAL 10 HOUR,
  'RESERVED', 'PENDING', IF(43 % 3 = 0, 'PIX', IF(43 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(43 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  NULL,
  NULL,
  DATE_SUB(NOW(), INTERVAL 2 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='felipe.andrade16@loja.neofarma.com.br' LIMIT 1;
INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT 5, (SELECT id FROM service_professionals WHERE email='roberto.alves@loja.neofarma.com.br' LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(44 % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=5 LIMIT 1),
  DATE_ADD(NOW(), INTERVAL -1 DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL -1 DAY) + INTERVAL 10 HOUR,
  'NO_SHOW', 'REFUNDED_PARTIAL', IF(44 % 3 = 0, 'PIX', IF(44 % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(44 % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  NULL,
  19.95,
  NULL,
  DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='bianca.luiza17@loja.neofarma.com.br' LIMIT 1;

-- Receitas médicas
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. André Silva', 'CRM-SP 100000', DATE_SUB(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'Receita 1 — Dr. André Silva'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ana.beatriz@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='Receita 1 — Dr. André Silva' AND p.sku='NF-0001' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dra. Patricia Mendes', 'CRM-SP 100001', DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 89 DAY), 'Receita 2 — Dra. Patricia Mendes'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='carlos.eduardo2@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='Receita 2 — Dra. Patricia Mendes' AND p.sku='NF-0002' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Fernando Costa', 'CRM-SP 100002', DATE_SUB(CURDATE(), INTERVAL 24 DAY), DATE_ADD(CURDATE(), INTERVAL 88 DAY), 'Receita 3 — Dr. Fernando Costa'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='mariana.oliveira3@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='Receita 3 — Dr. Fernando Costa' AND p.sku='NF-0003' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dra. Luiza Barros', 'CRM-SP 100003', DATE_SUB(CURDATE(), INTERVAL 36 DAY), DATE_ADD(CURDATE(), INTERVAL 87 DAY), 'Receita 4 — Dra. Luiza Barros'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='joao.pedro4@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='Receita 4 — Dra. Luiza Barros' AND p.sku='NF-0004' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. André Silva', 'CRM-SP 100004', DATE_SUB(CURDATE(), INTERVAL 48 DAY), DATE_ADD(CURDATE(), INTERVAL 86 DAY), 'Receita 5 — Dr. André Silva'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='fernanda.rocha5@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='Receita 5 — Dr. André Silva' AND p.sku='NF-0005' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dra. Patricia Mendes', 'CRM-SP 100005', DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_ADD(CURDATE(), INTERVAL 85 DAY), 'Receita 6 — Dra. Patricia Mendes'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='ricardo.henrique6@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='Receita 6 — Dra. Patricia Mendes' AND p.sku='NF-0006' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. Fernando Costa', 'CRM-SP 100006', DATE_SUB(CURDATE(), INTERVAL 72 DAY), DATE_ADD(CURDATE(), INTERVAL 84 DAY), 'Receita 7 — Dr. Fernando Costa'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='juliana.costa7@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='Receita 7 — Dr. Fernando Costa' AND p.sku='NF-0007' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dra. Luiza Barros', 'CRM-SP 100007', DATE_SUB(CURDATE(), INTERVAL 84 DAY), DATE_ADD(CURDATE(), INTERVAL 83 DAY), 'Receita 8 — Dra. Luiza Barros'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='lucas.gabriel8@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='Receita 8 — Dra. Luiza Barros' AND p.sku='NF-0008' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dr. André Silva', 'CRM-SP 100008', DATE_SUB(CURDATE(), INTERVAL 96 DAY), DATE_ADD(CURDATE(), INTERVAL 82 DAY), 'Receita 9 — Dr. André Silva'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='patricia.mendes9@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 0 FROM prescriptions pr, products p WHERE pr.notes='Receita 9 — Dr. André Silva' AND p.sku='NF-0009' LIMIT 1;
INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, 'Dra. Patricia Mendes', 'CRM-SP 100009', DATE_SUB(CURDATE(), INTERVAL 108 DAY), DATE_ADD(CURDATE(), INTERVAL 81 DAY), 'Receita 10 — Dra. Patricia Mendes'
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email='roberto.carlos10@loja.neofarma.com.br' LIMIT 1;
INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, 1 FROM prescriptions pr, products p WHERE pr.notes='Receita 10 — Dra. Patricia Mendes' AND p.sku='NF-0010' LIMIT 1;

-- Resumo
SELECT 'Usuários demo' AS item, COUNT(*) AS qtd FROM users WHERE email LIKE '%@loja.neofarma.com.br'
UNION ALL SELECT 'Produtos', COUNT(*) FROM products WHERE sku LIKE 'NF-%'
UNION ALL SELECT 'Lotes', COUNT(*) FROM inventory_batches ib INNER JOIN products p ON p.id=ib.product_id WHERE p.sku LIKE 'NF-%'
UNION ALL SELECT 'Pedidos', COUNT(*) FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%@loja.neofarma.com.br'
UNION ALL SELECT 'Agendamentos', COUNT(*) FROM service_appointments WHERE customer_email LIKE '%@loja.neofarma.com.br'
;

-- ============================================================
-- Acessos principais
-- Admin (schema): admin@neofarma.com / Admin@123
-- Gerente:      marcos.ribeiro@loja.neofarma.com.br / NeoFarma@2026
-- Atendente:    eliane.moraes@loja.neofarma.com.br / NeoFarma@2026
-- Estoquista:   robson.lima@loja.neofarma.com.br / NeoFarma@2026
-- Cliente:      ana.beatriz@loja.neofarma.com.br / NeoFarma@2026
-- ============================================================