

-- A Demo to understand Ghost records 

USE DatabaseName

/****** Create a sample Table [Messages_0_Id]  ******/
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Messages_0_Id](
	[PayloadId] [bigint] NOT NULL,
	[SampleMessage] nchar(2000),
PRIMARY KEY CLUSTERED 
(
	[PayloadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

insert into Messages_0_Id values(1,'Sample Message') 
GO


-- Number of logical reads must be minimum
SET STATISTICS IO ON
--SET STATISTICS TIME ON
 SELECT * FROM Messages_0_Id
SET STATISTICS IO OFF
--SET STATISTICS TIME OFF



-- -- Suspend replication 
USE master
ALTER DATABASE [DBATools] SET HADR SUSPEND;
GO
USE DBATOOLS 
GO


--SET NOCOUNT ON 
UPDATE Messages_0_Id SET PayloadId = PayloadId + 1 
GO 50 


-- Number of logical reads to go up 
SET STATISTICS IO ON
SET STATISTICS TIME ON
 SELECT * FROM Messages_0_Id
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO

-- Partition stats 
select * from sys.dm_db_partition_stats where object_id = object_id('Messages_0_Id')
GO

-- Ghost record count 
select record_count,
       ghost_record_count,
       version_ghost_record_count
	   ,index_id, index_level
	   ,page_count
  from sys.dm_db_index_physical_stats(db_id(), object_id('dbo.Messages_0_Id'), default, default, 'detailed')
GO


-- -- resume Replication 
USE master
ALTER DATABASE [DBATools] SET HADR RESUME;
GO
USE DBATools
GO


-- Number of logical reads to come down once the DB is in Sync
SET STATISTICS IO ON
SET STATISTICS TIME ON
 SELECT * FROM Messages_0_Id
SET STATISTICS IO OFF
SET STATISTICS TIME OFF
GO




-- -- -- No dependency with Isolation level 
------SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

------ -- Detailed information about the page, un-documented 
----select top 10000 * from sys.dm_db_database_page_allocations(6,597577167,1,1,'limited')
------ db_id= 5, table_id, IndexID, PartitionID


-- Drop table 
DROP TABLE [Messages_0_Id]
