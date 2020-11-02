CREATE
OR REPLACE PROCEDURE genericmodelv3.public.SAGE_REPLICATE_MIF (IN iLOOP INTEGER) LANGUAGE plpgsql AS  $$ 
DECLARE 
i integer;
sqlstr VARCHAR(7000);
tChar char(10);
BEGIN
    i := 0;
LOOP 
    i := i + 1;
    tChar = cast(i as varchar(10));
	                              
	IF i < iLOOP THEN
			sqlstr := concat(concat('INSERT INTO genericmodelv3.public.SAGE_PERSON 
            SELECT concat(''',tChar),''',HICNO), DOB, SEX,OREC,LTIMCAID,NEMCAID,ESRD,MCAID FROM genericmodelv3.public.SAGE_PERSON');
			EXECUTE sqlstr;
            sqlstr := CONCAT(concat('INSERT INTO genericmodelv3.public.SAGE_DIAG 
            SELECT concat(''',tChar),''',HICNO), DIAG FROM genericmodelv3.public.SAGE_DIAG');
            EXECUTE sqlstr;
    ELSE
        exit;
    END IF;
  END LOOP;

END;
$$

--TRUNCATE TABLE genericmodelv3.public.SAGE_PERSON;
--TRUNCATE TABLE genericmodelv3.public.SAGE_DIAG;
--copy genericmodelv3.public.SAGE_PERSON
--from 's3://sage.generic.model.v2/sage_person.txt'
--iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
--region 'us-east-1'
--delimiter '\t' ;

--copy genericmodelv3.public.SAGE_DIAG
--from 's3://sage.generic.model.v2/sage_diag.txt'
--iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
--region 'us-east-1'
--delimiter '\t' ;
--call genericmodelv3.public.SAGE_REPLICATE_MIF ()
--select count(*) from sage_person;