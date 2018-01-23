-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_file_io_efficiency.sql                                     |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : This script produces a cumulative report that gives information |
-- |            based on IO efficiency since the Oracle instance was started.   |
-- |            The report generated will list physical block reads and         |
-- |            efficiency (the efficiency number measures the percentage of    |
-- |            time Oracle asked for and got the right block the first time;   |
-- |            this is a function of the type of table scan and indexing).     |
-- |                                                                            |
-- |            The relative low efficiency of the SYSTEM areas is normal. This |
-- |            is due to indexes and tables being mixed together in the SYSTEM |
-- |            tablespace. A classic case on Oracle's part of "Do what we say, |
-- |            not what we do."                                                |
-- |                                                                            |
-- |            * If your temporary tablespace shows an efficiency number,      |
-- |              someone is using if for data instead of temporary tables.     |
-- |            * Rollback efficiency should always be 100 percent; if not,     |
-- |              someone is using the rollback tablespace for tables/indexes.  |
-- |            * Index tablespace should always show high efficiencies; if     |
-- |              they don't, then either the indexes are bad or someone is     |
-- |              using the index tablespace for tables.                        |
-- |            * An attempt should be made to even out IO. If a disk is        |
-- |              showing a considerable amount of IO, move some of the         |
-- |              datafiles to other disks.                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999

COLUMN ts        FORMAT a15     HEADING 'Tablespace'
COLUMN fn        FORMAT a38     HEADING 'Filename'
COLUMN rds                      HEADING 'Reads'
COLUMN blk_rds                  HEADING 'Block Reads'
COLUMN wrts                     HEADING 'Writes'
COLUMN blk_wrts                 HEADING 'Block Writes'
COLUMN rw                       HEADING 'Reads+Writes'
COLUMN blk_rw                   HEADING 'Block Reads+Writes'
COLUMN eff      FORMAT a10  HEADING 'Effeciency'

SELECT
    f.tablespace_name          ts
  , f.file_name                fn
  , v.phyrds                   rds
  , v.phyblkrd                 blk_rds
  , v.phywrts                  wrts
  , v.phyblkwrt                blk_wrts
  , v.phyrds + v.phywrts       rw
  , v.phyblkrd + v.phyblkwrt   blk_rw
  , DECODE(v.phyblkrd, 0, null, ROUND(100*(v.phyrds + v.phywrts)/(v.phyblkrd + v.phyblkwrt), 2)) eff
FROM
    dba_data_files  f
  , v$filestat      v
WHERE
  f.file_id = v.file#
ORDER BY
  rds
/

