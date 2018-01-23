-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_purge_30_days_10g.sql                                        |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : This script is responsible for removing all Statspack snapshot  |
-- |            records older than 30 days. Most of the code contained in this  |
-- |            script is modeled after the Oracle supplied sppurge.sql script  |
-- |            but removes by Snapshot date rather than Snapshot IDs.          |
-- |                                                                            |
-- |            Note that this script only works with Oracle10g.                |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET FEEDBACK  off
SET VERIFY    off

DEFINE days_to_keep=30

UNDEFINE dbid inst_num snapshots_purged

WHENEVER SQLERROR EXIT ROLLBACK

SPOOL sp_purge_&days_to_keep._days_10g.lis

PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Get database and instance currently connected to.                          |
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


VARIABLE dbid              NUMBER;
VARIABLE inst_num          NUMBER;
VARIABLE inst_name         VARCHAR2(20);
VARIABLE db_name           VARCHAR2(20);
VARIABLE num_days          NUMBER;
VARIABLE snapshots_purged  NUMBER;

BEGIN
  :dbid      :=  &dbid;
  :inst_num  :=  &inst_num;
  :inst_name := '&inst_name';
  :db_name   := '&db_name';
  :num_days  := &days_to_keep;

  :snapshots_purged := statspack.purge( i_num_days        => :num_days
                                      , i_extended_purge  => true
                                      , i_dbid            => :dbid
                                      , i_instance_number => :inst_num);
END;
/

SET FEEDBACK on

PROMPT 
PROMPT 
PROMPT 
PROMPT +----------------------------------------------------------------------------+
PROMPT | Removed Statspack snapshots older than &days_to_keep days.                            |
PROMPT +----------------------------------------------------------------------------+

PRINT snapshots_purged

SPOOL off

COMMIT;

EXIT

