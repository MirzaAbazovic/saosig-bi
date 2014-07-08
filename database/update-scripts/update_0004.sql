ALTER TABLE `insurance_dw`.`dim_claim` 
ADD COLUMN `claim_number` VARCHAR(45) NULL AFTER `claim_key`;