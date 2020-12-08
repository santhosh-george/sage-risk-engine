CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_4 (iMODEL_YR IN INTEGER,iVRSN_NUM IN VARCHAR(10),  iRUN_TYPE IN VARCHAR(20),iSEDIT IN CHAR(1)) AS $$
DECLARE 
    sqlstr1 VARCHAR(max);
    sqlstr2 VARCHAR(max);
    sqlstr0 VARCHAR(max);
    sqlstr3 VARCHAR(max);
    sqlstr VARCHAR(max);
    iINPUT_VAR VARCHAR(100);                                                                  
    iVARIABLE VARCHAR(100);
    --sortkeysql VARCHAR(7000);
    affected_rows INTEGER;
    iHCC_VAR VARCHAR(100);
    --iCALC_TYPE VARCHAR(100);
    iCC INTEGER;
    --iCC_PREV INTEGER;
    iDIAG_CD VARCHAR(2000);
    iHCC_NUM INTEGER;
    iCALCULATION VARCHAR(max);
    iTBLNM VARCHAR(100);
    C0 CURSOR FOR SELECT CC, CALCULATION, DIAG_CD FROM genericmodelv3.public.ME_ADDL_CC_MAP
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
	ORDER BY CALC_ORDER ASC;
    C0A CURSOR FOR SELECT HCC_VARIABLE,HCC_NUM FROM genericmodelv3.public.ME_HCC_VARIABLES 
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE;
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
        SELECT HCC_VARIABLE as VARIABLE FROM genericmodelv3.public.ME_HCC_VARIABLES
        WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE
        ) Y
        ORDER BY VARIABLE;
BEGIN                                                          
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_DIAG_EDIT;
    CREATE TABLE genericmodelv3.public.SAGE_DIAG_EDIT (HICNO VARCHAR(50), DIAG VARCHAR(10), 
        PRIMARY KEY (HICNO,DIAG)) 
        DISTKEY(DIAG) SORTKEY(HICNO);
        
    IF iSEDIT = 'Y' THEN
        sqlstr := CONCAT('INSERT INTO genericmodelv3.public.SAGE_DIAG_EDIT (HICNO,DIAG) ',
        CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(
            'SELECT diag.hicno, diag.diag FROM genericmodelv3.public.SAGE_DIAG diag EXCEPT SELECT diag.HICNO, diag.DIAG FROM genericmodelv3.public.SAGE_DIAG diag INNER JOIN genericmodelv3.public.ME_SEDIT_AGE age ON diag.DIAG = age.DIAG_CD INNER JOIN genericmodelv3.public.SAGE_OFILE_3 ofile on ofile.HICNO = diag.HICNO and (ofile.AGEF_EDIT < age.AGE_LOWER or ofile.AGEF_EDIT > age.AGE_UPPER) WHERE age.MODEL_YR = ',iMODEL_YR), ' and age.VRSN_NUM = '''),iVRSN_NUM),''' and age.RUN_TYPE = '''),iRUN_TYPE),''' EXCEPT SELECT diag.HICNO, diag.DIAG FROM genericmodelv3.public.SAGE_DIAG diag INNER JOIN genericmodelv3.public.ME_SEDIT_SEX sex ON diag.DIAG = sex.DIAG_CD INNER JOIN genericmodelv3.public.SAGE_OFILE_3 ofile on ofile.HICNO = diag.HICNO and (ofile.SEX <> sex.SEX) WHERE sex.MODEL_YR = '),iMODEL_YR),  ' and sex.VRSN_NUM = '''),iVRSN_NUM),''' and sex.RUN_TYPE = '''),iRUN_TYPE),''''));
    ELSE
        sqlstr := 'INSERT INTO genericmodelv3.public.SAGE_DIAG_EDIT (HICNO,DIAG) SELECT diag.hicno, diag.diag FROM genericmodelv3.public.SAGE_DIAG diag';
    END IF;
    RAISE NOTICE '%',sqlstr;
    EXECUTE sqlstr;
    
    DROP TABLE IF EXISTS SAGE_TCC;
    CREATE TABLE genericmodelv3.public.SAGE_TCC (HICNO VARCHAR(50),CC INTEGER, PRIMARY KEY (HICNO,CC)) 
    DISTKEY(HICNO) SORTKEY(CC);
    
    OPEN C0;
    LOOP
        FETCH C0 INTO iCC,iCALCULATION,iDIAG_CD;
        -- exit when no more row to fetch
        exit when not found;
        sqlstr0:= 'DELETE FROM SAGE_DIAG_EDIT WHERE DIAG IN ' || iDIAG_CD || ' AND HICNO IN (SELECT a.HICNO FROM genericmodelv3.public.SAGE_ofile_3 a INNER JOIN genericmodelv3.public.SAGE_DIAG_EDIT b on a.HICNO = b.HICNO WHERE ' || iCALCULATION || ')';
            
        IF iCC <> -1 THEN    
            sqlstr := 'INSERT INTO genericmodelv3.public.SAGE_TCC SELECT a.HICNO,';
            sqlstr := concat(concat(concat(sqlstr,iCC), ' from genericmodelv3.public.SAGE_ofile_3 a inner join genericmodelv3.public.SAGE_DIAG_EDIT b on a.HICNO = b.HICNO where '),iCALCULATION);
			RAISE NOTICE '%',sqlstr;
            EXECUTE sqlstr;
        END IF;
        RAISE NOTICE '%',sqlstr0;
        EXECUTE sqlstr0;
        
    END LOOP;
    CLOSE C0;
    
    
    sqlstr:='INSERT INTO genericmodelv3.public.SAGE_TCC (HICNO,CC) ';
    sqlstr := concat(concat(concat(concat(concat(concat(concat(sqlstr,' select HICNO,CC from genericmodelv3.public.SAGE_DIAG_EDIT diag inner join genericmodelv3.public.ME_CC_MAP cc on trim(diag.diag) = trim(cc.diag_cd) where model_yr = '), iMODEL_YR),'  and VRSN_NUM = '''), iVRSN_NUM), ''' and RUN_TYPE = '''),iRUN_TYPE),''' group by 1,2');
	EXECUTE sqlstr;
                                                                                            
	TRUNCATE TABLE genericmodelv3.public.SAGE_OFILE_4;
    sqlstr1 := 'INSERT INTO genericmodelv3.public.SAGE_OFILE_4 (MODEL_YR, VRSN_NUM, RUN_TYPE ';
    sqlstr2 := concat('SELECT ',concat(iMODEL_YR,concat(' AS MODEL_YR,''', concat(iVRSN_NUM, concat(''' AS VRSN_NUM,''', concat(iRUN_TYPE, ''' AS RUN_TYPE '))))));
    sqlstr3 := ' GROUP BY MODEL_YR, VRSN_NUM, RUN_TYPE';
	OPEN C1;
    LOOP 
    FETCH C1 INTO iINPUT_VAR;
    -- exit when no more row to fetch
    exit when not found;

    sqlstr1 := concat(sqlstr1, concat(',', iINPUT_VAR));
    sqlstr2 := concat(sqlstr2, concat(',ofile.', iINPUT_VAR));
    sqlstr3 := concat(sqlstr3, concat(',ofile.', iINPUT_VAR));
    END LOOP;
    CLOSE C1;
    sqlstr1 := concat(sqlstr1,',AGEF,AGEF_EDIT');
    sqlstr2 := concat(sqlstr2,',ofile.AGEF,ofile.AGEF_EDIT');
    sqlstr3 := concat(sqlstr3,',ofile.AGEF,ofile.AGEF_EDIT');                                      
    OPEN C2;
    LOOP 
    FETCH C2 INTO iINPUT_VAR;
    -- exit when no more row to fetch
    exit when not found;

    sqlstr1 := concat(sqlstr1, concat(',',iINPUT_VAR));
    sqlstr2 := concat(sqlstr2, concat(',ofile.', iINPUT_VAR));
    sqlstr3 := concat(sqlstr3, concat(',ofile.', iINPUT_VAR));
    END LOOP;
    CLOSE C2;
    
    --sortkeysql := ' ALTER TABLE genericmodelv3.public.sage_ofile_4 ALTER SORTKEY (HICNO ';
    OPEN C0A;
    LOOP
        FETCH C0A INTO iHCC_VAR,iHCC_NUM;
        -- exit when no more row to fetch
        exit when not found;
        --sortkeysql:= sortkeysql || ',' || iHCC_VAR;
        sqlstr1 := concat(sqlstr1, concat(' ,', iHCC_VAR));

        sqlstr2 := concat(concat(concat(concat(sqlstr2, ' , CASE WHEN SUM(CASE WHEN CC =  '),iHCC_NUM),' THEN 1 ELSE 0 END)>0 THEN 1 ELSE 0 END AS '),iHCC_VAR);
    END LOOP;
    CLOSE C0A;
    sqlstr1 := concat(sqlstr1,') ');
    sqlstr2 := concat(sqlstr2,' FROM genericmodelv3.public.SAGE_OFILE_3 ofile LEFT OUTER JOIN 
    genericmodelv3.public.SAGE_TCC tcc ON tcc.HICNO = ofile.HICNO ');
    --sqlstr := concat(concat(concat(concat(sqlstr1, ' '), sqlstr2), ' '),sqlstr3);
                                          
	EXECUTE concat(concat(concat(concat(sqlstr1, ' '), sqlstr2), ' '),sqlstr3);
	DROP TABLE genericmodelv3.public.SAGE_OFILE_3;
--    sortkeysql:=sortkeysql || ')';
--'                where HICNO in (select HICNO from genericmodelv3.public.SAGE_tcc where cc = '),iHCC_NUM),')');

--    EXECUTE sortkeysql;                                      
END;
$$ LANGUAGE plpgsql;
