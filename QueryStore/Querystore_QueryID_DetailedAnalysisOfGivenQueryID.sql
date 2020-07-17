

-- Querystore, Detailed information on Given Query_ID
-- Filter is to pull data for last 24 hours. Modify of needed 

DECLARE @QueryID int  

SET @QueryID = 19380011

-- USE UserDatabase 

select top 2000 query_sql_text, qsqt.query_text_id,  qsrsi.start_time as MetricDate,  sum(count_executions) As count_executions, 
avg(avg_duration)/1000 AS ms_Approx_avg_duration, sum(count_executions*avg_duration)/1000/1000 as Seconds_TotalExecutionTime, 
avg(avg_cpu_time) as avg_cpu_time,sum(avg_cpu_time*count_executions) as Total_cpu_time,
avg(avg_logical_io_reads) as Avg_LogicalIOReads, sum(avg_logical_io_reads*count_executions) as Total_LogicalIOReads, 
avg(avg_logical_io_writes) as Avg_LogicalIOWrites, sum(avg_logical_io_writes*count_executions) as Total_LogicalIOWrites, 
avg(avg_physical_io_reads) as Avg_PhysicalIOReads, sum(avg_physical_io_reads*count_executions) as Total_PhysicalIOReads, 
avg(avg_duration) as avg_duration, sum(avg_duration*count_executions) as Total_duration, 
avg(avg_query_max_used_memory) as avg_query_max_used_memory, 
avg(avg_rowcount) as avg_rowcount
-- avg(avg_num_physical_io_reads) as avg_num_physical_io_reads, sum(avg_num_physical_io_reads*count_executions) as Total_num_physical_io_reads, 
-- avg(avg_log_bytes_used) as avg_log_bytes_used,
-- avg(avg_tempdb_space_used) as avg_tempdb_space_used
from [sys].[query_store_query] qsq
join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id
join [sys].[query_store_plan] qsp on qsp.Query_id = qsq.Query_id 
-- join [sys].[query_store_wait_stats] qsw on qsw.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats] qsrs on qsrs.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats_interval] qsrsi on qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
--WHERE qsqt.query_sql_text like '%SELECT %' 
--AND qsqt.query_sql_text like '%TimeslicePre%'
--AND qsqt.query_sql_text like '%@TransactionType%' 
where qsq.query_id in( @QueryID ) 
AND qsrsi.start_time > DATEADD(hh,-24,getdate())
group by qsqt.query_text_id, query_sql_text,  qsrsi.start_time
order by 3 desc, 1 




select top 2000 query_sql_text, qsqt.query_text_id,  qsrsi.start_time as MetricDate
,qsp.plan_id
,  count_executions As count_executions, 
avg_duration/1000 AS ms_Approx_avg_duration
,count_executions*avg_duration/1000/1000 as Seconds_TotalExecutionTime, 
avg_cpu_time as avg_cpu_time,
avg_cpu_time*count_executions as Total_cpu_time,
avg_logical_io_reads as Avg_LogicalIDReads
, avg_logical_io_reads*count_executions as Total_LogicalIOReads, 
avg_logical_io_writes as Avg_LogicalIOWrites, 
avg_logical_io_writes*count_executions as Total_LogicalIOWrites, 
avg_physical_io_reads as Avg_PhysicalIOReads, 
avg_physical_io_reads*count_executions as Total_PhysicalIOReads, 
avg_duration as avg_duration, 
avg_duration*count_executions as Total_duration, 
avg_query_max_used_memory as avg_query_max_used_memory, 
avg_rowcount as avg_rowcount
,*
-- avg(avg_num_physical_io_reads) as avg_num_physical_io_reads, sum(avg_num_physical_io_reads*count_executions) as Total_num_physical_io_reads, 
-- avg(avg_log_bytes_used) as avg_log_bytes_used,
-- avg(avg_tempdb_space_used) as avg_tempdb_space_used
from [sys].[query_store_query] qsq
join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id
join [sys].[query_store_plan] qsp on qsp.Query_id = qsq.Query_id 
-- join [sys].[query_store_wait_stats] qsw on qsw.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats] qsrs on qsrs.plan_id = qsp.plan_id 
join [sys].[query_store_runtime_stats_interval] qsrsi on qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
--WHERE qsqt.query_sql_text like '%SELECT %' 
--AND qsqt.query_sql_text like '%TimeslicePre%'
--AND qsqt.query_sql_text like '%@TransactionType%' 
where qsq.query_id in( @QueryID)
AND qsrsi.start_time > DATEADD(hh,-1124,getdate())
-- group by qsqt.query_text_id, query_sql_text,  qsrsi.start_time
order by 3 desc, 1 



--select * from [sys].[query_store_plan] qsp 
--where plan_id = 42855

---- TSQL to get list of SQLs that are not completed and their stats
--select top 200 qsq.query_id, qsq.object_id, query_sql_text, qsrs.*, qsrsi.*  ,qsqt.* from [sys].[query_store_query] qsq
--join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id
--join [sys].[query_store_plan] qsp on qsp.Query_id = qsq.Query_id 
--join [sys].[query_store_runtime_stats] qsrs on qsrs.plan_id = qsp.plan_id 
--join [sys].[query_store_runtime_stats_interval] qsrsi on qsrsi.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
--where execution_type <> 0 -- Not regular (Abort or Exception type / SQLs that are not completed successfully) 
--AND qsq.query_id = @QueryID
--order by last_execution_time  desc 

