use insurance_staging;
DROP TABLE IF EXISTS `map_branch`;
CREATE TABLE `map_branch` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sql_id` INT NULL,
  `dw_id` INT NULL,
  PRIMARY KEY (`id`));

DROP TABLE IF EXISTS `map_claim`;
  CREATE TABLE `map_claim` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sql_id` INT NULL,
  `dw_id` INT NULL,
  `unique_claim_number` VARCHAR(45) NULL,
  `claim_number` VARCHAR(45) NULL,
  PRIMARY KEY (`id`));

  ALTER TABLE `insurance_staging`.`map_claim` 
ADD UNIQUE INDEX `unique1` (`sql_id` ASC, `dw_id` ASC);
  
DROP TABLE IF EXISTS `map_insurance_type`;
  CREATE TABLE `map_insurance_type` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sql_id` INT NULL,
  `dw_id` INT NULL,
  PRIMARY KEY (`id`));

INSERT INTO map_branch(sql_id,dw_id) VALUES 
(NULL,1),
(1010356,2),
(1010359,3),
(1010362,4),
(1010365,5),
(1010368,6),
(NULL,7),
(1010374,8),
(1010377,9),
(1010380,10),
(1010383,11),
(1010386,12),
(1010389,13),
(1010392,14),
(1010395,15),
(1100514,16);

ALTER TABLE `insurance_staging`.`map_claim` 
ADD INDEX `unique_claim_number_index` (`unique_claim_number` ASC);

ALTER TABLE `insurance_staging`.`map_claim` 
ADD INDEX `sql_id_index` (`sql_id` ASC),
ADD INDEX `dw_id_index` (`dw_id` ASC);


ALTER TABLE `insurance_staging`.`map_claim` 
DROP INDEX `unique_claim_number_index` ;

