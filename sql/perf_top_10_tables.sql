-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_top_10_tables.sql                                          |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on top 10 tables with respect to usage and command type. |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN ctyp      FORMAT a13                  HEADING 'Command Type'
COLUMN obj       FORMAT a30                  HEADING 'Object Name'
COLUMN noe       FORMAT 999,999,999,999,999  HEADING 'Number of Executions'
COLUMN gets      FORMAT 999,999,999,999,999  HEADING 'Buffer Gets'
COLUMN rowp      FORMAT 999,999,999,999,999  HEADING 'Rows Processed'

BREAK ON report
COMPUTE sum OF noe   ON report
COMPUTE sum OF gets  ON report
COMPUTE sum OF rowp  ON report

SELECT
    ctyp
  , obj
  , 0 - exem noe
  , gets
  , rowp
FROM (
    select distinct exem, ctyp, obj, gets, rowp 
    from (select
              DECODE(   s.command_type
                      , 2,  'Insert into '
                      , 3,  'Select from '
                      , 6,  'Update  of  '
                      , 7,  'Delete from '
                      , 26, 'Lock    of  ')   ctyp
            , o.owner || '.' || o.name        obj
            , SUM(0 - s.executions)           exem
            , SUM(s.buffer_gets)              gets
            , SUM(s.rows_processed)           rowp
          from
              v$sql                s
            , v$object_dependency  d
            , v$db_object_cache    o 
          where
                s.command_type  IN (2,3,6,7,26) 
            and d.from_address  = s.address 
            and d.to_owner      = o.owner 
            and d.to_name       = o.name   
            and o.type          = 'TABLE' 
          group by
              s.command_type
            , o.owner
            , o.name
    )
)
WHERE rownum <= 10;

