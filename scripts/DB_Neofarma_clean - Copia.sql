-- ============================================================
-- NEOFARMA - SCRIPT LIMPO E CONSOLIDADO
-- Compatível com o código atual (catálogo, carrinho, checkout)
-- ============================================================



USE PFS1_10442511034;

-- ==============================
-- Tabelas de apoio
-- ==============================

CREATE TABLE IF NOT EXISTS roles (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(50) NOT NULL UNIQUE,
  description  VARCHAR(255),
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payment_methods (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(50) NOT NULL UNIQUE,
  description  VARCHAR(255),
  active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS shipping_methods (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(80) NOT NULL UNIQUE,
  description    VARCHAR(255),
  estimated_days INT UNSIGNED NOT NULL,
  active         TINYINT(1) NOT NULL DEFAULT 1,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==============================
-- Endereços
-- ==============================

CREATE TABLE IF NOT EXISTS addresses (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  street       VARCHAR(150) NOT NULL,
  number       VARCHAR(20)  NOT NULL,
  complement   VARCHAR(100),
  district     VARCHAR(100),
  city         VARCHAR(100) NOT NULL,
  state        VARCHAR(2)   NOT NULL,
  country      VARCHAR(80)  NOT NULL DEFAULT 'Brasil',
  zip_code     VARCHAR(15)  NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==============================
-- Usuários / Clientes / Funcionários
-- ==============================

CREATE TABLE IF NOT EXISTS users (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id         BIGINT UNSIGNED NOT NULL,
  full_name       VARCHAR(150) NOT NULL,
  email           VARCHAR(150) NOT NULL UNIQUE,
  password_hash   VARCHAR(255) NOT NULL,
  document        VARCHAR(20),
  phone           VARCHAR(20),
  birth_date      DATE,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role
    FOREIGN KEY (role_id) REFERENCES roles(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id             BIGINT UNSIGNED NOT NULL UNIQUE,
  default_address_id  BIGINT UNSIGNED NULL,
  loyalty_points      INT UNSIGNED NOT NULL DEFAULT 0,
  created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_customers_user
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_customers_default_address
    FOREIGN KEY (default_address_id) REFERENCES addresses(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employees (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         BIGINT UNSIGNED NOT NULL UNIQUE,
  hire_date       DATE NOT NULL,
  salary          DECIMAL(10,2) NOT NULL,
  role_title      VARCHAR(100) NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_employees_user
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer_addresses (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id     BIGINT UNSIGNED NOT NULL,
  address_id      BIGINT UNSIGNED NOT NULL,
  label           VARCHAR(50),
  is_default      TINYINT(1) NOT NULL DEFAULT 0,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_customer_address (customer_id, address_id),
  CONSTRAINT fk_customer_addresses_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_customer_addresses_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==============================
-- Fornecedores / Laboratórios
-- ==============================

CREATE TABLE IF NOT EXISTS suppliers (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  corporate_name  VARCHAR(150) NOT NULL,
  trade_name      VARCHAR(150),
  cnpj            VARCHAR(20) UNIQUE,
  email           VARCHAR(150),
  phone           VARCHAR(20),
  address_id      BIGINT UNSIGNED,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_suppliers_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS labs (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(150) NOT NULL,
  cnpj            VARCHAR(20) UNIQUE,
  email           VARCHAR(150),
  phone           VARCHAR(20),
  address_id      BIGINT UNSIGNED,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_labs_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==============================
-- Categorias / Produtos
-- ==============================

CREATE TABLE IF NOT EXISTS categories (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  parent_id       BIGINT UNSIGNED NULL,
  name            VARCHAR(100) NOT NULL,
  slug            VARCHAR(120) NOT NULL UNIQUE,
  description     VARCHAR(255),
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_id) REFERENCES categories(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_types (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  slug        VARCHAR(120) NOT NULL UNIQUE,
  description VARCHAR(255) NULL,
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
  id                    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  lab_id                BIGINT UNSIGNED,
  main_supplier_id      BIGINT UNSIGNED,
  product_type_id       BIGINT UNSIGNED NULL,
  name                  VARCHAR(200) NOT NULL,
  slug                  VARCHAR(220) NOT NULL UNIQUE,
  sku                   VARCHAR(50) UNIQUE,
  ean13                 VARCHAR(20) UNIQUE,
  gtin14                VARCHAR(20) UNIQUE,
  description           TEXT,
  composition           TEXT,
  usage_info            TEXT,
  prescription_required TINYINT(1) NOT NULL DEFAULT 0,
  unit_price            DECIMAL(10,2) NOT NULL,
  promotional_price     DECIMAL(10,2),
  status                ENUM('ACTIVE','INACTIVE','DISCONTINUED') NOT NULL DEFAULT 'ACTIVE',
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_lab
    FOREIGN KEY (lab_id) REFERENCES labs(id)
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_products_supplier
    FOREIGN KEY (main_supplier_id) REFERENCES suppliers(id)
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_products_product_type
    FOREIGN KEY (product_type_id) REFERENCES product_types(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_categories (
  product_id    BIGINT UNSIGNED NOT NULL,
  category_id   BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, category_id),
  CONSTRAINT fk_product_categories_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_product_categories_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_images (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id    BIGINT UNSIGNED NOT NULL,
  image_url     VARCHAR(500) NOT NULL,
  sort_order    INT UNSIGNED NOT NULL DEFAULT 0,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_images_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_product_images_product_id (product_id)
) ENGINE=InnoDB;

-- ==============================
-- Estoque por lotes (FEFO)
-- ==============================

CREATE TABLE IF NOT EXISTS inventory_batches (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id   BIGINT UNSIGNED NOT NULL,
  batch_code   VARCHAR(80) NOT NULL,
  mfg_date     DATE NULL,
  expiry_date  DATE NOT NULL,
  quantity     INT NOT NULL DEFAULT 0,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_inventory_product_batch (product_id, batch_code),
  INDEX idx_inventory_product_expiry (product_id, expiry_date),
  CONSTRAINT fk_inventory_batch_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

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
  CONSTRAINT fk_disposals_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_disposals_batch
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_disposals_user
    FOREIGN KEY (disposed_by) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==============================
-- Estruturas extras de estoque/compras (mantidas)
-- ==============================

CREATE TABLE IF NOT EXISTS stock_locations (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  description   VARCHAR(255),
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS product_batches (
  id                 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id         BIGINT UNSIGNED NOT NULL,
  batch_code         VARCHAR(50) NOT NULL,
  expiration_date    DATE NOT NULL,
  manufacturing_date DATE,
  UNIQUE KEY uk_product_batch (product_id, batch_code),
  CONSTRAINT fk_product_batches_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stock_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id    BIGINT UNSIGNED NOT NULL,
  location_id   BIGINT UNSIGNED NOT NULL,
  batch_id      BIGINT UNSIGNED NULL,
  quantity      INT NOT NULL DEFAULT 0,
  min_quantity  INT NOT NULL DEFAULT 0,
  max_quantity  INT,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_stock_product_location_batch (product_id, location_id, batch_id),
  CONSTRAINT fk_stock_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_stock_items_location
    FOREIGN KEY (location_id) REFERENCES stock_locations(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_stock_items_batch
    FOREIGN KEY (batch_id) REFERENCES product_batches(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_orders (
  id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  supplier_id     BIGINT UNSIGNED NOT NULL,
  employee_id     BIGINT UNSIGNED NULL,
  order_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expected_date   DATETIME NULL,
  status          ENUM('DRAFT','AWAITING_DELIVERY','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  payment_status  ENUM('PENDING','PAID','FAILED') NOT NULL DEFAULT 'PENDING',
  payment_method  ENUM('PIX','TRANSFER','BOLETO','CASH') NULL,
  total_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
  notes           TEXT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_purchase_orders_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_purchase_orders_employee
    FOREIGN KEY (employee_id) REFERENCES employees(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id                  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  purchase_order_id   BIGINT UNSIGNED NOT NULL,
  product_id          BIGINT UNSIGNED NOT NULL,
  batch_id            BIGINT UNSIGNED NULL,
  quantity            INT NOT NULL,
  quantity_received   INT NOT NULL DEFAULT 0,
  batch_code          VARCHAR(60) NULL,
  expiry_date         DATE NULL,
  unit_cost           DECIMAL(10,2) NOT NULL,
  total_cost          DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_po_items_order
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_po_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_po_items_batch
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ==============================
-- Pedidos / Itens / Pagamentos (compatível com checkout atual)
-- ==============================

CREATE TABLE IF NOT EXISTS orders (
  id                    BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id           BIGINT UNSIGNED NOT NULL,
  address_id            BIGINT UNSIGNED NOT NULL,
  status                ENUM('CONFIRMED','PROCESSING','SHIPPED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
  subtotal              DECIMAL(12,2) NOT NULL DEFAULT 0,
  shipping_cost         DECIMAL(12,2) NOT NULL DEFAULT 0,
  total                 DECIMAL(12,2) NOT NULL DEFAULT 0,
  payment_method        ENUM('PIX','CREDIT_CARD','BOLETO') NOT NULL,
  payment_status        ENUM('PENDING','PAID','FAILED') NOT NULL DEFAULT 'PENDING',
  shipping_zip          VARCHAR(8) NULL,
  shipping_service      VARCHAR(20) NULL,
  shipping_deadline_days INT NULL,
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_orders_customer (customer_id),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_orders_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id      BIGINT UNSIGNED NOT NULL,
  product_id    BIGINT UNSIGNED NOT NULL,
  batch_id      BIGINT UNSIGNED NOT NULL,
  quantity      INT NOT NULL,
  unit_price    DECIMAL(12,2) NOT NULL,
  line_total    DECIMAL(12,2) NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_order_items_order (order_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_order_items_batch
    FOREIGN KEY (batch_id) REFERENCES inventory_batches(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

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
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_pending_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id       BIGINT UNSIGNED NOT NULL,
  method         ENUM('PIX','CREDIT_CARD','BOLETO') NOT NULL,
  status         ENUM('PENDING','PAID','FAILED') NOT NULL DEFAULT 'PENDING',
  amount         DECIMAL(12,2) NOT NULL,
  pix_qr_code    TEXT NULL,
  pix_copy_paste TEXT NULL,
  boleto_barcode VARCHAR(120) NULL,
  boleto_due_date DATE NULL,
  card_brand     VARCHAR(40) NULL,
  card_last4     CHAR(4) NULL,
  installments   INT NULL,
  interest_rate  DECIMAL(6,2) NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_payments_order (order_id),
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
      ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==============================
-- Receita médica e auditoria
-- ==============================

CREATE TABLE IF NOT EXISTS prescriptions (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id       BIGINT UNSIGNED NOT NULL,
  doctor_name       VARCHAR(150) NOT NULL,
  doctor_crm        VARCHAR(50),
  issued_at         DATE NOT NULL,
  valid_until       DATE,
  notes             TEXT,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_prescriptions_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS prescription_items (
  id                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  prescription_id   BIGINT UNSIGNED NOT NULL,
  product_id        BIGINT UNSIGNED NOT NULL,
  dosage            VARCHAR(100),
  quantity_allowed  INT,
  quantity_used     INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_prescription_items_prescription
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(id)
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_prescription_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NULL,
  entity      VARCHAR(100) NOT NULL,
  entity_id   BIGINT UNSIGNED NULL,
  action      VARCHAR(50) NOT NULL,
  details     JSON,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Módulo de Agendamento de Serviços (Admin)

CREATE TABLE IF NOT EXISTS health_services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  duration_minutes INT NOT NULL DEFAULT 30,
  requires_prescription TINYINT(1) NOT NULL DEFAULT 0,
  service_group ENUM('VACINACAO','PROCEDIMENTO','TESTE_RAPIDO','ACOMPANHAMENTO','ORIENTACAO','OUTRO') NOT NULL DEFAULT 'OUTRO',
  in_store_available TINYINT(1) NOT NULL DEFAULT 1,
  home_available TINYINT(1) NOT NULL DEFAULT 1,
  min_age_years TINYINT UNSIGNED NULL,
  max_age_years TINYINT UNSIGNED NULL,
  post_observation_minutes TINYINT UNSIGNED NOT NULL DEFAULT 0,
  prep_instructions TEXT NULL,
  contraindications TEXT NULL,
  required_supplies TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_health_service_name (name)
);

CREATE TABLE IF NOT EXISTS service_professionals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(120) NOT NULL,
  role_name ENUM('FARMACEUTICO','ENFERMEIRO') NOT NULL DEFAULT 'FARMACEUTICO',
  email VARCHAR(150) NULL,
  phone VARCHAR(40) NULL,
  council_type ENUM('CRF','COREN') NOT NULL,
  council_uf CHAR(2) NOT NULL,
  council_number VARCHAR(30) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_service_professionals_email (email),
  UNIQUE KEY uk_service_professionals_phone (phone),
  UNIQUE KEY uk_service_professionals_council (council_type, council_uf, council_number)
);

CREATE TABLE IF NOT EXISTS service_professional_availability (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  professional_id BIGINT UNSIGNED NOT NULL,
  day_of_week TINYINT UNSIGNED NOT NULL COMMENT '0=Domingo ... 6=Sábado',
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_professional_dow (professional_id, day_of_week),
  CONSTRAINT fk_professional_availability_professional
    FOREIGN KEY (professional_id) REFERENCES service_professionals(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS service_holidays (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  holiday_date DATE NOT NULL,
  name VARCHAR(120) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_service_holidays_date (holiday_date)
);

CREATE TABLE IF NOT EXISTS service_appointments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_id BIGINT UNSIGNED NOT NULL,
  professional_id BIGINT UNSIGNED NULL,
  customer_id BIGINT UNSIGNED NULL,
  customer_name VARCHAR(120) NOT NULL,
  customer_email VARCHAR(150) NULL,
  customer_phone VARCHAR(40) NULL,
  modality ENUM('IN_STORE','HOME') NOT NULL DEFAULT 'IN_STORE',
  address_text VARCHAR(255) NULL,
  zip_code VARCHAR(20) NULL,
  travel_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  scheduled_start DATETIME NOT NULL,
  scheduled_end DATETIME NOT NULL,
  reservation_expires_at DATETIME NULL,
  status ENUM('RESERVED','PAYMENT_FAILED','CONFIRMED','IN_PROGRESS','COMPLETED','NO_SHOW','INCOMPLETE','CANCELLED') NOT NULL DEFAULT 'RESERVED',
  payment_status ENUM('PENDING','PAID','FAILED','REFUNDED_PARTIAL') NOT NULL DEFAULT 'PENDING',
  payment_method ENUM('CASH','PIX','CREDIT_CARD','DEBIT_CARD') NOT NULL DEFAULT 'PIX',
  booking_channel ENUM('ADMIN','CUSTOMER_ONLINE') NOT NULL DEFAULT 'ADMIN',
  payment_attempts INT NOT NULL DEFAULT 0,
  payment_ref VARCHAR(80) NULL,
  clinical_record TEXT NULL,
  vaccine_batch_code VARCHAR(60) NULL,
  vaccine_expiry_date DATE NULL,
  application_site VARCHAR(80) NULL,
  observations TEXT NULL,
  incomplete_reason TEXT NULL,
  refund_amount DECIMAL(10,2) NULL,
  completed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_service_appointments_start (scheduled_start),
  KEY idx_service_appointments_status (status),
  CONSTRAINT fk_service_appointments_service
    FOREIGN KEY (service_id) REFERENCES health_services(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_service_appointments_professional
    FOREIGN KEY (professional_id) REFERENCES service_professionals(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_service_appointments_customer
    FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);
-- ==============================
-- Dados iniciais
-- ==============================

INSERT INTO roles (name, description) VALUES
  ('ADMIN', 'Administrador do sistema'),
  ('FUNCIONARIO', 'Funcionário da farmácia'),
  ('ESTOQUISTA', 'Estoquista — descarte e conferência de estoque'),
  ('CLIENTE', 'Cliente da loja')
ON DUPLICATE KEY UPDATE description = VALUES(description);

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

INSERT INTO health_services (
  name,
  price,
  duration_minutes,
  requires_prescription,
  service_group,
  in_store_available,
  home_available,
  min_age_years,
  max_age_years,
  post_observation_minutes,
  prep_instructions,
  contraindications,
  required_supplies,
  is_active,
  notes
) VALUES
  ('Aplicação de injetáveis (IM/SC)', 39.90, 20, 1, 'PROCEDIMENTO', 1, 1, 12, NULL, 10, 'Levar receita válida e documento com foto.', 'Hipersensibilidade conhecida ao medicamento ou orientação médica contrária.', 'Seringa, agulha, algodão, antisséptico, descarpack.', 1, 'Aplicação por profissional habilitado com conferência de prescrição.'),
  ('Curativo simples domiciliar', 49.90, 35, 0, 'PROCEDIMENTO', 1, 1, NULL, NULL, 0, 'Higienizar local e separar materiais anteriores, se houver.', 'Feridas extensas, sangramento ativo importante ou sinais de infecção grave exigem encaminhamento.', 'Gaze, soro fisiológico, cobertura estéril, fita hipoalergênica.', 1, 'Procedimento de baixa complexidade com orientação de troca.'),
  ('Aferição de pressão arterial', 14.90, 10, 0, 'ACOMPANHAMENTO', 1, 1, NULL, NULL, 0, 'Evitar cafeína e exercício intenso 30 min antes quando possível.', 'Sem contraindicações absolutas.', 'Esfigmomanômetro validado.', 1, 'Inclui orientação breve e registro do resultado.'),
  ('Glicemia capilar', 19.90, 12, 0, 'TESTE_RAPIDO', 1, 1, NULL, NULL, 0, 'Levar resultados anteriores para comparação quando disponível.', 'Nenhuma contraindicação relevante para teste capilar rotineiro.', 'Lanceta, tira reagente, glicosímetro.', 1, 'Triagem e orientação para procurar atendimento quando necessário.'),
  ('Teste rápido de COVID-19', 34.90, 15, 0, 'TESTE_RAPIDO', 1, 0, 2, NULL, 0, 'Seguir orientação de janela de testagem conforme sintomas/exposição.', 'Não substitui avaliação médica em caso de sinais de gravidade.', 'Kit teste rápido aprovado, EPI.', 1, 'Disponível somente na farmácia para garantir biossegurança.'),
  ('Vacinação aplicada na farmácia', 79.90, 25, 0, 'VACINACAO', 1, 0, NULL, NULL, 20, 'Apresentar carteira de vacinação e documento de identificação.', 'Febre aguda, alergia grave prévia a componente vacinal, conforme protocolo.', 'Imunobiológico, seringa, EPI e insumos de emergência.', 1, 'Valor base; vacina e protocolo podem variar conforme campanha.'),
  ('Acompanhamento farmacoterapêutico mensal', 99.90, 45, 0, 'ACOMPANHAMENTO', 1, 1, 18, NULL, 0, 'Levar lista de medicamentos, exames e histórico clínico.', 'Sem contraindicação; serviço de cuidado contínuo.', 'Ficha clínica e plano de cuidado.', 1, 'Focado em adesão, interações e metas terapêuticas.'),
  ('Revisão da farmacoterapia (polifarmácia)', 129.90, 60, 0, 'ACOMPANHAMENTO', 1, 1, 18, NULL, 0, 'Levar todos os medicamentos em uso (incluindo fitoterápicos e suplementos).', 'Sem contraindicação; requer colaboração do paciente/cuidador.', 'Checklist de interações e conciliação medicamentosa.', 1, 'Análise técnica e plano de intervenção farmacêutica.'),
  ('Orientação farmacêutica pós-alta', 69.90, 30, 0, 'ORIENTACAO', 1, 1, NULL, NULL, 0, 'Trazer receita de alta, exames recentes e dúvidas principais.', 'Sem contraindicação.', 'Roteiro de educação em saúde.', 1, 'Suporte para transição de cuidado após internação.'),
  ('Nebulização assistida', 29.90, 20, 1, 'PROCEDIMENTO', 1, 0, 2, NULL, 10, 'Levar medicação prescrita e receita quando aplicável.', 'Dispneia intensa, saturação baixa ou desconforto respiratório importante exigem emergência.', 'Nebulizador, máscara, solução prescrita.', 1, 'Realizada na farmácia com monitoramento básico.')
ON DUPLICATE KEY UPDATE
  price = VALUES(price),
  duration_minutes = VALUES(duration_minutes),
  requires_prescription = VALUES(requires_prescription),
  service_group = VALUES(service_group),
  in_store_available = VALUES(in_store_available),
  home_available = VALUES(home_available),
  min_age_years = VALUES(min_age_years),
  max_age_years = VALUES(max_age_years),
  post_observation_minutes = VALUES(post_observation_minutes),
  prep_instructions = VALUES(prep_instructions),
  contraindications = VALUES(contraindications),
  required_supplies = VALUES(required_supplies),
  is_active = VALUES(is_active),
  notes = VALUES(notes);

INSERT INTO stock_locations (name, description) VALUES
  ('LOJA_FISICA', 'Estoque da loja física'),
  ('CD_ONLINE', 'Centro de distribuição da loja online')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Cria admin padrão apenas se não existir
INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date)
SELECT
  r.id,
  'Administrador Sistema',
  'admin@neofarma.com',
  '$2b$10$mx0hdTZc/sRDyZUVwgDRAu9vr46zBNCwms179w88db45nsfF3saz.',
  NULL,
  NULL,
  NULL
FROM roles r
WHERE r.name = 'ADMIN'
  AND NOT EXISTS (
    SELECT 1 FROM users u WHERE u.email = 'admin@neofarma.com'
  );
