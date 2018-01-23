-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_tablespace_mapper.sql                                       |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Report on all USED and FREE SPACE within a tablespace. This is  |
-- |            a good script to report on tablespace fragmentation.            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_instance_nt NEW_VALUE current_instance_nt NOPRINT;
SELECT rpad(instance_name, 17) current_instance, instance_name current_instance_nt FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Tablespace Mapper                                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT tbs_in CHAR PROMPT 'Enter tablespace name : '

SET TERMOUT OFF;
COLUMN tbs NEW_VALUE tbs NOPRINT;
SELECT rpad(upper('&tbs_in'), 30) tbs
FROM dual;
SET TERMOUT ON;

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     OFF
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

DEFINE fileName=tablespace_mapper

SPOOL &FileName._&current_instance_nt._&tbs_in..txt

COLUMN owner       FORMAT a20             HEADING "Owner"
COLUMN object      FORMAT a30             HEADING "Object"
COLUMN file_id                            HEADING "File ID"
COLUMN block_id                           HEADING "Block ID"
COLUMN bytes       FORMAT 999,999,999,999 HEADING "Bytes" 

SELECT
    'FREE SPACE' owner
  , ' '          object
  , file_id
  , block_id
  , bytes
FROM
    dba_free_space
WHERE
    tablespace_name = UPPER('&tbs_in')
UNION
SELECT
    SUBSTR(owner, 1, 20)
  , SUBSTR(segment_name, 1, 32)
  , file_id
  , block_id
  , bytes
FROM
    dba_extents
WHERE
    tablespace_name = UPPER('&tbs_in')
ORDER BY
    3
  , 4
/

SPOOL off

SET FEEDBACK    6
SET HEADING     ON
SET TERMOUT     ON

PROMPT 
PROMPT Report written to &FileName._&current_instance_nt._&tbs_in..txt
PROMPT 

