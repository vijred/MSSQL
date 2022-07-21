-- 1_prepare_CDC_IntegrationTest 

create table t(i int identity(1,1), sometext nchar(3992), insertdatetime datetime);

-- Add table t to cdc for tracking 
EXEC sys.sp_cdc_enable_table  @source_schema = N'dbo',  @source_name   = N't',  @role_name  = NULL,  @supports_net_changes = 0


create table checkpointtable(tablename nvarchar(100), fullcopydatetime datetime)
