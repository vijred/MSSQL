-- Script not tested yet! 

DECLARE @memberName AS nvarchar(256)
set @memberName = ''
DECLARE @RoleName AS nvarchar(256)

-- find any members of the role if it exists

CREATE TABLE #rolemember (membername nvarchar(256) NOT NULL, Sequence int NOT NULL)

INSERT INTO #rolemember
SELECT distinct grantee.name,  ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS Sequence
FROM     sys.database_role_members ro, 
	 sys.database_principals db_role, 
	 sys.database_principals grantee 
WHERE	ro.role_principal_id = db_role.principal_id
	and ro.member_principal_id = grantee.principal_id
	and db_role.name = @RoleName

--  Drop the Role Members If they exist
IF EXISTS (SELECT 1 FROM #rolemember)
BEGIN
  PRINT '==> Dropping the  databbase role '+@RoleName+' members on: ' + @databaseName
  
DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM #rolemember)
DECLARE @i as INT
set @i = 1

WHILE   @i <= @nbr_statements
   BEGIN   
    set @memberName = (SELECT membername FROM #rolemember WHERE Sequence = @i)
   --Escape username with single quote by replacing it with double quote. 
    set @memberName = replace(@memberName,'''','''''')
    PRINT '==> Dropping member: ''' + @memberName + ''''
    exec('EXEC sp_droprolemember ''' + @RoleName +''', ''' + @memberName + ''' ;')
    SET @i +=1
   END
END

-- drop the @RoleName schema if it exists
IF EXISTS(SELECT 1 FROM sys.schemas where name = @RoleName)
BEGIN
  PRINT '==> Dropping the schema @RoleName ' 
  DROP SCHEMA @RoleName
END

-- drop the @RoleName role if it exists
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @RoleName and type = 'R')
BEGIN
  PRINT '==> Dropping the database role '+@RoleName+' on: ' 
  DROP ROLE @RoleName
END
