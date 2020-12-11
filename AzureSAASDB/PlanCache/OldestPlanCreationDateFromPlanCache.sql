

-- Azure: Best way to find if the database was failed over recently; This is last created plan from Plan Cache 

select top 100 DB_NAME(dbid), creation_time, * FROM    sys.dm_exec_query_stats qs
JOIN sys.dm_exec_cached_plans cp on cp.plan_handle = qs.plan_handle
cross apply sys.dm_exec_sql_text(qs.plan_handle) as q
where  dbid = db_id()
ORDER BY creation_time

