CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_1 (iMODEL_YR IN INT, iVRSN_NUM IN VARCHAR(10), iRUN_TYPE IN VARCHAR(20)) AS $$ 
                                                                                                       DECLARE
    sqlstr VARCHAR(max);
    ivariable VARCHAR(100);
    idata_type VARCHAR(100);                                                                                                                                  
    C1 CURSOR FOR SELECT INPUT_VAR, DATA_TYPE FROM genericmodelv3.public.ME_PERSON 
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE ORDER BY VARIABLE_ORDER;
    C2 CURSOR FOR SELECT UPPER(VARIABLE), DATA_TYPE FROM (
        SELECT DISTINCT VARIABLE, 'SMALLINT DEFAULT 0' AS DATA_TYPE FROM genericmodelv3.public.ME_SCORE_VARIABLES 
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE 
        UNION   
        select VARIABLE, 'SMALLINT DEFAULT 0' as DATA_TYPE from
        (
        select variable from genericmodelv3.public.ME_DEM_VARIABLE_CALC 
        WHERE  model_yr =   iMODEL_YR
        and vrsn_num = iVRSN_NUM
        and run_type = iRUN_TYPE
        UNION 
        SELECT VARIABLE FROM genericmodelv3.public.ME_INT_VARIABLE_CALC 
        WHERE  model_yr = iMODEL_YR
        and vrsn_num = iVRSN_NUM
        and run_type = iRUN_TYPE
        UNION 
        SELECT HCC_VARIABLE FROM genericmodelv3.public.ME_HCC_VARIABLES
        WHERE  model_yr = iMODEL_YR
        and vrsn_num = iVRSN_NUM
        and run_type = iRUN_TYPE
        ) x
        where 
        variable not in (
        SELECT VARIABLE FROM genericmodelv3.public.ME_SCORE_VARIABLES
        WHERE  model_yr = iMODEL_YR
        and vrsn_num = iVRSN_NUM
        and run_type = iRUN_TYPE)) Y
        ORDER BY VARIABLE;
    C3 CURSOR FOR SELECT DISTINCT SCORE_TYPE, 'DECIMAL(10,8) DEFAULT 0' AS DATA_TYPE 
    FROM genericmodelv3.public.ME_SCORE_VARIABLES
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE ORDER BY SCORE_TYPE;
    C4 CURSOR FOR SELECT HCC_VARIABLE FROM genericmodelv3.public.ME_HCC_VARIABLES
        WHERE  model_yr = iMODEL_YR and vrsn_num = iVRSN_NUM and run_type = iRUN_TYPE;
BEGIN  
                                                                                                            
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE;
   sqlstr := 'CREATE TABLE genericmodelv3.public.SAGE_OFILE( ';
    
    --Add Basic variables
   sqlstr := concat(sqlstr,'MODEL_YR INTEGER, ');
   sqlstr := concat(sqlstr,'VRSN_NUM VARCHAR(10), ');
   sqlstr := concat(sqlstr,'RUN_TYPE VARCHAR(20), ');
    
   OPEN C1;
   LOOP
        FETCH C1 INTO iVARIABLE,iDATA_TYPE;
        -- exit when no more row to fetch
        exit when not found;
        sqlstr := concat(sqlstr,concat(iVARIABLE,concat(' ', concat(iDATA_TYPE, ', '))));
    END LOOP;
    CLOSE C1;

    
    --Adding Age Variable
        sqlstr := concat(sqlstr,'AGEF INTEGER DEFAULT 0, ');
        sqlstr := concat(sqlstr,'AGEF_EDIT INTEGER DEFAULT 0, ');
    OPEN C2;
    LOOP
        FETCH C2 INTO iVARIABLE,iDATA_TYPE;
        -- exit when no more row to fetch
        exit when not found;
        sqlstr := concat(sqlstr,concat(iVARIABLE,concat(' ', concat(iDATA_TYPE, ', '))));
    END LOOP;
    CLOSE C2; 
    
 /*   OPEN C3;
    LOOP
        FETCH C3 INTO iVARIABLE,iDATA_TYPE;
        -- exit when no more row to fetch
        exit when not found;
        sqlstr := concat(sqlstr,concat(iVARIABLE,concat(' ', concat(iDATA_TYPE, ', '))));
    END LOOP;
    CLOSE C3; */
    
    sqlstr := concat(sqlstr, ' PRIMARY KEY (HICNO))');
    
    --Amazon Redshift
    sqlstr := concat(sqlstr,' DISTKEY(HICNO) SORTKEY (HICNO,SEX,AGEF,OREC ');
    
    --It is better (performance wise) not to have HCC as sort key right now. 
    --The table will be altered later in step 4
    --Hence this section is commented out 
    --OPEN C4;
    --LOOP
    --    FETCH C4 INTO iVARIABLE;
        -- exit when no more row to fetch
    --    exit when not found;
    --    sqlstr := sqlstr || ',' || iVARIABLE;
    --END LOOP;
    --CLOSE C4;
    
    sqlstr := concat(sqlstr,')');
    EXECUTE sqlstr;
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_2;
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_3;
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_4;
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_5;
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_VARIABLE;
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_2 (LIKE genericmodelv3.public.SAGE_OFILE INCLUDING DEFAULTS);
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_3 (LIKE genericmodelv3.public.SAGE_OFILE INCLUDING DEFAULTS);
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_4 (LIKE genericmodelv3.public.SAGE_OFILE INCLUDING DEFAULTS);
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_5 (LIKE genericmodelv3.public.SAGE_OFILE INCLUDING DEFAULTS);
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_VARIABLE (LIKE genericmodelv3.public.SAGE_OFILE INCLUDING DEFAULTS);
    ALTER TABLE genericmodelv3.public.SAGE_OFILE_2 ADD CONSTRAINT ofile2_pk PRIMARY KEY (HICNO);
    ALTER TABLE genericmodelv3.public.SAGE_OFILE_3 ADD CONSTRAINT ofile3_pk PRIMARY KEY (HICNO);
    ALTER TABLE genericmodelv3.public.SAGE_OFILE_4 ADD CONSTRAINT ofile4_pk PRIMARY KEY (HICNO);
    ALTER TABLE genericmodelv3.public.SAGE_OFILE_5 ADD CONSTRAINT ofile5_pk PRIMARY KEY (HICNO);
    ALTER TABLE genericmodelv3.public.SAGE_OFILE_VARIABLE ADD CONSTRAINT ofile_var_pk PRIMARY KEY (HICNO);
    
END;
          
$$ LANGUAGE plpgsql;