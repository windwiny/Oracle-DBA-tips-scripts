-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_files.sql                                                   |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all files, file metadata, and       |
-- |            volume information for all ASM disk groups customized for       |
-- |            Oracle 11g and higher.                                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : ASM Files                                                   |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

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

COLUMN full_path              FORMAT a75                  HEAD 'ASM File Name / Volume Name / Device Name'
COLUMN system_created         FORMAT a8                   HEAD 'System|Created?'
COLUMN bytes                  FORMAT 9,999,999,999,999    HEAD 'Bytes'
COLUMN space                  FORMAT 9,999,999,999,999    HEAD 'Space'
COLUMN type                   FORMAT a18                  HEAD 'File Type'
COLUMN redundancy             FORMAT a12                  HEAD 'Redundancy'
COLUMN striped                FORMAT a8                   HEAD 'Striped'
COLUMN creation_date          FORMAT a20                  HEAD 'Creation Date'
COLUMN disk_group_name        noprint

BREAK ON report ON disk_group_name SKIP 1

COMPUTE sum LABEL ""              OF bytes space ON disk_group_name
COMPUTE sum LABEL "Grand Total: " OF bytes space ON report

SELECT
    CONCAT('+' || db_files.disk_group_name, SYS_CONNECT_BY_PATH(db_files.alias_name, '/')) full_path
  , db_files.bytes
  , db_files.space
  , NVL(LPAD(db_files.type, 18), '<DIRECTORY>')  type
  , db_files.creation_date
  , db_files.disk_group_name
  , LPAD(db_files.system_created, 4) system_created
FROM
    ( SELECT
          g.name               disk_group_name
        , a.parent_index       pindex
        , a.name               alias_name
        , a.reference_index    rindex
        , a.system_created     system_created
        , f.bytes              bytes
        , f.space              space
        , f.type               type
        , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
      FROM
          v$asm_file f RIGHT OUTER JOIN v$asm_alias     a USING (group_number, file_number)
                                   JOIN v$asm_diskgroup g USING (group_number)
    ) db_files
WHERE db_files.type IS NOT NULL
START WITH (MOD(db_files.pindex, POWER(2, 24))) = 0
    CONNECT BY PRIOR db_files.rindex = db_files.pindex
UNION
SELECT
    '+' || volume_files.disk_group_name ||  ' [' || volume_files.volume_name || '] ' ||  volume_files.volume_device full_path
  , volume_files.bytes
  , volume_files.space
  , NVL(LPAD(volume_files.type, 18), '<DIRECTORY>')  type
  , volume_files.creation_date
  , volume_files.disk_group_name
  , null
FROM
    ( SELECT
          g.name               disk_group_name
        , v.volume_name        volume_name
        , v.volume_device       volume_device
        , f.bytes              bytes
        , f.space              space
        , f.type               type
        , TO_CHAR(f.creation_date, 'DD-MON-YYYY HH24:MI:SS')  creation_date
      FROM
          v$asm_file f RIGHT OUTER JOIN v$asm_volume    v USING (group_number, file_number)
                                   JOIN v$asm_diskgroup g USING (group_number)
    ) volume_files
WHERE volume_files.type IS NOT NULL
/

