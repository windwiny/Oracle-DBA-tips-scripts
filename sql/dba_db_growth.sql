-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_db_growth.sql                                               |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides a report on physical database growth with respect to   |
-- |            the date that data files have been added.                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Database Growth                                             |
PROMPT | Instance : &current_instance                                           |
PROMPT | Note     : This script only tracks when a new data file was added to   |
PROMPT |            the database. Any data file that was manually increased or  |
PROMPT |            decreased in size or automatically increased using the      |
PROMPT |            AUTOEXTEND option is not tracked by this script.            |
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

COLUMN month        FORMAT a7                   HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999  HEADING 'Growth (Bytes)'

BREAK ON report

COMPUTE sum OF growth ON report

SELECT
    TO_CHAR(creation_time, 'RRRR-MM') month
  , SUM(bytes)                        growth
FROM     sys.v_$datafile
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');

