
-- 1. Find list of SQL statements with Forced Execution Plan
-- 2. Force one of the Execution Plan
-- 3. Unforce one of the Execution Plans 

--
-- 1. Find all SQL Statements with forced execution plan
SELECT top 100 Txt.query_text_id, Txt.query_sql_text, Pl.plan_id, Qry.* 
FROM sys.query_store_plan AS Pl 
JOIN sys.query_store_query AS Qry 
    ON Pl.query_id = Qry.query_id 
JOIN sys.query_store_query_text AS Txt 
    ON Qry.query_text_id = Txt.query_text_id
    where is_forced_plan = 1;
 

-- 2. Stored procedure to Force Given Execution Plan
sp_query_store_force_plan [ @query_id = ] query_id , [ @plan_id = ] plan_id [;] 
 

-- 3. Stored procedure to Un-Force Given Execution Plan
sp_query_store_unforce_plan [ @query_id = ] query_id , [ @plan_id = ] plan_id [;] 
--
