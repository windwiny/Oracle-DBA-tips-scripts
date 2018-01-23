-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_top_10_procedures.sql                                      |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on top 10 procedures with respect to usage .             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN ptyp      FORMAT a13                  HEADING 'Object Type'
COLUMN obj       FORMAT a42                  HEADING 'Object Name'
COLUMN noe       FORMAT 999,999,999,999,999  HEADING 'Number of Executions'

BREAK ON report
COMPUTE sum OF noe   ON report

SELECT
    ptyp
  , obj
  , 0 - exem noe
FROM ( select distinct exem, ptyp, obj  
       from ( select
                  o.type                    ptyp
                , o.owner || '.' || o.name  obj
                , 0 - o.executions          exem
              from  v$db_object_cache O 
              where o.type in ('FUNCTION','PACKAGE','PACKAGE BODY','PROCEDURE','TRIGGER')
	   )
     )
WHERE rownum <= 10;

