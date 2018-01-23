-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_index_fragmentation.sql                                     |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : To ascertain index fragmentation. As a rule of thumb if 10-15%  |
-- |            of the table data changes, then you should consider rebuilding  |
-- |            the index.                                                      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    OFF
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

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Calculate Index Fragmentation for a Specified Index                    |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT index_name CHAR prompt 'Enter index name [SCHEMA].index_name : '

ANALYZE INDEX &index_name VALIDATE STRUCTURE;
 
COLUMN name           HEADING 'Index Name'          FORMAT a30
COLUMN del_lf_rows    HEADING 'Deleted|Leaf Rows'   FORMAT 999,999,999,999,999
COLUMN lf_rows_used   HEADING 'Used|Leaf Rows'      FORMAT 999,999,999,999,999
COLUMN ibadness       HEADING '% Deleted|Leaf Rows' FORMAT 999.99999
 
SELECT
    name
  , del_lf_rows
  , lf_rows - del_lf_rows lf_rows_used
  , TO_CHAR( del_lf_rows /(DECODE(lf_rows,0,0.01,lf_rows))*100,'999.99999') ibadness
FROM   index_stats
/
 
PROMPT 
PROMPT Consider rebuilding any index if % of Deleted Leaf Rows is > 20%
PROMPT 

UNDEFINE index_name

SET FEEDBACK    6
