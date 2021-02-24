
-- This is sample to add a database to AG 


-- PRIMARY 
----------
-- Full Backup on Primary Server 
BACKUP DATABASE [DBName]
TO DISK = 'M:\SQL\Backups\MYBackups\DBName_FULLBackup.bak'

-- Log Backup on Primary 
BACKUP LOG [DBName]
TO DISK = 'M:\SQL\Backups\MYBackups\DBName_LOG_20210224_142805.trn'

-- Add DB to AG on Primary 
ALTER AVAILABILITY GROUP [AGName] ADD DATABASE [DBName];




-------------
-- -- Secondary 
--------------
-- Restore Full Database 
EXECUTE AS LOGIN = 'sa' -- This helps to keep the DB ownership to SA , verify using sys.databases 
RESTORE DATABASE [DBName]
FROM DISK = 'M:\SQL\Backups\MYBackups\DBName_FULLBackup.bak'
WITH NORECOVERY 

-- Restore Diff Bakcup 
RESTORE DATABASE [DBName]
FROM DISK = 'M:\SQL\Backups\MYBackups\DBName_DIFFBackup.bak'
WITH NORECOVERY 

-- Restore Log Backup 
RESTORE LOG [DBName]
FROM DISK = 'M:\SQL\Backups\MYBackups\DBName_FULLBackup.trn'
WITH NORECOVERY 

-- Add Database to AG 
ALTER DATABASE [DBName] 
SET HADR AVAILABILITY GROUP = [AGName] ;



------------
--  Removing a dataase from AG 
------------
-- How to suspend data movement on a given DB 
ALTER DATABASE [DBName] SET HADR SUSPEND;
GO

-- How to remove a database from AG 
ALTER DATABASE [DBName] SET HADR OFF;
GO
