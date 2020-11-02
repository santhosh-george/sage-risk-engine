CREATE
OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_2 (
  iMODEL_YR IN INTEGER,
  iVRSN_NUM IN VARCHAR(10),
  iRUN_TYPE IN VARCHAR(20),
  iREF_DT IN DATE,
  iREF_EDIT_DT IN DATE
) LANGUAGE plpgsql
AS  $$ 
DECLARE 
sqlstr1 VARCHAR(7000);
sqlstr2 VARCHAR(7000);
sqlstr VARCHAR(7000);
iINPUT_VAR VARCHAR(100);
C1 CURSOR FOR
SELECT
  INPUT_VAR
FROM
  genericmodelv3.public.ME_PERSON
WHERE
  MODEL_YR = iMODEL_YR
  AND VRSN_NUM = iVRSN_NUM
  AND RUN_TYPE = iRUN_TYPE;

BEGIN
DELETE FROM
  genericmodelv3.public.SAGE_OFILE_2
WHERE
  1 = 1;

OPEN C1;

sqlstr1 := 'INSERT INTO genericmodelv3.public.SAGE_OFILE_2 (MODEL_YR, VRSN_NUM, RUN_TYPE, ';

sqlstr2 := concat(
  'SELECT ',
  concat(
    iMODEL_YR,
    concat(
      ',''',
      concat(iVRSN_NUM, concat(''',''', concat(iRUN_TYPE, '''')))
    )
  )
);

LOOP 

FETCH C1 INTO iINPUT_VAR;
-- exit when no more row to fetch
exit when not found;

sqlstr1 := concat(sqlstr1, concat(iINPUT_VAR, ','));
sqlstr2 := concat(sqlstr2, concat(',', iINPUT_VAR));


END LOOP;

CLOSE C1;

sqlstr1 := concat(sqlstr1, 'AGEF,AGEF_EDIT) ');

sqlstr2 := 

--Amazon Redshift
     concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(concat(
         sqlstr2,', case when (date_part(''mon'',dob) = date_part(''mon'','''),
            iREF_DT),''')) and (date_part(''day'',dob) > date_part(''day'','''),iREF_DT),''')) then 
	case when (((trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)-1) = 64) AND (OREC = ''0'')) then 65
               when ((trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)-1)<0)  then 0
               else (trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)-1) end
    else 
        case when (((trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)) = 64) AND (OREC = ''0'')) then 65
               when ((trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12))<0)  then 0
               else (trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)) end   
    end as agef ');    
IF iREF_EDIT_DT IS NOT NULL THEN 
    sqlstr2 := 
    concat(concat(concat(concat(concat(concat(concat(concat(concat(
         sqlstr2,', case when (date_part(''mon'',dob) = date_part(''mon'','''),
            iREF_EDIT_DT),''')) and (date_part(''day'',dob) > date_part(''day'','''),iREF_EDIT_DT),''')) then 
	    (trunc(DATEDIFF(''mon'',DOB,'''),iREF_EDIT_DT),''')/12)-1) 
    else 
        (trunc(DATEDIFF(''mon'',DOB,'''),iREF_EDIT_DT),''')/12))   
    end as agef_edit ');    

ELSE
    sqlstr2 := 
    concat(concat(concat(concat(concat(concat(concat(concat(concat(
         sqlstr2,', case when (date_part(''mon'',dob) = date_part(''mon'','''),
            iREF_DT),''')) and (date_part(''day'',dob) > date_part(''day'','''),iREF_DT),''')) then 
	    (trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12)-1) 
    else 
        (trunc(DATEDIFF(''mon'',DOB,'''),iREF_DT),''')/12))   
    end as agef_edit ');   
END IF;

sqlstr2 := concat(sqlstr2,' FROM genericmodelv3.public.SAGE_PERSON ');

sqlstr := concat(sqlstr1, concat(' ', sqlstr2));
EXECUTE sqlstr;

END;
$$

