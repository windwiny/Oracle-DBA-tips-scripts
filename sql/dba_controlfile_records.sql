-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_controlfile_records.sql                                     |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Query information information about the control file record     |
-- |            sections.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Control File Records                                        |
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

COLUMN type           FORMAT           a30   HEADING "Record Section Type"
COLUMN record_size    FORMAT       999,999   HEADING "Record Size|(in bytes)"
COLUMN records_total  FORMAT       999,999   HEADING "Records Allocated"
COLUMN bytes_alloc    FORMAT   999,999,999   HEADING "Bytes Allocated"
COLUMN records_used   FORMAT       999,999   HEADING "Records Used"
COLUMN bytes_used     FORMAT   999,999,999   HEADING "Bytes Used"
COLUMN pct_used       FORMAT           B999  HEADING "% Used"
COLUMN first_index                           HEADING "First Index"
COLUMN last_index                            HEADING "Last Index"
COLUMN last_recid                            HEADING "Last RecID"

BREAK ON report

COMPUTE sum OF records_total ON report
COMPUTE sum OF bytes_alloc   ON report
COMPUTE sum OF records_used  ON report
COMPUTE sum OF bytes_used    ON report
COMPUTE avg OF pct_used      ON report

SELECT
    type
  , record_size
  , records_total
  , (records_total * record_size) bytes_alloc
  , records_used
  , (records_used * record_size) bytes_used
  , NVL(records_used/records_total * 100, 0) pct_used
  , first_index
  , last_index
  , last_recid
FROM v$controlfile_record_section
ORDER BY type
/

