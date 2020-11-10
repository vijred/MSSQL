

-- Add single Database to replication; either standalone or to elastic pool 

-- Move a database into elastic pool (From stand alone or a different pool)
ALTER DATABASE [myDBName] MODIFY ( SERVICE_OBJECTIVE = ELASTIC_POOL (name = [myElasticPoolName] ));
 
-- Move a database from elastic pool to standalone or change Service Tier
ALTER DATABASE [myDBName] MODIFY ( SERVICE_OBJECTIVE = 'S0'); 
 

