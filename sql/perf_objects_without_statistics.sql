-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_objects_without_statistics.sql                             |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report on all objects that do not have statistics collected on  |
-- |            them.                                                           |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

COLUMN owner            FORMAT a17    HEAD 'Owner'
COLUMN object_type      FORMAT a15    HEAD 'Object Type'
COLUMN object_name      FORMAT a30    HEAD 'Object Name'
COLUMN partition_name   FORMAT a30    HEAD 'Partition Name'

SELECT
    owner           owner
  , 'Table'         object_type
  , table_name      object_name
  , NULL            partition_name
FROM
    sys.dba_tables 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('SYS','SYSTEM') 
  AND partitioned = 'NO' 
UNION 
SELECT
    owner           owner
  , 'Index'         object_type
  , index_name      object_name
  , NULL            partition_name
FROM
    sys.dba_indexes 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('SYS','SYSTEM') 
  AND partitioned = 'NO' 
UNION 
SELECT
    table_owner       owner
  , 'Table Partition' object_type
  , table_name        object_name
  , partition_name    partition_name
FROM
    sys.dba_tab_partitions 
WHERE
      last_analyzed IS NULL 
  AND table_owner NOT IN ('SYS','SYSTEM') 
UNION 
SELECT
    index_owner       owner
  , 'Index Partition' object_type
  , index_name        object_name
  , partition_name    partition_name
FROM
    sys.dba_ind_partitions 
WHERE
      last_analyzed IS NULL 
  AND index_owner NOT IN ('SYS','SYSTEM')
ORDER BY
    1
  , 2
  , 3
/

