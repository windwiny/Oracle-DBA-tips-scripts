-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dpump_jobs.sql                                                  |
-- | CLASS    : Data Pump                                                       |
-- | PURPOSE  : Query all Data Pump jobs.                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Data Pump Jobs                                              |
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

COLUMN owner_name         FORMAT a15            HEADING 'Owner Name'
COLUMN job_name           FORMAT a20            HEADING 'Job Name'
COLUMN operation          FORMAT a10            HEADING 'Operation'
COLUMN job_mode           FORMAT a10            HEADING 'Job Mode'
COLUMN state              FORMAT a10            HEADING 'State'
COLUMN degree             FORMAT 999999         HEADING 'Degree'
COLUMN attached_sessions  FORMAT 999,999        HEADING 'Attached Sessions'

SELECT
    dpj.owner_name           owner_name
  , dpj.job_name             job_name
  , dpj.operation            operation
  , dpj.job_mode             job_mode
  , dpj.state                state
  , dpj.degree               degree
  , dpj.attached_sessions    attached_sessions
FROM
    dba_datapump_jobs      dpj
ORDER BY
    dpj.owner_name
  , dpj.job_name;

