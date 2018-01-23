-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : locks_dml_lock_time.sql                                         |
-- | CLASS    : Locks                                                           |
-- | PURPOSE  : Query all DML locks in the database (INSERT, UPDATE, DELETE)    |
-- |            and the number of minutes they have been holding the lock.      |
-- |            This script will also query critical information about the lock |
-- |            including Lock Type, Object Name/Owner, OS/Oracle User and Wait |
-- |            time (in minutes). This script is not RAC enabled and will only |
-- |            display locks on the current instance.                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : DML Table Lock Time                                         |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN instance_name                FORMAT a9           HEADING 'Instance'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN sid_serial                   FORMAT a15          HEADING 'SID / Serial#'
COLUMN mode_held                    FORMAT a15          HEADING 'Mode Held'
COLUMN mode_requested               FORMAT a15          HEADING 'Mode Requested'
COLUMN lock_type                    FORMAT a15          HEADING 'Lock Type'
COLUMN object                       FORMAT a42          HEADING 'Object'
COLUMN program                      FORMAT a20          HEADING 'Program'
COLUMN lock_time_min                FORMAT 999,999      HEADING 'Lock Time (min)'

CLEAR BREAKS

SELECT
    i.instance_name                                 instance_name
  , l.sid || ' / ' || s.serial#                     sid_serial
  , s.username                                      locking_oracle_user
  , DECODE(   l.lmode
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None')                            mode_held
  , DECODE(   l.request
            , 1, NULL
            , 2, 'Row Share'
            , 3, 'Row Exclusive'
            , 4, 'Share'
            , 5, 'Share Row Exclusive'
            , 6, 'Exclusive'
            ,    'None')                            mode_requested
  , DECODE (   l.type
             , 'CF', 'Control File'
             , 'DX', 'Distributed Transaction'
             , 'FS', 'File Set'
             , 'IR', 'Instance Recovery'
             , 'IS', 'Instance State'
             , 'IV', 'Libcache Invalidation'
             , 'LS', 'Log Start or Log Switch'
             , 'MR', 'Media Recovery'
             , 'RT', 'Redo Thread'
             , 'RW', 'Row Wait'
             , 'SQ', 'Sequence Number'
             , 'ST', 'Diskspace Transaction'
             , 'TE', 'Extend Table'
             , 'TT', 'Temp Table'
             , 'TX', 'Transaction'
             , 'TM', 'DML'
             , 'UL', 'PLSQL User_lock'
             , 'UN', 'User Name'
             ,       'Nothing'
           )                                        lock_type
  , o.owner || '.' || o.object_name                 object
  , ROUND(l.ctime/60, 2)                            lock_time_min
FROM
    v$instance    i
  , v$session     s
  , v$lock        l
  , dba_objects   o
  , dba_tables    t
WHERE
      l.id1            =  o.object_id 
  AND s.sid            =  l.sid
  AND o.owner          =  t.owner
  AND o.object_name    =  t.table_name
  AND o.owner          <> 'SYS'
  AND l.type           =  'TM'
ORDER BY
    i.instance_name
  , l.sid;

