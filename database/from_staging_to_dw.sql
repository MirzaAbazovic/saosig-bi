DELIMITER $$
CREATE DEFINER=`am`@`localhost` PROCEDURE `paid_claims_to_dw`(IN dateFrom Datetime,IN dateTo Datetime)
BEGIN
-- insertuj nove stete u mapirajucu tabelu
INSERT INTO insurance_staging.map_claim(sql_id)
SELECT distinct claim_id as sql_id 
FROM insurance_staging.izv_analitika_po_isplatama 
WHERE claim_id  NOT IN (SELECT sql_id FROM insurance_staging.map_claim);

-- prvo popunjavamo dimenziju steta sa novim u mapiranim
INSERT INTO insurance_dw.dim_claim (claim_key)
SELECT sql_id FROM insurance_staging.map_claim WHERE dw_id is null;
UPDATE insurance_dw.dim_claim d
JOIN insurance_staging.izv_analitika_po_isplatama s ON d.claim_key=s.claim_id
SET unique_claim_number = CONCAT(tarifa,"-",LEFT(claimno, IF(LOCATE(" ", claimno)=0,LENGTH(claimno)+1,LOCATE(" ", claimno))-1)) ,
claim_number = claimNo,
is_pre_war = IF(PreWar=1,'Da','Ne'),
is_green_card= IF(GreenCard=1,'Da','Ne'),
is_judical = ProsecutionJudical ;

-- vrsimo update u map tabeli sa novim idjevima iz dimenzije kako bi imali mapiranje za fact_claim
UPDATE insurance_staging.map_claim m join insurance_dw.dim_claim d on m.sql_id = d.claim_key
SET m.dw_id=d.claim_id WHERE m.dw_id is null;

-- brisemo sve iz fact tabele za datume
DELETE FROM  insurance_dw.fact_claim WHERE dim_paid_time_id in
(SELECT time_id FROM insurance_dw.dim_time WHERE date BETWEEN dateFrom AND dateTo);

-- punimo fact claim koristeci map tabele 

INSERT INTO insurance_dw.fact_claim (dim_claim_id,dim_branch_id,dim_insurance_type_id,dim_paid_time_id,paid_amount_material,paid_amount_nonmaterial,paid_amount)
SELECT mclaim.dw_id as dim_claim_id
,mbranch.dw_id as dim_branch_id
,dins.insurance_type_id as dim_insurance_type_id
,DATE_FORMAT(izv.payoffdate,'%Y%m%d') as dim_paid_time_id
,izv.payoffamountmaterial as paid_amount_material
,izv.payoffamountnonmaterial as paid_amount_nonmaterial 
,izv.payoffamountmaterial+payoffamountnonmaterial  as paid_amount
FROM insurance_staging.izv_analitika_po_isplatama izv LEFT JOIN insurance_staging.map_claim mclaim
ON izv.claim_id = mclaim.sql_id 
JOIN insurance_staging.map_branch mbranch
ON izv.OrgUnitSubjectId = mbranch.sql_id
JOIN insurance_dw.dim_insurance_type dins
-- ON dins.risk_code=izv.tarifa
ON REPLACE(dins.risk_code,'.','')=izv.tarifa4
WHERE PayOffDate BETWEEN dateFrom AND dateTo;
END$$
DELIMITER ;


