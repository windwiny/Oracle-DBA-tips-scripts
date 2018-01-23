-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_plsql_package_size.sql                                      |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Internal size of PL/SQL Packages.                               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : PL/SQL Package Body Size Report                             |
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

COLUMN owner       FORMAT a20               HEAD "Owner"
COLUMN name        FORMAT a35               HEAD "Name"
COLUMN type        FORMAT a18               HEAD "Type"
COLUMN total_bytes FORMAT 999,999,999,999   HEAD "Total bytes"

SELECT
    owner
  , name
  , type
  , source_size+code_size+parsed_size+error_size total_bytes
FROM
  dba_object_size
WHERE
      type = 'PACKAGE BODY'
  AND owner NOT IN ('SYS')
ORDER BY
  4 DESC;

