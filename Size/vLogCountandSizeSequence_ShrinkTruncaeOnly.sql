

-- VLog fiZe and count on all databases 

SELECT [name], s.database_id,
COUNT(l.database_id) AS 'VLF Count',
SUM(vlf_size_mb) AS 'VLF Size (MB)',
SUM(CAST(vlf_active AS INT)) AS 'Active VLF',
SUM(vlf_active*vlf_size_mb) AS 'Active VLF Size (MB)',
COUNT(l.database_id)-SUM(CAST(vlf_active AS INT)) AS 'In-active VLF',
SUM(vlf_size_mb)-SUM(vlf_active*vlf_size_mb) AS 'In-active VLF Size (MB)'
FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) l
GROUP BY [name], s.database_id
ORDER BY 'VLF Count' DESC
GO


-- VLog fiZe and count on all databases 
SELECT [name], vlf_sequence_number, s.database_id,
-- COUNT(l.database_id) AS 'VLF Count',
vlf_size_mb AS 'VLF Size (MB)',
vlf_active  AS 'Active VLF'
-- vlf_size_mb AS 'VLF Size (MB)'
-- COUNT(l.database_id)-SUM(CAST(vlf_active AS INT)) AS 'In-active VLF',
-- SUM(vlf_size_mb)-SUM(vlf_active*vlf_size_mb) AS 'In-active VLF Size (MB)'
 -- ,*
,vlf_begin_offset
,vlf_create_lsn

FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) l
--GROUP BY [name], s.database_id
--ORDER BY 'VLF Count' DESC
-- WHERE [name] = 'Uptake'
-- ORDER BY [name], vlf_sequence_number
-- WHERE name = 'Adeptia_Log'
ORDER BY 1, vlf_begin_offset
GO




-- VLog fiZe and count on all databases 

SELECT [name], vlf_sequence_number, s.database_id,
-- COUNT(l.database_id) AS 'VLF Count',
vlf_size_mb AS 'VLF Size (MB)',
vlf_active  AS 'Active VLF'
-- vlf_size_mb AS 'VLF Size (MB)'
-- COUNT(l.database_id)-SUM(CAST(vlf_active AS INT)) AS 'In-active VLF',
-- SUM(vlf_size_mb)-SUM(vlf_active*vlf_size_mb) AS 'In-active VLF Size (MB)'
 -- ,*
,vlf_begin_offset
,vlf_create_lsn
,vlf_first_lsn
,log_reuse_wait_desc
FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) l
--GROUP BY [name], s.database_id
--ORDER BY 'VLF Count' DESC
-- WHERE [name] = 'Uptake'
-- ORDER BY [name], vlf_sequence_number
-- WHERE name = 'Adeptia_Log'
ORDER BY 1, 7
GO



-- -- Sample to troundateonly!! 
--USE [DBName]
--GO
--DBCC SHRINKFILE (N'DBName_Log' , 0, TRUNCATEONLY)
--GO

--USE [DBName]
--select 'DBCC SHRINKFILE (N'''+ name + ''' , 0, TRUNCATEONLY)' AS LogTruncateTSQL
--from sys.database_files
--WHERE type_desc = 'LOG'
