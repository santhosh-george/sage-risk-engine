CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_5 (iMODEL_YR IN INTEGER, iVRSN_NUM IN VARCHAR(10),  iRUN_TYPE IN VARCHAR(20)) AS $$
DECLARE 
    sqlstr1 VARCHAR(max);
    sqlstr2 VARCHAR(max);
    sqlstr VARCHAR(max);
    iINPUT_VAR VARCHAR(100);                                                                  
    iVARIABLE VARCHAR(100);
    iTEMPLOWER VARCHAR(50);
    iTEMPCASE VARCHAR(500);
    iHCC_HIGHER VARCHAR(50);
    iHCC_LOWER VARCHAR(50);
    C0 CURSOR FOR SELECT HCC_HIGHER, HCC_LOWER FROM genericmodelv3.public.ME_HCC_HIERARCHY 
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE ORDER BY HCC_LOWER;
    C1 CURSOR FOR
    SELECT INPUT_VAR FROM genericmodelv3.public.ME_PERSON
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE;
    C2 CURSOR FOR 
    /*SELECT DISTINCT SCORE_TYPE as VARIABLE 
    FROM genericmodelv3.public.ME_SCORE_VARIABLES
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE 
    UNION*/
    SELECT UPPER(VARIABLE) AS VARIABLE FROM (
        SELECT DISTINCT VARIABLE 
        FROM genericmodelv3.public.ME_SCORE_VARIABLES 
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE 
        UNION   
        select VARIABLE from
        (
        select variable from genericmodelv3.public.ME_DEM_VARIABLE_CALC 
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
        UNION 
        SELECT VARIABLE FROM genericmodelv3.public.ME_INT_VARIABLE_CALC 
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
        UNION 
        SELECT HCC_VARIABLE FROM genericmodelv3.public.ME_HCC_VARIABLES
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
        ) x
        where 
        variable not in (
        SELECT VARIABLE FROM genericmodelv3.public.ME_SCORE_VARIABLES
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE)
        EXCEPT
        select distinct hcc_lower from me_hcc_hierarchy 
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
        ) Y
        ORDER BY VARIABLE;
    
BEGIN
    TRUNCATE TABLE genericmodelv3.public.SAGE_OFILE_5;
    sqlstr1 := 'INSERT INTO genericmodelv3.public.SAGE_OFILE_5 (MODEL_YR, VRSN_NUM, RUN_TYPE ';
    sqlstr2 := concat('SELECT ',concat(iMODEL_YR,concat(',''',
      concat(iVRSN_NUM, concat(''',''', concat(iRUN_TYPE, ''''))))));
    OPEN C1;
    LOOP 
    FETCH C1 INTO iINPUT_VAR;
    -- exit when no more row to fetch
    exit when not found;

    sqlstr1 := concat(sqlstr1, concat(',', iINPUT_VAR));
    sqlstr2 := concat(sqlstr2, concat(',', iINPUT_VAR));
    END LOOP;
    CLOSE C1;
    sqlstr1 := concat(sqlstr1,',AGEF,AGEF_EDIT');
    sqlstr2 := concat(sqlstr2,',AGEF,AGEF_EDIT');
    OPEN C2;
    LOOP 
    FETCH C2 INTO iINPUT_VAR;
    -- exit when no more row to fetch
    exit when not found;

    sqlstr1 := concat(sqlstr1, concat(',',iINPUT_VAR));
    sqlstr2 := concat(sqlstr2, concat(',', iINPUT_VAR));
    END LOOP;
    CLOSE C2;
    iTEMPLOWER := 'FIRST';
    iTEMPCASE := 'CASE WHEN (';
    OPEN C0;
    LOOP
        FETCH C0 INTO iHCC_HIGHER, iHCC_LOWER;
        -- exit when no more row to fetch
        exit when not found;
        IF ((iTEMPLOWER = iHCC_LOWER) OR (iTEMPLOWER = 'FIRST')) 
        THEN
            iTEMPCASE := concat(concat(iTEMPCASE,iHCC_HIGHER),'=1 OR ');
			                                         
        ELSE
            IF iTEMPCASE <> 'CASE WHEN (' THEN
                SELECT SUBSTR(TRIM(iTEMPCASE), 1, LENGTH(TRIM(iTEMPCASE))-3) INTO iTEMPCASE;
			ELSE
				iTEMPCASE := concat(concat(iTEMPCASE,iHCC_HIGHER),'=1 ');
            END IF;
			sqlstr1 := concat(sqlstr1, concat(',',iTEMPLOWER));
            sqlstr2 := concat(concat(concat(concat(concat(concat(sqlstr2,','), iTEMPCASE),') THEN 0 ELSE '),iTEMPLOWER),' END AS '), iTEMPLOWER); 
                                              
			iTEMPCASE := 'CASE WHEN (';  
			iTEMPCASE := concat(concat(iTEMPCASE,iHCC_HIGHER),'=1 OR ');
			                                              
        END IF;
        iTEMPLOWER = iHCC_LOWER;
    END LOOP;
    CLOSE C0;                                         
    SELECT SUBSTR(TRIM(iTEMPCASE), 1, LENGTH(TRIM(iTEMPCASE))-3) INTO iTEMPCASE;
    sqlstr1 := concat(concat(sqlstr1,','),iTEMPLOWER);
    sqlstr2 := concat(concat(concat(concat(concat(concat(sqlstr2, ','), iTEMPCASE),') THEN 0 ELSE '),iTEMPLOWER),' END AS '), iTEMPLOWER);
    
    sqlstr1 := concat(sqlstr1,') ');
    sqlstr2 := concat(sqlstr2,' FROM genericmodelv3.public.SAGE_OFILE_4 ');
    sqlstr := concat(sqlstr1, concat(' ', sqlstr2));
	EXECUTE sqlstr;           
	DROP TABLE genericmodelv3.public.SAGE_OFILE_4;
END;
$$ LANGUAGE plpgsql;