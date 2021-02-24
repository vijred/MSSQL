-- Following to capture Always-On Data Movement Tracing 

CREATE EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER
ADD EVENT sqlserver.file_write_completed,
ADD EVENT sqlserver.file_write_enqueued,
ADD EVENT sqlserver.hadr_apply_log_block,
ADD EVENT sqlserver.hadr_apply_vlfheader,
ADD EVENT sqlserver.hadr_capture_compressed_log_cache,
ADD EVENT sqlserver.hadr_capture_filestream_wait,
ADD EVENT sqlserver.hadr_capture_log_block,
ADD EVENT sqlserver.hadr_capture_vlfheader,
ADD EVENT sqlserver.hadr_db_commit_mgr_harden,
ADD EVENT sqlserver.hadr_db_commit_mgr_harden_still_waiting,
ADD EVENT sqlserver.hadr_db_commit_mgr_update_harden,
ADD EVENT sqlserver.hadr_filestream_processed_block,
ADD EVENT sqlserver.hadr_log_block_compression,
ADD EVENT sqlserver.hadr_log_block_decompression,
ADD EVENT sqlserver.hadr_log_block_group_commit ,
ADD EVENT sqlserver.hadr_log_block_send_complete,
ADD EVENT sqlserver.hadr_lsn_send_complete,
ADD EVENT sqlserver.hadr_receive_harden_lsn_message,
ADD EVENT sqlserver.hadr_send_harden_lsn_message,
ADD EVENT sqlserver.hadr_transport_flow_control_action,
ADD EVENT sqlserver.hadr_transport_receive_log_block_message,
ADD EVENT sqlserver.log_block_pushed_to_logpool,
ADD EVENT sqlserver.log_flush_complete ,
ADD EVENT sqlserver.log_flush_start,
ADD EVENT sqlserver.recovery_unit_harden_log_timestamps
--CHANGE LOCATION OF FILE BELOW TO PSSDIAG OUTPUT DIRECTORY
ADD TARGET package0.event_file(SET filename=N'M:\SQL\Backups\ExcludeFromNetbackup\02232021\H2_AlwaysOn_Data_Movement_Tracing.xel',max_file_size=(500),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)

GO


-- -- Start the Events 
-- ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE=START;


-- -- Stop the event 
-- ALTER EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER STATE=STOP;


-- -- -- Drop an Event 
-- -- DROP EVENT SESSION [AlwaysOn_Data_Movement_Tracing] ON SERVER  
-- -- GO 

