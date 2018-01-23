-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_purge_30_days_9i.sql                                         |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : This script is responsible for removing all Statspack snapshot  |
-- |            records older than 30 days. Most of the code contained in this  |
-- |            script is modeled after the Oracle supplied sppurge.sql script  |
-- |            but removes by Snapshot date rather than Snapshot IDs.          |
-- |                                                                            |
-- |            Note that this script only works with Oracle9i.                 |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET FEEDBACK  off
SET VERIFY    off

DEFINE days_to_keep=30

UNDEFINE dbid inst_num hisnapid

WHENEVER SQLERROR EXIT ROLLBACK

SPOOL sp_purge_&days_to_keep._days_9i.lis

PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Get database and instance currently connected to. This will be used later  |
PROMPT | in the report along with other metadata to lookup snapshots.               |
PROMPT +----------------------------------------------------------------------------+

SET FEEDBACK off

COLUMN inst_num   FORMAT 99999999999999  HEADING "Instance Num."  NEW_VALUE inst_num
COLUMN inst_name  FORMAT a15             HEADING "Instance Name"  NEW_VALUE inst_name
COLUMN db_name    FORMAT a10             HEADING "DB Name"        NEW_VALUE db_name
COLUMN dbid       FORMAT 9999999999      HEADING "DB Id"          NEW_VALUE dbid

SELECT
    d.dbid             dbid
  , d.name             db_name
  , i.instance_number  inst_num
  , i.instance_name    inst_name
FROM
    v$database d
  , v$instance i
/


VARIABLE dbid        NUMBER;
VARIABLE inst_num    NUMBER;
VARIABLE inst_name   VARCHAR2(20);
VARIABLE db_name     VARCHAR2(20);

BEGIN
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
  :inst_name := '&inst_name';
  :db_name   := '&db_name';
END;
/

SET FEEDBACK on


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Obtain the MIN and MAX Snapshot IDs to be removed from the range of IDs    |
PROMPT | order than &days_to_keep days.                                                        |
PROMPT +----------------------------------------------------------------------------+

SET FEEDBACK off

COLUMN lo_snap    HEADING "Min Snapshot ID"  NEW_VALUE LoSnapId
COLUMN hi_snap    HEADING "Max Snapshot ID"  NEW_VALUE HiSnapId

SELECT  NVL(MAX(snap_id),0)    hi_snap
      , NVL(MIN(snap_id),0)    lo_snap
FROM    stats$snapshot
WHERE   snap_time < (sysdate - &days_to_keep);

VARIABLE lo_snap   NUMBER;
VARIABLE hi_snap   NUMBER;

BEGIN 
  :lo_snap   :=  &losnapid;
  :hi_snap   :=  &hisnapid; 
END;
/


COLUMN l  HEADING 'Low Snap ID'
COLUMN h  HEADING 'High Snap ID'

SELECT
    :lo_snap  l
  , :hi_snap  h
FROM dual;

SET FEEDBACK ON


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Snapshots that will be removed for this database instance.                 |
PROMPT +----------------------------------------------------------------------------+

SET FEEDBACK off

COLUMN snap_id    FORMAT 9999990  HEADING 'Snap Id'
COLUMN level      FORMAT 99       HEADING 'Snap|Level'
COLUMN snap_date  FORMAT a21      HEADING 'Snapshot Started'
COLUMN host_name  FORMAT a15      HEADING 'Host'
COLUMN ucomment   format a25      HEADING 'Comment' 

SELECT
    s.snap_id                                      snap_id
  , s.snap_level                                   "level"
  , to_char(s.snap_time,'mm/dd/yyyy HH24:MI:SS')   snap_date
  , di.host_name                                   host_name
  , s.ucomment                                     ucomment
FROM
    stats$snapshot           s
  , stats$database_instance  di
WHERE
      s.dbid              = :dbid
  AND di.dbid             = :dbid
  AND s.instance_number   = :inst_num
  AND di.instance_number  = :inst_num
  AND di.startup_time     = s.startup_time
  AND s.snap_id           < :hi_snap
ORDER BY
    db_name
  , instance_name
  , snap_id
/

SET HEADING off

SELECT 'WARNING: No snapshots found older than &days_to_keep days in STATS$SNAPSHOT'
FROM   dual
WHERE  NOT EXISTS 
       (
         select null
         from   stats$snapshot
         where  instance_number = :inst_num
           and  dbid            = :dbid
           and  snap_id         = :lo_snap
       )
       OR
       NOT EXISTS
       (
         select null
         from   stats$snapshot
         where  instance_number = :inst_num
           and  dbid            = :dbid
          and  snap_id         = :hi_snap
       )
/

SET HEADING on
SET FEEDBACK ON



PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Get begin and end snapshot times - these are used to delete undostat.      |
PROMPT +----------------------------------------------------------------------------+

SET FEEDBACK OFF

COLUMN btime  NEW_VALUE btime
COLUMN etime  NEW_VALUE etime

SELECT
    b.snap_id
  , TO_CHAR(b.snap_time, 'YYYYMMDD HH24:MI:SS') btime
FROM
    stats$snapshot b
WHERE
      b.snap_id         = :lo_snap
  AND b.dbid            = :dbid
  AND b.instance_number = :inst_num;


SELECT
    e.snap_id
  , TO_CHAR(e.snap_time, 'YYYYMMDD HH24:MI:SS') etime
FROM stats$snapshot e
WHERE
      e.snap_id         = :hi_snap
  AND e.dbid            = :dbid
  AND e.instance_number = :inst_num;

VARIABLE btime   VARCHAR2(25);
VARIABLE etime   VARCHAR2(25);

BEGIN 
  :btime     :=  '&btime';
  :etime     :=  '&etime';
END;
/

SET FEEDBACK on


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Deleting snapshots older than &days_to_keep days.
PROMPT | Deleting snapshots &&losnapid - &&hisnapid.
PROMPT +----------------------------------------------------------------------------+

DELETE FROM stats$snapshot
 WHERE instance_number = :inst_num
   AND dbid            = :dbid
   AND snap_id between :lo_snap and :hi_snap;


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Delete any dangling SQLtext. The following statement deletes any dangling  |
PROMPT | SQL statements which are no longer referred to by ANY snapshots. By        |
PROMPT | default, Oracle comments this statement out as it can be very resource     |
PROMPT | intensive.                                                                 |
PROMPT +----------------------------------------------------------------------------+

SET FEEDBACK off

ALTER SESSION SET hash_area_size=1048576;

COLUMN last_snap_id  HEADING 'Last Snap ID'
COLUMN count         HEADING 'Count'

SELECT --+ index_ffs(st)
    last_snap_id
  , count(*)      count
FROM
    stats$sqltext st
WHERE
    (   hash_value
      , text_subset
    )
    NOT IN
    (  select --+ hash_aj full(ss) no_expand 
           hash_value
         , text_subset
       from stats$sql_summary ss
       where ( (
                 snap_id     < :lo_snap
                 or
                 snap_id     > :hi_snap
               )
               and dbid            = :dbid
               and instance_number = :inst_num
             )
             or
             (
               dbid            != :dbid
               or
               instance_number != :inst_num
             )
    )
GROUP BY
    last_snap_id;

SET FEEDBACK on

DELETE --+ index_ffs(st) 
FROM  stats$sqltext st
WHERE
    (   hash_value
      , text_subset
    )
    NOT IN
    (  select --+ hash_aj full(ss) no_expand 
           hash_value
         , text_subset
       from stats$sql_summary ss
       where ( (
                 snap_id     < :lo_snap
                 or
                 snap_id     > :hi_snap
               )
               and dbid            = :dbid
               and instance_number = :inst_num
             )
             or
             (
               dbid            != :dbid
               or
               instance_number != :inst_num
             )
    );


SET FEEDBACK on

PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | (OPTIONAL) - STATS$SEG_STAT_OBJ delete statement                           |
PROMPT +----------------------------------------------------------------------------+

DELETE --+ index_ffs(sso)
FROM  stats$seg_stat_obj sso
WHERE (   dbid
        , dataobj#
        , obj#
      )
      NOT IN
      (
        select --+ hash_aj full(ss) no_expand
            dbid
          , dataobj#
          , obj#
        from
            stats$seg_stat ss
        where ( ( snap_id     < :lo_snap
                  or
                  snap_id     > :hi_snap
                 )
                 and dbid            = :dbid
                 and instance_number = :inst_num
              )
              or
              ( dbid            != :dbid
                or
                instance_number != :inst_num
              )
      );


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Delete from stats$undostat                                                 |
PROMPT | Undostat rows that cover the snap times                                    |
PROMPT +----------------------------------------------------------------------------+

COLUMN dbid             HEADING 'DB Id'
COLUMN instance_number  HEADING 'Instance Number'
COLUMN snap_id          HEADING 'Snap ID'
COLUMN begin_time       HEADING 'Begin Time'
COLUMN end_time         HEADING 'End Time'

SELECT
    dbid
  , instance_number
  , snap_id
  , TO_CHAR(begin_time, 'YYYYMMDD HH24:MI:SS') begin_time
  , TO_CHAR(end_time,   'YYYYMMDD HH24:MI:SS') end_time
FROM
    stats$undostat us
WHERE
      dbid            = :dbid
  AND instance_number = :inst_num
  AND end_time        <  to_date(:etime, 'YYYYMMDD HH24:MI:SS')
ORDER BY
    snap_id;


DELETE from stats$undostat us
 WHERE dbid            = :dbid
   AND instance_number = :inst_num
   AND end_time        <  to_date(:etime, 'YYYYMMDD HH24:MI:SS');


PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Delete from stats$database_instance                                        |
PROMPT | Dangling database instance rows for that startup time                      |
PROMPT +----------------------------------------------------------------------------+

COLUMN dbid             HEADING 'DB Id'
COLUMN instance_number  HEADING 'Instance Number'
COLUMN startup_time     HEADING 'Startup Time'
COLUMN snap_id          HEADING 'Snap ID'

SELECT
    dbid
  , instance_number
  , TO_CHAR(startup_time, 'DD-MON-YYYY HH24:MI:SS') startup_time
  , snap_id
FROM
    stats$database_instance di
WHERE
      instance_number = :inst_num
  AND dbid            = :dbid
  AND NOT EXISTS (select 1
                  from   stats$snapshot s
                  where  s.dbid            = di.dbid
                    and  s.instance_number = di.instance_number
                    and  s.startup_time    = di.startup_time)
ORDER BY
    snap_id;


DELETE from stats$database_instance di
 WHERE instance_number = :inst_num
   AND dbid            = :dbid
   AND NOT EXISTS (select 1
                   from   stats$snapshot s
                   where  s.dbid            = di.dbid
                     and  s.instance_number = di.instance_number
                     and  s.startup_time    = di.startup_time);

PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Delete from stats$statspack_parameter                                      |
PROMPT | Dangling statspack parameter rows for the database / instance              |
PROMPT +----------------------------------------------------------------------------+

COLUMN dbid             HEADING 'DB Id'
COLUMN instance_number  HEADING 'Instance Number'
COLUMN session_id       HEADING 'Session ID'
COLUMN snap_level       HEADING 'Snap Level'

SELECT
    dbid
  , instance_number
  , session_id
  , snap_level
FROM
    stats$statspack_parameter sp
WHERE
      instance_number = :inst_num
  AND dbid            = :dbid
  AND NOT EXISTS (select 1
                  from   stats$snapshot s
                  where  s.dbid            = sp.dbid
                    and  s.instance_number = sp.instance_number);


DELETE from stats$statspack_parameter sp
 WHERE instance_number = :inst_num
   AND dbid            = :dbid
   AND NOT EXISTS (select 1
                   from   stats$snapshot s
                   where  s.dbid            = sp.dbid
                     and  s.instance_number = sp.instance_number);


SPOOL off

COMMIT;

EXIT

