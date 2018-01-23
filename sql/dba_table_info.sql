-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_table_info.sql                                              |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Prompt the user for a schema and and table name then query all  |
-- |            metadata about the table.                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Table Information                                           |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema     CHAR PROMPT 'Enter table owner : '
ACCEPT table_name CHAR PROMPT 'Enter table name  : '

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET LONG        9000
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
PROMPT | TABLE INFORMATION                                                      |
PROMPT +------------------------------------------------------------------------+

COLUMN owner               FORMAT a20                   HEADING "Owner"
COLUMN table_name          FORMAT a30                   HEADING "Table Name"
COLUMN tablespace_name     FORMAT a30                   HEADING "Tablespace"
COLUMN last_analyzed       FORMAT a23                   HEADING "Last Analyzed"
COLUMN num_rows            FORMAT 9,999,999,999,999     HEADING "# of Rows"

SELECT
    owner
  , table_name
  , tablespace_name
  , TO_CHAR(last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
  , num_rows
FROM
    dba_tables
WHERE
      owner      = UPPER('&schema')
  AND table_name = UPPER('&table_name')
/

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | OBJECT INFORMATION                                                     |
PROMPT +------------------------------------------------------------------------+

COLUMN object_id                                     HEADING "Object ID"
COLUMN data_object_id                                HEADING "Data Object ID"
COLUMN created             FORMAT A23                HEADING "Created"
COLUMN last_ddl_time       FORMAT A23                HEADING "Last DDL"
COLUMN status                                        HEADING "Status"

SELECT
    object_id
  , data_object_id
  , TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS')        created
  , TO_CHAR(last_ddl_time, 'DD-MON-YYYY HH24:MI:SS')  last_ddl_time
  , status
FROM
    dba_objects
WHERE
      owner       = UPPER('&schema')
  AND object_name = UPPER('&table_name')
  AND object_type = 'TABLE'
/

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | SEGMENT INFORMATION                                                    |
PROMPT +------------------------------------------------------------------------+

COLUMN segment_name        FORMAT a30                HEADING "Segment Name"
COLUMN partition_name      FORMAT a30                HEADING "Partition Name"
COLUMN segment_type        FORMAT a16                HEADING "Segment Type"
COLUMN tablespace_name     FORMAT a30                HEADING "Tablespace"
COLUMN num_rows            FORMAT 9,999,999,999,999  HEADING "Num Rows"
COLUMN bytes               FORMAT 9,999,999,999,999  HEADING "Bytes"
COLUMN last_analyzed       FORMAT a23                HEADING "Last Analyzed"

SELECT 
    seg.segment_name      segment_name
  , null                  partition_name
  , seg.segment_type      segment_type
  , seg.tablespace_name   tablespace_name
  , tab.num_rows          num_rows
  , seg.bytes             bytes
  , TO_CHAR(tab.last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
from
    dba_segments seg
  , dba_tables tab
WHERE
      seg.owner = UPPER('&schema')
  AND seg.segment_name = UPPER('&table_name')
  AND seg.segment_name = tab.table_name
  AND seg.owner = tab.owner
  AND seg.segment_type = 'TABLE'
UNION ALL
SELECT 
    seg.segment_name      segment_name
  , seg.partition_name    partition_name
  , seg.segment_type      segment_type
  , seg.tablespace_name   tablespace_name
  , part.num_rows         num_rows
  , seg.bytes             bytes
  , TO_CHAR(part.last_analyzed, 'DD-MON-YYYY HH24:MI:SS') last_analyzed
FROM
    dba_segments seg
  , dba_tab_partitions part
WHERE
      part.table_owner = UPPER('&schema')
  AND part.table_name = UPPER('&table_name')
  AND part.partition_name = seg.partition_name
  AND seg.segment_type = 'TABLE PARTITION'
ORDER BY
    segment_name
  , partition_name
/


PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | COLUMNS                                                                |
PROMPT +------------------------------------------------------------------------+

COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN data_type           FORMAT a25                HEADING "Data Type"
COLUMN nullable            FORMAT a13                HEADing "Null?"

SELECT
    column_name
  , DECODE(nullable, 'Y', ' ', 'NOT NULL') nullable
  , DECODE(data_type
               , 'RAW',      data_type || '(' ||  data_length || ')'
               , 'CHAR',     data_type || '(' ||  data_length || ')'
               , 'VARCHAR',  data_type || '(' ||  data_length || ')'
               , 'VARCHAR2', data_type || '(' ||  data_length || ')'
               , 'NUMBER', NVL2(   data_precision
                                 , DECODE(    data_scale
                                            , 0
                                            , data_type || '(' || data_precision || ')'
                                            , data_type || '(' || data_precision || ',' || data_scale || ')'
                                   )
                                 , data_type)
               , data_type
    ) data_type
FROM
    dba_tab_columns
WHERE
      owner      = UPPER('&schema')
  AND table_name = UPPER('&table_name')
ORDER BY
    column_id
/


PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | INDEXES                                                                |
PROMPT +------------------------------------------------------------------------+

COLUMN index_name          FORMAT a40                HEADING "Index Name"
COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN column_length                                 HEADING "Column Length"

BREAK ON index_name SKIP 1

SELECT 
    index_owner || '.' || index_name  index_name
  , column_name
  , column_length
FROM
    dba_ind_columns
WHERE
      table_owner  = UPPER('&schema')
  AND table_name   = UPPER('&table_name')
ORDER BY
    index_name
  , column_position
/


PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | CONSTRAINTS                                                            |
PROMPT +------------------------------------------------------------------------+

COLUMN constraint_name     FORMAT a30                HEADING "Constraint Name"
COLUMN constraint_type     FORMAT a13                HEADING "Constraint|Type"
COLUMN search_condition    FORMAT a30                HEADING "Search Condition"
COLUMN r_constraint_name   FORMAT a30                HEADING "R / Constraint Name"
COLUMN delete_rule         FORMAT a12                HEADING "Delete Rule"
COLUMN status                                        HEADING "Status"

BREAK ON constraint_name ON constraint_type

SELECT 
    a.constraint_name
  , DECODE(a.constraint_type
             , 'P', 'Primary Key'
             , 'C', 'Check'
             , 'R', 'Referential'
             , 'V', 'View Check'
             , 'U', 'Unique'
             , a.constraint_type
    ) constraint_type
  , b.column_name
  , a.search_condition
  , NVL2(a.r_owner, a.r_owner || '.' ||  a.r_constraint_name, null) r_constraint_name
  , a.delete_rule
  , a.status
FROM 
    dba_constraints  a
  , dba_cons_columns b
WHERE
      a.owner            = UPPER('&schema')
  AND a.table_name       = UPPER('&table_name')
  AND a.constraint_name  = b.constraint_name
  AND b.owner            = UPPER('&schema')
  AND b.table_name       = UPPER('&table_name')
ORDER BY
    a.constraint_name
  , b.position
/


PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | PARTITIONS (TABLE)                                                     |
PROMPT +------------------------------------------------------------------------+

COLUMN partition_name                                HEADING "Partition Name"
COLUMN column_name         FORMAT a30                HEADING "Column Name"
COLUMN tablespace_name     FORMAT a30                HEADING "Tablespace"
COLUMN composite           FORMAT a9                 HEADING "Composite"
COLUMN subpartition_count                            HEADING "Sub. Part.|Count"
COLUMN logging             FORMAT a7                 HEADING "Logging"
COLUMN high_value          FORMAT a13                HEADING "High Value" TRUNC

BREAK ON partition_name

SELECT
    a.partition_name
  , b.column_name
  , a.tablespace_name
  , a.composite
  , a.subpartition_count
  , a.logging
FROM 
    dba_tab_partitions    a
  , dba_part_key_columns  b
WHERE
      a.table_owner        = UPPER('&schema')
  AND a.table_name         = UPPER('&table_name')
  AND RTRIM(b.object_type) = 'TABLE'
  AND b.owner              = a.table_owner
  AND b.name               = a.table_name
ORDER BY
    a.partition_position
  , b.column_position
/


PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | PARTITIONS (INDEX)                                                     |
PROMPT +------------------------------------------------------------------------+

COLUMN index_name              FORMAT a30                HEADING "Index Name"
COLUMN partitioning_type       FORMAT a9                 HEADING "Type"
COLUMN partition_count         FORMAT 99999              HEADING "Part.|Count"
COLUMN partitioning_key_count  FORMAT 99999              HEADING "Part.|Key Count"
COLUMN locality                FORMAT a8                 HEADING "Locality"
COLUMN alignment               FORMAT a12                HEADING "Alignment"

SELECT
    a.owner || '.' || a.index_name   index_name
  , b.column_name
  , a.partitioning_type
  , a.partition_count
  , a.partitioning_key_count
  , a.locality
  , a.alignment
FROM 
    dba_part_indexes      a
  , dba_part_key_columns  b
WHERE
      a.owner              = UPPER('&schema')
  AND a.table_name         = UPPER('&table_name')
  AND RTRIM(b.object_type) = 'INDEX'
  AND b.owner              = a.owner
  AND b.name               = a.index_name
ORDER BY
    a.index_name
  , b.column_position
/



PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | TRIGGERS                                                               |
PROMPT +------------------------------------------------------------------------+

COLUMN trigger_name            FORMAT a30                HEADING "Trigger Name"
COLUMN trigger_type            FORMAT a18                HEADING "Type"
COLUMN triggering_event        FORMAT a9                 HEADING "Trig.|Event"
COLUMN referencing_names       FORMAT a65                HEADING "Referencing Names" newline
COLUMN when_clause             FORMAT a65                HEADING "When Clause" newline
COLUMN trigger_body            FORMAT a65                HEADING "Trigger Body" newline

SELECT
    owner || '.' || trigger_name  trigger_name
  , trigger_type
  , triggering_event
  , status
  , referencing_names
  , when_clause
  , trigger_body
FROM
    dba_triggers
WHERE
      table_owner = UPPER('&schema')
  AND table_name  = UPPER('&table_name')
ORDER BY
     trigger_name
/

