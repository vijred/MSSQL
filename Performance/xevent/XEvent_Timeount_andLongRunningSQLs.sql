
-- XEvent for Long Running SQLs
CREATE EVENT SESSION [LongRunningQueries] ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.session_id)
    WHERE ([duration]>(6000000))),

ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.session_id)
    WHERE ([duration]>(6000000)))

ADD TARGET package0.ring_buffer(SET max_events_limit=(0),max_memory=(1048576))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO



-- XEvent for Timeouts , include database filter 
CREATE EVENT SESSION [execution_timeout] ON SERVER 
ADD EVENT sqlserver.attention(
    ACTION(package0.collect_system_time,sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.plan_handle,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)) AND [sqlserver].[database_name]=N'FlexForwardStats'))
ADD TARGET package0.ring_buffer(SET max_events_limit=(0),max_memory=(1048576))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO





--CREATE EVENT SESSION execution_timeout ON SERVER
--ADD EVENT sqlserver.attention
--(ACTION (sqlserver.session_id, sqlserver.database_id, sqlserver.database_name,
--sqlserver.username, sqlserver.sql_text, sqlserver.client_hostname,
--sqlserver.client_app_name)
--WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0))))
--ADD TARGET package0.event_file(SET filename=N'execution_timeout.xel',
--max_file_size=(5),max_rollover_files=(2))
--ALTER EVENT SESSION execution_timeout  ON SERVER STATE = start


-- Start data collection 
ALTER EVENT SESSION [LongRunningQueries] ON SERVER STATE = start
ALTER EVENT SESSION execution_timeout  ON SERVER STATE = start


SELECT CAST(target_data as xml) AS targetdata
FROM sys.dm_xe_session_targets xet
JOIN sys.dm_xe_sessions xes
ON xes.address = xet.event_session_address
WHERE xes.name in ('execution_timeout')
-- WHERE xes.name in ('LongRunningQueries', 'execution_timeout')
AND xet.target_name = 'ring_buffer';



IF OBJECT_ID('tempdb..#capture_waits_data') IS NOT NULL
DROP TABLE #capture_waits_data
SELECT CAST(target_data as xml) AS targetdata
INTO #capture_waits_data
FROM sys.dm_xe_session_targets xet
JOIN sys.dm_xe_sessions xes
ON xes.address = xet.event_session_address
-- WHERE xes.name = 'execution_timeout'
WHERE xes.name in ('LongRunningQueries', 'execution_timeout')
AND xet.target_name = 'ring_buffer';
--*/
/**********************************************************/
SELECT xed.event_data.value('(@timestamp)[1]', 'datetime2') AS datetime_utc,
CONVERT(datetime2,SWITCHOFFSET(CONVERT(datetimeoffset,xed.event_data.value('(@timestamp)[1]', 'datetime2')),DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS datetime_local,
xed.event_data.value('(@name)[1]', 'varchar(50)') AS event_type,
xed.event_data.value('(data[@name="statement"]/value)[1]', 'varchar(max)') AS statement,
xed.event_data.value('(data[@name="duration"]/value)[1]', 'bigint')/1000 AS duration_ms,
xed.event_data.value('(data[@name="cpu_time"]/value)[1]', 'bigint')/1000 AS cpu_time_ms,
xed.event_data.value('(data[@name="physical_reads"]/value)[1]', 'bigint') AS physical_reads,
xed.event_data.value('(data[@name="logical_reads"]/value)[1]', 'bigint') AS logical_reads,
xed.event_data.value('(data[@name="writes"]/value)[1]', 'bigint') AS writes,
xed.event_data.value('(data[@name="row_count"]/value)[1]', 'bigint') AS row_count,
xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(255)') AS database_name,
xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(255)') AS client_hostname,
xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(255)') AS client_app_name,
xed.event_data.value('(action[@name="sql_text"]/value)[1]', 'varchar(MAX)') AS SQLText
FROM #capture_waits_data
CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS xed (event_data)
WHERE 1=1
-- Database filter 
-- AND xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(255)') = 'FlexForwardStats'
ORDER BY 1 
--ALTER EVENT SESSION execution_timeout  ON SERVER STATE = stop 



-- SELECT (@@microsoftversion / 0x1000000) & 0xff AS [VersionMajor]



--ALTER EVENT SESSION LongRunningQueries  ON SERVER STATE = stop 
--DROP EVENT SESSION [LongRunningQueries] ON SERVER 

--ALTER EVENT SESSION execution_timeout  ON SERVER STATE = stop 
--DROP EVENT SESSION execution_timeout ON SERVER 
