
When you use CDC, there is no easy way to find when latest record is modified on any CDC table.
Technically, `fn_cdc_get_max_lsn` function should get the latest LSN however documentation of `cdc.lsn_time_mapping` indicates there will be some dummy entries. Following SQL statement is one of the options to get latest cdc updated and and latest LSN value.

```
SELECT TOP 1 ISNULL(tran_begin_time,'1990/1/1') AS latest_tran_begin_time
, ISNULL(start_lsn,0x00000000000000000000) as Latest_known_lsn FROM (select 1 as mycol) m
LEFT JOIN cdc.lsn_time_mapping l ON m.mycol =1 AND tran_id <> 0x00 
order by tran_begin_time desc 
```

Reference - https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/cdc-lsn-time-mapping-transact-sql?view=sql-server-ver16 
`Entries may also be logged for which there are no change tables entries. This allows the table to record the completion of LSN processing in periods of low or no change activity.`
