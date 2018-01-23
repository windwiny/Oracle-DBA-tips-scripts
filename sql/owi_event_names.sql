-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : owi_event_names.sql                                             |
-- | CLASS    : Oracle_Wait_Interface                                           |
-- | PURPOSE  : Reports on all defined event names included in the Oracle Wait  |
-- |            Interface.                                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle Wait Interface: Event Names                          |
PROMPT | Instance : &current_instance                                           |
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

COLUMN event#      FORMAT 9999      HEADING 'Event #'
COLUMN name        FORMAT a60       HEADING 'Event Name'
COLUMN parameter1  FORMAT a40       HEADING 'Parameter 1' TRUNC
COLUMN parameter2  FORMAT a20       HEADING 'Parameter 2' TRUNC
COLUMN parameter3  FORMAT a20       HEADING 'Parameter 3' TRUNC


SELECT
    en.event#               event#
  , en.name                 name
  , en.parameter1           parameter1
  , en.parameter2           parameter2
  , en.parameter3           parameter3
FROM
    v$event_name  en
ORDER BY
    en.event#;

