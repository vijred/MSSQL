--create a table to poll spinlock stats
select getdate() as runtime, * 
into newtable
from sys.dm_os_spinlock_stats
where name = 'ghost_hash'

--insert values into the table by running the following repeatedly
insert into newtable
select getdate() as runtime, * 
from sys.dm_os_spinlock_stats
where name = 'ghost_hash'

--what's in the table
select * from newtable

--calculate the deltas
--the output is like what’s in the image above.  The two runtime columns represent the difference between the last two polling intervals and you’d want to look at whether spinsdiff decreases to see if your query tuning is having the desired impact.
select
    t1.[name]
    , t1.runtime
    , t2.runtime
    , t1.Collisions
    , t2.Collisions
       , t1.spins_per_collision
       , t2.spins_per_collision
    , cast(t1.Collisions as bigint) - cast(t2.Collisions as bigint) as 'collisionsdiff'
       , cast(t1.spins as bigint) - cast(t2.spins as bigint) as 'spinsdiff'
       , cast(t1.backoffs as bigint) - cast(t2.backoffs as bigint) as 'backoffsdiff'
       , cast(t1.sleep_time as bigint) - cast(t2.sleep_time as bigint) as 'sleeptimediff'
       , cast(t1.spins_per_collision as bigint) - cast(t2.spins_per_collision as bigint) as 'spinscollisions'
       , case when cast(t1.Collisions as bigint) - cast(t2.Collisions as bigint) = 0 then 0  else (1.0 * cast(t1.spins as bigint) - cast(t2.spins as bigint)) / (1.0 * cast(t1.Collisions as bigint) - cast(t2.Collisions as bigint)) end as 'spinspercollision'
from
    newtable t1
    inner join newtable t2 on t1.[name] = t2.[name]
          and t2.runtime = (select max(t3.runtime) from newtable t3 where t1.[name] = t3.[name] and t3.runtime < t1.runtime)
where
    t1.name = 'GHOST_HASH'
order by
    t1.runtime asc
       --, cast(t1.spins as bigint) - cast(t2.spins as bigint) desc
       , case when cast(t1.Collisions as bigint) - cast(t2.Collisions as bigint) = 0 then 0  else (1.0 * cast(t1.spins as bigint) - cast(t2.spins as bigint)) / (1.0 * cast(t1.Collisions as bigint) - cast(t2.Collisions as bigint)) end  desc Insert data from a query like this into a table:
select getdate() as runtime, * 
from sys.dm_os_spinlock_stats
where name = 'ghost_hash'
