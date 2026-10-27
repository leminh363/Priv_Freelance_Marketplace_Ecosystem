SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mydb`;

-- Table: user profile
CREATE TABLE IF NOT EXISTS `user_account` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_account_email` (`email`)
) ENGINE=InnoDB;

-- Table: tests for freelancers 
CREATE TABLE IF NOT EXISTS `test` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `test_name` VARCHAR(255) NOT NULL,
  `test_link` VARCHAR(500) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_test_name` (`test_name`)
) ENGINE=InnoDB;

-- Table: freelancers' skills
CREATE TABLE IF NOT EXISTS `skill` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `skill_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_skill_name` (`skill_name`)
) ENGINE=InnoDB;

-- Table: company
CREATE TABLE IF NOT EXISTS `company` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `company_location` VARCHAR(255) NULL,
  `company_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- Table: payment type
CREATE TABLE IF NOT EXISTS `payment_type` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payment_type_name` (`type_name`)
) ENGINE=InnoDB;

-- Table: proposal status catalog & contract statuses
CREATE TABLE IF NOT EXISTS `status_catalog` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `status_name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_status_name` (`status_name`)
) ENGINE=InnoDB;

-- Table: Product duration ranges
CREATE TABLE IF NOT EXISTS `expected_duration` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `duration_text` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_duration_text` (`duration_text`)
) ENGINE=InnoDB;

-- Table: project complexity levels
CREATE TABLE IF NOT EXISTS `complexity` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `complexity_type` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_complexity_type` (`complexity_type`)
) ENGINE=InnoDB;

-- Table: freelancer profile
CREATE TABLE IF NOT EXISTS `freelancer` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `registration_date` DATE NULL,
  `user_account_id` BIGINT NOT NULL,
  `location` VARCHAR(255) NULL,
  `overview` TEXT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_freelancer_user_account` (`user_account_id`),
  CONSTRAINT `fk_freelancer_user_account`
    FOREIGN KEY (`user_account_id`) REFERENCES `user_account` (`id`)
) ENGINE=InnoDB;

-- Table: hire manager profile
CREATE TABLE IF NOT EXISTS `hire_manager` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_account_id` BIGINT NOT NULL,
  `registration_date` DATE NULL,
  `location` VARCHAR(255) NULL,
  `company_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_hire_manager_user_account` (`user_account_id`),
  CONSTRAINT `fk_hire_manager_user_account`
    FOREIGN KEY (`user_account_id`) REFERENCES `user_account` (`id`),
  CONSTRAINT `fk_hire_manager_company`
    FOREIGN KEY (`company_id`) REFERENCES `company` (`id`)
) ENGINE=InnoDB;

-- Table: test result
CREATE TABLE IF NOT EXISTS `test_result` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `freelancer_id` BIGINT NOT NULL,
  `test_id` BIGINT NOT NULL,
  `start_time` DATE NOT NULL,
  `end_time` DATE NULL,
  `test_result_link` TEXT NULL,
  `score` DECIMAL(5,2) NULL,
  `display_on_profile` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id`),
  KEY `idx_test_result_freelancer` (`freelancer_id`),
  KEY `idx_test_result_test` (`test_id`),
  CONSTRAINT `fk_test_result_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_test_result_test`
    FOREIGN KEY (`test_id`) REFERENCES `test` (`id`),
  CONSTRAINT `chk_test_result_score`
    CHECK (`score` IS NULL OR (`score` >= 0 AND `score` <= 100))
) ENGINE=InnoDB;

-- Table: freelancer's certification
CREATE TABLE IF NOT EXISTS `certification` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `certification_name` VARCHAR(255) NOT NULL,
  `freelancer_id` BIGINT NOT NULL,
  `provider` VARCHAR(255) NULL,
  `description` TEXT NULL,
  `date_earned` DATE NULL,
  `certification_link` TEXT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_certification_freelancer` (`freelancer_id`),
  CONSTRAINT `fk_certification_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`)
) ENGINE=InnoDB;

-- Table: a freelancer has skill (many to many)
CREATE TABLE IF NOT EXISTS `has_skill` (
  `freelancer_id` BIGINT NOT NULL,
  `skill_id` BIGINT NOT NULL,
  PRIMARY KEY (`freelancer_id`, `skill_id`),
  CONSTRAINT `fk_has_skill_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_has_skill_skill`
    FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`)
) ENGINE=InnoDB;

-- Table: job description
CREATE TABLE IF NOT EXISTS `job` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `hire_manager_id` BIGINT NOT NULL,
  `duration_id` BIGINT NOT NULL,
  `complexity_id` BIGINT NOT NULL,
  `description` TEXT NULL,
  `main_skill_id` BIGINT NOT NULL,
  `payment_type_id` BIGINT NOT NULL,
  `payment_amount` DECIMAL(10,2) NULL,
  `title` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_job_hire_manager` (`hire_manager_id`),
  KEY `idx_job_duration` (`duration_id`),
  KEY `idx_job_complexity` (`complexity_id`),
  KEY `idx_job_main_skill` (`main_skill_id`),
  KEY `idx_job_payment_type` (`payment_type_id`),
  CONSTRAINT `fk_job_hire_manager`
    FOREIGN KEY (`hire_manager_id`) REFERENCES `hire_manager` (`id`),
  CONSTRAINT `fk_job_duration`
    FOREIGN KEY (`duration_id`) REFERENCES `expected_duration` (`id`),
  CONSTRAINT `fk_job_complexity`
    FOREIGN KEY (`complexity_id`) REFERENCES `complexity` (`id`),
  CONSTRAINT `fk_job_main_skill`
    FOREIGN KEY (`main_skill_id`) REFERENCES `skill` (`id`),
  CONSTRAINT `fk_job_payment_type`
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`id`),
  CONSTRAINT `chk_job_payment_amount`
    CHECK (`payment_amount` IS NULL OR `payment_amount` >= 0)
) ENGINE=InnoDB;

-- Table: skills needed for a job
CREATE TABLE IF NOT EXISTS `job_require_skill` (
  `job_id` BIGINT NOT NULL,
  `skill_id` BIGINT NOT NULL,
  PRIMARY KEY (`job_id`, `skill_id`),
  CONSTRAINT `fk_job_require_skill_job`
    FOREIGN KEY (`job_id`) REFERENCES `job` (`id`),
  CONSTRAINT `fk_job_require_skill_skill`
    FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`)
) ENGINE=InnoDB;

-- Table: freelancer job proposals
CREATE TABLE IF NOT EXISTS `proposal` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `job_id` BIGINT NOT NULL,
  `freelancer_id` BIGINT NOT NULL,
  `proposal_time` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_type_id` BIGINT NOT NULL,
  `payment_amount` DECIMAL(10,2) NOT NULL,
  `current_proposal_status_id` BIGINT NOT NULL,
  `client_grade` DECIMAL(2,1) NULL,
  `client_comment` TEXT NULL,
  `freelancer_comment` TEXT NULL,
  `freelancer_grade` DECIMAL(2,1) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_proposal_job` (`job_id`),
  KEY `idx_proposal_freelancer` (`freelancer_id`),
  KEY `idx_proposal_payment_type` (`payment_type_id`),
  KEY `idx_proposal_status` (`current_proposal_status_id`),
  CONSTRAINT `fk_proposal_job`
    FOREIGN KEY (`job_id`) REFERENCES `job` (`id`),
  CONSTRAINT `fk_proposal_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_proposal_payment_type`
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`id`),
  CONSTRAINT `fk_proposal_status`
    FOREIGN KEY (`current_proposal_status_id`) REFERENCES `status_catalog` (`id`),
  CONSTRAINT `chk_proposal_client_grade`
    CHECK (`client_grade` IS NULL OR (`client_grade` >= 0.0 AND `client_grade` <= 5.0)),
  CONSTRAINT `chk_proposal_freelancer_grade`
    CHECK (`freelancer_grade` IS NULL OR (`freelancer_grade` >= 0.0 AND `freelancer_grade` <= 5.0)),
  CONSTRAINT `chk_proposal_payment_amount`
    CHECK (`payment_amount` >= 0)
) ENGINE=InnoDB;

-- Table: contracts between freelancers and companies
CREATE TABLE IF NOT EXISTS `contract` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `proposal_id` BIGINT NOT NULL,
  `company_id` BIGINT NOT NULL,
  `freelancer_id` BIGINT NOT NULL,
  `start_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` TIMESTAMP NULL,
  `payment_type_id` BIGINT NOT NULL,
  `payment_amount` DECIMAL(10,2) NOT NULL,
  `current_contract_status_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_contract_proposal` (`proposal_id`),
  KEY `idx_contract_company` (`company_id`),
  KEY `idx_contract_freelancer` (`freelancer_id`),
  KEY `idx_contract_payment_type` (`payment_type_id`),
  KEY `idx_contract_status` (`current_contract_status_id`),
  CONSTRAINT `fk_contract_proposal`
    FOREIGN KEY (`proposal_id`) REFERENCES `proposal` (`id`),
  CONSTRAINT `fk_contract_company`
    FOREIGN KEY (`company_id`) REFERENCES `company` (`id`),
  CONSTRAINT `fk_contract_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_contract_payment_type`
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`id`),
  CONSTRAINT `fk_contract_status`
    FOREIGN KEY (`current_contract_status_id`) REFERENCES `status_catalog` (`id`),
  CONSTRAINT `chk_contract_payment_amount`
    CHECK (`payment_amount` >= 0)
) ENGINE=InnoDB;

-- Table: work sessions belonging to contracts
CREATE TABLE IF NOT EXISTS `work_session` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `contract_id` BIGINT NOT NULL,
  `start_time` TIMESTAMP NULL,
  `end_time` TIMESTAMP NULL,
  PRIMARY KEY (`id`),
  KEY `idx_work_session_contract` (`contract_id`),
  CONSTRAINT `fk_work_session_contract`
    FOREIGN KEY (`contract_id`) REFERENCES `contract` (`id`)
) ENGINE=InnoDB;

-- Table: messages between freelancers and hiring managers
CREATE TABLE IF NOT EXISTS `message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `freelancer_id` BIGINT NOT NULL,
  `hire_manager_id` BIGINT NOT NULL,
  `message_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message_text` TEXT NULL,
  `proposal_id` BIGINT NOT NULL,
  `proposal_status_catalog_id` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_message_freelancer` (`freelancer_id`),
  KEY `idx_message_hire_manager` (`hire_manager_id`),
  KEY `idx_message_proposal` (`proposal_id`),
  KEY `idx_message_status` (`proposal_status_catalog_id`),
  CONSTRAINT `fk_message_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_message_hire_manager`
    FOREIGN KEY (`hire_manager_id`) REFERENCES `hire_manager` (`id`),
  CONSTRAINT `fk_message_proposal`
    FOREIGN KEY (`proposal_id`) REFERENCES `proposal` (`id`),
  CONSTRAINT `fk_message_status`
    FOREIGN KEY (`proposal_status_catalog_id`) REFERENCES `status_catalog` (`id`)
) ENGINE=InnoDB;

-- Table: attachment information for messages
CREATE TABLE IF NOT EXISTS `attachment` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `message_id` BIGINT NOT NULL,
  `attachment_link` TEXT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_attachment_message` (`message_id`),
  CONSTRAINT `fk_attachment_message`
    FOREIGN KEY (`message_id`) REFERENCES `message` (`id`)
) ENGINE=InnoDB;

-- Table: stores projects in the freelancer portfolio
CREATE TABLE IF NOT EXISTS `freelancer_portfolio` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `freelancer_id` BIGINT NOT NULL,
  `job_id` BIGINT NULL,
  `project_title` VARCHAR(255) NOT NULL,
  `project_description` TEXT NULL,
  `project_url` VARCHAR(500) NULL,
  `completed_date` DATE NULL,
  PRIMARY KEY (`id`),
  KEY `idx_portfolio_freelancer` (`freelancer_id`),
  KEY `idx_portfolio_job` (`job_id`),
  CONSTRAINT `fk_portfolio_freelancer`
    FOREIGN KEY (`freelancer_id`) REFERENCES `freelancer` (`id`),
  CONSTRAINT `fk_portfolio_job`
    FOREIGN KEY (`job_id`) REFERENCES `job` (`id`)
) ENGINE=InnoDB;