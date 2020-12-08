CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_WRAPPER (iMODEL_YR IN INTEGER,iVRSN_NUM IN VARCHAR(10),iREF_DT IN DATE,iSEDIT IN CHAR(1),iREF_EDIT_DT IN DATE) AS $$
BEGIN
DECLARE iRUN_TYPE VARCHAR(20);

IF iMODEL_YR = 2020 THEN iRUN_TYPE = 'Mid-year';
IF iMODEL_YR = 2021 THEN iRUN_TYPE = 'Initial';
--Create oFile Structure with all Variables from Model
call genericmodelv3.public.SAGE_MEP_STEP_1 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE);
--Insert the Person file into the oFile
call genericmodelv3.public.SAGE_MEP_STEP_2 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE,iREF_DT,iREF_EDIT_DT);
--Calculate demographic values and update oFile
call genericmodelv3.public.SAGE_MEP_STEP_3 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE);
--SEdits and Map CC to Diagnosis Codes including demographics based CC and update into oFile
call  genericmodelv3.public.SAGE_MEP_STEP_4 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE,iSEDIT);
--Apply HCC hierarchies into oFile
call  genericmodelv3.public.SAGE_MEP_STEP_5 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE);
--Calculate interaction variables and update oFile
call  genericmodelv3.public.SAGE_MEP_STEP_6 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE);
--Calculate score for the model
call  genericmodelv3.public.SAGE_MEP_STEP_7 (iMODEL_YR,iVRSN_NUM,iRUN_TYPE);    

END;
$$
LANGUAGE plpgsql;
