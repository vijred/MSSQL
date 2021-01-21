

use [Databasename]

select  (size*8/1024/1024) as SizeGB, * from sys.database_files
