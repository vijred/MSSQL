This test is to validate integration of table full copy and cdc delta copy.

Table copy operation (SELECT statement) is not associated with lsn, you need to use `sys.fn_cdc_map_time_to_lsn` function to convert time to lsn. store checkpointdatetime just before initiating SELECT statement (copy operation).
Since time can be stored with a precision of milli second, there will be a channelge when there is a transaction at the same milli second.

* What opitons to choose for `sys.fn_cdc_map_time_to_lsn` function?
  * If missing data is acceptable scenario to handle use `smallest greater than` or `largest less than or equal` 
  * If duplicate data  is acceptable scenario to handle, use `smallest greater than or equal` or `largest less than`

Example of duplicate transaction:
Referring to below image, id#2444 is processed during full data copy. Fetching data using  `smallest greater than or equal` or `largest less than` method assumes id#2444 is a new row! 
![duplicate data](https://github.com/vijred/MSSQL/blob/master/CDC/image/duplicatedata.png?raw=true)

Example of missing data:
Referring to below image, full copy processed records up to id#837. Fetching data using   `smallest greater than` or `largest less than or equal` method misses id#838 and starts cdc extracts from id#839
![missing data](https://github.com/vijred/MSSQL/blob/master/CDC/image/missingdata.png?raw=true)


How to use the test script - 
1. create test table, add it to cdc - 1_prepare_CDC_IntegrationTest.sql
2. Insert a few records into test table - 2_insertrecords_CDC_IntegrationTest.sql 
3. Run the test immedaitely after #2 execution - 3_validate_CDC_IntegrationTest.sql
4. Repeat #2, #3 a few times to reproduce different scenarios 
5. Cleanup test table and checkpoint table - 4_cleanup_CDC_IntegrationTest.sql 

Ref - https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-cdc-map-time-to-lsn-transact-sql?view=sql-server-ver16 
    - https://stackoverflow.com/questions/73057627/how-to-fully-automate-cdc-in-sql-server/73058890#73058890 
