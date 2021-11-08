


use cdctest
go
declare @rc int
exec @rc = sys.sp_cdc_enable_db
select @rc
-- new column added to sys.databases: is_cdc_enabled
select name, is_cdc_enabled from sys.databases


create table dbo.customer
(
id int identity not null
, name varchar(50) not null
, state varchar(2) not null
, constraint pk_customer primary key clustered (id)
)


exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'customer' ,
    @role_name = 'CDCRole',
    @supports_net_changes = 1select name, type, type_desc, is_tracked_by_cdc from sys.tables


       select o.name, o.type, o.type_desc from sys.objects o
join sys.schemas  s on s.schema_id = o.schema_id
where s.name = 'cdc'



insert customer values ('abc company', 'md')
insert customer values ('xyz company', 'de')
insert customer values ('xox company', 'va')
update customer set state = 'pa' where id = 1
delete from customer where id = 3

select * from customer


declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the first LSN for customer changes --0x0000001F00000B260039
select @begin_lsn = sys.fn_cdc_get_min_lsn('dbo_customer')
-- get the last LSN for customer changes--0x0000001F000014970001
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get net changes; group changes in the range by the pk
select * from cdc.fn_cdc_get_net_changes_dbo_customer(
@begin_lsn, @end_lsn, 'all'); 
-- get individual changes in the range
select * from cdc.fn_cdc_get_all_changes_dbo_customer(
@begin_lsn, @end_lsn, 'all');

select sys.fn_cdc_get_min_lsn('dbo_customer')

0x0000001F00000B260039

sys.sp_cdc_get_captured_columns 

create table dbo.customer_lsn (
last_lsn binary(10)
)
create function dbo.get_last_customer_lsn() 
returns binary(10)
as
begin
declare @last_lsn binary(10)
select @last_lsn = last_lsn from dbo.customer_lsn
select @last_lsn = isnull(@last_lsn, sys.fn_cdc_get_min_lsn('dbo_customer'))
return @last_lsn
end

declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the next LSN for customer changes
select @begin_lsn = dbo.get_last_customer_lsn()
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get the net changes; group all changes in the range by the pk
select * from cdc.fn_cdc_get_net_changes_dbo_customer(
@begin_lsn, @end_lsn, 'all'); 
-- get all individual changes in the range
select * from cdc.fn_cdc_get_all_changes_dbo_customer(
@begin_lsn, @end_lsn, 'all'); 
-- save the end_lsn in the customer_lsn table
update dbo.customer_lsn
set last_lsn = @end_lsn
if @@ROWCOUNT = 0
insert into dbo.customer_lsn values(@end_lsn)



