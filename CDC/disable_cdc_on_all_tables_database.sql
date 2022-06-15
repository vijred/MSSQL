-- Disable CDC on all Tables , database 
-- Vijay Kundanagurthi

SET NOCOUNT ON

DECLARE @disablequerytable table (
		querystring nvarchar(600), 
		cdc_tablename nvarchar(600)) 
DECLARE @q nvarchar(600)
DECLARE @cdc_tablename nvarchar(600)
DECLARE @db_name nvarchar(80) = db_name()

IF EXISTS ( SELECT is_cdc_enabled, * FROM sys.databases
WHERE name = db_name() AND is_cdc_enabled = 1 )
BEGIN
	INSERT INTO @disablequerytable
	SELECT  TOP 2000 'EXEC sys.sp_cdc_disable_table
	 @source_schema = ''' + OBJECT_SCHEMA_NAME (source_object_id) +''',
	 @source_name = ''' + object_name(source_object_id)+ ''',
	 @capture_instance = '''+ capture_instance +''';' AS querystring, object_name(source_object_id) as CDC_TableName  From cdc.change_tables 
 
	 WHILE EXISTS(SELECT 1 FROM @disablequerytable)
	 BEGIN
		SELECT TOP 1 @q = querystring , @cdc_tablename = cdc_tablename FROM @disablequerytable
		DELETE FROM @disablequerytable WHERE @q = querystring
		print 'Disabling CDC on table '+@cdc_tablename
		EXEC (@q)
	 END 
	print 'Disabling CDC on database - ' + @db_name
	EXEC sys.sp_cdc_disable_db  
END

SET NOCOUNT OFF
