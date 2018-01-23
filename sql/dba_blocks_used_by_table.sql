-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_blocks_used_by_table.sql                                    |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This article describes how to find out how many blocks are      |
-- |            really being used within a table. (ie. Blocks that are not      |
-- |            empty) Scripts are included for both Oracle7 and Oracle8.       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

--------------------------------------------
HOW MANY BLOCKS CONTAIN DATA (are not empty)
-----------------------------------------------------------------------
Each row in the table has pseudocolumn called ROWID.
This pseudo contains information about physical location
of the row in format:

       block_number.row.file

If the table is stored in a tablespace which has one 
datafile, all we have to do is to get DISTINCT
number of block_number from ROWID column of this table.

But if the table is stored in a tablespace with more than one
datafile then you can have the same block_number but in 
different datafiles so we have to get DISTINCT number of 
block_number+file from ROWID.

The SELECT statements which give us the number of "really used"
blocks is below. They are different for ORACLE 7 and ORACLE 8 
because of different structure of ROWID column in these versions.

You could ask why the above information could not be determined
by using the ANALYZE TABLE command. The ANALYZE TABLE command only
identifies the number of 'ever' used blocks or the high water mark
for the table.
-----------------------------------------------------------------------



-------
ORACLE7
-----------------------------------------------------------------------

SELECT
  COUNT(DISTINCT(SUBSTR(rowid,1,8)
                ||
                SUBSTR(rowid,15,4)))
FROM &table_name
/


--------
ORACLE8+
-----------------------------------------------------------------------

SELECT COUNT ( DISTINCT 
         DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid)
         ||
         DBMS_ROWID.ROWID_RELATIVE_FNO(rowid)
       ) "Used"
FROM &table_name;

  - or -

SELECT COUNT (DISTINCT SUBSTR(rowid,1,15)) "Used"
FROM &table_name;

