-- 4_cleanup_CDC_IntegrationTest

EXEC sys.sp_cdc_disable_table   @source_schema = 'dbo',   @source_name = 't',   @capture_instance = 'dbo_t';

DROP TABLE t
DROP TABLE checkpointtable