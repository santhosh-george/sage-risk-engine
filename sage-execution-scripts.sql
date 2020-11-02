--call genericmodelv3.public.SAGE_MEP_STEP_0(); 
--call genericmodelv3.public.SAGE_REPLICATE_MIF (2);
select count(*) from sage_person;
--Model Year, Version Number, Run Type, Age Reference Date (Feb 1 of Payment Year),SEDITS (Y or NULL), Age Edit Reference Date (YYYY-MM-DD or NULL)
call genericmodelv3.public.SAGE_MEP_WRAPPER (2020,'ESRD-P1','Mid-year','2020-02-01','Y',NULL); 

--call genericmodelv3.public.SAGE_MEP_STEP_1 (2020,'V24','Mid-year');
/*Insert the Person file into the oFile*/
--call genericmodelv3.public.SAGE_MEP_STEP_2 (2020,'V24','Mid-year','2020-02-01',NULL);
/*Calculate demographic values and update oFile*/
--call genericmodelv3.public.SAGE_MEP_STEP_3 (2020,'V24','Mid-year');
/*SEdits and Map CC to Diagnosis Codes including demographics based CC and update into oFile*/
--call  genericmodelv3.public.SAGE_MEP_STEP_4 (2020,'V24','Mid-year','Y');
/*Apply HCC hierarchies into oFile*/
--call  genericmodelv3.public.SAGE_MEP_STEP_5 (2020,'V24','Mid-year');
/*Calculate interaction variables and update oFile*/
--call  genericmodelv3.public.SAGE_MEP_STEP_6 (2020,'V24','Mid-year');
/*Calculate score for the model*/
--call  genericmodelv3.public.SAGE_MEP_STEP_7 (2020,'V24','Mid-year');

select count(*) FROM genericmodelv3.public.SAGE_OFILE_VARIABLE;
select avg(score) from genericmodelv3.public.SAGE_OFILE_SCORE;


