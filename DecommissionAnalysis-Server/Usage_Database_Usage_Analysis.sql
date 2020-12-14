

-- This is handy-dandy SQL that can be used to validate different scenarios if I have to make a decision about server decommission! 
-- This is only guidelines, update the SQL statemetns as needed.

-- 0. When was the server last rebooted 

-- 0. Version
select @@version

-- Last reboot time based on TempDB creation time 
sp_helpdb tempdb


select create_date, * from sys.databases where name = 'tempdb'
select create_date, * from sys.databases where name not in ('master', 'tempdb', 'model', 'msdb')


-- 1. Find Table access details on given database 
SELECT DB_NAME(ius.[database_id]) AS [Database],
SCHEMA_NAME(so.schema_id) + '.' + OBJECT_NAME(ius.[object_id]) AS [TableName],
MAX(ius.[last_user_lookup]) AS [last_user_lookup],
MAX(ius.[last_user_scan]) AS [last_user_scan],
MAX(ius.[last_user_seek]) AS [last_user_seek] ,
MAX(ius.[last_user_update]) AS [last_user_update],
max(so.type_desc) as Max_Sysobject_Type
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
WHERE so.type_desc NOT in ('SYSTEM_TABLE')
AND ius.[database_id] = DB_ID()
GROUP BY ius.[database_id], ius.[object_id], so.schema_id;

-- 1.1.1 run the same query against all databases 

DECLARE @query nvarchar(2048)

set @query = 'use [?]; SELECT DB_NAME(ius.[database_id]) AS [Database],
SCHEMA_NAME(so.schema_id) + ''.'' + OBJECT_NAME(ius.[object_id]) AS [TableName],
MAX(ius.[last_user_lookup]) AS [last_user_lookup],
MAX(ius.[last_user_scan]) AS [last_user_scan],
MAX(ius.[last_user_seek]) AS [last_user_seek] ,
MAX(ius.[last_user_update]) AS [last_user_update],
max(so.type_desc) as Max_Sysobject_Type
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
WHERE so.type_desc NOT in (''SYSTEM_TABLE'')
AND ius.[database_id] = DB_ID()
GROUP BY ius.[database_id], ius.[object_id], so.schema_id
ORDER BY last_user_scan DESC; '
  
EXEC sp_msforeachdb @query



-- 1.2 All Databases 

SELECT DB_NAME(ius.[database_id]) AS [Database],
SCHEMA_NAME(so.schema_id) + '.' + OBJECT_NAME(ius.[object_id]) AS [TableName],
MAX(ius.[last_user_lookup]) AS [last_user_lookup],
MAX(ius.[last_user_scan]) AS [last_user_scan],
MAX(ius.[last_user_seek]) AS [last_user_seek] ,
MAX(ius.[last_user_update]) AS [last_user_update],
max(so.type_desc) as Max_Sysobject_Type
FROM sys.dm_db_index_usage_stats AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
WHERE so.type_desc NOT in ('SYSTEM_TABLE')
-- AND ius.[database_id] = DB_ID()
GROUP BY ius.[database_id], ius.[object_id], so.schema_id
ORDER BY 1 



-- 2. Each Database Last Access date

SELECT DatabaseName, MAX(LastAccessDate) LastAccessDate
FROM
    (SELECT
        DB_NAME(database_id) DatabaseName
        , last_user_seek
        , last_user_scan
        , last_user_lookup
        , last_user_update
    FROM sys.dm_db_index_usage_stats  AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
	WHERE so.type_desc NOT in ('SYSTEM_TABLE') ) AS PivotTable
UNPIVOT 
    (LastAccessDate FOR last_user_access IN
        (last_user_seek
        , last_user_scan
        , last_user_lookup
        , last_user_update)
    ) AS UnpivotTable
GROUP BY DatabaseName
HAVING DatabaseName NOT IN ('master', 'tempdb', 'model', 'msdb')
ORDER BY 2




-- 3. Last Update date 

SELECT DatabaseName, MAX(LastUpdateDate) LastUpdateDate
FROM
    (SELECT
        DB_NAME(database_id) DatabaseName
        , last_user_update
    FROM sys.dm_db_index_usage_stats  AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
	WHERE so.type_desc NOT in ('SYSTEM_TABLE') ) AS PivotTable
UNPIVOT 
    (LastUpdateDate FOR last_user_access IN
        (last_user_update)
    ) AS UnpivotTable
GROUP BY DatabaseName
HAVING DatabaseName NOT IN ('master', 'tempdb', 'model', 'msdb')
ORDER BY 2



-- 4. Connection counts on each database 
SELECT @@ServerName AS server
 ,NAME AS dbname
 ,COUNT(STATUS) AS number_of_connections
 ,GETDATE() AS timestamp
FROM sys.databases sd
LEFT JOIN sys.sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
GROUP BY NAME
ORDER BY 2 


-- 5. Capture processes every few minutes and logon trigger:
--https://www.mssqltips.com/sqlservertip/3171/identify-sql-server-databases-that-are-no-longer-in-use/


-- 5.2 Enable Database configuration to capture all login attempts not just failures 


-- 5.3 
sp_who2 
sp_whoisactive 


select r.session_id,@@servername instance, command,start_time, getdate() [current_time], percent_complete
,r.status,command ,blocking_session_id,wait_type,r.total_elapsed_time,wait_time,last_wait_type,wait_resource,query_hash,query_plan_hash
,db_name(r.database_id) as Databasename, s.login_name, s.host_name, s.program_name
--,statement_sql_handle
,text
from sys.dm_exec_requests r
join sys.dm_exec_sessions s on s.session_id  = r.session_id 
cross apply sys.dm_exec_sql_text(sql_handle)
order by 1 


-- 6. Execution Plans on the database 
SELECT top 1000
  DB_NAME(pl.dbid) AS DatabaseName ,
  SUBSTRING(tx.[text],
    (qs.statement_start_offset / 2) + 1,
    (CASE WHEN qs.statement_end_offset =-1 THEN DATALENGTH(tx.text) ELSE qs.statement_end_offset END - qs.statement_start_offset)
    / 2 + 1) AS QueryText,
  case when pl.query_plan LIKE '%<MissingIndexes>%' then 1 else 0 end as [Missing Indexes?],
    qs.execution_count,
  qs.total_worker_time/execution_count AS avg_cpu_time,
  qs.total_worker_time AS total_cpu_time,
  qs.total_logical_reads/execution_count AS avg_logical_reads,
  qs.total_logical_reads,
  qs.creation_time AS [plan creation time],
  qs.last_execution_time [last execution time],
  CAST(pl.query_plan AS XML) AS sqlplan
FROM    sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS pl
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS tx
--WHERE pl.query_plan LIKE '%[AdventureWorks2012]%'
 WHERE DB_NAME(pl.dbid) not in  ('master', 'tempdb', 'model', 'msdb')
-- ORDER BY execution_count DESC 
ORDER BY qs.last_execution_time DESC 
OPTION (RECOMPILE);
GO




-- 7. Login infomrtion from Server event viewer


-- 8. Check Mirroring databse infomration 

select DB_NAME(database_id) as DB_Name,
mirroring_state_desc, *
from sys.database_mirroring 
WHERE mirroring_guid IS NOT NULL 
GO



-- 9. Inactive Databases
SELECT @@SERVERNAME as ServerName, name as DatabaseNAme, state_desc, is_read_only from sys.databases  
where name not in ( 
'master', 
'tempdb', 
'model', 
'msdb')  AND state_desc <> 'ONLINE'AND state_desc <> 'ONLINE'
GO



-- 10.. Always On infomration  (Only on Always-On datbases)
select @@SERVERNAME as ServerName, primary_replica AS PrimaryReplica from sys.dm_hadr_availability_group_states			


-- 11. All SQL Statemetns in cache that are not from system databases 
SELECT top 1000 db_name(dbid) AS DBName, *
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.plan_handle) e
WHERE 1=1
AND db_name(dbid) NOT in ('master','msdb','tempdb','model')
ORDER BY s.last_execution_time



-- 12. Find records from sp_who2 within given timeframe
DECLARE @Table TABLE(
	SPID INT, Status VARCHAR(MAX), LOGIN VARCHAR(MAX), HostName VARCHAR(MAX), BlkBy VARCHAR(MAX),
	DBName VARCHAR(MAX), Command VARCHAR(MAX), CPUTime INT, DiskIO INT, LastBatch VARCHAR(MAX),
	ProgramName VARCHAR(MAX), SPID_1 INT, REQUESTID INT, insertdatetime datetime default getdate())
DECLARE @i int = 0
while (@i < 4)
begin
	INSERT INTO @Table(SPID,Status,LOGIN,HostName,BlkBy,DBName,Command,CPUTime,DiskIO,LastBatch,ProgramName,SPID_1,REQUESTID) EXEC sp_who2
	WAITFOR DELAY '00:00:02'; 
	set @i = @i + 1 
end
SELECT  * FROM    @Table
WHERE dbname NOT in ('master','msdb','tempdb','model')
SELECT  * FROM    @Table
