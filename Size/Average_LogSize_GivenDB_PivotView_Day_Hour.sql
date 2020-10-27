
DECLARE @DatabaseName NVARCHAR(80) = N'InteractionMediaStore'

SELECT BackupHour, [1] AS Sunday, [2] AS Monday, [3] AS Tuesday, [4] AS Wednesday, [5] AS Thursday, [6] as Friday, [7] as Saturday 
FROM 
( SELECT  bs.database_name
		,datepart(weekday,bs.backup_start_date) As BackupWeekDay
		,datepart(HOUR,bs.backup_start_date) AS BackupHour
		,CAST( AVG(bs.backup_size) / 1048576 / 1024 AS DECIMAL(10, 2) )  AS [Average_BackupSize_GB]
FROM  msdb.dbo.backupmediafamily bmf
JOIN msdb.dbo.backupmediaset bms ON bmf.media_set_id = bms.media_set_id
JOIN msdb.dbo.backupset bs ON bms.media_set_id = bs.media_set_id
WHERE   1=1 
AND bs.[type] = 'L'
AND bs.is_copy_only = 0
and database_name = @DatabaseName
GROUP BY bs.database_name
		,datepart(weekday,bs.backup_start_date) 
		,datepart(HOUR,bs.backup_start_date)  ) P 
PIVOT  
(  
SUM (Average_BackupSize_GB)  
FOR BackupWeekday IN  
( [1], [2], [3], [4], [5] , [6], [7])  
) AS pvt  
ORDER BY pvt.BackupHour;  






SELECT BackupHour, [1] AS Sunday, [2] AS Monday, [3] AS Tuesday, [4] AS Wednesday, [5] AS Thursday, [6] as Friday, [7] as Saturday 
FROM 
( SELECT  bs.database_name
		,datepart(weekday,bs.backup_start_date) As BackupWeekDay
		,datepart(HOUR,bs.backup_start_date) AS BackupHour
		, CAST( bs.backup_size / 1048576 / 1024 AS DECIMAL(10, 2) ) AS [BackupSize_GB]
FROM  msdb.dbo.backupmediafamily bmf
JOIN msdb.dbo.backupmediaset bms ON bmf.media_set_id = bms.media_set_id
JOIN msdb.dbo.backupset bs ON bms.media_set_id = bs.media_set_id
WHERE   1=1 
AND bs.[type] = 'L'
AND bs.is_copy_only = 0
and database_name = @DatabaseName
) P 
PIVOT  
(  
AVG(BackupSize_GB) 
FOR BackupWeekday IN  
( [1], [2], [3], [4], [5] , [6], [7])  
) AS pvt  
ORDER BY pvt.BackupHour;  



---- UnPIVOT Sample 
--select BackupHour, BackupDay, AverageLogSize_GB FROM #LogBackupSizePivot
--UNPIVOT 
--(
--	AverageLogSize_GB FOR BackupDay in (Sunday, Monday, Tuesday)
--) AS UnPivotTable 

