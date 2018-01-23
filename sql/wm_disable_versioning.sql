-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : wm_disable_versioning.sql                                       |
-- | CLASS    : Workspace Manager                                               |
-- | PURPOSE  : Prompt the user for an owner and table name. This table will be |
-- |            disabled of any versioning used with Workspace Manager. This    |
-- |            script deletes all support structures that were created to      |
-- |            enable the table to support versioned rows. This procedure is   |
-- |            used to reverse the effect of the EnableVersioning Procedure.   |
-- |            It deletes the Workspace Manager infrastructure (support        |
-- |            structures) for versioning of rows, but does not affect any     |
-- |            user data in the LIVE workspace. The workspace hierarchy and    |
-- |            any savepoints still exist, but all rows are the same as in the |
-- |            LIVE workspace. (If there are multiple versions in the LIVE     |
-- |            workspace of a row in the table for which versioning is         |
-- |            disabled, only the most recent version of the row is kept.)     |
-- |            Only the owner of a table or a user with the WM_ADMIN_ROLE role |
-- |            can disable versioning on the table. Tables that are            |
-- |            version-enabled and users that own version-enabled tables       |
-- |            cannot be deleted. You must first disable versioning on the     |
-- |            relevant table or tables. An exception is raised if the table   |
-- |            is not version-enabled.                                         |
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
PROMPT | Report   : Disable Table Versioning for Current Workspace              |
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

COLUMN getworkspace     FORMAT a50          HEADING "Current Workspace"
COLUMN ver_tables       FORMAT a50          HEADING "All Current Versioned Tables"

SELECT dbms_wm.getworkspace FROM dual;

SELECT
    owner || '.' || table_name AS ver_tables
FROM
    wmsys.wm$versioned_tables
UNION ALL
SELECT
    'No versioned tables found'
FROM
    dual
WHERE NOT EXISTS ( SELECT owner, table_name
                   FROM wmsys.wm$versioned_tables)
ORDER BY 1;

PROMPT 
ACCEPT wm_ev_owner  CHAR PROMPT 'Enter table owner : '
ACCEPT wm_ev_table  CHAR PROMPT 'Enter table name  : '
PROMPT 

DEFINE wm_ev_table_name = &wm_ev_owner..&wm_ev_table

BEGIN
    dbms_wm.disableversioning('&wm_ev_table_name');
END;
/

SELECT
    owner || '.' || table_name AS ver_tables
FROM
    wmsys.wm$versioned_tables
UNION ALL
SELECT
    'No versioned tables found'
FROM
    dual
WHERE NOT EXISTS ( SELECT owner, table_name
                   FROM wmsys.wm$versioned_tables)
ORDER BY 1;

