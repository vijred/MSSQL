
-- TSQL to understand the trends of wait-Stats on a Given SQLQueryID or overall databse 

DECLARE @Numberofhours INT = 20 

;WITH CTE AS (
select  wait_category_desc, qsrsi.start_time -- convert(date,qsrsi.start_time) 
 , avg(avg_query_wait_time_ms) as avg_query_wait_time_ms
from [sys].[query_store_query] qsq
--join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id
join [sys].[query_store_plan] qsp on qsp.Query_id = qsq.Query_id 
join [sys].[query_store_wait_stats] qsw on qsw.plan_id = qsp.plan_id -- and wait_category_desc = 'Parallelism'  -- and wait_category_desc = 'Lock' -- and avg_query_wait_time_ms > 20 
join [sys].[query_store_runtime_stats] qsrs on qsrs.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats_interval] qsrsi on qsrsi.runtime_stats_interval_id = qsw.runtime_stats_interval_id
--WHERE qsqt.query_sql_text like '%SELECT %' 
--AND qsqt.query_sql_text like '%TimeslicePre%'
where 1=1
 -- qsq.query_id in( 1964420959 ) -- ,2013746646, 1953905594 )
and start_time > dateadd(hh,-1*@Numberofhours,GETDATE()) 
group by  engine_version, wait_category_desc, qsrsi.start_time -- convert(date,qsrsi.start_time) 
-- order by wait_category_desc, qsrsi.start_time desc
)
SELECT * FROM CTE 
PIVOT(
	SUM(avg_query_wait_time_ms) 
	FOR wait_category_desc IN 
	( [Buffer IO], [Buffer Latch], [CPU], [Idle], [Latch] ,[Lock], [Log Rate Governor], [Memory], [Network IO] ,[Other Disk IO], [Parallelism], [Preemptive], [Replication], [Tracing], [Tran Log IO], [Unknown])
) AS pvt
ORDER BY start_time DESC 
