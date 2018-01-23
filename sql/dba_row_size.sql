-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_row_size.sql                                                |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Determines the row sizes for all tables in a given schema.      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Calculate Row Size for Tables in a Specified Schema         |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema CHAR  PROMPT 'Enter schema name : '

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

COLUMN Tot_Size   FORMAT 99,999
COLUMN data_type  FORMAT a15

BREAK ON table_name SKIP 2

COMPUTE sum OF Tot_Size    ON table_name
COMPUTE sum OF data_length ON table_name

SELECT
    table_name
  , column_name
  , DECODE(    DATA_TYPE
             , 'NUMBER'   , DATA_PRECISION+DATA_SCALE
             , 'VARCHAR2' , TO_NUMBER(DATA_LENGTH)
             , 'CHAR'     , TO_NUMBER(DATA_LENGTH)
             , 'DATE'     , TO_NUMBER(DATA_LENGTH)) Tot_Size
  , DATA_TYPE
FROM      dba_tab_columns
WHERE     owner = UPPER('&schema')
ORDER BY  table_name
        , column_id
/

