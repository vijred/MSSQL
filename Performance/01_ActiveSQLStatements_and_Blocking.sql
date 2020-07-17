

-- Includes session table 

select r.session_id,@@servername instance, command,start_time, getdate() [current_time], percent_complete
,r.status,command ,blocking_session_id,wait_type,r.total_elapsed_time,wait_time,last_wait_type,wait_resource,query_hash,query_plan_hash
,db_name(r.database_id) as Databasename, s.login_name, s.host_name, s.program_name
--,statement_sql_handle
,text
from sys.dm_exec_requests r
join sys.dm_exec_sessions s on s.session_id  = r.session_id 
cross apply sys.dm_exec_sql_text(sql_handle)
order by 1 



--select session_id,@@servername instance, command,start_time, getdate() [current_time], percent_complete
--,status,command ,blocking_session_id,wait_type,total_elapsed_time,wait_time,last_wait_type,wait_resource,query_hash,query_plan_hash,statement_sql_handle,text
--from sys.dm_exec_requests
--cross apply sys.dm_exec_sql_text(sql_handle)
--order by 1 



