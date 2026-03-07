-- ============================================================
-- Cashflow Clarity - MySQL Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS cashflow_clarity
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cashflow_clarity;

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email                VARCHAR(255) NOT NULL UNIQUE,
  password_hash        VARCHAR(255) NOT NULL,
  full_name            VARCHAR(255),
  company_name         VARCHAR(255),
  company_street       VARCHAR(255),
  company_zipcode      VARCHAR(20),
  company_city         VARCHAR(100),
  company_vat_number   VARCHAR(50),
  company_phone        VARCHAR(50),
  company_phone_prefix VARCHAR(10) DEFAULT '+32',
  company_currency     VARCHAR(10) DEFAULT 'EUR',
  company_country      VARCHAR(100) DEFAULT 'Belgium',
  created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- EXPENSE CATEGORIES
-- ============================================================
CREATE TABLE IF NOT EXISTS expense_categories (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id      INT UNSIGNED NOT NULL,
  name         VARCHAR(255) NOT NULL,
  description  TEXT,
  is_active    TINYINT(1) NOT NULL DEFAULT 1,
  flow_type    ENUM('Cash In','Cash Out','Adjustment') NOT NULL DEFAULT 'Cash Out',
  type_name    VARCHAR(255),
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- TRANSACTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS transactions (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  month           VARCHAR(20) NOT NULL,
  month_number    TINYINT UNSIGNED NOT NULL,
  year            SMALLINT UNSIGNED NOT NULL,
  type            VARCHAR(100) NOT NULL,
  category        VARCHAR(100),
  description     TEXT,
  amount_excl_vat DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  vat_rate        DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  vat_amount      DECIMAL(15,2) GENERATED ALWAYS AS (amount_excl_vat * vat_rate / 100) STORED,
  amount_incl_vat DECIMAL(15,2) GENERATED ALWAYS AS (amount_excl_vat + (amount_excl_vat * vat_rate / 100)) STORED,
  vat_status      VARCHAR(50) DEFAULT 'not applicable',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_year         (user_id, year),
  INDEX idx_user_year_month   (user_id, year, month_number)
);

--- Trigger 


DELIMITER $$

CREATE TRIGGER trg_transactions_after_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN

INSERT INTO cashflow_entries (
    user_id,
    month,
    month_number,
    year,
    cash_in,
    cash_out
)
SELECT
    NEW.user_id,
    NEW.month,
    NEW.month_number,
    NEW.year,
    SUM(CASE WHEN type = 'cash in' THEN amount_incl_vat ELSE 0 END),
    SUM(CASE WHEN type = 'cash out' THEN amount_incl_vat ELSE 0 END)
FROM transactions
WHERE
    user_id = NEW.user_id
    AND year = NEW.year
    AND month_number = NEW.month_number

ON DUPLICATE KEY UPDATE
    cash_in = VALUES(cash_in),
    cash_out = VALUES(cash_out);

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_transactions_after_update
AFTER UPDATE ON transactions
FOR EACH ROW
BEGIN

/* ---------- RECALCULATE OLD PERIOD ---------- */

UPDATE cashflow_entries c
JOIN (
    SELECT
        user_id,
        year,
        month_number,
        SUM(CASE WHEN type = 'cash in' THEN amount_incl_vat ELSE 0 END) AS cash_in,
        SUM(CASE WHEN type = 'cash out' THEN amount_incl_vat ELSE 0 END) AS cash_out
    FROM transactions
    WHERE
        user_id = OLD.user_id
        AND year = OLD.year
        AND month_number = OLD.month_number
    GROUP BY user_id, year, month_number
) t
ON c.user_id = t.user_id
AND c.year = t.year
AND c.month_number = t.month_number
SET
    c.cash_in = IFNULL(t.cash_in,0),
    c.cash_out = IFNULL(t.cash_out,0);


/* ---------- RECALCULATE NEW PERIOD ---------- */

UPDATE cashflow_entries c
JOIN (
    SELECT
        user_id,
        year,
        month_number,
        SUM(CASE WHEN type = 'cash in' THEN amount_incl_vat ELSE 0 END) AS cash_in,
        SUM(CASE WHEN type = 'cash out' THEN amount_incl_vat ELSE 0 END) AS cash_out
    FROM transactions
    WHERE
        user_id = NEW.user_id
        AND year = NEW.year
        AND month_number = NEW.month_number
    GROUP BY user_id, year, month_number
) t
ON c.user_id = t.user_id
AND c.year = t.year
AND c.month_number = t.month_number
SET
    c.cash_in = IFNULL(t.cash_in,0),
    c.cash_out = IFNULL(t.cash_out,0);

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_transactions_after_delete
AFTER DELETE ON transactions
FOR EACH ROW
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM transactions
    WHERE
        user_id = OLD.user_id
        AND year = OLD.year
        AND month_number = OLD.month_number
) THEN

    DELETE FROM cashflow_entries
    WHERE
        user_id = OLD.user_id
        AND year = OLD.year
        AND month_number = OLD.month_number;

ELSE

    UPDATE cashflow_entries c
    JOIN (
        SELECT
            user_id,
            year,
            month_number,
            SUM(CASE WHEN type = 'cash in' THEN amount_incl_vat ELSE 0 END) AS cash_in,
            SUM(CASE WHEN type = 'cash out' THEN amount_incl_vat ELSE 0 END) AS cash_out
        FROM transactions
        WHERE
            user_id = OLD.user_id
            AND year = OLD.year
            AND month_number = OLD.month_number
        GROUP BY user_id, year, month_number
    ) t
    ON c.user_id = t.user_id
    AND c.year = t.year
    AND c.month_number = t.month_number

    SET
        c.cash_in = IFNULL(t.cash_in,0),
        c.cash_out = IFNULL(t.cash_out,0);

END IF;

END$$

DELIMITER ;


CREATE INDEX idx_transactions_cashflow
ON transactions (user_id, year, month_number, type);

-- ============================================================
-- CASHFLOW ADJUSTMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS cashflow_adjustments (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id           INT UNSIGNED NOT NULL,
  month             VARCHAR(20) NOT NULL,
  month_number      TINYINT UNSIGNED NOT NULL,
  year              SMALLINT UNSIGNED NOT NULL,
  adjustment_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  notes             TEXT,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_year_month (user_id, year, month_number)
);

-- ============================================================
-- TREASURY RULES
-- ============================================================
CREATE TABLE IF NOT EXISTS treasury_rules (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id           INT UNSIGNED NOT NULL UNIQUE,
  run_percentage    DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  pay_percentage    DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  grow_percentage   DECIMAL(5,2) NOT NULL DEFAULT 30.00,
  pay_cap           DECIMAL(15,2) DEFAULT NULL,
  currency          VARCHAR(10) NOT NULL DEFAULT 'EUR',
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- TREASURY SETTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS treasury_settings (
  id                         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id                    INT UNSIGNED NOT NULL UNIQUE,
  vat_exemption_scheme       TINYINT(1) NOT NULL DEFAULT 0,
  run_percentage             DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  pay_percentage             DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  pay_cap                    DECIMAL(15,2) DEFAULT 0.00,
  grow_percentage            DECIMAL(5,2) NOT NULL DEFAULT 30.00,
  invest_enabled             TINYINT(1) NOT NULL DEFAULT 1,
  invest_min_months_positive INT UNSIGNED NOT NULL DEFAULT 3,
  currency                   VARCHAR(10) NOT NULL DEFAULT 'EUR',
  created_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- REVIEWED NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS reviewed_notifications (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id           INT UNSIGNED NOT NULL,
  year              SMALLINT UNSIGNED NOT NULL,
  notification_type VARCHAR(100) NOT NULL,
  month             VARCHAR(20),
  reviewed_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_year (user_id, year)
);

-- ============================================================
-- CASHFLOW ENTRIES (legacy sync table used in DataEntry page)
-- ============================================================
CREATE TABLE IF NOT EXISTS cashflow_entries (
  id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id            INT UNSIGNED NOT NULL,
  month              VARCHAR(20) NOT NULL,
  month_number       TINYINT UNSIGNED NOT NULL,
  year               SMALLINT UNSIGNED NOT NULL,
  cash_in            DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  cash_out           DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  expense_categories JSON,
  notes              TEXT,
  created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_year_month (user_id, year, month_number)
);

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER $$

-- Auto-create treasury_rules and treasury_settings when a new user registers
CREATE TRIGGER trg_after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT IGNORE INTO treasury_rules (user_id) VALUES (NEW.id);
  INSERT IGNORE INTO treasury_settings (user_id) VALUES (NEW.id);
END$$

-- Keep updated_at fresh on transactions
CREATE TRIGGER trg_transactions_before_update
BEFORE UPDATE ON transactions
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Keep updated_at fresh on cashflow_adjustments
CREATE TRIGGER trg_cashflow_adjustments_before_update
BEFORE UPDATE ON cashflow_adjustments
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Keep updated_at fresh on expense_categories
CREATE TRIGGER trg_expense_categories_before_update
BEFORE UPDATE ON expense_categories
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Keep updated_at fresh on treasury_rules
CREATE TRIGGER trg_treasury_rules_before_update
BEFORE UPDATE ON treasury_rules
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Keep updated_at fresh on treasury_settings
CREATE TRIGGER trg_treasury_settings_before_update
BEFORE UPDATE ON treasury_settings
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

-- Keep updated_at fresh on cashflow_entries
CREATE TRIGGER trg_cashflow_entries_before_update
BEFORE UPDATE ON cashflow_entries
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- ============================================================
-- SUBSCRIPTIONS (for subscription gate / checkout flow)
-- ============================================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id              INT UNSIGNED NOT NULL,
  user_email           VARCHAR(255) NOT NULL,
  plan                 VARCHAR(50) NOT NULL,
  status               ENUM('active', 'cancelled', 'grace_period', 'blocked') NOT NULL DEFAULT 'active',
  current_period_end    DATETIME,
  grace_period_end      DATETIME,
  external_id           VARCHAR(255),
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_subscription (user_id),
  INDEX idx_user_email (user_email),
  INDEX idx_status (status)
);

-- ============================================================
-- CHECKOUT SESSIONS (optional: track checkout redirect URLs)
-- ============================================================
CREATE TABLE IF NOT EXISTS checkout_sessions (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id      INT UNSIGNED NOT NULL,
  plan         VARCHAR(50) NOT NULL,
  success_url  VARCHAR(512),
  cancel_url   VARCHAR(512),
  external_id  VARCHAR(255),
  status       VARCHAR(20) DEFAULT 'pending',
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_created (user_id, created_at)
);

-- ============================================================
-- SUBSCRIPTIONS - seed for test users
-- ============================================================
INSERT INTO subscriptions (user_id, user_email, plan, status, current_period_end, grace_period_end)
VALUES
  (1, 'test@cashflow.local', 'standard', 'active', NULL, NULL),
  (2, 'autotest@cashflow.local', 'standard', 'active', NULL, NULL)
ON DUPLICATE KEY UPDATE user_email = VALUES(user_email), plan = VALUES(plan), status = VALUES(status);

-- ============================================================
-- DEFAULT EXPENSE CATEGORIES (inserted per user via app seed)
-- These are inserted after user registration by the app
-- ============================================================
