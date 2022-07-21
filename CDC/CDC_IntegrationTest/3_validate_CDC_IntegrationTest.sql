-- 3_validate_CDC_IntegrationTest

--set statistics IO ON 
--set statistics TIME ON 
--set statistics IO OFF
--set statistics TIME OFF

-- insert into maxlsntracker(tablename ,insertdatetime , lsn) values ('t', getdate(), sys.fn_cdc_get_max_lsn())
insert into maxlsntracker(tablename ,fullcopydatetime) values ('t', getdate())

select TOP 2 *, getdate() as fetchdatetime from t
order by insertdatetime desc

select getdate() as SelectStatement_endTime
-- insert into maxlsntracker(tablename ,insertdatetime , lsn) values ('t', getdate(), sys.fn_cdc_get_max_lsn())


--select TOP 100 * from t
--order by insertdatetime desc

--select * from maxlsntracker 
--order by 2 desc 
-- Delay to make sure cdc changes are pushed into cdc table 
WAITFOR DELAY '00:00:21.000'


DECLARE @smallestGreaterorequal_lsn binary(10)
DECLARE @smallestGreater_lsn binary(10)
DECLARE @largestLess_or_equal_lsn binary(10)
DECLARE @largestLess_lsn binary(10)
DECLARE @to_lsn  binary(10)
DECLARE @from_lsn binary(10)
DECLARE @from_lsn2 binary(10)

--DECLARE @TableMin_lsn binary(10)
--SET @TableMin_lsn = sys.fn_cdc_get_min_lsn('dbo_t')

select top 1 
@smallestGreaterorequal_lsn = sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', fullcopydatetime)
,@smallestGreater_lsn = sys.fn_cdc_map_time_to_lsn('smallest greater than', fullcopydatetime)
,@largestLess_or_equal_lsn = sys.fn_cdc_map_time_to_lsn('largest less than or equal', fullcopydatetime)
,@largestLess_lsn = sys.fn_cdc_map_time_to_lsn('largest less than', fullcopydatetime)
from maxlsntracker 
ORDER BY fullcopydatetime desc 

SELECT @to_lsn  = sys.fn_cdc_get_max_lsn()
SELECT @from_lsn = sys.fn_cdc_increment_lsn ( @largestLess_or_equal_lsn )  
SELECT @from_lsn2 = sys.fn_cdc_increment_lsn ( @largestLess_lsn )  

IF (@smallestGreaterorequal_lsn IS NOT NULL)
	SELECT top 1 'First id - smallest greater than or equal' as comment, * FROM cdc.fn_cdc_get_all_changes_dbo_t(@smallestGreaterorequal_lsn, @to_lsn, 'all') ORDER BY 1 

IF (@smallestGreater_lsn IS NOT NULL)
	SELECT top 1 'First id - smallest greater than' as comment, * FROM cdc.fn_cdc_get_all_changes_dbo_t(@smallestGreater_lsn, @to_lsn, 'all') ORDER BY 1 

IF (@from_lsn <= @to_lsn)
	SELECT top 1 'First id - largest less than or equal' as comment, * FROM cdc.fn_cdc_get_all_changes_dbo_t(@from_lsn, @to_lsn, 'all') ORDER BY 1 

IF (@from_lsn2 <= @to_lsn)
	SELECT top 1 'First id - largest less than ' as comment, * FROM cdc.fn_cdc_get_all_changes_dbo_t(@from_lsn2, @to_lsn, 'all') ORDER BY 1 

SELECT TOP 1 fullcopydatetime AS StartTimeOfFullCopy, @smallestGreaterorequal_lsn as smallestGreaterorequal_lsn, @smallestGreater_lsn as smallestGreater_lsn, @largestLess_or_equal_lsn as largestLess_or_equal_lsn
, @largestLess_lsn as largestLess_lsn ,@from_lsn AS From_lsn, @from_lsn2 AS From_lsn2, @to_lsn AS to_lsn FROM maxlsntracker order by fullcopydatetime desc 

select top 300 *
,sys.fn_cdc_map_time_to_lsn('largest less than', insertdatetime)
,sys.fn_cdc_map_time_to_lsn('largest less than or equal', insertdatetime)
,sys.fn_cdc_map_time_to_lsn('smallest greater than or equal', insertdatetime)
,sys.fn_cdc_map_time_to_lsn('smallest greater than', insertdatetime)
from cdc.dbo_t_CT
order by __$start_lsn desc 


