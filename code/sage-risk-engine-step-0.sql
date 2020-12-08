CREATE OR REPLACE PROCEDURE genericmodelv3.public.SAGE_MEP_STEP_0 () AS $$ 
BEGIN

DROP TABLE IF EXISTS genericmodelv3.public.ME_PERSON;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_PERSON (
MODEL_YR INTEGER,   
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
INPUT_VAR VARCHAR(100),
DATA_TYPE VARCHAR(50),
VARIABLE_ORDER SMALLINT,
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,INPUT_VAR)
)
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);

DROP TABLE IF EXISTS genericmodelv3.public.ME_DEM_VARIABLE_CALC;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_DEM_VARIABLE_CALC (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
VARIABLE VARCHAR(100),
CALCULATION VARCHAR(max),
CALC_ORDER INTEGER,
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,VARIABLE))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);



DROP TABLE IF EXISTS genericmodelv3.public.ME_CC_MAP;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_CC_MAP (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
DIAG_CD VARCHAR(10),
CC INTEGER,
CC_TYPE VARCHAR(10),
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,DIAG_CD,CC)
)
DISTKEY(DIAG_CD)
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE,CC);

DROP TABLE IF EXISTS genericmodelv3.public.ME_ADDL_CC_MAP;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_ADDL_CC_MAP (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
--CC_PREV INTEGER,
CC INTEGER,
CALCULATION VARCHAR(max),
--CALC_TYPE VARCHAR(10),
DIAG_CD VARCHAR(2000),
CALC_ORDER INTEGER,
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,CC))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);


DROP TABLE IF EXISTS genericmodelv3.public.ME_SEDIT_AGE;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_SEDIT_AGE (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
DIAG_CD VARCHAR(10),
AGE_CD VARCHAR(10),
AGE_LOWER INTEGER,
AGE_UPPER INTEGER,
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,DIAG_CD))
DISTKEY(DIAG_CD)
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE,AGE_LOWER,AGE_UPPER);

DROP TABLE IF EXISTS genericmodelv3.public.ME_SEDIT_SEX;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_SEDIT_SEX (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
DIAG_CD VARCHAR(10),
SEX VARCHAR(10),
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,DIAG_CD))
DISTKEY(DIAG_CD)
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE,SEX);

DROP TABLE IF EXISTS genericmodelv3.public.ME_HCC_VARIABLES;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_HCC_VARIABLES (
MODEL_YR INTEGER,   
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),   
HCC_VARIABLE VARCHAR(10),
HCC_NUM INTEGER,
PRIMARY KEY
(MODEL_YR, VRSN_NUM, RUN_TYPE, HCC_NUM))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE,HCC_NUM);

DROP TABLE IF EXISTS genericmodelv3.public.ME_HCC_HIERARCHY;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_HCC_HIERARCHY (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
HIER_TYPE VARCHAR(50),
HIER_LEVEL INTEGER,
HCC_HIGHER VARCHAR(10),
HCC_LOWER VARCHAR(10),
PRIMARY KEY (MODEL_YR, VRSN_NUM, RUN_TYPE, HCC_HIGHER, HCC_LOWER))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);

DROP TABLE IF EXISTS genericmodelv3.public.ME_INT_VARIABLE_CALC;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_INT_VARIABLE_CALC (
MODEL_YR INTEGER,
VRSN_NUM VARCHAR(10),   
RUN_TYPE VARCHAR(20),
VARIABLE VARCHAR(100),
CALCULATION VARCHAR(max),
CALC_ORDER INTEGER,
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,VARIABLE))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);

DROP TABLE IF EXISTS genericmodelv3.public.ME_SCORE_VARIABLES;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.ME_SCORE_VARIABLES (
MODEL_YR INTEGER,   
VRSN_NUM VARCHAR(10),       
RUN_TYPE VARCHAR(20),
SCORE_TYPE VARCHAR(100),    
VARIABLE VARCHAR(100),  
COEFFICIENT DECIMAL(8,5),
PRIMARY KEY (MODEL_YR,VRSN_NUM,RUN_TYPE,SCORE_TYPE,VARIABLE))
SORTKEY(MODEL_YR,VRSN_NUM,RUN_TYPE);

DROP TABLE IF EXISTS genericmodelv3.public.SAGE_PERSON;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.SAGE_PERSON (
HICNO VARCHAR(50),  
DOB DATE,
SEX CHAR(1),
OREC CHAR(1),
LTIMCAID SMALLINT,
NEMCAID SMALLINT, 
ESRD SMALLINT,
MCAID SMALLINT,
PRIMARY KEY
(HICNO))
DISTKEY(HICNO)
SORTKEY(SEX,DOB,OREC);

DROP TABLE IF EXISTS genericmodelv3.public.SAGE_DIAG;
CREATE TABLE IF NOT EXISTS genericmodelv3.public.SAGE_DIAG (
HICNO VARCHAR(50),  
DIAG VARCHAR(10),
PRIMARY KEY (HICNO, DIAG))
DISTKEY(DIAG)
SORTKEY(HICNO);

TRUNCATE TABLE genericmodelv3.public.ME_PERSON;
TRUNCATE TABLE genericmodelv3.public.ME_DEM_VARIABLE_CALC;
TRUNCATE TABLE genericmodelv3.public.ME_CC_MAP;
TRUNCATE TABLE genericmodelv3.public.ME_ADDL_CC_MAP;
TRUNCATE TABLE genericmodelv3.public.ME_SEDIT_AGE;
TRUNCATE TABLE genericmodelv3.public.ME_SEDIT_SEX;
TRUNCATE TABLE genericmodelv3.public.ME_HCC_VARIABLES;
TRUNCATE TABLE genericmodelv3.public.ME_HCC_HIERARCHY;
TRUNCATE TABLE genericmodelv3.public.ME_INT_VARIABLE_CALC;
TRUNCATE TABLE genericmodelv3.public.ME_SCORE_VARIABLES;
TRUNCATE TABLE genericmodelv3.public.SAGE_PERSON;
TRUNCATE TABLE genericmodelv3.public.SAGE_DIAG;

--For Amazon Refshift use below:
copy genericmodelv3.public.me_person
from 's3://sage.generic.model.v2/me_person.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_DEM_VARIABLE_CALC
from 's3://sage.generic.model.v2/me_dem_variable_calc.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_CC_MAP
from 's3://sage.generic.model.v2/me_cc_map.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_ADDL_CC_MAP
from 's3://sage.generic.model.v2/me_addl_cc_map.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_SEDIT_AGE
from 's3://sage.generic.model.v2/me_sedit_age.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_SEDIT_SEX
from 's3://sage.generic.model.v2/me_sedit_sex.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_HCC_VARIABLES
from 's3://sage.generic.model.v2/me_hcc_variables.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_HCC_HIERARCHY
from 's3://sage.generic.model.v2/me_hcc_hierarchy.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.me_int_variable_calc
from 's3://sage.generic.model.v2/me_int_variable_calc.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.ME_SCORE_VARIABLES
from 's3://sage.generic.model.v2/me_score_variables.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.SAGE_PERSON
from 's3://sage.generic.model.v2/sage_person.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

copy genericmodelv3.public.SAGE_DIAG
from 's3://sage.generic.model.v2/sage_diag.txt'
iam_role 'arn:aws:iam::337736145808:role/RedshiftCopy'
region 'us-east-1'
delimiter '\t' ;

END;
$$ LANGUAGE plpgsql;