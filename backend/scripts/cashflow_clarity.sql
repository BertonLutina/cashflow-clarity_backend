-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : sam. 07 mars 2026 à 20:05
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cashflow_clarity`
--

-- --------------------------------------------------------

--
-- Structure de la table `cashflow_adjustments`
--

CREATE TABLE `cashflow_adjustments` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `month` varchar(20) NOT NULL,
  `month_number` tinyint(3) UNSIGNED NOT NULL,
  `year` smallint(5) UNSIGNED NOT NULL,
  `adjustment_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Déclencheurs `cashflow_adjustments`
--
DELIMITER $$
CREATE TRIGGER `trg_cashflow_adjustments_before_update` BEFORE UPDATE ON `cashflow_adjustments` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `cashflow_entries`
--

CREATE TABLE `cashflow_entries` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `month` varchar(20) NOT NULL,
  `month_number` tinyint(3) UNSIGNED NOT NULL,
  `year` smallint(5) UNSIGNED NOT NULL,
  `cash_in` decimal(15,2) NOT NULL DEFAULT 0.00,
  `cash_out` decimal(15,2) NOT NULL DEFAULT 0.00,
  `expense_categories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`expense_categories`)),
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Déclencheurs `cashflow_entries`
--
DELIMITER $$
CREATE TRIGGER `trg_cashflow_entries_before_update` BEFORE UPDATE ON `cashflow_entries` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `checkout_sessions`
--

CREATE TABLE `checkout_sessions` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `plan` varchar(50) NOT NULL,
  `success_url` varchar(512) DEFAULT NULL,
  `cancel_url` varchar(512) DEFAULT NULL,
  `external_id` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `flow_type` enum('Cash In','Cash Out','Adjustment') NOT NULL DEFAULT 'Cash Out',
  `type_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `expense_categories`
--
DELIMITER $$
CREATE TRIGGER `trg_expense_categories_before_update` BEFORE UPDATE ON `expense_categories` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `reviewed_notifications`
--

CREATE TABLE `reviewed_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `year` smallint(5) UNSIGNED NOT NULL,
  `notification_type` varchar(100) NOT NULL,
  `month` varchar(20) DEFAULT NULL,
  `reviewed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `plan` varchar(50) NOT NULL,
  `status` enum('active','cancelled','grace_period','blocked') NOT NULL DEFAULT 'active',
  `current_period_end` datetime DEFAULT NULL,
  `grace_period_end` datetime DEFAULT NULL,
  `external_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- --------------------------------------------------------

--
-- Structure de la table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `month` varchar(20) NOT NULL,
  `month_number` tinyint(3) UNSIGNED NOT NULL,
  `year` smallint(5) UNSIGNED NOT NULL,
  `type` varchar(100) NOT NULL,
  `flow_type` text NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `amount_excl_vat` decimal(15,2) NOT NULL DEFAULT 0.00,
  `vat_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `vat_amount` decimal(15,2) GENERATED ALWAYS AS (`amount_excl_vat` * `vat_rate` / 100) STORED,
  `amount_incl_vat` decimal(15,2) GENERATED ALWAYS AS (`amount_excl_vat` + `amount_excl_vat` * `vat_rate` / 100) STORED,
  `vat_status` varchar(50) DEFAULT 'not applicable',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
--
-- Déclencheurs `transactions`
--
DELIMITER $$
CREATE TRIGGER `trg_transactions_after_delete` AFTER DELETE ON `transactions` FOR EACH ROW BEGIN

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
    SUM(CASE WHEN flow_type = 'Cash In' THEN amount_incl_vat ELSE 0 END),
    SUM(CASE WHEN flow_type = 'Cash Out' THEN amount_incl_vat ELSE 0 END)
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

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transactions_after_insert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN

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
    MAX(month) AS month,
    NEW.month_number,
    NEW.year,
    SUM(CASE WHEN flow_type = 'Cash In' THEN amount_incl_vat ELSE 0 END),
    SUM(CASE WHEN flow_type = 'Cash Out' THEN amount_incl_vat ELSE 0 END)
FROM transactions
WHERE
    user_id = NEW.user_id
    AND year = NEW.year
    AND month_number = NEW.month_number
GROUP BY user_id, month_number, year

ON DUPLICATE KEY UPDATE
    cash_in = VALUES(cash_in),
    cash_out = VALUES(cash_out);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transactions_after_update` AFTER UPDATE ON `transactions` FOR EACH ROW BEGIN

/* ---------- RECALCULATE OLD PERIOD ---------- */

UPDATE cashflow_entries c
JOIN (
    SELECT
        user_id,
        year,
        month_number,
        SUM(CASE WHEN flow_type = 'Cash In' THEN amount_incl_vat ELSE 0 END) AS cash_in,
    SUM(CASE WHEN flow_type = 'Cash Out' THEN amount_incl_vat ELSE 0 END) AS cash_out
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
        SUM(CASE WHEN flow_type = 'Cash In' THEN amount_incl_vat ELSE 0 END) AS cash_in,
    SUM(CASE WHEN flow_type = 'Cash Out' THEN amount_incl_vat ELSE 0 END) AS cash_out
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

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_transactions_before_update` BEFORE UPDATE ON `transactions` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `treasury_rules`
--

CREATE TABLE `treasury_rules` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `run_percentage` decimal(5,2) NOT NULL DEFAULT 50.00,
  `pay_percentage` decimal(5,2) NOT NULL DEFAULT 20.00,
  `grow_percentage` decimal(5,2) NOT NULL DEFAULT 30.00,
  `pay_cap` decimal(15,2) DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'EUR',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `treasury_rules`
--
DELIMITER $$
CREATE TRIGGER `trg_treasury_rules_before_update` BEFORE UPDATE ON `treasury_rules` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `treasury_settings`
--

CREATE TABLE `treasury_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `vat_exemption_scheme` tinyint(1) NOT NULL DEFAULT 0,
  `run_percentage` decimal(5,2) NOT NULL DEFAULT 50.00,
  `pay_percentage` decimal(5,2) NOT NULL DEFAULT 20.00,
  `pay_cap` decimal(15,2) DEFAULT 0.00,
  `grow_percentage` decimal(5,2) NOT NULL DEFAULT 30.00,
  `invest_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `invest_min_months_positive` int(10) UNSIGNED NOT NULL DEFAULT 3,
  `currency` varchar(10) NOT NULL DEFAULT 'EUR',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Déclencheurs `treasury_settings`
--
DELIMITER $$
CREATE TRIGGER `trg_treasury_settings_before_update` BEFORE UPDATE ON `treasury_settings` FOR EACH ROW BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `company_street` varchar(255) DEFAULT NULL,
  `company_zipcode` varchar(20) DEFAULT NULL,
  `company_city` varchar(100) DEFAULT NULL,
  `company_vat_number` varchar(50) DEFAULT NULL,
  `company_phone` varchar(50) DEFAULT NULL,
  `company_phone_prefix` varchar(10) DEFAULT '+32',
  `company_currency` varchar(10) DEFAULT 'EUR',
  `company_country` varchar(100) DEFAULT 'Belgium',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `users` (default expense_categories for new users)
--
DELIMITER $$
CREATE TRIGGER `after_user_insert`
AFTER INSERT ON `users`
FOR EACH ROW
BEGIN
    INSERT INTO `expense_categories`
        (`user_id`, `name`, `description`, `is_active`, `flow_type`, `type_name`, `created_at`, `updated_at`)
    VALUES
        (NEW.id, 'Sales', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', NOW(), NOW()),
        (NEW.id, 'Consulting', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', NOW(), NOW()),
        (NEW.id, 'Revenu', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', NOW(), NOW()),
        (NEW.id, 'Administration et bureau', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Charges (électricité, gaz, eau)', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Déplacements et frais', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Dons', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Formation et conférences', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'IT', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Loyer', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Marketing', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Marchandises', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Consommables', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Mobilier et matériel', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Téléphone et Internet', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Autres dépenses', NULL, 1, 'Cash Out', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Frais bancaires', NULL, 1, 'Cash Out', 'Frais bancaires', NOW(), NOW()),
        (NEW.id, 'Cotisations sociales', NULL, 1, 'Cash Out', 'Cotisations sociales', NOW(), NOW()),
        (NEW.id, 'Investissement', NULL, 1, 'Adjustment', 'Investissement', NOW(), NOW()),
        (NEW.id, 'Cas de force majeure', NULL, 1, 'Adjustment', 'Cas de force majeure', NOW(), NOW()),
        (NEW.id, 'Top up RUN', NULL, 1, 'Adjustment', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Top up GROW', NULL, 1, 'Adjustment', 'Dépenses', NOW(), NOW()),
        (NEW.id, 'Décompte TVA', NULL, 1, 'Adjustment', 'Dépenses', NOW(), NOW());
END$$
DELIMITER ;

--
-- Déclencheurs `users` (treasury_rules + treasury_settings)
--
DELIMITER $$
CREATE TRIGGER `trg_after_user_insert` AFTER INSERT ON `users` FOR EACH ROW BEGIN
  INSERT INTO `treasury_rules` (`user_id`, `run_percentage`, `pay_percentage`, `grow_percentage`, `pay_cap`, `currency`, `created_at`, `updated_at`) VALUES
(NEW.id, 50.00, 20.00, 30.00, NULL, 'EUR', NOW(),NOW());
  INSERT IGNORE INTO `treasury_settings` (`user_id`, `vat_exemption_scheme`, `run_percentage`, `pay_percentage`, `pay_cap`, `grow_percentage`, `invest_enabled`, `invest_min_months_positive`, `currency`, `created_at`, `updated_at`) VALUES
(NEW.id, 0, 50.00, 20.00, 0.00, 30.00, 1, 3, 'EUR', NOW(),NOW());
END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `cashflow_adjustments`
--
ALTER TABLE `cashflow_adjustments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_year_month` (`user_id`,`year`,`month_number`);

--
-- Index pour la table `cashflow_entries`
--
ALTER TABLE `cashflow_entries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_year_month` (`user_id`,`year`,`month_number`);

--
-- Index pour la table `checkout_sessions`
--
ALTER TABLE `checkout_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_created` (`user_id`,`created_at`);

--
-- Index pour la table `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `reviewed_notifications`
--
ALTER TABLE `reviewed_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_year` (`user_id`,`year`);

--
-- Index pour la table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_subscription` (`user_id`),
  ADD KEY `idx_user_email` (`user_email`),
  ADD KEY `idx_status` (`status`);

--
-- Index pour la table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_year` (`user_id`,`year`),
  ADD KEY `idx_user_year_month` (`user_id`,`year`,`month_number`),
  ADD KEY `idx_transactions_cashflow` (`user_id`,`year`,`month_number`,`type`);

--
-- Index pour la table `treasury_rules`
--
ALTER TABLE `treasury_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Index pour la table `treasury_settings`
--
ALTER TABLE `treasury_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `cashflow_adjustments`
--
ALTER TABLE `cashflow_adjustments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `cashflow_entries`
--
ALTER TABLE `cashflow_entries`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT pour la table `checkout_sessions`
--
ALTER TABLE `checkout_sessions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT pour la table `reviewed_notifications`
--
ALTER TABLE `reviewed_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT pour la table `treasury_rules`
--
ALTER TABLE `treasury_rules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `treasury_settings`
--
ALTER TABLE `treasury_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `cashflow_adjustments`
--
ALTER TABLE `cashflow_adjustments`
  ADD CONSTRAINT `cashflow_adjustments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cashflow_entries`
--
ALTER TABLE `cashflow_entries`
  ADD CONSTRAINT `cashflow_entries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `checkout_sessions`
--
ALTER TABLE `checkout_sessions`
  ADD CONSTRAINT `checkout_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD CONSTRAINT `expense_categories_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `reviewed_notifications`
--
ALTER TABLE `reviewed_notifications`
  ADD CONSTRAINT `reviewed_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `treasury_rules`
--
ALTER TABLE `treasury_rules`
  ADD CONSTRAINT `treasury_rules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `treasury_settings`
--
ALTER TABLE `treasury_settings`
  ADD CONSTRAINT `treasury_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
