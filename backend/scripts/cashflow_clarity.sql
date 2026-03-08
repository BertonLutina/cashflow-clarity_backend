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
-- Déchargement des données de la table `cashflow_adjustments`
--

INSERT INTO `cashflow_adjustments` (`id`, `user_id`, `month`, `month_number`, `year`, `adjustment_amount`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 'January', 1, 2026, 500.00, NULL, '2026-02-22 10:20:04', '2026-02-22 10:20:04');

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
-- Déchargement des données de la table `cashflow_entries`
--

INSERT INTO `cashflow_entries` (`id`, `user_id`, `month`, `month_number`, `year`, `cash_in`, `cash_out`, `expense_categories`, `notes`, `created_at`, `updated_at`) VALUES
(1, 2, 'January', 1, 2026, 1210.00, 242.00, '[]', NULL, '2026-02-22 10:20:04', '2026-02-22 10:20:04'),
(2, 1, 'January', 1, 2026, 4000.00, 5999.00, '[]', '', '2026-02-22 10:35:48', '2026-03-06 21:51:20'),
(3, 1, 'February', 2, 2026, 8470.00, 0.00, '[]', '', '2026-03-01 19:26:24', '2026-03-06 21:51:20'),
(4, 4, 'February', 2, 2025, 1210.00, 200.00, '[]', '', '2026-03-01 21:34:52', '2026-03-06 21:51:20'),
(5, 1, 'January', 1, 2025, 1000.00, 1223.00, '[]', '', '2026-03-05 15:26:34', '2026-03-06 21:51:20'),
(6, 1, 'March', 3, 2025, 4356.00, 5234.61, '[]', '', '2026-03-05 15:26:34', '2026-03-06 21:51:20'),
(7, 1, 'April', 4, 2025, 0.00, 1545.00, '[]', '', '2026-03-05 15:26:34', '2026-03-06 21:51:20'),
(9, 1, 'February', 2, 2025, 3388.00, 1075.00, '[]', '', '2026-03-05 15:30:46', '2026-03-06 21:51:20'),
(11, 1, 'May', 5, 2025, 3200.00, 1125.00, '[]', '', '2026-03-05 15:33:02', '2026-03-06 21:51:20'),
(12, 1, 'June', 6, 2025, 4496.00, 375.00, '[]', '', '2026-03-05 15:34:17', '2026-03-06 21:51:20'),
(13, 1, 'July', 7, 2025, 3751.00, 1428.75, '[]', '', '2026-03-05 15:35:16', '2026-03-06 21:51:20'),
(14, 1, 'August', 8, 2025, 3630.00, 1161.50, '[]', '', '2026-03-05 15:36:37', '2026-03-06 21:51:20'),
(15, 1, 'September', 9, 2025, 4114.00, 1275.00, '[]', '', '2026-03-05 15:37:43', '2026-03-06 21:51:20'),
(16, 1, 'October', 10, 2025, 4598.00, 1325.00, '[]', '', '2026-03-05 15:38:32', '2026-03-06 21:51:20'),
(17, 1, 'November', 11, 2025, 4477.00, 1271.00, '[]', '', '2026-03-05 15:39:37', '2026-03-06 21:51:20'),
(18, 1, 'December', 12, 2025, 4719.00, 1327.00, '[]', '', '2026-03-05 15:41:01', '2026-03-06 21:51:20');

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

--
-- Déchargement des données de la table `checkout_sessions`
--

INSERT INTO `checkout_sessions` (`id`, `user_id`, `plan`, `success_url`, `cancel_url`, `external_id`, `status`, `created_at`) VALUES
(1, 4, 'pro', 'http://localhost:5173/CashflowDashboard', 'http://localhost:5173/Subscribe', 'cs_test_a1dZ6YBpweKhrYfV9KmsQsaZicHW9cygf5IdO81AhOllGgxlcUymOBvcVe', 'pending', '2026-03-01 21:27:45');

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


DELIMITER $$

CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO expense_categories 
        (user_id, name, description, is_active, flow_type, type_name, created_at, updated_at)
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
-- Déchargement des données de la table `expense_categories`
--

INSERT INTO `expense_categories` (`id`, `user_id`, `name`, `description`, `is_active`, `flow_type`, `type_name`, `created_at`, `updated_at`) VALUES
(1, 1, 'Sales', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(2, 1, 'Consulting', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(3, 1, 'Revenu', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(4, 1, 'Administration et bureau', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(5, 1, 'Charges (électricité, gaz, eau)', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(6, 1, 'Déplacements et frais', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(7, 1, 'Dons', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(8, 1, 'Formation et conférences', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(9, 1, 'IT', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(10, 1, 'Loyer', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(11, 1, 'Marketing', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(12, 1, 'Marchandises', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(13, 1, 'Consommables', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(14, 1, 'Mobilier et matériel', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(15, 1, 'Téléphone et Internet', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(16, 1, 'Autres dépenses', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(17, 1, 'Frais bancaires', NULL, 1, 'Cash Out', 'Frais bancaires', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(18, 1, 'Cotisations sociales', NULL, 1, 'Cash Out', 'Cotisations sociales', '2026-02-22 10:18:44', '2026-03-01 22:14:25'),
(19, 1, 'Investissement', NULL, 1, 'Adjustment', 'Investissement', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(20, 1, 'Cas de force majeure', NULL, 1, 'Adjustment', 'Cas de force majeure', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(21, 1, 'Top up RUN', NULL, 1, 'Adjustment', 'Top up RUN', '2026-02-22 10:18:44', '2026-03-06 15:49:18'),
(22, 1, 'Top up GROW', NULL, 1, 'Adjustment', 'Top up GROW', '2026-02-22 10:18:44', '2026-03-06 15:49:26'),
(23, 1, 'Décompte TVA', NULL, 1, 'Adjustment', 'Décompte TVA', '2026-02-22 10:18:44', '2026-03-06 15:49:34'),
(26, 2, 'Revenu', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(27, 2, 'Administration et bureau', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(28, 2, 'Charges (électricité, gaz, eau)', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(29, 2, 'Déplacements et frais', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(30, 2, 'Dons', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(31, 2, 'Formation et conférences', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(32, 2, 'IT', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(33, 2, 'Loyer', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(34, 2, 'Marketing', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(35, 2, 'Marchandises', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(36, 2, 'Consommables', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(37, 2, 'Mobilier et matériel', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(38, 2, 'Téléphone et Internet', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(39, 2, 'Autres dépenses', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(40, 2, 'Frais bancaires', NULL, 1, 'Cash Out', 'Frais bancaires', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(41, 2, 'Cotisations sociales', NULL, 1, 'Cash Out', 'Cotisations', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(42, 2, 'Investissement', NULL, 1, 'Adjustment', 'Investissement', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(43, 2, 'Cas de force majeure', NULL, 1, 'Adjustment', 'Cas de force majeure', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(44, 2, 'Top up RUN', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(45, 2, 'Top up GROW', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(46, 2, 'Décompte TVA', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(47, 3, 'Sales', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(48, 3, 'Consulting', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(49, 3, 'Revenu', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(50, 3, 'Administration et bureau', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(51, 3, 'Charges (électricité, gaz, eau)', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(52, 3, 'Déplacements et frais', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(53, 3, 'Dons', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(54, 3, 'Formation et conférences', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(55, 3, 'IT', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(56, 3, 'Loyer', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(57, 3, 'Marketing', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(58, 3, 'Marchandises', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(59, 3, 'Consommables', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(60, 3, 'Mobilier et matériel', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(61, 3, 'Téléphone et Internet', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(62, 3, 'Autres dépenses', NULL, 1, 'Cash Out', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(63, 3, 'Frais bancaires', NULL, 1, 'Cash Out', 'Frais bancaires', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(64, 3, 'Cotisations sociales', NULL, 1, 'Cash Out', 'Cotisations', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(65, 3, 'Investissement', NULL, 1, 'Adjustment', 'Investissement', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(66, 3, 'Cas de force majeure', NULL, 1, 'Adjustment', 'Cas de force majeure', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(67, 3, 'Top up RUN', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(68, 3, 'Top up GROW', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(69, 3, 'Décompte TVA', NULL, 1, 'Adjustment', 'Dépenses', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(70, 4, 'Sales', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(71, 4, 'Consulting', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(72, 4, 'Revenu', NULL, 1, 'Cash In', 'Revenu (Hors Taxe)', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(73, 4, 'Administration et bureau', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(74, 4, 'Charges (électricité, gaz, eau)', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(75, 4, 'Déplacements et frais', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(76, 4, 'Dons', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(77, 4, 'Formation et conférences', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(78, 4, 'IT', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(79, 4, 'Loyer', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(80, 4, 'Marketing', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(81, 4, 'Marchandises', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(82, 4, 'Consommables', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(83, 4, 'Mobilier et matériel', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(84, 4, 'Téléphone et Internet', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(85, 4, 'Autres dépenses', NULL, 1, 'Cash Out', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(86, 4, 'Frais bancaires', NULL, 1, 'Cash Out', 'Frais bancaires', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(87, 4, 'Cotisations sociales', NULL, 1, 'Cash Out', 'Cotisations', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(88, 4, 'Investissement', NULL, 1, 'Adjustment', 'Investissement', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(89, 4, 'Cas de force majeure', NULL, 1, 'Adjustment', 'Cas de force majeure', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(90, 4, 'Top up RUN', NULL, 1, 'Adjustment', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(91, 4, 'Top up GROW', NULL, 1, 'Adjustment', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(92, 4, 'Décompte TVA', NULL, 1, 'Adjustment', 'Dépenses', '2026-03-01 20:52:46', '2026-03-01 20:52:46'),
(93, 1, 'Subsides', '', 1, 'Cash In', 'Subsides', '2026-03-06 16:43:11', '2026-03-06 16:43:11'),
(94, 1, 'Frais facturables', '', 1, 'Cash Out', 'Frais facturables', '2026-03-06 21:06:36', '2026-03-06 21:06:36');

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

--
-- Déchargement des données de la table `reviewed_notifications`
--

INSERT INTO `reviewed_notifications` (`id`, `user_id`, `year`, `notification_type`, `month`, `reviewed_at`, `created_at`) VALUES
(1, 2, 2026, 'vat_reminder', 'January', '2026-02-22 10:20:04', '2026-02-22 10:20:04');

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

--
-- Déchargement des données de la table `subscriptions`
--

INSERT INTO `subscriptions` (`id`, `user_id`, `user_email`, `plan`, `status`, `current_period_end`, `grace_period_end`, `external_id`, `created_at`, `updated_at`) VALUES
(1, 1, 'test@cashflow.local', 'standard', 'active', NULL, NULL, NULL, '2026-02-27 02:17:54', '2026-02-27 02:17:54'),
(2, 2, 'autotest@cashflow.local', 'standard', 'active', NULL, NULL, NULL, '2026-02-27 02:17:54', '2026-02-27 02:17:54');

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
-- Déchargement des données de la table `transactions`
--

INSERT INTO `transactions` (`id`, `user_id`, `month`, `month_number`, `year`, `type`, `flow_type`, `category`, `description`, `amount_excl_vat`, `vat_rate`, `vat_status`, `created_at`, `updated_at`) VALUES
(2, 2, 'February', 2, 2026, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', NULL, 500.00, 21.00, 'not applicable', '2026-02-22 10:20:04', '2026-03-06 21:51:20'),
(3, 2, 'March', 3, 2026, 'Dépenses', 'Cash Out', 'IT', NULL, 200.00, 21.00, 'not applicable', '2026-02-22 10:20:04', '2026-03-06 21:51:20'),
(4, 1, 'January', 1, 2026, 'Subsides', 'Cash In', 'Subsides', 'Subside de test', 4000.00, 0.00, 'not applicable', '2026-02-22 10:33:53', '2026-03-06 21:51:20'),
(5, 1, 'January', 1, 2026, 'Dépenses', 'Cash Out', 'IT', 'Pc pour le developer', 3099.00, 0.00, 'not applicable', '2026-02-22 10:56:24', '2026-03-06 21:51:20'),
(6, 1, 'January', 1, 2026, 'Dépenses', 'Cash Out', 'Loyer', 'Loyer', 700.00, 0.00, 'not applicable', '2026-02-26 11:23:06', '2026-03-06 21:51:20'),
(7, 1, 'February', 2, 2026, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', 'Vents de voiture', 7000.00, 21.00, 'payable', '2026-02-27 08:57:53', '2026-03-06 21:51:20'),
(8, 1, 'January', 1, 2026, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 2000.00, 0.00, 'not applicable', '2026-02-27 08:58:36', '2026-03-06 21:51:20'),
(9, 4, 'February', 2, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 200.00, 0.00, 'not applicable', '2026-03-01 21:31:46', '2026-03-06 21:51:20'),
(10, 4, 'February', 2, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Consulting', '', 1000.00, 21.00, 'payable', '2026-03-01 21:33:31', '2026-03-06 21:51:20'),
(11, 1, 'January', 1, 2026, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 200.00, 0.00, 'not applicable', '2026-03-01 21:37:03', '2026-03-06 21:51:20'),
(12, 1, 'March', 3, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', 'Test', 3000.11, 0.00, 'not applicable', '2026-03-01 22:19:06', '2026-03-06 21:51:20'),
(13, 1, 'February', 2, 2026, 'Cas de force majeure', 'Adjustment', 'Cas de force majeure', '', 100.00, 21.00, 'to be reclaimed', '2026-03-01 22:25:27', '2026-03-06 21:51:20'),
(14, 1, 'February', 2, 2026, 'Investissement', 'Adjustment', 'Investissement', 'test', 300.00, 21.00, 'to be reclaimed', '2026-03-01 23:49:28', '2026-03-06 21:51:20'),
(15, 1, 'April', 4, 2025, 'Dépenses', 'Cash Out', 'Déplacements et frais', '', 1000.00, 12.00, 'to be reclaimed', '2026-03-05 15:23:39', '2026-03-06 21:51:20'),
(16, 1, 'April', 4, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 50.00, 0.00, 'not applicable', '2026-03-05 15:23:55', '2026-03-06 21:51:20'),
(17, 1, 'January', 1, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Consulting', '', 1000.00, 0.00, 'not applicable', '2026-03-05 15:25:00', '2026-03-06 21:51:20'),
(18, 1, 'January', 1, 2025, 'Dépenses', 'Cash Out', 'IT', '', 800.00, 6.00, 'to be reclaimed', '2026-03-05 15:25:59', '2026-03-06 21:51:20'),
(19, 1, 'February', 2, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 2800.00, 21.00, 'payable', '2026-03-05 15:28:53', '2026-03-06 21:51:20'),
(20, 1, 'February', 2, 2025, 'Dépenses', 'Cash Out', 'Loyer', '', 700.00, 0.00, 'not applicable', '2026-03-05 15:29:32', '2026-03-06 21:51:20'),
(22, 1, 'March', 3, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 3600.00, 21.00, 'payable', '2026-03-05 15:30:42', '2026-03-06 21:51:20'),
(23, 1, 'March', 3, 2025, 'Dépenses', 'Cash Out', 'IT', '', 2050.00, 9.00, 'to be reclaimed', '2026-03-05 15:32:23', '2026-03-06 21:51:20'),
(24, 1, 'May', 5, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 3200.00, 0.00, 'not applicable', '2026-03-05 15:33:02', '2026-03-06 21:51:20'),
(25, 1, 'May', 5, 2025, 'Dépenses', 'Cash Out', 'Loyer', '', 750.00, 0.00, 'not applicable', '2026-03-05 15:33:53', '2026-03-06 21:51:20'),
(26, 1, 'June', 6, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Consulting', '', 3600.00, 0.00, 'not applicable', '2026-03-05 15:34:17', '2026-03-06 21:51:20'),
(27, 1, 'June', 6, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Consulting', '', 800.00, 12.00, 'payable', '2026-03-05 15:34:43', '2026-03-06 21:51:20'),
(28, 1, 'July', 7, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Revenu', '', 3100.00, 21.00, 'payable', '2026-03-05 15:35:16', '2026-03-06 21:51:20'),
(29, 1, 'July', 7, 2025, 'Dépenses', 'Cash Out', 'Déplacements et frais', '', 700.00, 50.00, 'to be reclaimed', '2026-03-05 15:35:57', '2026-03-06 21:51:20'),
(30, 1, 'August', 8, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 3000.00, 21.00, 'payable', '2026-03-05 15:36:37', '2026-03-06 21:51:20'),
(31, 1, 'August', 8, 2025, 'Dépenses', 'Cash Out', 'Marketing', '', 650.00, 21.00, 'to be reclaimed', '2026-03-05 15:37:20', '2026-03-06 21:51:20'),
(32, 1, 'September', 9, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Consulting', '', 3400.00, 21.00, 'payable', '2026-03-05 15:37:43', '2026-03-06 21:51:20'),
(33, 1, 'September', 9, 2025, 'Dépenses', 'Cash Out', 'Dons', '', 900.00, 0.00, 'not applicable', '2026-03-05 15:38:05', '2026-03-06 21:51:20'),
(34, 1, 'October', 10, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Revenu', '', 3800.00, 21.00, 'payable', '2026-03-05 15:38:32', '2026-03-06 21:51:20'),
(35, 1, 'October', 10, 2025, 'Frais bancaires', 'Cash Out', 'Frais bancaires', '', 950.00, 0.00, 'not applicable', '2026-03-05 15:39:16', '2026-03-06 21:51:20'),
(36, 1, 'November', 11, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 3700.00, 21.00, 'payable', '2026-03-05 15:39:37', '2026-03-06 21:51:20'),
(37, 1, 'November', 11, 2025, 'Dépenses', 'Cash Out', 'Téléphone et Internet', '', 800.00, 12.00, 'to be reclaimed', '2026-03-05 15:40:38', '2026-03-06 21:51:20'),
(38, 1, 'December', 12, 2025, 'Revenu (Hors Taxe)', 'Cash In', 'Sales', '', 3900.00, 21.00, 'payable', '2026-03-05 15:41:01', '2026-03-06 21:51:20'),
(39, 1, 'December', 12, 2025, 'Dépenses', 'Cash Out', 'Consommables', '', 850.00, 12.00, 'to be reclaimed', '2026-03-05 15:41:40', '2026-03-06 21:51:20'),
(40, 1, 'January', 1, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:48:42', '2026-03-06 21:51:20'),
(41, 1, 'February', 2, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:49:19', '2026-03-06 21:51:20'),
(43, 1, 'April', 4, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:49:42', '2026-03-06 21:51:20'),
(44, 1, 'May', 5, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:49:55', '2026-03-06 21:51:20'),
(45, 1, 'June', 6, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:50:09', '2026-03-06 21:51:20'),
(46, 1, 'July', 7, 2025, 'Dépenses', 'Cash Out', 'IT', '', 375.00, 1.00, 'to be reclaimed', '2026-03-05 15:50:22', '2026-03-06 21:51:20'),
(47, 1, 'August', 8, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:50:34', '2026-03-06 21:51:20'),
(48, 1, 'September', 9, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:50:49', '2026-03-06 21:51:20'),
(49, 1, 'October', 10, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:51:04', '2026-03-06 21:51:20'),
(50, 1, 'November', 11, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:51:18', '2026-03-06 21:51:20'),
(51, 1, 'December', 12, 2025, 'Cotisations sociales', 'Cash Out', 'Cotisations sociales', '', 375.00, 0.00, 'not applicable', '2026-03-05 15:51:42', '2026-03-06 21:51:20');

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
    NEW.month,
    NEW.month_number,
    NEW.year,
    SUM(CASE WHEN NEW.flow_type = 'Cash In' THEN amount_incl_vat ELSE 0 END),
    SUM(CASE WHEN NEW.flow_type = 'Cash Out' THEN amount_incl_vat ELSE 0 END)
FROM transactions
WHERE
    user_id = NEW.user_id
    AND year = NEW.year
    AND month_number = NEW.month_number

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
-- Déchargement des données de la table `treasury_rules`
--

INSERT INTO `treasury_rules` (`id`, `user_id`, `run_percentage`, `pay_percentage`, `grow_percentage`, `pay_cap`, `currency`, `created_at`, `updated_at`) VALUES
(1, 1, 50.00, 20.00, 30.00, NULL, 'EUR', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(2, 2, 50.00, 20.00, 30.00, NULL, 'EUR', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(3, 3, 50.00, 20.00, 30.00, NULL, 'EUR', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(4, 4, 50.00, 20.00, 30.00, NULL, 'EUR', '2026-03-01 20:52:46', '2026-03-01 21:32:32');

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
-- Déchargement des données de la table `treasury_settings`
--

INSERT INTO `treasury_settings` (`id`, `user_id`, `vat_exemption_scheme`, `run_percentage`, `pay_percentage`, `pay_cap`, `grow_percentage`, `invest_enabled`, `invest_min_months_positive`, `currency`, `created_at`, `updated_at`) VALUES
(1, 1, 0, 50.00, 20.00, 0.00, 30.00, 1, 3, 'EUR', '2026-02-22 10:18:44', '2026-03-05 15:45:44'),
(2, 2, 0, 55.00, 25.00, 0.00, 20.00, 1, 3, 'EUR', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(3, 3, 0, 50.00, 20.00, 0.00, 30.00, 1, 3, 'EUR', '2026-02-26 22:40:39', '2026-02-26 22:40:39'),
(4, 4, 0, 50.00, 20.00, 0.00, 30.00, 1, 5, 'EUR', '2026-03-01 20:52:46', '2026-03-01 21:32:32');

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
  `company_name` varchar(255) DEFAULT NULL,
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
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `full_name`, `company_name`, `company_street`, `company_zipcode`, `company_city`, `company_vat_number`, `company_phone`, `company_phone_prefix`, `company_currency`, `company_country`, `created_at`, `updated_at`) VALUES
(1, 'test@cashflow.local', '$2a$12$b7A76BGwvrtFk/Gf7oFppuXxanpsELl8gnijLGUCUnzSvsUliB9W6', 'Test User', NULL, NULL, NULL, NULL, NULL, NULL, '+32', 'EUR', 'Belgium', '2026-02-22 10:18:44', '2026-02-22 10:18:44'),
(2, 'autotest@cashflow.local', '$2a$12$4ckEXTal4Qlo3EPtiL7vIO51GJt2G6msLpsLRdvHIwg8WSpxzU59a', 'Auto Test', 'Test Corp', NULL, NULL, NULL, NULL, NULL, '+32', 'EUR', 'Belgium', '2026-02-22 10:20:03', '2026-02-22 10:20:03'),
(3, 'logintest_1772142038595@test.local', '$2a$12$jCIMeH0K39959bl7BGL7/uaUd0Yl37NQKt0FSCI9GjdooAWot/BdG', 'Login Tester', 'Test Corp', NULL, NULL, 'Brussels', NULL, NULL, '+32', 'EUR', 'Belgium', '2026-02-26 22:40:39', '2026-02-26 22:40:40'),
(4, 'berton.lutina@hotmail.com', '$2a$12$KitKV7UI0bgwuPkRZ/y8OOSVv2yP2jqEQiF4sEf23mI3Yc.LCT.Py', 'Berton Lutina Mulamba', NULL, NULL, NULL, NULL, NULL, NULL, '+32', 'EUR', 'Belgium', '2026-03-01 20:52:46', '2026-03-01 20:52:46');

--
-- Déclencheurs `users`
--
DELIMITER $$
CREATE TRIGGER `trg_after_user_insert` AFTER INSERT ON `users` FOR EACH ROW BEGIN
  INSERT IGNORE INTO treasury_rules (user_id) VALUES (NEW.id);
  INSERT IGNORE INTO treasury_settings (user_id) VALUES (NEW.id);
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
