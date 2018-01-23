-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_cr_init.sql                                                 |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This script reads the database instance parameters and creates  |
-- |            an example init.ora file. This is often used when cloning a     |
-- |            database and need a fresh text init.ora file for the new        |
-- |            database.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    OFF
SET HEADING     OFF
SET LINESIZE    32767
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN oracle_sid   NEW_VALUE xoracle_sid  NOPRINT FORMAT a1

SELECT  value  oracle_sid
FROM    v$parameter
WHERE   name = 'instance_name'
/

spool init&xoracle_sid..ora.sample

SELECT 
    '# +-------------------------------------------------------------------+' || chr(10) ||
    '# | FILE          : init' || i.value || '.ora' || LPAD('|', 43-length(i.value), ' ') || chr(10) || 
    '# | CREATION DATE : ' || 
      to_char(sysdate, 'DD-MON-YYYY') || 
      '                                       |' || chr(10) || 
    '# | DATABASE NAME : ' || d.value || LPAD('|', 51-length(d.value), ' ') || chr(10) ||
    '# | INSTANCE NAME : ' || i.value || LPAD('|', 51-length(i.value), ' ') || chr(10) ||
    '# | SERVER NAME   : ' || s.value || LPAD('|', 51-length(s.value), ' ') || chr(10) ||
    '# | GLOBAL NAME   : ' || g.global_name|| LPAD('|', 51-length(g.global_name), ' ') || chr(10) ||
    '# +-------------------------------------------------------------------+'
FROM
    v$parameter d
  , v$parameter i
  , v$parameter s
  , global_name g
WHERE
      d.name = 'db_name'
  AND i.name = 'instance_name'
  AND s.name = 'service_names';


select 
    '# +---------------------+' || chr(10) ||
    '# | DATABASE PARAMETERS |' || chr(10) ||
    '# +---------------------+'
from dual;

SELECT
  DECODE(isdefault, 'TRUE', '# ') ||
  DECODE(isdefault, 'TRUE', RPAD(name,43), RPAD(name,45)) ||
  ' = ' ||
  value
FROM v$parameter
ORDER BY name;

spool off

SET FEEDBACK    6
SET HEADING     ON

