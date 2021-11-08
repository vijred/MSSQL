


select * from msdb..cdc_job

-- Check the Throughput of CDC – 
SELECT command_count/duration AS [Throughput] FROM sys.dm_cdc_log_scan_sessions WHERE session_id = 0

-- CDC is just a replication – You can use to check the latency of data between source and CT table
sp_replcounters

-- Check the Status of CDC flow-

select 
command_count,log_record_count,* from sys.dm_cdc_log_scan_sessions  --where session_id = 0
order by 3 desc

-- Ref: 
-- --- http://weblogs.sqlteam.com/derekc/archive/2008/01/28/60469.aspx




