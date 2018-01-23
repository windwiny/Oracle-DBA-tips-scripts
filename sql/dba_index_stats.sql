-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_index_stats.sql                                             |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Report index statistics.                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     OFF
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
PROMPT | Calculate Index Statistics for a Specified Index                       |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT index_name CHAR prompt 'Enter index name [SCHEMA].index_name : '
  
COLUMN name                   newline
COLUMN headsep                newline
COLUMN height                 newline
COLUMN blocks                 newline
COLUMN lf_rows                newline
COLUMN lf_blks        	      newline
COLUMN lf_rows_len            newline
COLUMN lf_blk_len             newline
COLUMN br_rows                newline
COLUMN br_blks                newline
COLUMN br_rows_len            newline
COLUMN br_blk_len             newline
COLUMN del_lf_rows            newline
COLUMN del_lf_rows_len        newline
COLUMN distinct_keys          newline
COLUMN most_repeated_key      newline
COLUMN btree_space            newline
COLUMN used_space    	        newline
COLUMN pct_used               newline
COLUMN rows_per_key           newline
COLUMN blks_gets_per_access   newline

ANALYZE INDEX &index_name VALIDATE STRUCTURE;

SELECT  
    name
  , '----------------------------------------------------------------------------'      headsep
  , 'height               ' ||to_char(height,     '999,999,990')                        height
  , 'blocks               ' ||to_char(blocks,     '999,999,990')                        blocks
  , 'del_lf_rows          ' ||to_char(del_lf_rows,'999,999,990')                        del_lf_rows
  , 'del_lf_rows_len      ' ||to_char(del_lf_rows_len,'999,999,990')                    del_lf_rows_len
  , 'distinct_keys        ' ||to_char(distinct_keys,'999,999,990')                      distinct_keys
  , 'most_repeated_key    ' ||to_char(most_repeated_key,'999,999,990')                  most_repeated_key
  , 'btree_space          ' ||to_char(btree_space,'999,999,990')                        btree_space
  , 'used_space           ' ||to_char(used_space,'999,999,990')                         used_space
  , 'pct_used             ' ||to_char(pct_used,'990')                                   pct_used
  , 'rows_per_key         ' ||to_char(rows_per_key,'999,999,990')                       rows_per_key
  , 'blks_gets_per_access ' ||to_char(blks_gets_per_access,'999,999,990')               blks_gets_per_access
  , 'lf_rows              ' ||to_char(lf_rows,    '999,999,990') || '        ' || +  
    'br_rows              ' ||to_char(br_rows,    '999,999,990')                        br_rows
  , 'lf_blks              ' ||to_char(lf_blks,    '999,999,990') || '        ' || +
    'br_blks              ' ||to_char(br_blks,    '999,999,990')                        br_blks
  , 'lf_rows_len          ' ||to_char(lf_rows_len,'999,999,990') || '        ' || +
    'br_rows_len          ' ||to_char(br_rows_len,'999,999,990')                        br_rows_len
  , 'lf_blk_len           ' ||to_char(lf_blk_len, '999,999,990') || '        ' || +
    'br_blk_len           ' ||to_char(br_blk_len, '999,999,990')                        br_blk_len
FROM
  index_stats
/  
  
UNDEFINE index_name

SET FEEDBACK    6
SET HEADING     ON
