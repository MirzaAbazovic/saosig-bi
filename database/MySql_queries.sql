-- isplate po mjesecima iz staging tabele koja odgovara izvjestaju analitika po isplatama
SELECT year(payOffDate),month(payOffDate),sum(payoffamountmaterial+payoffamountnonmaterial) 
FROM insurance_staging.izv_analitika_po_isplatama group by year(payOffDate),month(payOffDate);
-- isplate po mjesecima iz fact tabele
SELECT left(dim_paid_time_id,6), sum(paid_amount) 
FROM insurance_dw.fact_claim group by left(dim_paid_time_id,6);


-- update postojecih podataka u dimenziji steta iz tabele za mapiranje steta map_claim koja se puni procedurom map_claims
UPDATE insurance_dw.dim_claim  claim join (
SELECT mc.sql_id,mc.claim_number,dc.claim_id FROM 
insurance_staging.map_claim mc join insurance_dw.dim_claim dc 
on mc.unique_claim_number = dc.unique_claim_number) sp on claim.claim_id = sp.claim_id
SET claim.claim_number = sp.claim_number,claim.claim_key = sp.sql_id;


-- update mapirajuce tabele stete sa vec postojecim stetama u dimenziji steta 
UPDATE insurance_staging.map_claim  m join (
SELECT mc.sql_id,mc.claim_number,dc.claim_id FROM 
insurance_staging.map_claim mc join insurance_dw.dim_claim dc 
on mc.unique_claim_number = dc.unique_claim_number) sp on m.sql_id = sp.sql_id
SET m.dw_id = sp.claim_id;
-- ostale su nemapirane i njih treba prebacit u dimenziju steta
SELECT * FROM insurance_staging.map_claim WHERE dw_id is null;


-- prvo popunjavamo dimenziju steta sa novim u mapiranim 
INSERT INTO insurance_dw.dim_claim (unique_claim_number,claim_key,claim_number)
SELECT unique_claim_number,sql_id,claim_number FROM insurance_staging.map_claim WHERE dw_id is null;
-- vrsimo update u map tabeli sa novim idjevima iz dimenzije kako bi imali mapiranje za fact_claim
UPDATE insurance_staging.map_claim  m join (
SELECT mc.sql_id,mc.claim_number,dc.claim_id FROM 
insurance_staging.map_claim mc join insurance_dw.dim_claim dc 
on mc.unique_claim_number = dc.unique_claim_number) sp on m.sql_id = sp.sql_id
SET m.dw_id = sp.claim_id;