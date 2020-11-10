

-- Replication statuson given Server 

-- find the status of replication
select * from sys.geo_replication_links r
right join sys.databases  d on d.database_id = r.database_id
where r.database_id is NOT NULL

-- replication_state_desc is the column to look for, CATCH_UP indicates good shape; SEEDING indicates not in sync

