-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_related_child_tables.sql                                    |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Query all child tables related to a given parent table name.    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

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

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | All child tables related to a parent table name                        |
PROMPT +------------------------------------------------------------------------+
PROMPT 

ACCEPT table_owner  prompt 'Enter parent table owner : '
ACCEPT table_name   prompt 'Enter parent table name  : '

SELECT
    p.table_name  PARENT_TABLE_NAME
  , c.table_name  CHILD_TABLE
FROM
    dba_constraints  p
  , dba_constraints  c
WHERE
    (p.constraint_type = 'P' OR p.constraint_type = 'U')
    AND
    (c.constraint_type = 'R')
    AND
    (p.constraint_name = c.r_constraint_name)
    AND
    (p.owner = UPPER('&table_owner'))
    AND
    (p.table_name = UPPER('&table_name'))
ORDER BY 2
/

