--A. Identify how valuable a customer is to the company relative to other customers
--See customers from the one with more total Spend to the ones with less total spend and see if their contracts have ended
SELECT  cf.phone_number, cf.total_spend, c.is_ended
FROM    customer_facts cf 
INNER JOIN contract_dim c ON cf.contract_id = c.id
GROUP BY cf.phone_number, cf.total_spend, c.is_ended
ORDER BY total_spend DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


--B. Build up a picture of their customers’ profiles
SELECT  cf.phone_number, 
        cf.total_spend, 
        cf.avg_call_duration avg_call,
        cf.dob,
        cp.name as plan,
        c.is_ended is_contract_ended,
        sg.social_class
        
FROM    customer_facts cf 
INNER JOIN contract_dim c ON cf.contract_id = c.id
INNER JOIN contract_plans_dim cp ON cf.contract_plans_id = cp.id
INNER JOIN social_grade_dim sg ON cf.grade_id = sg.grade
GROUP BY cf.phone_number, cf.total_spend, cf.avg_call_duration, c.is_ended, cf.dob, cp.name, sg.social_class
ORDER BY total_spend DESC --probably business will be more interested in who spends more money, so I'll order the same way as in the last query
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


SELECT  phone_number, 
        total_spend,
        total_calls        
FROM    customer_facts 
GROUP BY phone_number,total_spend,total_calls
ORDER BY total_spend DESC --probably business will be more interested in who spends more money, so I'll order the same way as in the last query
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


SELECT  phone_number, 
        total_spend,
        round(percentage_customer_service,1) "%Customer Service",
        round(percentage_international_calls,1) "%Int Calls",
        round(percentage_roaming_calls,1) "%Roaming Calls",
        round(percentage_peak_calls,1) "%Peak Calls",
        round(percentage_offpeak_calls,1) "%Offpeak Calls",
        round(percentage_voicemails,1) "%Voicemails"
        
FROM    customer_facts 
GROUP BY phone_number,total_spend,percentage_customer_service,percentage_international_calls,percentage_roaming_calls,percentage_peak_calls,percentage_offpeak_calls,percentage_voicemails
ORDER BY total_spend DESC --probably business will be more interested in who spends more money, so I'll order the same way as in the last query
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;



--C. Determine whether a customer’s behaviour patterns have changed recently
-- Was there a drop in the number of calls last month or the number of minutes spend on call? (only look at active contracts
-- Was there an increase in the percentage of customer_calls recently also? Or is this customer calling customer service frequently for longer time?
-- Was there a change in the type of calls that this customer makes? Does he have the best plan for this type of calls? Can we offer him a new one?
SELECT  cf.phone_number, 
        cf.total_spend, 
        round(cf.avg_calls_per_month,1) "Avg Calls Per Month",
        round(cf.total_calls_last_month,1) "Total Calls Last Month",
        round((cf.total_calls_last_month * 100 / cf.avg_calls_per_month),1) as "% of last month calls form avg"

FROM    customer_facts cf 
INNER JOIN contract_dim c ON cf.contract_id = c.id
WHERE c.is_ended = 0 -- who ended the contract will not have behaviour for the full last month
AND   cf.total_spend > (SELECT AVG(total_spend) FROM customer_facts)
ORDER BY "% of last month calls form avg" --shows first the users that changed the most for less
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

SELECT  cf.phone_number, 
        cf.total_spend, 
        round((cf.total_calls_last_month * 100 / cf.avg_calls_per_month),1) as "% of last month calls form avg",
        round(percentage_customer_service,1) "% Customer Service",
        round(percentage_customer_service_last_month,1) "% Customer Service Last Month"

FROM    customer_facts cf 
INNER JOIN contract_dim c ON cf.contract_id = c.id
WHERE c.is_ended = 0 -- who ended the contract will not have behaviour for the full last month
AND   cf.total_spend > (SELECT AVG(total_spend) FROM customer_facts)
ORDER BY "% of last month calls form avg" --shows first the users that changed the most for less
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


SELECT  cf.phone_number, 
        cf.total_spend, 
        round((cf.total_calls_last_month * 100 / cf.avg_calls_per_month),1) as "% of last month calls form avg",
        round(percentage_voicemails,1) "% Voicemails",
        round(percentage_voicemails_last_month,1) "% Voicemails Last Month"

FROM    customer_facts cf 
INNER JOIN contract_dim c ON cf.contract_id = c.id
WHERE c.is_ended = 0 -- who ended the contract will not have behaviour for the full last month
AND   cf.total_spend > (SELECT AVG(total_spend) FROM customer_facts)
ORDER BY "% of last month calls form avg" --shows first the users that changed the most for less
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

    
--D. identify the call plans which bring in the most revenue 
SELECT  cp.name, 
        ROUND(SUM (cf.total_spend),2) as contract_plan_revenue,
        SUM(cf.total_calls) as total_calls,
        round(SUM (cf.total_spend) / SUM(cf.total_call_duration),2) as average_revenue_per_call_minute,
        round(SUM (cf.total_spend) / SUM(cf.total_calls),2) as averare_revenue_per_call
FROM    customer_facts cf 
INNER JOIN contract_plans_dim cp ON cf.contract_plans_id = cp.id
GROUP BY cp.name  
ORDER BY contract_plan_revenue DESC