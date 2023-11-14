use fegbe2;

## STUDY POPULATION: ------------------------------------------------------
# PATIENTS WITH DMII ('E11%')

SELECT *
FROM tab_long_term_illness tlti
WHERE LTI_ICD_REASON like 'E11%'
AND YEAR(LTI_START_DATE) < 2018;


## OUTCOME #1: ------------------------------------------------------
# PATIENT IDs FOR PATIENTS TAKING GLP-1 ('A10BJ%') or DPP-4 ('A10BH%'), 2018-2020

SELECT *
FROM tab_prs_drugs tpd, ths_drugs td, tab_prescription tp 
WHERE tpd.DRUG_CIP7 = td.DRUG_CIP7 AND tpd.PRS_KEY = tp.PRS_KEY
AND (td.DRUG_ATC_C07 like 'A10BJ%'
	OR td.DRUG_ATC_C07 like 'A10BH%')
AND YEAR(tp.PRS_DATE) > 2018 AND YEAR(tp.PRS_DATE) < 2021;


## OUTCOME #2: ------------------------------------------------------
# HOSPITALIZED PATIENTS, 2018-2020

SELECT *
FROM tab_hospitalisation th
WHERE YEAR(HOSP_START_DATE) > 2018 AND YEAR (HOSP_START_DATE) < 2021;




# MERGE THE 2  ------------------------------------------------------
SELECT t1.PAT_ID as 'drug_PAT_ID', t1.DRUG_ATC_C07, t1.PAT_DPT_RES, t2.PAT_ID as 't2d_PAT_ID'
FROM(SELECT tp.PAT_ID, tp.PRS_KEY, td.DRUG_ATC_C07, tp2.PAT_DPT_RES 
	FROM tab_prs_drugs tpd, ths_drugs td, tab_prescription tp, tab_patient tp2 
	WHERE tpd.DRUG_CIP7 = td.DRUG_CIP7 AND tpd.PRS_KEY = tp.PRS_KEY AND tp.PAT_ID = tp2.PAT_ID 
	AND (td.DRUG_ATC_C07 like 'A10BJ%'
		OR td.DRUG_ATC_C07 like 'A10BH%')) t1 LEFT JOIN
	(SELECT PAT_ID
	FROM tab_long_term_illness tlti
	WHERE LTI_ICD_REASON like 'E11%') t2
ON t1.PAT_ID = t2.PAT_ID;



