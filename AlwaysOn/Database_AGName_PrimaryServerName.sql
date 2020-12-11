
-- Database, ServerName, Primary ServerName, IsPrimaryDatabase
-- Created by vijred 

WITH CTE AS(
SELECT @@SERVERNAME as Servername,
	adc.database_name, 
	ag.name AS ag_name, 
	ags.Primary_replica as PrimaryServer	
	,case WHEN (@@SERVERNAME = ags.Primary_replica) THEN 'Database-ReadWrite'
	else 'Database-Standalone/ReadOnly' END AS IsDatabasePrimaryReadWrite
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_databases_cluster AS adc 
	ON drs.group_id = adc.group_id AND 
	drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag
	ON ag.group_id = drs.group_id
join sys.dm_hadr_availability_group_states ags 
	ON ag.group_id = ags.group_id
WHERE 1=1
AND is_local = 1)
select * from CTE 
UNION
SELECT @@SERVERNAME, D.name, 'DatabaseIsStandalone', 'NA' , 'StandaloneDatabase' FROM CTE 
RIGHT JOIN sys.databases D on D.name = cte.database_name 
WHERE CTE.Database_Name is NULL
order by 2 
