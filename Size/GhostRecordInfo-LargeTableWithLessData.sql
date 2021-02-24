
-- Sample SQL to find Ghost Records; This helps explain why large reads are done on a small table 
-- SignalR is one of the good example to track such scenario

use DatabaseName

select getdate() as recorddatetime,
       sum(record_count) as records,
       sum(ghost_record_count) as ghost_records,
       sum(version_ghost_record_count) as version_ghost_records
	   ,sum(page_count) as Page_count 
	   ,sum(forwarded_record_count) AS forwarded_record_count
  from sys.dm_db_index_physical_stats(db_id(), object_id('signalR.Messages_0_Id'), default, default, 'detailed')
 where index_id = 1
       and index_level = 0

