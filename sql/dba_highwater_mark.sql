-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_highwater_mark.sql                                          |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Determine the highwater mark of a given table.                  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

ANALYZE TABLE &owner.&table_name COMPUTE STATISTICS
/

SELECT
      blocks
FROM
      dba_segments
WHERE
      owner = '&&owner'
  AND segment_name = '&&table_name'
/

SELECT
      empty_blocks
FROM
      dba_tables
WHERE
      owner = '&&owner'
  AND table_name = '&&table_name'
/

PROMPT HIGHWATER_MARK = dba_segments.blocks - dba_tables.empty_blocks - 1


/*

----------------------------------------------------------------

What is the High Water Mark?
----------------------------
All Oracle segments have an upper boundary containing the data within
the segment. This upper boundary is called the "high water mark" or HWM.
The high water mark is an indicator that marks blocks that are allocated 
to a segment, but are not used yet. This high water mark typically bumps 
up at 5 data blocks at a time. It is reset to "zero" (position to the start
of the segment) when a TRUNCATE command is issued.  So you can have empty 
blocks below the high water mark, but that means that the block has been 
used (and is probably empty caused by deletes). Oracle does not move the 
HWM, nor does it *shrink* tables, as a result of deletes.  This is also 
true of Oracle8.  Full table scans typically read up to the high water mark.
 
Data files do not have a high water mark; only segments do have them. 
 
How to determine the high water mark
------------------------------------
To view the high water mark of a particular table::
 
    ANALYZE TABLE <tablename> ESTIMATE/COMPUTE STATISTICS;

This will update the table statistics. After generating the statistics,
to determine the high water mark:

SELECT blocks, empty_blocks, num_rows
FROM   user_tables
WHERE table_name = <tablename>;

BLOCKS represents the number of blocks 'ever' used by the segment. 
EMPTY_BLOCKS represents only the number of blocks above the 'HIGH WATER MARK' 

Deleting records doesn't lower the high water mark. Therefore, deleting 
records doesn't raise the EMPTY_BLOCKS figure.

Let us take the following example based on table BIG_EMP1 which
has 28672 rows (Oracle 8.0.6):

SQL> connect system/manager

Connected.

SQL> SELECT segment_name,segment_type,blocks
  2> FROM dba_segments
  3> WHERE segment_name='BIG_EMP1';

SEGMENT_NAME                  SEGMENT_TYPE      BLOCKS      EXTENTS
----------------------------- ----------------- ----------  -------
BIG_EMP1                      TABLE                   1024      2

1 row selected.

SQL> connect scott/tiger

SQL> ANALYZE TABLE big_emp1 ESTIMATE STATISTICS;

Statement processed.

SQL> SELECT table_name,num_rows,blocks,empty_blocks
  2> FROM user_tables
  3> WHERE table_name='BIG_EMP1';

TABLE_NAME                     NUM_ROWS   BLOCKS     EMPTY_BLOCKS
------------------------------ ---------- ---------- ------------
BIG_EMP1                            28672        700        323

1 row selected.

Note: BLOCKS + EMPTY_BLOCKS (700+323=1023) is one block less than 
DBA_SEGMENTS.BLOCKS. This is because one block is reserved for the 
segment header. DBA_SEGMENTS.BLOCKS holds the total number of blocks 
allocated to the table. USER_TABLES.BLOCKS holds the total number of
blocks allocated for data.

SQL> SELECT COUNT (DISTINCT 
  2>          DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid)||
  3>          DBMS_ROWID.ROWID_RELATIVE_FNO(rowid)) "Used"
  4> FROM big_emp1;

Used      
----------
       700

1 row selected.

SQL> DELETE from big_emp1;

28672 rows processed.

SQL> commit;

Statement processed.

SQL> ANALYZE TABLE big_emp1 ESTIMATE STATISTICS;

Statement processed.

SQL> SELECT table_name,num_rows,blocks,empty_blocks
  2> FROM user_tables
  3> WHERE table_name='BIG_EMP1';

TABLE_NAME                     NUM_ROWS   BLOCKS     EMPTY_BLOCKS
------------------------------ ---------- ---------- ------------
BIG_EMP1                                0        700        323

1 row selected.

SQL> SELECT COUNT (DISTINCT 
  2>          DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid)||
  3>          DBMS_ROWID.ROWID_RELATIVE_FNO(rowid)) "Used"
  4> FROM big_emp1;

Used      
----------
         0

1 row selected.

SQL> TRUNCATE TABLE big_emp1;

Statement processed.

SQL> ANALYZE TABLE big_emp1 ESTIMATE STATISTICS;

Statement processed.

SQL> SELECT table_name,num_rows,blocks,empty_blocks
  2> FROM user_tables
  3> WHERE table_name='BIG_EMP1';

TABLE_NAME                     NUM_ROWS   BLOCKS     EMPTY_BLOCKS
------------------------------ ---------- ---------- ------------
BIG_EMP1                                0          0        511

1 row selected.

SQL> connect system/manager

Connected.

SQL> SELECT segment_name,segment_type,blocks
  2> FROM dba_segments
  3> WHERE segment_name='BIG_EMP1';

SEGMENT_NAME                  SEGMENT_TYPE      BLOCKS      EXTENTS
----------------------------- ----------------- ----------  -------
BIG_EMP1                      TABLE                   512      1

1 row selected.

NOTE:
----
  TRUNCATE has also deallocated the space from the deleted rows.
  To retain the space from the deleted rows allocated to the table use:

  SQL> TRUNCATE TABLE big_emp1 REUSE STORAGE

*/

