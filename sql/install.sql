-- World of Freedom Lottery - Database Setup
-- Führe dieses SQL in deiner Datenbank aus

CREATE TABLE IF NOT EXISTS `wof_lottery_tickets` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `charid` int(11) NOT NULL,
    `identifier` varchar(50) NOT NULL,
    `ticket_number` int(11) NOT NULL,
    `draw_date` date NOT NULL,
    `bought_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `draw_date` (`draw_date`),
    KEY `charid` (`charid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `wof_lottery_draws` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `draw_date` date NOT NULL UNIQUE,
    `jackpot` decimal(10,2) NOT NULL DEFAULT 0.00,
    `total_tickets` int(11) NOT NULL DEFAULT 0,
    `winner_charid` int(11) DEFAULT NULL,
    `winner_identifier` varchar(50) DEFAULT NULL,
    `winner_name` varchar(100) DEFAULT NULL,
    `winning_ticket` int(11) DEFAULT NULL,
    `claimed` tinyint(1) DEFAULT 0,
    `drawn_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `wof_lottery_jackpot` (
    `id` int(11) NOT NULL DEFAULT 1,
    `current_jackpot` decimal(10,2) NOT NULL DEFAULT 50.00,
    `last_update` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `wof_lottery_jackpot` (`id`, `current_jackpot`) VALUES (1, 50.00);