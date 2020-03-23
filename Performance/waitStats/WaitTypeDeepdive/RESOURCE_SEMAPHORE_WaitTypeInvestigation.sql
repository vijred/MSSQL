

-- Last modified by vijred on 3/21/2020 
-- RESOURCE_SEMAPHORE investigation
-- Ref: https://www.mssqltips.com/sqlservertip/2827/troubleshooting-sql-server-resourcesemaphore-waittype-memory-issues/

-- Find the number of queries wtih granted memory and waiying for memory 
SELECT * FROM sys.dm_exec_query_resource_semaphores


-- Find actual SQLs granted with memory and waiting for memory 
select top 10 * from sys.dm_exec_query_memory_grants

