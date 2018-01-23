-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_recompile_invalid_objects.sql                               |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Dynamically create a SQL script to recompile all INVALID        |
-- |            objects.                                                        |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

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

spool compile.sql

SELECT  'alter ' ||
       decode(object_type, 'PACKAGE BODY', 'package', object_type) ||
       ' ' ||
       object_name||
       ' compile' ||
       decode(object_type, 'PACKAGE BODY', ' body;', ';')
FROM   dba_objects
WHERE  status = 'INVALID'
/

spool off

SET ECHO        off
SET FEEDBACK    off
SET HEADING     off
SET LINESIZE    180
SET PAGESIZE    0
SET TERMOUT     on
SET TIMING      off
SET TRIMOUT     on
SET TRIMSPOOL   on
SET VERIFY      off

@compile

SET FEEDBACK    6
SET HEADING     ON
