
-- List all Always_On failovers (AG Status chagnes) in last 1 month 

DECLARE @EndDate DATETIME = GETDATE() 
DECLARE @StartDate DATETIME = dateadd(dd,-131,GETDATE() )

exec xp_readerrorlog 0						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date

exec xp_readerrorlog 1						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date

exec xp_readerrorlog 2						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date

exec xp_readerrorlog 3						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date

exec xp_readerrorlog 4						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date

exec xp_readerrorlog 5						-- 0=current SQL Server log
						,1						-- 1=SQL Server log, 2=SQL Agent log
						,N'The state of the local availability replica in availability group'					-- Search string
						,null					-- second search string
						,@StartDate			-- start date
						,@EndDate	-- end date
						,N'DESC'				-- order the logs by date
