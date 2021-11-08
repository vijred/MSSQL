


-- -- -- Reference: https://www.red-gate.com/simple-talk/sql/learn-sql-server/introduction-to-change-data-capture-cdc-in-sql-server-2008/ 


-- CDC 
-- CDC is Change Data Capture.

-- -- How to check if CDC is enabled on a Server or DB 


select @@SERVERNAME

-- Check if CDC is enabled or not! 
USE master 
GO 
SELECT [name], database_id, is_cdc_enabled  
FROM sys.databases       
GO     


-- How to enable CDC on DB Sample1 
use Sample1

EXEC sys.sp_cdc_enable_db 
GO  


-- How to disable CDC on a DB Sample1 
EXEC sys.sp_cdc_disable_db 
GO 


-- How to Enable CDC on a Table. 
USE AdventureWorks 
GO 
EXEC sys.sp_cdc_enable_table 
@source_schema = N'HumanResources', 
@source_name   = N'Shift', 
@role_name     = NULL 
GO


-- -- How to Enable CDC on a Table with specific columns only. 
USE AdventureWorks 
GO 
EXEC sys.sp_cdc_enable_table 
@source_schema = N'HumanResources', 
@source_name   = N'Shift', 
@role_name     = NULL, 
@captured_column_list = '[ShiftID],[Name]' 
GO


-- Disable CDC on a table
USE AdventureWorks;
GO
EXECUTE sys.sp_cdc_disable_table 
    @source_schema = N'HumanResources', 
    @source_name = N'Shift',
    @capture_instance = N'HumanResources_Shift';
GO

