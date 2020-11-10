

-- Following TSQL generates a statement that can be executed to create replication against all databases  on given elastic pool(s) 

DECLARE @DRServer NVARCHAR(80) 
DECLARE @PoolName NVARCHAR(80) 
DECLARE @PoolName2 NVARCHAR(80) 

SET @DRServer = 'Servernamedr001'
SET @PoolName = 'Server-Pool004'
SET @PoolName2 = 'Server-Pool005'

SELECT @@SERVERNAME as [ServerName],
       dso.elastic_pool_name,
       d.name as DatabaseName,
       dso.edition, r.database_id
,'ALTER DATABASE ['+d.name+'] ADD SECONDARY ON SERVER '+@DRServer+' WITH (ALLOW_CONNECTIONS = ALL, SERVICE_OBJECTIVE = ELASTIC_POOL (name = ['+elastic_pool_name+']));'  AS Q
,r.database_id
FROM sys.databases d inner join sys.database_service_objectives dso on d.database_id = dso.database_id
	   left join sys.geo_replication_links r on d.database_id = r.database_id
WHERE d.Name <> 'master' 
AND  elastic_pool_name in ( @PoolName , @PoolName2)
AND r.database_id is NULL 
