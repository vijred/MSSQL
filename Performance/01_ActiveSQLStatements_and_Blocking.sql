

-- Includes session table 

select r.session_id,r.total_elapsed_time,wait_time,@@servername instance, command,start_time, getdate() [current_time], percent_complete
	,estimated_completion_time
	,estimated_completion_time /60/1000 as estimate_completion_minutes
	,DATEADD(n,(estimated_completion_time /60/1000),GETDATE()) as estimated_completion_time
,r.status,command ,blocking_session_id,wait_type,last_wait_type,wait_resource,query_hash,query_plan_hash
,db_name(r.database_id) as Databasename, s.login_name, s.host_name, s.program_name
--,statement_sql_handle
,s.open_transaction_count
,text
from sys.dm_exec_requests r
join sys.dm_exec_sessions s on s.session_id  = r.session_id 
cross apply sys.dm_exec_sql_text(sql_handle)
where r.session_id <> @@SPID
order by 1 




--select session_id,@@servername instance, command,start_time, getdate() [current_time], percent_complete
--,status,command ,blocking_session_id,wait_type,total_elapsed_time,wait_time,last_wait_type,wait_resource,query_hash,query_plan_hash,statement_sql_handle,text
--from sys.dm_exec_requests
--cross apply sys.dm_exec_sql_text(sql_handle)
--order by 1 





