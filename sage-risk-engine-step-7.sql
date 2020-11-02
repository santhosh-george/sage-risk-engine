CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_7 (iMODEL_YR IN INTEGER, iVRSN_NUM IN VARCHAR(10),  iRUN_TYPE IN VARCHAR(20)) AS $$
DECLARE 
    sqlstr VARCHAR(max);
    iVARIABLE VARCHAR(100);
    C0 CURSOR FOR SELECT DISTINCT VARIABLE FROM genericmodelv3.public.ME_SCORE_VARIABLES 
    WHERE MODEL_YR = iMODEL_YR AND VRSN_NUM = iVRSN_NUM AND RUN_TYPE = iRUN_TYPE ORDER BY VARIABLE;

BEGIN
    DROP TABLE IF EXISTS genericmodelv3.public.SAGE_OFILE_SCORE;
    CREATE TABLE genericmodelv3.public.SAGE_OFILE_SCORE (MODEL_YR INTEGER, VRSN_NUM VARCHAR(10), RUN_TYPE VARCHAR(20),
            HICNO VARCHAR(50),SCORE_TYPE VARCHAR(100), SCORE DECIMAL(10,8), PRIMARY KEY (HICNO,SCORE_TYPE)) 
    DISTKEY(HICNO) SORTKEY(HICNO);
    sqlstr := 'INSERT INTO genericmodelv3.public.SAGE_OFILE_SCORE select model_yr,vrsn_num,run_type,hicno,score_type, sum(coefficient) as score from 
                (select model_yr,vrsn_num,run_type,hicno,score_type,coefficient from (select hicno, ''';
    OPEN C0;
        LOOP 
            FETCH C0 INTO iVARIABLE;
            -- exit when no more row to fetch
            exit when not found;
            sqlstr := concat(concat(concat(concat(sqlstr,iVARIABLE),'''as var from sage_ofile_variable where '),iVARIABLE),'=1 
            UNION select hicno, ''');
        END LOOP;        
    CLOSE C0;
    SELECT SUBSTR(TRIM(sqlstr), 1, LENGTH(TRIM(sqlstr))-21) INTO sqlstr;
    sqlstr:= concat(concat(concat(concat(concat(concat(concat(sqlstr, ') x inner join me_score_variables y on x.var = y.variable
        where model_yr = '),iMODEL_YR),' and vrsn_num='''),iVRSN_NUM),''' and run_type = '''),iRUN_TYPE),''') z 
        group by model_yr,vrsn_num,run_type,hicno,score_type order by hicno');
    EXECUTE sqlstr;
END;
$$ LANGUAGE plpgsql;