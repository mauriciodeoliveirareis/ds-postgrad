set serveroutput on;

-- create intermediate sampled views because the sampling command doesn't work with the full query
CREATE VIEW customer_training_view AS        
SELECT * FROM customer_facts SAMPLE(80) SEED (1)

CREATE VIEW customer_test_view AS        
SELECT * FROM customer_facts minus SELECT * FROM customer_training_view

--create the views that will be used for the ML algoriths
CREATE VIEW cust_churn_training_view AS        
SELECT  cf.phone_number || '->' || ct.start_date as id,
        sg.social_class,
        cp.name contract_plan_name,
        (CASE WHEN substr(dob,8,10) >= 46 and substr(dob,8,10) <= 64 THEN  'boomer'
        ELSE 
            CASE WHEN substr(dob,8,10) >= 65 and substr(dob,8,10) <= 80 THEN  'x'
            ELSE
                CASE WHEN substr(dob,8,10) >= 81 and substr(dob,8,10) <= 96 THEN  'y'
                ELSE 'z' 
                END 
            END
        END) as generation,
        round(cf.percentage_customer_service,3) as percentage_customer_service,
        ct.is_ended as churn
        
        FROM customer_training_view cf 
        INNER JOIN contract_dim ct ON cf.contract_id = ct.id 
        INNER JOIN social_grade sg ON cf.grade_id = sg.grade
        INNER JOIN contract_plans cp ON cf.contract_plans_id = cp.id 


CREATE VIEW cust_churn_test_view AS        
SELECT  cf.phone_number || '->' || ct.start_date as id,
        sg.social_class,
        cp.name contract_plan_name,
        (CASE WHEN substr(dob,8,10) >= 46 and substr(dob,8,10) <= 64 THEN  'boomer'
        ELSE 
            CASE WHEN substr(dob,8,10) >= 65 and substr(dob,8,10) <= 80 THEN  'x'
            ELSE
                CASE WHEN substr(dob,8,10) >= 81 and substr(dob,8,10) <= 96 THEN  'y'
                ELSE 'z' 
                END 
            END
        END) as generation,
        round(cf.percentage_customer_service,3)  as percentage_customer_service,
        ct.is_ended as churn
        
        FROM customer_test_view cf 
        INNER JOIN contract_dim ct ON cf.contract_id = ct.id 
        INNER JOIN social_grade sg ON cf.grade_id = sg.grade
        INNER JOIN contract_plans cp ON cf.contract_plans_id = cp.id 
---


--grant permissions for user manipulae mining model (this is commented out as it has to be run on another window with a used that has permissions to grant those permissions
--GRANT CREATE MINING MODEL TO mauricio;
--GRANT SELECT ANY MINING MODEL TO mauricio;
--GRANT ALTER ANY MINING MODEL TO mauricio;
--GRANT DROP ANY MINING MODEL TO mauricio;
--GRANT COMMENT ANY MINING MODEL TO mauricio;

--create decision tree model 
CREATE TABLE decision_tree_model_settings (
setting_name VARCHAR2(30),
setting_value VARCHAR2(30));

---- Populate the settings table
BEGIN
   INSERT INTO decision_tree_model_settings (setting_name, setting_value)
   VALUES (dbms_data_mining.algo_name,dbms_data_mining.algo_decision_tree);

   INSERT INTO decision_tree_model_settings (setting_name, setting_value)
   VALUES (dbms_data_mining.prep_auto,dbms_data_mining.prep_auto_on);
   COMMIT;
END;

-- Show settings for decision model  
SELECT * FROM decision_tree_model_settings;

-- Create model using training dataset
BEGIN
DBMS_DATA_MINING.CREATE_MODEL(
   model_name => 'Decision_Tree_Model2',
   mining_function => dbms_data_mining.classification,
   data_table_name => 'cust_churn_training_view',
   case_id_column_name => 'id',
   target_column_name => 'churn',
   settings_table_name => 'decision_tree_model_settings');
END;


-- show which ML models I've created  
SELECT model_name,
   mining_function,
   algorithm,
   build_duration,
   model_size
FROM user_MINING_MODELS;

--List the algorithm settings used for the machine learning model (the ones I've defined plus the defaults)   
SELECT setting_name,
   setting_value,
   setting_type
FROM user_mining_model_settings
WHERE model_name in 'DECISION_TREE_MODEL2';
--List the attribute the machine learning model uses. It may use a subset of the attributes. This allows you to see what attributes were selected.
--Here it only used percentage of customer service  
SELECT attribute_name,
   attribute_type,
   usage_type,
   target
from all_mining_model_attributes
where model_name = 'DECISION_TREE_MODEL2';

-- create a view that will contain the case ID column, the predicted label and the prediction probability for each row in the test data set.
CREATE OR REPLACE VIEW customer_churn_dt_test_results
AS
SELECT id,
   prediction(DECISION_TREE_MODEL2 USING *) predicted_value,
   prediction_probability(DECISION_TREE_MODEL2 USING *) probability
FROM cust_churn_test_view;

-- Shows this view with the prediction probabilities
SELECT *
FROM customer_churn_dt_test_results;

--Generating confusion matrix using test data from cust_churn_test_view
--Gave a **** MODEL ACCURACY ****: .7382
DECLARE
   v_accuracy NUMBER;
BEGIN
DBMS_DATA_MINING.COMPUTE_CONFUSION_MATRIX (
   accuracy => v_accuracy,
   apply_result_table_name => 'customer_churn_dt_test_results',
   target_table_name => 'cust_churn_test_view',
   case_id_column_name => 'id',
   target_column_name => 'churn',
   confusion_matrix_table_name => 'customer_churn_dt_confusion_matrix2',
   score_column_name => 'PREDICTED_VALUE',
   score_criterion_column_name => 'PROBABILITY',
   cost_matrix_table_name => null,
   apply_result_schema_name => null,
   target_schema_name => null,
   cost_matrix_schema_name => null,
   score_criterion_type => 'PROBABILITY');
   DBMS_OUTPUT.PUT_LINE('**** Decision Tree Model Prep Auto ON Accuracy ****: ' || ROUND(v_accuracy,4));
END;

--show confusion matrix
--for 0 values, it predicted right 753 times 
--for 1 values, it predicted wrong 267 times
--it basically predicted all the times 0 
SELECT *
FROM customer_churn_dt_confusion_matrix2;

--it basically predicted all the times 0, that doesn't seem like a good model 
SELECT churn, count(*) FROM cust_churn_test_view GROUP BY churn;

-- the probability prediction is not linear, 5 percentage customer service have a higher probability to not churn than 0 and 100 
-- in all cases below the probability is above 0.5 anyways
Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 0 as PERCENTAGE_CUSTOMER_SERVICE) Pred_Prob
from dual;

Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 5 as PERCENTAGE_CUSTOMER_SERVICE) Pred_Prob
from dual;

Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 100 as PERCENTAGE_CUSTOMER_SERVICE) Pred_Prob
from dual;

--as we saw, the model is just using percentage customer service calls, other parms like generation doesn't seem to affect the probability results
Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 5 as PERCENTAGE_CUSTOMER_SERVICE,
'z' as GENERATION) Pred_Prob
from dual;

Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 5 as PERCENTAGE_CUSTOMER_SERVICE,
'boomer' as GENERATION) Pred_Prob
from dual;

Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 5 as PERCENTAGE_CUSTOMER_SERVICE,
'x' as GENERATION,
'cosmopolitan' as contract_plan_name) Pred_Prob
from dual;

Select PREDICTION_PROBABILITY (Decision_Tree_Model2, 0
USING 5 as PERCENTAGE_CUSTOMER_SERVICE,
'x' as GENERATION,
'standard' as contract_plan_name) Pred_Prob
from dual;
--

-- Using nayve bayes with prep auto off
--create decision tree model 
CREATE TABLE naive_bayes_model_settings4 (
setting_name VARCHAR2(30),
setting_value VARCHAR2(30));

---- Populate the settings table
BEGIN
--Don't specify decision tree this time so it will use the default algorithms which is naive bayes
--   INSERT INTO naive_bayes_model_settings (setting_name, setting_value)
--   VALUES (dbms_data_mining.algo_name,dbms_data_mining.algo_decision_tree);

       INSERT INTO naive_bayes_model_settings4 (setting_name, setting_value)
       VALUES (dbms_data_mining.prep_auto,dbms_data_mining.prep_auto_off);
       COMMIT;
END;

-- Show settings for decision model  
SELECT * FROM naive_bayes_model_settings4;

-- Create model using training dataset
BEGIN
DBMS_DATA_MINING.CREATE_MODEL(
   model_name => 'Naive_Bayes_Model4',
   mining_function => dbms_data_mining.classification,
   data_table_name => 'cust_churn_training_view',
   case_id_column_name => 'id',
   target_column_name => 'churn',
   settings_table_name => 'naive_bayes_model_settings4');
END;


-- show which ML models I've created, now it shows the previous decision tree and the  new naive bayes
SELECT model_name,
   mining_function,
   algorithm,
   build_duration,
   model_size
FROM user_MINING_MODELS;

--List the algorithm settings used for the machine learning model (the ones I've defined plus the defaults)   
SELECT setting_name,
   setting_value,
   setting_type
FROM user_mining_model_settings
WHERE model_name in 'NAIVE_BAYES_MODEL4';
--List the attribute the machine learning model uses. It may use a subset of the attributes. This allows you to see what attributes were selected.
--Here we can see that it is using all parms now
SELECT attribute_name,
   attribute_type,
   usage_type,
   target
from all_mining_model_attributes
where model_name = 'NAIVE_BAYES_MODEL4';

-- create a view that will contain the case ID column, the predicted label and the prediction probability for each row in the test data set.
CREATE OR REPLACE VIEW customer_churn_nb_test_results4
AS
SELECT id,
   prediction(NAIVE_BAYES_MODEL4 USING *) predicted_value,
   prediction_probability(NAIVE_BAYES_MODEL4 USING *) probability
FROM cust_churn_test_view;

-- Shows this view with the prediction probabilities
SELECT *
FROM customer_churn_nb_test_results4;

--Generating confusion matrix using test data from cust_churn_test_view
--Gave a slightly different **** Nayve Bayes Prep Auto Model Accuracy ****: .7324, slightly worse than the other
DECLARE
   v_accuracy NUMBER;
BEGIN
DBMS_DATA_MINING.COMPUTE_CONFUSION_MATRIX (
   accuracy => v_accuracy,
   apply_result_table_name => 'customer_churn_nb_test_results4',
   target_table_name => 'cust_churn_test_view',
   case_id_column_name => 'id',
   target_column_name => 'churn',
   confusion_matrix_table_name => 'customer_churn_nb_confusion_matrix4',
   score_column_name => 'PREDICTED_VALUE',
   score_criterion_column_name => 'PROBABILITY',
   cost_matrix_table_name => null,
   apply_result_schema_name => null,
   target_schema_name => null,
   cost_matrix_schema_name => null,
   score_criterion_type => 'PROBABILITY');
   DBMS_OUTPUT.PUT_LINE('**** Nayve Bayes Prep Auto Model Accuracy ****: ' || ROUND(v_accuracy,4));
END;

--show confusion matrix
--Still pretty close to predicting all times 0 but this time it was slightly different
SELECT *
FROM customer_churn_nb_confusion_matrix4;



