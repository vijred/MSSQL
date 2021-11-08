
-- Handy TSQL statements about CDC 
-- These are more focus on troubleshooting and operations perspective ! 

-- 1. How to verify which DBs has CDC Enabled
SELECT [name], database_id, is_cdc_enabled
FROM sys.databases
GO


-- 2. How to find if the jobs are corrupt; if corrupt, we need to recreate the jobs 
use msdb
select * from msdb.dbo.cdc_jobs

-- 3. Delete CDC related jobs from SQL Agent 

-- 4. Re-Create CDC related jobs 
use UserDatabaseName 
exec sys.sp_cdc_add_job @job_type = 'capture',
 @maxtrans = 50000,
 @maxscans = 100,
 @continuous = 1,
 @pollinginterval = 1


exec sys.sp_cdc_add_job @job_type = 'cleanup',
 @retention = 7200,
 @threshold = 50000


-- Error wrong database is selected! 
-- Msg 22901, Level 16, State 1, Procedure sp_MScdc_job_security_check, Line 20 [Batch Start Line 10]
--The database 'msdb' is not enabled for Change Data Capture. Ensure that the correct database context is set and retry the operation. To report on the databases enabled for Change Data Capture, query the is_cdc_enabled column in the sys.databases catalog view.



-- Find list of tables enabled for CDC! 
use USerDatabase
SELECT s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1
