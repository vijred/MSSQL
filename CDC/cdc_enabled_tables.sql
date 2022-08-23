-- List of all CDC enabled tables on a given database 

SELECT s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1
ORDER BY 2 


--  Generate SQL for Summary of CTC Tables 
SELECT 'select '''+tb.name+'_''+CONVERT(NVARCHAR(100),__$operation) AS OperationID,  count(*) as mycount from cdc.dbo_'+tb.name+'_CT GROUP BY __$operation UNION ALL' AS Q
, s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1
ORDER BY 2 




-- Group by Table 
SELECT 'select '''+tb.name+''' TableName,  count(*) as mycount from cdc.dbo_'+tb.name+'_CT UNION ALL' AS Q
, s.name AS Schema_Name, tb.name AS Table_Name
, tb.object_id, tb.type, tb.type_desc, tb.is_tracked_by_cdc
FROM sys.tables tb
INNER JOIN sys.schemas s on s.schema_id = tb.schema_id
WHERE tb.is_tracked_by_cdc = 1
ORDER BY 2 

