-- Módulo de Agendamento de Serviços (Admin)
-- Execute após criar o schema principal.

CREATE TABLE IF NOT EXISTS health_services (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  duration_minutes INT NOT NULL DEFAULT 30,
  requires_prescription TINYINT(1) NOT NULL DEFAULT 0,
  home_available TINYINT(1) NOT NULL DEFAULT 1,
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
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

-- Índices únicos para evitar duplicidade de profissional por contato.
-- (NULL continua permitido para registros sem contato preenchido.)
SET @idx_email_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'service_professionals'
    AND INDEX_NAME = 'uk_service_professionals_email'
);
SET @sql := IF(
  @idx_email_exists = 0,
  'ALTER TABLE service_professionals ADD UNIQUE KEY uk_service_professionals_email (email)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_phone_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'service_professionals'
    AND INDEX_NAME = 'uk_service_professionals_phone'
);
SET @sql := IF(
  @idx_phone_exists = 0,
  'ALTER TABLE service_professionals ADD UNIQUE KEY uk_service_professionals_phone (phone)',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

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

-- Compatibilidade para ambientes que já executaram versão anterior sem profissional.
-- MySQL mais antigo não aceita "ADD COLUMN IF NOT EXISTS".
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'service_appointments'
    AND COLUMN_NAME = 'professional_id'
);
SET @sql := IF(
  @col_exists = 0,
  'ALTER TABLE service_appointments ADD COLUMN professional_id BIGINT UNSIGNED NULL AFTER service_id',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

