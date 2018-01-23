-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : locks_blocking2.sql                                             |
-- | CLASS    : Locks                                                           |
-- | PURPOSE  : Query all Blocking Locks in the databases. This query will      |
-- |            display both the user(s) holding the lock and the user(s)       |
-- |            waiting for the lock. This script is RAC enabled.               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Blocking Locks                                              |
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

COLUMN waiting_instance_sid_serial  FORMAT a24          HEADING '[WAITING]|Instance - SID / Serial#'
COLUMN waiting_oracle_username      FORMAT a20          HEADING '[WAITING]|Oracle User'
COLUMN waiting_pid                  FORMAT a11          HEADING '[WAITING]|PID'
COLUMN waiting_machine              FORMAT a15          HEADING '[WAITING]|Machine'   TRUNC
COLUMN waiting_os_username          FORMAT a15          HEADING '[WAITING]|O/S User'
COLUMN waiter_lock_type_mode_req    FORMAT a35          HEADING 'Waiter Lock Type / Mode Requested'
COLUMN waiting_lock_time_min        FORMAT a10          HEADING '[WAITING]|Lock Time'
COLUMN waiting_instance_sid         FORMAT a15          HEADING '[WAITING]|Instance - SID'
COLUMN waiting_sql_text             FORMAT a105         HEADING '[WAITING]|SQL Text'    WRAP

COLUMN locking_instance_sid_serial  FORMAT a24          HEADING '[LOCKING]|Instance - SID / Serial#'
COLUMN locking_oracle_username      FORMAT a20          HEADING '[LOCKING]|Oracle User'
COLUMN locking_pid                  FORMAT a11          HEADING '[LOCKING]|PID'
COLUMN locking_machine              FORMAT a15          HEADING '[LOCKING]|Machine'   TRUNC
COLUMN locking_os_username          FORMAT a15          HEADING '[LOCKING]|O/S User'
COLUMN locking_lock_time_min        FORMAT a10          HEADING '[LOCKING]|Lock Time'

COLUMN instance_name                FORMAT a8           HEADING 'Instance'
COLUMN sid                          FORMAT 999999       HEADING 'SID'
COLUMN session_status               FORMAT a9           HEADING 'Status'
COLUMN locking_oracle_user          FORMAT a20          HEADING 'Locking Oracle User'
COLUMN locking_os_user              FORMAT a20          HEADING 'Locking O/S User'
COLUMN locking_os_pid               FORMAT a11          HEADING 'Locking PID'
COLUMN locking_machine              FORMAT a15          HEADING 'Locking Machine'   TRUNC
COLUMN object_owner                 FORMAT a15          HEADING 'Object Owner'
COLUMN object_name                  FORMAT a25          HEADING 'Object Name'
COLUMN object_type                  FORMAT a15          HEADING 'Object Type'
COLUMN locked_mode                                      HEADING 'Locked Mode'

CLEAR BREAKS

PROMPT 
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | BLOCKING LOCKS (Summary)                                               |
PROMPT +------------------------------------------------------------------------+

SELECT
    iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#  waiting_instance_sid_serial
  , sw.username                                                 waiting_oracle_username
  , ROUND(lw.ctime/60) || ' min.'                               waiting_lock_time_min
  , DECODE (   lh.type
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
             , 'Nothing-'
           ) || ' / ' ||
    DECODE (   lw.request
             , 0, 'None'                        /* Mon Lock equivalent */
             , 1, 'NoLock'                      /* N */
             , 2, 'Row-Share (SS)'              /* L */
             , 3, 'Row-Exclusive (SX)'          /* R */
             , 4, 'Share-Table'                 /* S */
             , 5, 'Share-Row-Exclusive (SSX)'   /* C */
             , 6, 'Exclusive'                   /* X */
             ,    '[Nothing]'
           )                                                            waiter_lock_type_mode_req
  , ih.instance_name || ' - ' || lh.sid || ' / ' || sh.serial#          locking_instance_sid_serial
  , sh.username                                                         locking_oracle_username
  , ROUND(lh.ctime/60) || ' min.'                                       locking_lock_time_min
FROM
    gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
WHERE
      iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN ( SELECT id1,id2
                            FROM   gv$lock
                            WHERE  request = 0
                            INTERSECT
                            SELECT id1,id2
                            FROM   gv$lock
                            WHERE  lmode = 0
                          )
ORDER BY
    iw.instance_name
  , lw.sid;


PROMPT 
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | BLOCKING LOCKS (User Details)                                          |
PROMPT +------------------------------------------------------------------------+

SELECT
    iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#          waiting_instance_sid_serial
  , sw.username                                                         waiting_oracle_username
  , sw.osuser                                                           waiting_os_username
  , sw.machine                                                          waiting_machine
  , pw.spid                                                             waiting_pid
  , ih.instance_name || ' - ' || lh.sid || ' / ' || sh.serial#          locking_instance_sid_serial
  , sh.username                                                         locking_oracle_username
  , sh.osuser                                                           locking_os_username
  , sh.machine                                                          locking_machine
  , ph.spid                                                             locking_pid
FROM
    gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
  , gv$process  pw
  , gv$process  ph
WHERE
      iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND pw.inst_id  = lw.inst_id
  AND ph.inst_id  = lh.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN ( SELECT id1,id2
                            FROM   gv$lock
                            WHERE  request = 0
                            INTERSECT
                            SELECT id1,id2
                            FROM   gv$lock
                            WHERE  lmode = 0
                          )
  AND sw.paddr  = pw.addr (+)
  AND sh.paddr  = ph.addr (+)
ORDER BY
    iw.instance_name
  , lw.sid;


PROMPT 
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | BLOCKING LOCKS (Waiting SQL)                                           |
PROMPT +------------------------------------------------------------------------+

SELECT
    iw.instance_name || ' - ' || lw.sid || ' / ' || sw.serial#    waiting_instance_sid_serial
  , aw.sql_text                                                   waiting_sql_text
FROM
    gv$lock     lw
  , gv$lock     lh
  , gv$instance iw
  , gv$instance ih
  , gv$session  sw
  , gv$session  sh
  , gv$sqlarea  aw
WHERE
      iw.inst_id  = lw.inst_id
  AND ih.inst_id  = lh.inst_id
  AND sw.inst_id  = lw.inst_id
  AND sh.inst_id  = lh.inst_id
  AND aw.inst_id  = lw.inst_id
  AND sw.sid      = lw.sid
  AND sh.sid      = lh.sid
  AND lh.id1      = lw.id1
  AND lh.id2      = lw.id2
  AND lh.request  = 0
  AND lw.lmode    = 0
  AND (lh.id1, lh.id2) IN ( SELECT id1,id2
                            FROM   gv$lock
                            WHERE  request = 0
                            INTERSECT
                            SELECT id1,id2
                            FROM   gv$lock
                            WHERE  lmode = 0
                          )
  AND sw.sql_address  = aw.address
ORDER BY
    iw.instance_name
  , lw.sid;


PROMPT 
PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | LOCKED OBJECTS                                                         |
PROMPT +------------------------------------------------------------------------+

SELECT
    i.instance_name           instance_name
  , l.session_id              sid
  , s.status                  session_status
  , l.oracle_username         locking_oracle_user
  , s.osuser                  locking_os_user
  , s.machine                 locking_machine
  , p.spid                    locking_os_pid
  , o.owner                   object_owner
  , o.object_name             object_name
  , o.object_type             object_type
  , DECODE (   l.locked_mode
             , 0, 'None'                        /* Mon Lock equivalent */
             , 1, 'NoLock'                      /* N */
             , 2, 'Row-Share (SS)'              /* L */
             , 3, 'Row-Exclusive (SX)'          /* R */
             , 4, 'Share-Table'                 /* S */
             , 5, 'Share-Row-Exclusive (SSX)'   /* C */
             , 6, 'Exclusive'                   /* X */
             ,    '[Nothing]'
           )                  locked_mode
FROM
    dba_objects       o
  , gv$session        s
  , gv$process        p
  , gv$locked_object  l
  , gv$instance       i
WHERE
      i.inst_id     = l.inst_id
  AND s.inst_id     = l.inst_id
  AND s.inst_id     = p.inst_id
  AND s.sid         = l.session_id
  AND o.object_id   = l.object_id
  AND s.paddr       = p.addr
ORDER BY
    i.instance_name
  , l.session_id;

