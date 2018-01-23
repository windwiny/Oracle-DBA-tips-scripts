-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : rman_backup_pieces.sql                                          |
-- | CLASS    : Recovery Manager                                                |
-- | PURPOSE  : Provide a listing of all RMAN Backup Pieces.                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : RMAN Backup Pieces                                          |
PROMPT | Instance : &current_instance                                           |
PROMPT | Note     : Available backup pieces contained in the control file.      |
PROMPT |            Includes available and expired backup sets.                 |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN bs_key              FORMAT 9999          HEADING 'BS|Key'
COLUMN piece#              FORMAT 99999         HEADING 'Piece|#'
COLUMN copy#               FORMAT 9999          HEADING 'Copy|#'
COLUMN bp_key              FORMAT 9999          HEADING 'BP|Key'
COLUMN status              FORMAT a9            HEADING 'Status'
COLUMN handle              FORMAT a75           HEADING 'Handle'
COLUMN start_time          FORMAT a19           HEADING 'Start|Time'
COLUMN completion_time     FORMAT a19           HEADING 'End|Time'
COLUMN elapsed_seconds     FORMAT 999,999       HEADING 'Elapsed|Seconds'
COLUMN deleted             FORMAT a8            HEADING 'Deleted?'

BREAK ON bs_key SKIP 2

SELECT
    bs.recid                                            bs_key
  , bp.piece#                                           piece#
  , bp.copy#                                            copy#
  , bp.recid                                            bp_key
  , DECODE(   bp.status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                             status
  , bp.handle                                             handle
  , TO_CHAR(bp.start_time, 'mm/dd/yyyy HH24:MI:SS')       start_time
  , TO_CHAR(bp.completion_time, 'mm/dd/yyyy HH24:MI:SS')  completion_time
  , bp.elapsed_seconds                                    elapsed_seconds
FROM
    v$backup_set bs JOIN v$backup_piece bp USING (set_stamp,set_count)
WHERE
    bp.status IN ('A', 'X')
ORDER BY
    bs.recid
  , bp.piece#
/

