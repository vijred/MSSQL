
-- -- Keep track of specific execution plan for improvements  
SELECT top 1000 
        execution_count, total_elapsed_time/execution_count as Average_ElapseTime, last_elapsed_time, max_elapsed_time, min_elapsed_time, creation_time, last_execution_time, d.plan_handle ,d.sql_handle 
FROM    sys.dm_exec_query_stats d
	WHERE SQL_handle = 0x03000600F2A43A426B226F0102A3000000000000000000000000000000000000000000000000000000000000


-- Find Execution plan

SELECT  query_plan
FROM    sys.dm_exec_query_plan(0x0500050038C1A312105638CD4500000001000000000000000000000000000000000000000000000000000000);




-- QueryCost from ExecutionPlan 

SELECT TOP(50)
      p.query_plan
    , e.[text]
    , qyery_cost = p.query_plan.value(
            '(/*:ShowPlanXML/*:BatchSequence/*:Batch/*:Statements/*:StmtSimple/@StatementSubTreeCost)[1]',
            'FLOAT'
        )
    , s.last_execution_time
    , last_exec_ms = s.last_worker_time / 1000
    , s.execution_count
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(s.plan_handle) e
WHERE 1=1
-- AND e.[text] NOT LIKE '%sys%'
--     AND s.last_execution_time >= DATEADD(MS, -2500, '2016-02-10 19:41:45.983')
    AND e.[dbid] = DB_ID()
ORDER BY s.last_execution_time



-- Expensive queries running on the Servers 
SELECT top 1000 
        e.text, creation_time, last_execution_time, d.plan_handle ,d.sql_handle ,execution_count, max_elapsed_time, min_elapsed_time, last_elapsed_time, total_elapsed_time/execution_count as Average_ElapseTime, * 
FROM    sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
--  WHERE Plan_handle = 0x01000500C2F9D91C901E000B7100000000000000
	-- WHERE SQL_handle = 0x02000000C2F9D91C0EBFB46B7422DBA298904DB0C2D298A70000000000000000000000000000000000000000
--	where (e.text like '%SELECT su.UserName AS strUserName, su.Name AS strName, su.Email AS strEmail, susl.RoleClassID, su.SystemNumber AS lngSystemNumber, r.ID as RoleID%' ) -- Filter with keyword
	--AND dbid = db_id()
WHERE execution_count < 10
order by Average_ElapseTime  desc -- Dxecution count 



-- Stats, SQL Text 
SELECT top 1000 
        e.text, creation_time, last_execution_time, d.plan_handle ,d.sql_handle ,execution_count, max_elapsed_time, min_elapsed_time, last_elapsed_time, total_elapsed_time/execution_count as Average_ElapseTime
,db_name(dbid) as DBName 
FROM    sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
	WHERE SQL_handle = 0x03000600F2A43A426B226F0102A3000000000000000000000000000000000000000000000000000000000000




-- QueryText using Offset values 

SELECT top 1000 
        st.text, creation_time, last_execution_time, qs.plan_handle ,qs.sql_handle ,execution_count, max_elapsed_time, min_elapsed_time, last_elapsed_time, total_elapsed_time/execution_count as Average_ElapseTime, 
		SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2) + 1) AS Text
		,* 
FROM    sys.dm_exec_query_stats qs
        CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
--  WHERE Plan_handle = 0x01000500C2F9D91C901E000B7100000000000000
	-- WHERE SQL_handle = 0x02000000C2F9D91C0EBFB46B7422DBA298904DB0C2D298A70000000000000000000000000000000000000000
	where (st.text like '%usp_get_esr_coverage_adequacy_analysis_site_setting%' ) -- Filter with keyword
	AND dbid = db_id()
order by 6 desc -- Dxecution count 


-- Find SQL Handle using SQL Text 

SELECT top 1000 
        e.text, creation_time, last_execution_time, d.plan_handle ,d.sql_handle ,execution_count, max_elapsed_time, min_elapsed_time, last_elapsed_time, total_elapsed_time/execution_count as Average_ElapseTime, * 
FROM    sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
--  WHERE Plan_handle = 0x01000500C2F9D91C901E000B7100000000000000
	-- WHERE SQL_handle = 0x02000000C2F9D91C0EBFB46B7422DBA298904DB0C2D298A70000000000000000000000000000000000000000
	where (e.text like '%AdminGetEmployeeList%' ) -- Filter with keyword
	--AND dbid = db_id()
order by 6 desc -- Dxecution count 





-- Additional analysis
SELECT top 1000 
        e.text, creation_time, last_execution_time, d.plan_handle ,d.sql_handle ,execution_count, max_elapsed_time, min_elapsed_time, last_elapsed_time, total_elapsed_time/execution_count as Average_ElapseTime
FROM    sys.dm_exec_query_stats d
        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
	WHERE ( query_hash = '0xB913AADA401C703D' OR query_plan_hash = '0xB47A804BF5DD71AF' )  OR (( query_hash = 0xB913AADA401C703D OR query_plan_hash = 0xB47A804BF5DD71AF ) )
	ORDER BY last_execution_time





-- query execution plan 
SELECT  query_plan
FROM    sys.dm_exec_query_plan(0x05000600F2A43A42C0FECFCA9400000001000000000000000000000000000000000000000000000000000000);
GO


select * from sys.dm_exec_sql_text(0x01000500C2F9D91C901E000B7100000000000000)


-- Clear Plan Cache for specific SQL Statement / Plan
--DBCC FREEPROCCACHE (0x05000600F2A43A4220BB27FA3C00000001000000000000000000000000000000000000000000000000000000);  
--GO  

--DBCC FREEPROCCACHE (0x06000500C2F9D91C40A003713D00000001000000000000000000000000000000000000000000000000000000);  



---- Remove the specific plan from the cache.  
--DBCC FREEPROCCACHE (0x05000600EF63206F305F022F3C00000001000000000000000000000000000000000000000000000000000000);  
--GO  



-- Stats analysis 
--SELECT  count(*)
--FROM    sys.dm_exec_query_stats d
--        CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
  

-- Other options to recompile a procedure 
--sp_recompile [tlo.Sessions_Add]


-- Further analysis 
--sp_who2



-- find SQL Objects 
--select * from sys.objects 
--where name like 'get%'
