
-- Created by vijred on 3/24/2020
-- This script used to create a custom counter in Idera and create an alert based on the counter 
--select is_receive_enabled, * from DBName.sys.service_queues

DECLARE @MyMessage nvarchar(240)  

-- at least 1 service queue is disabled
IF ( select TOP 1 1 from DBName.sys.service_queues WHERE is_receive_enabled <> 1 ) = 1 
BEGIN
	set @MyMessage = 'DBNameServiceBrokerQueuesMonitor-Warning:  At least one of the Service broker queues is disabled at:' + convert(nvarchar(40),getdate())
	EXEC xp_logevent 72993, @MyMessage, informational;  -- Log warning information in ErroLog
	WAITFOR DELAY '00:00:20'

-- at least 1 service queue is disabled even after a small delay
	IF ( select TOP 1 1 from hrcounselor.sys.service_queues WHERE is_receive_enabled <> 1 ) = 1 
	BEGIN
		set @MyMessage = 'DBNameServiceBrokerQueuesMonitor-Error:  At least one of the Service broker queues is disabled at:' + convert(nvarchar(40),getdate())
		EXEC xp_logevent 72993, @MyMessage, informational;  		
		SELECT 2 as DBNameServiceBrokerQueuesMonitorError
	END
	ELSE
	BEGIN
		SELECT 1 as DBNameServiceBrokerQueuesMonitorError
	END
END
BEGIN
	SELECT 0 as DBNameServiceBrokerQueuesMonitorError
END
