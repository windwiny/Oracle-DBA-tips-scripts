-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_query_hidden_parameters.sql                                 |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Reports on all hidden "undocumented" database parameters. You   |
-- |            must be connected as the SYS user to run this script.           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Invalid Objects                                             |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    256
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN ksppinm   FORMAT a55   HEAD 'Parameter Name'
COLUMN ksppstvl  FORMAT a40   HEAD 'Value'
COLUMN ksppdesc  FORMAT a60   HEAD 'Description'    TRUNC

SELECT
    ksppinm
  , ksppstvl
  , ksppdesc
FROM
    x$ksppi x
  , x$ksppcv y
WHERE
      x.indx = y.indx 
  AND TRANSLATE(ksppinm,'_','#') like '#%'
ORDER BY
  ksppinm
/

