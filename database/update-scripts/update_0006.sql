ALTER TABLE `insurance_dw`.`dim_claim` 
CHANGE COLUMN `claim_id` `claim_id` INT(11) NOT NULL AUTO_INCREMENT ;

ALTER TABLE `insurance_dw`.`fact_claim` 
CHANGE COLUMN `fact_claim_id` `fact_claim_id` INT(11) NOT NULL AUTO_INCREMENT ;


ALTER TABLE `insurance_dw`.`dim_claim` 
DROP INDEX `unique_claim_number_UNIQUE` ;

