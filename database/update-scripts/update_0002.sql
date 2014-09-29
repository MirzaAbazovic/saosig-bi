--  postaviti ime baze na kojoj se vrse izmjene --
USE `staging`;
START  TRANSACTION;
DROP PROCEDURE `paid_claims_to_dw`;
DELIMITER $$
CREATE PROCEDURE `paid_claims_to_dw`(IN dateFrom Datetime,IN dateTo Datetime)
BEGIN
-- insertuj nove stete u mapirajucu tabelu
INSERT INTO staging.map_claim(sql_id)
SELECT distinct claim_id as sql_id 
FROM staging.izv_analitika_po_isplatama 
WHERE claim_id  NOT IN (SELECT sql_id FROM staging.map_claim);

-- prvo popunjavamo dimenziju steta sa novim u mapiranim
INSERT INTO dw.dim_claim (claim_key)
SELECT sql_id FROM staging.map_claim WHERE dw_id is null;
UPDATE dw.dim_claim d
JOIN staging.izv_analitika_po_isplatama s ON d.claim_key=s.claim_id
SET unique_claim_number = CONCAT(tarifa,"-",LEFT(claimno, IF(LOCATE(" ", claimno)=0,LENGTH(claimno)+1,LOCATE(" ", claimno))-1)) ,
claim_number = claimNo,
is_pre_war = IF(PreWar=1,'Da','Ne'),
is_green_card= IF(GreenCard=1,'Da','Ne'),
is_judical = ProsecutionJudical,
is_reactivated = Reactivated,
is_reserved = IsReserved;

-- vrsimo update u map tabeli sa novim idjevima iz dimenzije kako bi imali mapiranje za fact_claim
UPDATE staging.map_claim m join dw.dim_claim d on m.sql_id = d.claim_key
SET m.dw_id=d.claim_id WHERE m.dw_id is null;

-- brisemo sve iz fact tabele za datume
DELETE FROM  dw.fact_claim WHERE dim_paid_time_id in
(SELECT time_id FROM dw.dim_time WHERE date BETWEEN dateFrom AND dateTo);

-- punimo fact claim koristeci map tabele 

INSERT INTO dw.fact_claim (dim_claim_id,dim_branch_id,dim_insurance_type_id,dim_paid_time_id,paid_amount_material,paid_amount_nonmaterial,paid_amount)
SELECT mclaim.dw_id as dim_claim_id
,mbranch.dw_id as dim_branch_id
,dins.insurance_type_id as dim_insurance_type_id
,DATE_FORMAT(izv.payoffdate,'%Y%m%d') as dim_paid_time_id
,izv.payoffamountmaterial as paid_amount_material
,izv.payoffamountnonmaterial as paid_amount_nonmaterial 
,izv.payoffamountmaterial+payoffamountnonmaterial  as paid_amount
FROM staging.izv_analitika_po_isplatama izv LEFT JOIN staging.map_claim mclaim
ON izv.claim_id = mclaim.sql_id 
JOIN staging.map_branch mbranch
ON izv.OrgUnitSubjectId = mbranch.sql_id
JOIN dw.dim_insurance_type dins
-- ON dins.risk_code=izv.tarifa
ON REPLACE(dins.risk_code,'.','')=izv.tarifa4
WHERE PayOffDate BETWEEN dateFrom AND dateTo;
END$$
DELIMITER ;

SET @Description = 'Izmjena procedure da prebacuje jeli reaktivirana i jeli rezervisana na 31.12 prethodne godine';
SET @RepositoryURL = 'https://bitbucket.org/mabazovic/saosig-bi/src/f68e25fe29811c0142a4615d310bca90a2ff2eb5/database/update-scripts/?at=master';
SET @FileName = 'Update_0002.sql';
SET @Author = 'mirza';
INSERT INTO dw.sys_db_history(SCRIPT_AUTHOR, SCRIPT_FILENAME, REPOSITORY_URL, DESCRIPTION) VALUES(@Author, @FileName, @RepositoryURL, @Description);
COMMIT;
