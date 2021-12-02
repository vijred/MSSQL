SQL ODBC commection
===================


* Command to Remove ODBC connection
	-	`Remove-OdbcDsn -Name ntest7d -DsnType System`


* How to read data from odbc connection
```
$conn = new-object System.Data.Odbc.OdbcConnection
$conn.connectionstring = "DSN=localmongobi2;Uid=vjuserid;Pwd=$pw;"
$conn.open()
$dataset = New-Object System.Data.DataSet

$dataset.Clear()
$sqlCommand = "select * from mytokens_cp where _id = 'example_id'"
$cmd = New-object System.Data.Odbc.OdbcCommand($sqlCommand,$conn)
(New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).Fill($dataSet)
$dataset.Tables[0].Rows.count 

$dataset.Clear()
#$dataset.Tables
$dataset.Tables[0].Rows[2]
#$dataset.Tables
$dataset.Tables[0].Rows.count 

$dataset.Clear()
$sqlCommand = "select * from zips where state = 'NY'"
$cmd = New-object System.Data.Odbc.OdbcCommand($sqlCommand,$conn)
(New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).Fill($dataSet)
$dataset.Tables[0].Rows.count 

$conn.Close()
```

* How to load data to Excel using odbc connection
	-	Excel -> Data -> Get Data -> From Other Sources -> From ODBC -> Select DSN -> Expand / Select Tables -> Click on Load  