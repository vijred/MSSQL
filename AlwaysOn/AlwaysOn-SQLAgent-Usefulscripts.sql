-- -- 1. Option-1
--
-- A . Simple if there is single AG on the Server
if (select primary_replica from sys.dm_hadr_availability_group_states)=(select SERVERPROPERTY ('ServerName'))
print 'true'
else RAISERROR('This is not the server you are looking for…',16,1)

-- B. This scenario works if there are more than 1 AG on given Server, Verify if DB is primary
if ( select is_local from sys.dm_hadr_availability_replica_states where is_local = 1 and role = 1 and replica_id IN ( select replica_id from sys.dm_hadr_database_replica_states where database_id =(
select database_id from sys.databases where name like 'DatabaseName'))) = 1
print 'true'
else RAISERROR('This is not the server you are looking for…',16,1)




-- -- 2. Option-2
--
-- Create a SQLAgent Job which needs to be enabled/disabled based on AG status. Following is sample
-- Update GivenJobNamePattern in below sample works 
DECLARE @TSQL NVARCHAR(MAX) 
DECLARE @UpateOneMore INT = 5
WHILE(@UpateOneMore > 1)
BEGIN
	SELECT TOP 1 @TSQL =  N'exec msdb..sp_update_job @job_name = ''' + j.name + ''', @enabled = ' + 
	 CASE WHEN (ars.role = 1 or ars.role is null )   and j.enabled =0 THEN '1'  -- Enable
		 WHEN  ars.role <> 1   and j.enabled =1 THEN '0'   -- Disable 
	 END  + ' ; '
	FROM msdb.dbo.sysjobs j with(nolock)
	INNER JOIN msdb.dbo.sysjobsteps s  with(nolock)
		ON j.job_id = s.job_id
	INNER JOIN sys.databases dbs WITH (NOLOCK) on dbs.name = s.database_name
	JOIN sys.dm_hadr_availability_replica_states ars WITH (NOLOCK) ON ars.replica_id = dbs.replica_id
	WHERE J.name like 'GivenJobNamePattern%' -- and J.name <> 'GivenJobNamePattern - exclude this'
	if (@@ROWCOUNT > 0)
		EXEC sys.sp_executesql @TSQL
	ELSE 
		SET @UpateOneMore = 0

	SET @UpateOneMore = @UpateOneMore - 1
	WAITFOR DELAY '00:00:03'
END 


-- Create Alert, update job_id to start the job you just created
-- This alert will trigger when AG fails-over, start the job with job_id N'abc06cbf-0a32-458d-aee6-0f2956249e07'
USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'AG Role Change', 
		@message_id=1480, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Application]', 
		@job_id=N'abc06cbf-0a32-458d-aee6-0f2956249e07'
GO
