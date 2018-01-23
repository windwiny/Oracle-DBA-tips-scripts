-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_file_io_7.sql                                              |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports on Read/Write datafile activity. This script was        |
-- |            designed to work with Oracle7 and Oracle8. This script can be   |
-- |            run against higher database versions (i.e. Oracle8i) but will   |
-- |            not return information about true TEMPORARY tablespaces.        |
-- |            (i.e. use of "tempfiles")                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN phys_reads   NEW_VALUE xphys_reads  NOPRINT FORMAT a1
COLUMN phys_writes  NEW_VALUE xphys_writes NOPRINT FORMAT a1

SELECT
    SUM(phyrds) phys_reads
  , SUM(phywrts) phys_writes
FROM v$filestat
/

COLUMN name       FORMAT a45          HEAD 'File Name'
COLUMN phyrds     FORMAT 999,999,999  HEAD 'Physical Reads'
COLUMN phywrts    FORMAT 999,999,999  HEAD 'Physical Writes'
COLUMN read_pct   FORMAT 999.99       HEAD 'Read Pct.'
COLUMN write_pct  FORMAT 999.99       HEAD 'Write Pct.'

BREAK ON report
COMPUTE SUM OF phyrds     ON report
COMPUTE SUM OF phywrts    ON report
COMPUTE AVG OF read_pct   ON report
COMPUTE AVG OF write_pct  ON report


SELECT
    name                                    name
  , phyrds                                  phyrds
  , phyrds * 100 / &xphys_reads             read_pct
  , phywrts                                 phywrts
  , phywrts * 100 / &xphys_writes           write_pct
FROM
    v$datafile       df
  , v$filestat       fs
WHERE
    df.file# = fs.file#
ORDER BY phyrds DESC
/

