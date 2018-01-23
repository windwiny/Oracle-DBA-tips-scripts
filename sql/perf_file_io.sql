-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_file_io.sql                                                |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports on Read/Write datafile activity. This script was        |
-- |            designed to work with Oracle8i or higher. It will include all   |
-- |            tablespaces using any type of extent management as well as true |
-- |            TEMPORARY tablespaces. (i.e. use of "tempfiles")                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN ts_name    FORMAT a15          HEAD 'Tablespace'
COLUMN fname      FORMAT a45          HEAD 'File Name'
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
    df.tablespace_name                       ts_name
  , df.file_name                             fname
  , fs.phyrds                                phyrds
  , (fs.phyrds * 100) / (fst.pr + tst.pr)    read_pct
  , fs.phywrts                               phywrts
  , (fs.phywrts * 100) / (fst.pw + tst.pw)   write_pct
FROM
    sys.dba_data_files df
  , v$filestat         fs
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    df.file_id = fs.file#
UNION
SELECT
    tf.tablespace_name                     ts_name
  , tf.file_name                           fname
  , ts.phyrds                              phyrds
  , (ts.phyrds * 100) / (fst.pr + tst.pr)  read_pct
  , ts.phywrts                             phywrts
  , (ts.phywrts * 100) / (fst.pw + tst.pw) write_pct
FROM
    sys.dba_temp_files  tf
  , v$tempstat          ts
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    tf.file_id = ts.file#
ORDER BY phyrds DESC
/

