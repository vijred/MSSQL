
-- Last Index Update , Scan, Seen infomration on given Database 

SELECT
        DB_NAME(database_id) DatabaseName
        , last_user_update , *
    FROM sys.dm_db_index_usage_stats  AS ius
JOIN sys.objects so on so.object_id = ius.object_id  
	WHERE so.type_desc NOT in ('SYSTEM_TABLE')
	AND database_id = db_id()
	order by 2

