DECLARE @danTo DATETIME, @danFrom DATETIME, @claimReservationIdPrevious INT
SET @danFrom = '2014.01.01'
SET @danTo = '2014.03.01' -- zadnji dan mora bii uvecan za jedan na izv je ovdje 2014.01.31 TJ za jan
SET @claimReservationIdPrevious = (
 SELECT MAX(CLAIM_RESERVATION_ID) FROM [ins].[I_CLAIM_RESERVATION] CR 
                        WHERE CR.Status_Id!=3
                        AND CR.Reservation_Date<@danTo                        
                        ) 

SELECT  
SUM(CASE LDH.IS_MATERIAL WHEN 1 THEN CMT.AMOUNT ELSE 0 END )AS PayoffAmountMaterial,
SUM(CASE LDH.IS_MATERIAL WHEN 0 THEN CMT.AMOUNT  ELSE 0 END ) AS PayoffAmountNonMaterial
                    FROM (
                        SELECT *, ISNULL(INS.GetReservedAmountTotalByClaimReservation(CLAIM_ID, CLAIM_VERSION_ON_YEARLY_BASIS, @claimReservationIdPrevious), 0) as ReservedAmountTotal  FROM INS.GetClaimHistDenormalizedExtended(@danTo) 
                        WHERE 
						    SERVICE_CLAIM = 0 /*ŠTETE KOJE NISU USLUŽNE*/ 
						    AND ISNULL(FOR_OFFICIAL_REPORTS_ONLY, 0) = 0
                        ) Claim
                    INNER JOIN INS.I_LIQUIDATION_HIST LH  WITH (NOLOCK) ON LH.CLAIM_HIST_ID = Claim.CLAIM_HIST_ID
                    INNER JOIN INS.I_LIQUIDATION_DETAIL_HIST LDH  WITH (NOLOCK) ON LH.LIQUIDATION_HIST_ID = LDH.LIQUIDATION_HIST_ID
                    INNER JOIN INS.I_CONTRACT_MONEY_TRANSFER CMT WITH (NOLOCK) ON CMT.REF_ID = LDH.LIQUIDATION_DETAIL_ID 
                    LEFT JOIN T_Company COMP  WITH (NOLOCK) ON (COMP.COMPANYID + 1) = Claim.COST_ORGUNIT_SUBJECTID
                    WHERE Claim.CLAIM_VERSION_ON_YEARLY_BASIS = LH.CLAIM_VERSION_ON_YEARLY_BASIS
                    AND CMT.TRANSFER_TYPE = 4 /*TIP: ISPLATA PO ŠTETI*/
                    AND CMT.TRANS_DATE >= @danFrom AND CMT.TRANS_DATE <= @danTo
						
SELECT  Claim.CLAIM_ID as claim_id, LDH.LIQUIDATION_DETAIL_ID AS Id
                        ,CMT.CMTID as CmtId
                        ,Claim.CLAIM_TYPE_ID AS ClaimTypeId
                        ,Claim.CONTRACT_TARIFF_GROUP AS Tarifa
						  ,Claim.CONTRACT_TARIFF As Tarifa4
						     ,Claim.GREEN_CARD AS IsGreenCard
                           ,Claim.PRE_WAR AS IsPreWar
                        ,Claim.CLAIM_NO AS ClaimNo
                        ,Claim.CLAIM_REQUEST_NO_OLD AS ClaimNoOld
                        ,Claim.COST_ORGUNIT_SUBJECTID as OrgUnitSubjectId
                        ,COMP.Name as OrgUnit
                        ,Claim.EVENT_DATE as EventDate
                        ,CASE Claim.CLAIM_VERSION_ON_YEARLY_BASIS 
                            WHEN 1 THEN CREATION_DATE
                            ELSE (SELECT MIN(DT_CRE) FROM INS.I_CLAIM_HIST CH  WITH (NOLOCK) WHERE CH.CLAIM_HIST_ID = Claim.CLAIM_HIST_ID AND Claim.CLAIM_VERSION_ON_YEARLY_BASIS = CH.CLAIM_VERSION_ON_YEARLY_BASIS)
                        END AS ClaimDate
                        ,ins.[GetReservedAmount](Claim.CLAIM_ID, Claim.CLAIM_VERSION_ON_YEARLY_BASIS, 1, @danTo) AS ExpectedAmountMaterial
                        ,ins.[GetReservedAmount](Claim.CLAIM_ID, Claim.CLAIM_VERSION_ON_YEARLY_BASIS, 0, @danTo) AS ExpectedAmountNonMaterial
                        ,CMT.TRANS_DATE AS PayoffDate
                        ,CASE LDH.IS_MATERIAL 
                            WHEN 1 THEN CMT.AMOUNT 
                            ELSE 0
                        END AS PayoffAmountMaterial
                        ,CASE LDH.IS_MATERIAL 
                            WHEN 0 THEN CMT.AMOUNT 
                            ELSE 0
                        END AS PayoffAmountNonMaterial
                        ,Claim.PRE_WAR AS PreWar
                        ,CASE Claim.PROSECUTION 
                            WHEN 0 THEN 'Ne'
                            ELSE 'Da'                        
                        END AS Prosecution
                        ,CASE Claim.CLAIM_VERSION
                            WHEN 1 THEN 'Ne'
                            ELSE 'Da'
                        END AS Reactivated,
                        CASE ReservedAmountTotal
                            WHEN 0 THEN 'Ne'
                            ELSE 'Da'
                        END AS IsReserved,
                        Claim.GREEN_CARD AS GreenCard
                        ,CASE Claim.PROSECUTION_AND_JUDICAL 
                            WHEN 0 THEN 'Ne'
                            ELSE 'Da'                            
                        END AS ProsecutionJudical
                        ,CASE
                            WHEN LH.AUTHORITY_ID IS NULL THEN (SELECT CLIENT_ID FROM INS.I_CLIENTS_HIST WHERE INS.I_CLIENTS_HIST.CLIENT_HIST_ID = LH.CLIENT_ID) 
                            ELSE (SELECT CLIENT_ID FROM INS.I_CLIENTS_HIST WHERE INS.I_CLIENTS_HIST.CLIENT_HIST_ID = LH.AUTHORITY_ID) 
                        END AS ApplicantClientId
                        ,Claim.CONTRACT_NO AS ContractNo
                        ,Claim.INSURED_NAME AS InsuredName
                        ,Claim.INSURED as InsuredClientId
                        ,Claim.AO_PLUS as AOPlus
                        ,Claim.AKD as AKD
                        ,Claim.AN as AN
                        ,Claim.PARENT_ORGUNIT_SUBJECTID AS ParentOrgUnitSubjectId
                        ,Claim.HOLDER AS HolderClientId
                    FROM (
                        SELECT *, ISNULL(INS.GetReservedAmountTotalByClaimReservation(CLAIM_ID, CLAIM_VERSION_ON_YEARLY_BASIS, @claimReservationIdPrevious), 0) as ReservedAmountTotal  FROM INS.GetClaimHistDenormalizedExtended(@danTo) 
                        WHERE 
						    SERVICE_CLAIM = 0 /*ŠTETE KOJE NISU USLUŽNE*/ 
						    AND ISNULL(FOR_OFFICIAL_REPORTS_ONLY, 0) = 0
                        ) Claim
                    INNER JOIN INS.I_LIQUIDATION_HIST LH  WITH (NOLOCK) ON LH.CLAIM_HIST_ID = Claim.CLAIM_HIST_ID
                    INNER JOIN INS.I_LIQUIDATION_DETAIL_HIST LDH  WITH (NOLOCK) ON LH.LIQUIDATION_HIST_ID = LDH.LIQUIDATION_HIST_ID
                    INNER JOIN INS.I_CONTRACT_MONEY_TRANSFER CMT WITH (NOLOCK) ON CMT.REF_ID = LDH.LIQUIDATION_DETAIL_ID 
                    LEFT JOIN T_Company COMP  WITH (NOLOCK) ON (COMP.COMPANYID + 1) = Claim.COST_ORGUNIT_SUBJECTID
                    WHERE Claim.CLAIM_VERSION_ON_YEARLY_BASIS = LH.CLAIM_VERSION_ON_YEARLY_BASIS
                    AND CMT.TRANSFER_TYPE = 4 /*TIP: ISPLATA PO ŠTETI*/
                    AND CMT.TRANS_DATE >= @danFrom AND CMT.TRANS_DATE <= @danTo
     