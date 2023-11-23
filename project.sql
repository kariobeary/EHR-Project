use fegbe2;

## STUDY POPULATION: ------------------------------------------------------
# PATIENTS WITH DMII ('E11%') DIAGNOSED BEFORE 2018
# NEW: associated/secondary diagnosis of T2D ('E11%')
#      OR any LTI diabetic diagnosis (LTI_NUM = 8 OR LTI_ICD_REASON like 'E11%')

SELECT *
FROM tab_hospitalisation th, tab_mso_ass_dgn tmad 
WHERE th.ETA_NUM = tmad.ETA_NUM AND th.RSA_NUM = tmad.RSA_NUM 
AND (DGN_ASS like 'E11%' OR
	HOSP_MAIN_DGN like 'E11%')
AND YEAR(HOSP_START_DATE) < 2018;

SELECT *
FROM tab_long_term_illness tlti
WHERE LTI_NUM = 8 AND LTI_ICD_REASON like 'E11%'
AND YEAR(LTI_START_DATE) < 2018
AND YEAR(LTI_END_DATE) > 2018;
	# Double-check if we keep this? Presumably, we want patients who
	# still have diabetes as LTI after the start of our study period


/*   checking how many LTI individuals have also been hospitalized before 2018 (4)
SELECT *
FROM tab_hospitalisation th, tab_mso_ass_dgn tmad 
WHERE th.ETA_NUM = tmad.ETA_NUM AND th.RSA_NUM = tmad.RSA_NUM 
AND DGN_ASS like 'E11%'
AND YEAR(HOSP_START_DATE) < 2018
AND PAT_ID IN(SELECT PAT_ID 
	FROM tab_long_term_illness tlti
	WHERE LTI_NUM = 8 AND LTI_ICD_REASON like 'E11%'
	AND YEAR(LTI_START_DATE) < 2018
	AND YEAR(LTI_END_DATE) > 2018);
*/



## OUTCOME #1: ------------------------------------------------------
# PATIENT IDs FOR DIABETIC PATIENTS WITH PRESCRIPTIONS, 2018-2020
# filter in R for GLP-1 ('A10BJ%') or DPP-4 ('A10BH%')
# NEW: anyone with at least 3 prescriptions of any diabetic medication (diff T1D and T2D)
#      ^^ I think we can do this in R

SELECT *
FROM tab_prs_drugs tpd, ths_drugs td, tab_prescription tp 
WHERE tpd.DRUG_CIP7 = td.DRUG_CIP7 AND tpd.PRS_KEY = tp.PRS_KEY
AND PAT_ID IN(SELECT tlti.PAT_ID
	FROM tab_long_term_illness tlti, tab_hospitalisation th, tab_mso_ass_dgn tmad 
	WHERE tlti.PAT_ID = th.PAT_ID AND th.ETA_NUM = tmad.ETA_NUM AND th.RSA_NUM = tmad.RSA_NUM 
	AND DGN_ASS like 'E11%'
	AND YEAR(HOSP_START_DATE) < 2018
	AND LTI_NUM = 8 AND LTI_ICD_REASON like 'E11%')
AND YEAR(tp.PRS_DATE) > 2018 AND YEAR(tp.PRS_DATE) < 2021;



## OUTCOME #2: ------------------------------------------------------
# HOSPITALIZED PATIENTS, 2018-2020

SELECT *
FROM tab_hospitalisation th
WHERE YEAR(HOSP_START_DATE) > 2018 AND YEAR (HOSP_START_DATE) < 2021;



## TAB_PATIENT ------------------------------------------------------
# all patients whose death date is null OR after the beginning of the study period

SELECT *
FROM tab_patient tp 
WHERE YEAR(PAT_DEATH_DATE) > 2018 OR PAT_DEATH_DATE IS NULL;



/*
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
*/
