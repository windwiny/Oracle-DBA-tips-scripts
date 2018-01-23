-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_files_all.sql                                               |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all data files, online redo log files, and control   |
-- |            files within the database.                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Data File Report (all physical files)                       |
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

COLUMN tablespace      FORMAT a30                 HEADING 'Tablespace Name / File Class'
COLUMN filename        FORMAT a75                 HEADING 'Filename'
COLUMN filesize        FORMAT 9,999,999,999,999   HEADING 'File Size'
COLUMN autoextensible  FORMAT a4                  HEADING 'Auto'
COLUMN increment_by    FORMAT 999,999,999,999     HEADING 'Next'
COLUMN maxbytes        FORMAT 999,999,999,999     HEADING 'Max'

BREAK ON report

COMPUTE sum OF filesize  ON report

SELECT /*+ ordered */
    d.tablespace_name                     tablespace
  , d.file_name                           filename
  , d.bytes                               filesize
  , d.autoextensible                      autoextensible
  , d.increment_by * e.value              increment_by
  , d.maxbytes                            maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    d.tablespace_name                     tablespace 
  , d.file_name                           filename
  , d.bytes                               filesize
  , d.autoextensible                      autoextensible
  , d.increment_by * e.value              increment_by
  , d.maxbytes                            maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
UNION
SELECT
    '[ ONLINE REDO LOG ]'
  , a.member
  , b.bytes
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '[ CONTROL FILE    ]'
  , a.name
  , TO_NUMBER(null)
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$controlfile a
ORDER BY 1,2
/

