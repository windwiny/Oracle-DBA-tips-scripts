-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_rebuild_indexes.sql                                         |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This script generates another script that will include all of   |
-- |            the ALTER INDEX REBUILD ....  commands needed to rebuild a      |
-- |            tablespaces indexes. This script will prompt the user for the   |
-- |            tablespace name. This script must be run be a user with the DBA |
-- |            role under Oracle7.                                             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Rebuild Index Build Script                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT TS_NAME CHAR PROMPT 'Enter the index tablespace name : '

PROMPT
PROMPT Thanks... Creating rebuild index script for tablespace: &TS_NAME

SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     OFF
SET LINESIZE    180
SET PAGESIZE    0
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET TERMOUT   OFF

spool rebuild_&TS_NAME._indexes.sql

SELECT 'REM FILE : rebuild_&TS_NAME._indexes.sql' FROM dual;
SELECT ' ' FROM dual;
SELECT 'REM' FROM dual;
SELECT 'REM ***** ALTER INDEX REBUILD commands for tablespace: &TS_NAME' FROM dual;
SELECT 'REM' FROM dual;
SELECT ' ' FROM dual;

SELECT 
  'REM +------------------------------------------------------------------------+' || chr(10) ||
  'REM | INDEX NAME : ' || owner   || '.' || segment_name 
         || lpad('|', 58 - (length(owner) + length(segment_name)) )
         || chr(10) ||
  'REM | BYTES      : ' || bytes   
         || lpad ('|', 59-(length(bytes)) ) || chr(10) ||
  'REM | EXTENTS    : ' || extents 
         || lpad ('|', 59-(length(extents)) ) || chr(10) ||
  'REM +------------------------------------------------------------------------+' || chr(10) ||
  'ALTER INDEX ' || owner || '.' || segment_name || chr(10) ||
  '    REBUILD ONLINE' || chr(10) ||
  '    TABLESPACE ' || tablespace_name || chr(10) ||
  '    STORAGE ( ' || chr(10) ||
  '        INITIAL     ' || initial_extent || chr(10) ||
  '        NEXT        ' || next_extent || chr(10) ||
  '        MINEXTENTS  ' || min_extents || chr(10) ||
  '        MAXEXTENTS  ' || max_extents || chr(10) ||
  '        PCTINCREASE ' || pct_increase || chr(10) ||
  ');' || chr(10) || chr(10)
FROM   dba_segments
WHERE  segment_type = 'INDEX'
  AND  owner NOT IN ('SYS')
  AND  tablespace_name = UPPER('&TS_NAME')
ORDER BY owner, bytes DESC
/

SPOOL OFF

SET TERMOUT ON

PROMPT 
PROMPT Done... Built the script rebuild_&TS_NAME._indexes.sql
PROMPT 
