-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : fra_status.sql                                                  |
-- | CLASS    : Fast Recovery Area                                              |
-- | PURPOSE  : Provide an overview of the Oracle Flash Recovery Area. This     |
-- |            script is RAC enabled.                                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(sys_context('USERENV', 'INSTANCE_NAME'), 17) current_instance
FROM dual;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : FRA Status                                                  |
PROMPT | Instance : &current_instance                                           |
PROMPT | Notes    : Current location, disk quota, space in use, space           |
PROMPT |            reclaimable by deleting files, and number of files in the   |
PROMPT |            Flash Recovery Area.                                        |
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

COLUMN recovery_file_dest FORMAT a30                  HEADING 'Recovery File Dest'
COLUMN space_limit        FORMAT 99,999,999,999,999   HEADING 'Space Limit'
COLUMN space_used         FORMAT 99,999,999,999,999   HEADING 'Space Used'
COLUMN space_used_pct     FORMAT 999.99               HEADING '% Used'
COLUMN space_reclaimable  FORMAT 99,999,999,999,999   HEADING 'Space Reclaimable'
COLUMN pct_reclaimable    FORMAT 999.99               HEADING '% Reclaimable'
COLUMN number_of_files    FORMAT 999,999              HEADING 'Number of Files'

SELECT
    f.name                                              recovery_file_dest
  , f.space_limit                                       space_limit
  , f.space_used                                        space_used
  , ROUND((f.space_used / f.space_limit)*100, 2)        space_used_pct
  , f.space_reclaimable                                 space_reclaimable
  , ROUND((f.space_reclaimable / f.space_limit)*100, 2) pct_reclaimable
  , f.number_of_files                                   number_of_files
FROM
    v$recovery_file_dest f
ORDER BY
    f.name;


COLUMN file_type                  FORMAT a30     HEADING 'File Type'
COLUMN percent_space_used                        HEADING 'Percent Space Used'
COLUMN percent_space_reclaimable                 HEADING 'Percent Space Reclaimable'
COLUMN number_of_files            FORMAT 999,999 HEADING 'Number of Files'

SELECT
    f.file_type
  , f.percent_space_used
  , f.percent_space_reclaimable
  , f.number_of_files
FROM
    v$flash_recovery_area_usage f
ORDER BY
    f.file_type;

