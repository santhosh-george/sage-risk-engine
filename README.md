The SaGe Risk Engine is a flexible data driven engine to calculate the risk adjustment factors (RAF) / risk scores based on CMS HCC (V22, V24, V21 (ESRD), V05 (RX)) models. The active models are included in the model and future models will be incorporated as CMS publishes the model software. The engine is developed for the Amazon Redshift platform. PostgreSQL and MySQL versions are also available. This codebase enables you to avoid SAS and calculate the risk score using the SaGe Risk Engine in the cloud (Redshift) or database on your local machine (MySQL / PostgreSQL)

## How to run the engine

1. Create a cluster with database name genericmodelv3 (if using a different database name please update the stored procedures with the database name used)
2. Upload the .txt files in model-settings folder to S3 bucket and apply IAM role for Redshift to access the S3 bucket
3. There are sample person and diag files that could be used to try the engine. If using the sample data in the sample-data folder upload the .txt files to the S3 bucket. When using your data use your data in similar structure. If the structure is different make necessary changes to me_person table found in sage-risk-engine-step-0.sql. One requirement to have the bene id to be identified as HICNO column 
4. Modify the URL for S3 bucket and IAM role in sage-risk-engine-step-0.sql 
5. Create stored procedures by running the script in sage-risk-engine-step-0.sql through sage-risk-engine-step-7.sql one at a time. The scripts can be found in the code folder
6. Create wrapper stored procedure by running the script in sage-risk-engine-wrapper.sql
7. Run the following command to populate the engine parameters:
   call genericmodelv3.public.SAGE_MEP_STEP_0(); 
8. Run the following command to run the model:
   call genericmodelv3.public.SAGE_MEP_WRAPPER (<<Model Year>>,<<Model Type (example 'V24', 'V22', 'RX', 'ESRD-P1', 'ESRD-P2'>>,<<Age calculated as of Date in 'YYYY-MM-DD' format (usually February 1 of the Model Year)>>,<<run MCE Edits 'Y' or NULL>>,<<Specify date different than the third parameter to calculate age for MCE Edits 'YYYY-MM-DD' format or NULL); 
    Example: call genericmodelv3.public.SAGE_MEP_WRAPPER (2020,'V24','2020-02-01','Y',NULL); 
 9. The outputs are available in three redshift tables:
    a. SAFE_OFILE_VARIABLE - This table is a wide table with columns for all inputs used in the model and the variable switches calculated
    b. SAGE_OFILE_SCORE - This table has a row for each beneficiary and score type
    c. SAGE_OFILE_SCORE_PART - This table is created for the purposes of BI reporting. This has rows for beneficiaries and the variable switch names that are equal to 1 along with it's coefficient

Note: Each run of the model engine will drop the previously created tables. The output tables will need to copied to another name if required.

## License

SaGe Risk Engine is licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0). See LICENSE.md for more info.
