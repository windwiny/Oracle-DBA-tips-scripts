-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : rman_controlfiles.sql                                           |
-- | CLASS    : Recovery Manager                                                |
-- | PURPOSE  : Provide a listing of automatically backed up control files.     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : RMAN Control Files                                          |
PROMPT | Instance : &current_instance                                           |
PROMPT | Note     : Available automatic control files within all available      |
PROMPT |            (and expired) backup sets.                                  |
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

COLUMN bs_key                 FORMAT 9999     HEADING 'BS|Key'
COLUMN piece#                 FORMAT 99999    HEADING 'Piece|#'
COLUMN copy#                  FORMAT 9999     HEADING 'Copy|#'
COLUMN bp_key                 FORMAT 9999     HEADING 'BP|Key'
COLUMN controlfile_included   FORMAT a11      HEADING 'Controlfile|Included?'
COLUMN completion_time        FORMAT a20      HEADING 'Completion|Time'
COLUMN status                 FORMAT a9       HEADING 'Status'
COLUMN handle                 FORMAT a75      HEADING 'Handle'

BREAK ON bs_key

SELECT
    bs.recid                                               bs_key
  , bp.piece#                                              piece#
  , bp.copy#                                               copy#
  , bp.recid                                               bp_key
  , DECODE(   bs.controlfile_included
            , 'NO', '-'
            , bs.controlfile_included)                     controlfile_included
  , TO_CHAR(bs.completion_time, 'mm/dd/yyyy HH24:MI:SS')   completion_time
  , DECODE(   status
            , 'A', 'Available'
            , 'D', 'Deleted'
            , 'X', 'Expired')                              status
  , handle                                                 handle
FROM
    v$backup_set bs JOIN v$backup_piece bp USING (set_stamp,set_count)
WHERE
      bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid
  , piece#
/

