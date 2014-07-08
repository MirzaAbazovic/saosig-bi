ALTER TABLE `insurance_dw`.`dim_claim` 
CHANGE COLUMN `claim_no` `unique_claim_number` VARCHAR(50) CHARACTER SET 'latin2' COLLATE 'latin2_croatian_ci' NOT NULL ;
ALTER TABLE `insurance_dw`.`dim_claim` 
ADD UNIQUE INDEX `unique_claim_number_UNIQUE` (`unique_claim_number` ASC);

