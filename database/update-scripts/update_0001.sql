--  postaviti ime baze na kojoj se vrse izmjene --
USE `dw`;
START  TRANSACTION;
CREATE TABLE `sys_db_history` (
	`id` INT(11) NOT NULL AUTO_INCREMENT ,
	`SCRIPT_AUTHOR`  VARCHAR(255)  CHARACTER SET 'cp1250' COLLATE 'cp1250_croatian_ci' NOT NULL,
	`SCRIPT_FILENAME` VARCHAR(255)  CHARACTER SET 'cp1250' COLLATE 'cp1250_croatian_ci' NOT NULL,
	`REPOSITORY_URL` VARCHAR(255)  CHARACTER SET 'cp1250' COLLATE 'cp1250_croatian_ci' NOT NULL,
	`DESCRIPTION` VARCHAR(255)  CHARACTER SET 'cp1250' COLLATE 'cp1250_croatian_ci' NOT NULL,
  PRIMARY KEY (`id`)
)
COMMENT='Tabela historije promjena na bazi i podacima preko update skripti'
COLLATE='cp1250_croatian_ci'
ENGINE=InnoDB;

ALTER TABLE `dw`.`dim_claim` 
ADD COLUMN `is_reactivated` VARCHAR(45) NULL AFTER `is_judical`,
ADD COLUMN `is_reserved` VARCHAR(45) NULL AFTER `is_reactivated`;

SET @Description = 'Dodata polja u dimenziju steta kako bi se moglo prikazivati jeli steta reaktivirana i jeli rezwervisana na 31.12 prethodne godine';
SET @RepositoryURL = 'https://bitbucket.org/mabazovic/saosig-bi/src/f68e25fe29811c0142a4615d310bca90a2ff2eb5/database/update-scripts/?at=master';
SET @FileName = 'Update_0001.sql';
SET @Author = 'mirza';
INSERT INTO sys_db_history(SCRIPT_AUTHOR, SCRIPT_FILENAME, REPOSITORY_URL, DESCRIPTION) VALUES(@Author, @FileName, @RepositoryURL, @Description);
COMMIT;
