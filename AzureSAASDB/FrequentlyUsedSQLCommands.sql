-- Ref: https://vijredblog.wordpress.com/2016/10/27/sql-commands-in-azure/ 

-- How to rename a database
ALTER DATABASE [dbname] MODIFY NAME = [newdbname]
 
-- delete a database
DROP DATABASE [dbname]
 
-- Move a database into elastic pool (From stand alone or a different pool)
ALTER DATABASE [myDBName] MODIFY ( SERVICE_OBJECTIVE = ELASTIC_POOL (name = [myElasticPoolName] ));
 
-- Move a database from elastic pool to standalone or change Service Tier
ALTER DATABASE [myDBName] MODIFY ( SERVICE_OBJECTIVE = 'S0'); 
 
-- Replication configuration, and status (From user Database)
SELECT link_guid, partner_server, last_replication, replication_lag_sec FROM sys.dm_geo_replication_link_status;
 
SELECT link_guid, partner_server, role_desc, replication_state, replication_state_desc, secondary_allow_connections_desc FROM sys.dm_geo_replication_link_status;
 
-- Replication configuration, and status (From Master Database)
select * from sys.geo_replication_links r
join sys.databases  d on d.database_id = r.database_id
where d.name in ('UserDB1','UserDB2')
 
-- Create replication (Execute on Master database of source server)
ALTER DATABASE [myDB] ADD SECONDARY ON SERVER myServer001 WITH (ALLOW_CONNECTIONS = ALL, SERVICE_OBJECTIVE = ELASTIC_POOL (name = [Srv001-Pool001])); 
 
-- Creating replication to a standard (destination - standard)
ALTER DATABASE [myDB] ADD SECONDARY ON SERVER myDRServer WITH (ALLOW_CONNECTIONS = NO, SERVICE_OBJECTIVE = 'S0'); 
 
-- remove a replication
ALTER DATABASE db1
REMOVE SECONDARY ON SERVER secondaryserver
 
-- Failover a database (Execute on Master databse of destination server)
ALTER DATABASE [myDatabase] FAILOVER
ALTER DATABASE [myDatabase] FORCE_FAILOVER_ALLOW_DATA_LOSS
 
-- Update Database Service tier.
ALTER DATABASE [myDBName] MODIFY (EDITION = 'Standard', SERVICE_OBJECTIVE = 'S0');
ALTER DATABASE [myDBName] MODIFY (EDITION = 'Premium', SERVICE_OBJECTIVE = 'P2');
 
--Creating new user and giving access to a database
 -- Master database
 CREATE LOGIN newUser WITH PASSWORD = 'myNewPassword'
 CREATE USER newUser FOR LOGIN newUser WITH DEFAULT_SCHEMA=[dbo]; 
 
 -- User Database
 CREATE USER newUser FOR LOGIN newUser WITH DEFAULT_SCHEMA=[dbo];
 EXEC sp_addrolemember 'db_owner', 'newUser';
 
-- Check Resource Stats of all databases on a given Server
-- Run it against master database, I see this has 5 minute aggregate values for each -- DB
select top 10 * from sys.resource_stats
where database_name in ('DB1', 'DB2')
order by end_time desc
 
-- Check Resource Stats of a single database
-- Run it against UserDB database
select top 10 * from [sys].[dm_db_resource_stats]
order by end_time desc
 
-- Check Resource Stats of a elastic pool
-- Run it against Master database
select top 10 * from [sys].[elastic_pool_resource_stats]
 
-- All Database metrics of all DBs in a pool on given time
select * from sys.resource_stats rs
JOIN sys.databases d on d.name = rs.database_name
join sys.database_service_objectives dso on d.database_id = dso.database_id
where elastic_pool_name = 'PoolName'
AND rs.end_time &amp;amp;amp;gt; '2017-10-20 20:49:00 -04:00' -- GMT Start time
AND rs.end_time &amp;amp;amp;lt; '2017-10-20 21:16:00 -04:00' -- GMT End time
order by end_time desc
 
-- Check Service Tier of a database
select DATABASEPROPERTYEX(db_name(),'serviceobjective') ServiceObjective,  DATABASEPROPERTYEX(db_name(),'edition') SqlEdition
 
-- Database MaxSize Update statement
ALTER DATABASE [DBName] MODIFY (MAXSIZE = 750 GB);
 
-- Check all Database activities (Example, DB Copy, FailoveR) on Server
-- Execute below command against master database
-- this can also be used to see % completion time of an operation but the data --- in this table will be deleted approximately within 1 hour.
select top 1000 * from [sys].[dm_operation_status]
order by start_time desc
 
-- Events/ Connection information
-- Execute against each Database
select top 100 * from [sys].[event_log]
 
-- Find events excluding most common successful connections 
select top 100 * from [sys].[event_log]
WHERE event_subtype_desc not in ('connection_successful')
and database_name = 'mydbname'
order by 2 desc
 
-- Find all DBs in a given elastic pool
-- TSQL to find Databases, corresponding elastic pool names and DB edition
SELECT
       @@SERVERNAME as [ServerName],
       dso.elastic_pool_name,
       d.name as DatabaseName,
       dso.edition
FROM
       sys.databases d inner join sys.database_service_objectives dso on d.database_id = dso.database_id
WHERE d.Name <> 'master' ORDER BY d.name, dso.elastic_pool_name 
 
-- -- Copy database from one Server to different Server (To be executed on destination server) 
CREATE DATABASE Database1_copy AS COPY OF server1.Database1; 
 
-- Copy database on same Server 
CREATE DATABASE Database1_copy AS COPY OF Database1; 
 
-- Check if any QueryID is running against the database 
-- query_id filter value needs to be updated. 
select qsqt.statement_sql_handle, * 
from [sys].[query_store_query] qsq 
join [sys].[query_store_query_text] qsqt on qsqt.query_text_id = qsq.query_text_id 
join sys.dm_exec_requests dmer on dmer.statement_sql_handle = qsqt.statement_sql_handle 
where query_id = 1960817766 
 
-- -- Update DBOwner in Azure Database 
ALTER AUTHORIZATION ON DATABASE::USERDATABASENAME to [ACCOUNTNAME]; 
 
-- NOTE: AFTER THE CHANGE, make sure to compare SID is same 
USE MASTER 
SELECT name, sid FROM sys.sql_logins where name = 'ACCOUNTNAME'
 
USE USERDATABASENAME 
SELECT name, sid FROM sys.sysusers where name = 'dbo'
 

-- -- Index recommendations, FORCE_LAST_GOOD_PLAN usage 
select * from sys.dm_db_tuning_recommendations 
