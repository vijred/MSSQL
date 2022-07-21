
-- 2_insertrecords_CDC_IntegrationTest

declare @i int = 0

while (@i < 399)
begin
	insert into t(sometext,insertdatetime) values('nothing',getdate())
	-- print @i 
	SET @i = @i + 1 
	WAITFOR DELAY '00:00:00.001'
end

