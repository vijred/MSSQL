-- Following statement is to find active session details based on Given Querystore-QueryID ; This helps to understand where the connection being established, user runing the given QueryID

DECLARE @QueryID INT 
SET @QueryID = 1676293982 

SELECT s.host_name, s.last_request_start_time ,s.last_request_end_time, r.start_time
,datediff(second,r.start_time,getdate()) as Runtime_Seconds
, * from sys.dm_exec_requests r
join sys.dm_exec_sessions s on s.session_id  = r.session_id 
join [sys].[query_store_query] qsq on qsq.query_hash = r.query_hash 
WHERE r.query_hash IS NOT  NULL
AND query_id = @QueryID 
