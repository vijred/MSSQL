

-- Following SQL can be be used to get overall summary of waits and its trends for each Time period. 

select  top 60000 engine_version, wait_category_desc, qsrsi.start_time -- convert(date,qsrsi.start_time) 
 , avg(avg_query_wait_time_ms) as avg_query_wait_time_ms, sum (count_executions) as TotalExecCount
from [sys].[query_store_query] qsq
--join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id
join [sys].[query_store_plan] qsp on qsp.Query_id = qsq.Query_id 
join [sys].[query_store_wait_stats] qsw on qsw.plan_id = qsp.plan_id -- and wait_category_desc = 'Parallelism'  -- and wait_category_desc = 'Lock' -- and avg_query_wait_time_ms > 20 
join [sys].[query_store_runtime_stats] qsrs on qsrs.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats_interval] qsrsi on qsrsi.runtime_stats_interval_id = qsw.runtime_stats_interval_id
--WHERE qsqt.query_sql_text like '%SELECT %' 
--AND qsqt.query_sql_text like '%TimeslicePre%'
--AND qsqt.query_sql_text like '%@TransactionType%' 
where 1=1
 -- qsq.query_id in( 1964420959 ) -- ,2013746646, 1953905594 )
and start_time > '2021-03-04 22:00:00.0000000 +00:00'
group by  engine_version, wait_category_desc, qsrsi.start_time -- convert(date,qsrsi.start_time) 
order by wait_category_desc, qsrsi.start_time desc

