-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_snapshot_database_9i.sql                                    |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format) on  |
-- |            all database metrics including installed options, storage,      |
-- |            performance data, and security.                                 |
-- | VERSION  : This script was designed for Oracle9i.                          |
-- | USAGE    :                                                                 |
-- |                                                                            |
-- |    sqlplus -s <dba>/<password>@<TNS string> @dba_snapshot_database_9i.sql  |
-- |                                                                            |
-- | TESTING  : This script has been successfully tested on the following       |
-- |            platforms:                                                      |
-- |                                                                            |
-- |              Solaris    : Oracle Database 9.2.0.8.0                        |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

define reportHeader="<a name=top></a><font size=+3 color=darkgreen><b>Snapshot Database 9<i>i</i></b></font><hr>Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved. (<a target=""_blank"" href=""http://www.idevelopment.info"">www.idevelopment.info</a>)<p>"


-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+

set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks

define fileName=dba_snapshot_database_9i
define versionNumber=3.6
define statsPackUser=PERFSTAT


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;



-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>Database Report</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#C0C0C0; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"' 

spool &FileName._&_dbname._&_spool_time..html

set markup html on entmap off


-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+

prompt &reportHeader



-- +----------------------------------------------------------------------------+
-- |                             - REPORT INDEX -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="report_index"></a>


prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Index</b></font><hr align="center" width="250"></center> -
<table width="90%" border="1"> -
<tr><th colspan="4">Database and Instance Information</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#report_header">Report Header</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#version">Version</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#options">Options</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_registry">Database Registry</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#instance_overview">Instance Overview</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_overview">Database Overview</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#initialization_parameters">Initialization Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#control_files">Control Files</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#control_file_records">Control File Records</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#online_redo_logs">Online Redo Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_switches">Redo Log Switches</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Jobs</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#jobs">Jobs</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -
<tr><th colspan="4">Storage</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespaces">Tablespaces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_files">Data Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_growth">Database Growth</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespace_extents">Tablespace Extents</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespace_to_owner">Tablespace to Owner</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#owner_to_tablespace">Owner to Tablespace</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">UNDO Segments</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_segments">UNDO Segments</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_segment_contention">UNDO Segment Contention</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -
<tr><th colspan="4">Archiving</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_mode">Archiving Mode</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_parameters">Archiving Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_history">Archiving History</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Recovery Manager - (RMAN)</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_configuration">RMAN Configuration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_sets">Backup Sets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_pieces">Backup Pieces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_control_files">Backup Control Files</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_spfile">Backup SPFILE</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Performance</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_information ">SGA Information</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#db_buffer_cache_hit_ratio">DB Buffer Cache Hit Ratio</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dictionary_cache_hit_ratio">Dictionary Cache Hit Ratio</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#library_cache_hit_ratio">Library Cache Hit Ratio</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#latch_contention">Latch Contention</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#system_wait_statistics">System Wait Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#system_statistics">System Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#system_event_statistics">System Event Statistics</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#file_io_statistics">File I/O Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#file_io_timings">File I/O Timings</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#average_overall_io_per_sec">Average Overall I/O per Second</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_contention">Redo Log Contention</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#full_table_scans">Full Table Scans</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sorts">Sorts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_outlines">Outlines</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_outline_hints">Outline Hints</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sql_statements_with_most_buffer_gets">SQL Statements With Most Buffer Gets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sql_statements_with_most_disk_reads">SQL Statements With Most Disk Reads</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_10_tables">Top 10 Tables</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_10_procedures">Top 10 Procedures</a></td> -
</tr>


prompt -
<tr><th colspan="4">Statspack</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sp_list">List</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sp_parameters">Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr> -
<tr><th colspan="4">Sessions</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#current_sessions">Current Sessions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#user_session_matrix">User Session Matrix</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Security</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#user_accounts">User Accounts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_dba_privileges">Users With DBA Privileges</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#roles">Roles</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#default_passwords">Default Passwords</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#db_links">DB Links</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Objects</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#object_summary">Object Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#segment_summary">Segment Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_200_segments_by_size">Top 200 Segments (by size)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_200_segments_by_extents">Top 200 Segments (by number of extents)</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directories">Directories</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_libraries">Libraries</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_types">Types</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_attributes">Type Attributes</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_methods">Type Methods</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_collections">Collections</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_lob_segments">LOB Segments</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_unable_to_extend">Objects Unable to Extend</a></td> -
</tr>

prompt -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_which_are_nearing_maxextents">Objects Which Are Nearing MAXEXTENTS</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#invalid_objects">Invalid Objects</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#procedural_object_errors">Procedural Object Errors</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_without_statistics">Objects Without Statistics</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tables_suffering_from_row_chaining_migration">Tables Suffering From Row Chaining/Migration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_tablespace_defined_as_system">Users With Default Tablespace - (SYSTEM)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_temporary_tablespace_as_system">Users With Default Temp Tablespace - (SYSTEM)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_in_the_system_tablespace">Objects in the SYSTEM Tablespace</a></td> -
</tr>


prompt -
<tr><th colspan="4">Online Analytical Processing - (OLAP)</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimensions">Dimensions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_levels">Dimension Levels</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_attributes">Dimension Attributes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_hierarchies">Dimension Hierarchies</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_cubes">Cubes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_views">Materialized Views</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_view_logs">Materialized View Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Networking</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_dispatcher_statistics">MTS Dispatcher Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_dispatcher_response_queue_wait_stats">MTS Dispatcher Response Queue Wait Stats</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_shared_server_wait_statistics">MTS Shared Server Wait Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Replication</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#replication_summary">Replication Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#deferred_transactions">Deferred Transactions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#administrative_request_jobs">Administrative Request Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rep_initialization_parameters">Initialization Parameters</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_purge_jobs">(Schedule) - Purge Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_push_jobs">(Schedule) - Push Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_refresh_jobs">(Schedule) - Refresh Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#multimaster_master_groups">(Multi-Master) - Master Groups</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#multimaster_master_groups_and_sites">(Multi-Master) - Master Groups and Sites</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_summary">(Materialized View) - Master Site Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_logs">(Materialized View) - Master Site Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_templates">(Materialized View) - Master Site Templates</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_summary">(Materialized View) - Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_groups">(Materialized View) - Groups</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_materialized_views">(Materialized View) - Materialized Views</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_refresh_groups">(Materialized View) - Refresh Groups</a></td> -
</tr> -
</table>

prompt <p>



-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database and Instance Information    >>>>>                |
-- |                                                                            |
-- +============================================================================+




-- +----------------------------------------------------------------------------+
-- |                            - REPORT HEADER -                               |
-- +----------------------------------------------------------------------------+

prompt 
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Header</b></font><hr align="left" width="460">

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_dbname._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Snapshot Database Version</th><td width="80%"><tt>&versionNumber</tt></td></tr> -
<tr><th align="left" width="20%">Run Date / Time</th><td width="80%"><tt>&_date_time</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Database Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
<tr><th align="left" width="20%">Statspack User</th><td width="80%"><tt>&statsPackUser</tt></td></tr> -
</table>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- SET TIMING ON




-- +----------------------------------------------------------------------------+
-- |                                 - VERSION -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="version"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Version</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN banner   FORMAT a120   HEADING 'Banner'

SELECT * FROM v$version;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                 - OPTIONS -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="options"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Options</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN parameter      HEADING 'Option Name'      ENTMAP off
COLUMN value          HEADING 'Installed?'       ENTMAP off

SELECT
    DECODE(   value
            , 'FALSE'
            , '<b><font color="#336699">' || parameter || '</font></b>'
            , '<b><font color="#336699">' || parameter || '</font></b>') parameter
  , DECODE(   value
            , 'FALSE'
            , '<div align="center"><font color="#990000"><b>' || value || '</b></font></div>'
            , '<div align="center">' || value || '</div>' ) value
FROM v$option
ORDER BY parameter;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - DATABASE REGISTRY -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="database_registry"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Registry</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN comp_id       FORMAT a75     HEADING 'Component ID'        ENTMAP off
COLUMN comp_name     FORMAT a75     HEADING 'Component Name'      ENTMAP off
COLUMN version                      HEADING 'Version'             ENTMAP off
COLUMN status        FORMAT a75     HEADING 'Status'              ENTMAP off
COLUMN modified      FORMAT a75     HEADING 'Modified'            ENTMAP off
COLUMN control                      HEADING 'Control'             ENTMAP off
COLUMN schema                       HEADING 'Schema'              ENTMAP off
COLUMN procedure                    HEADING 'Procedure'           ENTMAP off

SELECT
    '<font color="#336699"><b>' || comp_id    || '</b></font>'                                                comp_id
  , '<div nowrap>' || comp_name || '</div>'                                                                   comp_name
  , version                                                                                                   version
  , DECODE(   status
            , 'VALID',   '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INVALID', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,            '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , '<div nowrap align="right">' || modified || '</div>'                                                      modified
  , control                                                                                                   control
  , schema                                                                                                    schema
  , procedure                                                                                                 procedure
FROM dba_registry
ORDER BY comp_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - INSTANCE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="instance_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Instance Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name       FORMAT a75    HEADING 'Instance|Name'       ENTMAP off
COLUMN instance_number     FORMAT a75    HEADING 'Instance|Number'     ENTMAP off
COLUMN host_name_print     FORMAT a75    HEADING 'Host|Name'           ENTMAP off
COLUMN oracle_version                    HEADING 'Oracle|Version'      ENTMAP off
COLUMN start_time          FORMAT a75    HEADING 'Start|Time'          ENTMAP off
COLUMN uptime                            HEADING 'Uptime|(in days)'    ENTMAP off
COLUMN parallel            FORMAT a75    HEADING 'Parallel - (RAC)'    ENTMAP off
COLUMN status              FORMAT a75    HEADING 'Instance|Status'     ENTMAP off
COLUMN logins              FORMAT a75    HEADING 'Logins'              ENTMAP off
COLUMN archiver            FORMAT a75    HEADING 'Archiver'            ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || instance_name   || '</b></font></div>'       instance_name
  , '<div align="center">' || instance_number || '</div>'                                           instance_number
  , '<div align="center">' || host_name       || '</div>'                                           host_name_print
  , '<div align="center">' || version         || '</div>'                                           oracle_version
  , '<div align="center">' || TO_CHAR(startup_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , ROUND(TO_CHAR(SYSDATE-startup_time), 2)                                                         uptime
  , '<div align="center">' || parallel        || '</div>'                                           parallel
  , '<div align="center">' || status          || '</div>'                                           status
  , '<div align="center">' || logins          || '</div>'                                           logins
  , DECODE(   archiver
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || archiver || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || archiver || '</font></b></div>') archiver
FROM v$instance
ORDER BY instance_number;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="database_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN database_name      FORMAT a75    HEADING 'Database Name'          ENTMAP off
COLUMN dbid                             HEADING 'Database ID'            ENTMAP off
COLUMN creation_date      FORMAT a75    HEADING 'Creation Date'          ENTMAP off
COLUMN log_mode                         HEADING 'Log Mode'               ENTMAP off
COLUMN open_mode                        HEADING 'Open Mode'              ENTMAP off
COLUMN force_logging                    HEADING 'Force Logging'          ENTMAP off
COLUMN controlfile_type                 HEADING 'Controlfile Type'       ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || name  || '</b></font></div>'   database_name
  , '<div align="center">' || dbid                   || '</div>'                      dbid
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'   creation_date
  , '<div align="center">' || log_mode               || '</div>'                      log_mode
  , '<div align="center">' || open_mode              || '</div>'                      open_mode
  , '<div align="center">' || force_logging          || '</div>'                      force_logging
  , '<div align="center">' || controlfile_type       || '</div>'                      controlfile_type
FROM v$database;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - INITIALIZATION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="initialization_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Initialization Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN spfile  HEADING "SPFILE Usage"

SELECT
  'This database '||
  DECODE(   (1-SIGN(1-SIGN(count(*) - 0)))
          , 1
          , '<font color="#663300"><b>IS</b></font>'
          , '<font color="#990000"><b>IS NOT</b></font>') ||
  ' using an SPFILE.'spfile
FROM v$spparameter
WHERE value IS NOT null;



COLUMN pname              FORMAT a75  HEADING 'Parameter Name'    ENTMAP off
COLUMN value              FORMAT a75  HEADING 'Value'             ENTMAP off
COLUMN isdefault          FORMAT a75  HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable   FORMAT a75  HEADING 'Is Dynamic?'       ENTMAP off

SELECT
    DECODE(   isdefault
            , 'FALSE'
            , '<b><font color="#336699">' || SUBSTR(name,0,512) || '</font></b>'
            , '<b><font color="#336699">' || SUBSTR(name,0,512) || '</font></b>' )     pname
  , DECODE(   isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || SUBSTR(value,0,512) || '</b></font>'
            , SUBSTR(value,0,512) )                                                    value
  , DECODE(   isdefault
            , 'FALSE'
            , '<div align="center"><font color="#663300"><b>' || isdefault || '</b></font></div>'
            , '<div align="center">' || isdefault || '</div>')                          isdefault
  , DECODE(   isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || issys_modifiable || '</b></font></div>'
            , '<div align="right">' || issys_modifiable || '</div>')                   issys_modifiable
FROM
    v$parameter
ORDER BY
    name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - CONTROL FILES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name          HEADING 'Controlfile Name'         ENTMAP off
COLUMN status        HEADING 'Status'                   ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'  name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
FROM v$controlfile c
ORDER BY c.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - CONTROL FILE RECORDS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="control_file_records"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control File Records</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN type           FORMAT          a95    HEADING 'Record Section Type'      ENTMAP off
COLUMN record_size    FORMAT       999,999   HEADING 'Record Size|(in bytes)'   ENTMAP off
COLUMN records_total  FORMAT       999,999   HEADING 'Records Allocated'        ENTMAP off
COLUMN bytes_alloc    FORMAT   999,999,999   HEADING 'Bytes Allocated'          ENTMAP off
COLUMN records_used   FORMAT       999,999   HEADING 'Records Used'             ENTMAP off
COLUMN bytes_used     FORMAT   999,999,999   HEADING 'Bytes Used'               ENTMAP off
COLUMN pct_used       FORMAT          B999   HEADING '% Used'                   ENTMAP off
COLUMN first_index                           HEADING 'First Index'              ENTMAP off
COLUMN last_index                            HEADING 'Last Index'               ENTMAP off
COLUMN last_recid                            HEADING 'Last RecID'               ENTMAP off

BREAK ON REPORT
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>'   OF record_size records_total bytes_alloc records_used bytes_used ON report
COMPUTE avg LABEL '<font color="#990000"><b>Average: </b></font>' OF pct_used      ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || type || '</b></font></div>' type
  , record_size
  , records_total
  , (records_total * record_size) bytes_alloc
  , records_used
  , (records_used * record_size) bytes_used
  , NVL(records_used/records_total * 100, 0) pct_used
  , first_index
  , last_index
  , last_recid
FROM v$controlfile_record_section
ORDER BY type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN groupno         FORMAT a75                HEADING 'Group Number'    ENTMAP off
COLUMN member                                    HEADING 'Member'          ENTMAP off
COLUMN redo_file_type  FORMAT a75                HEADING 'Redo Type'       ENTMAP off
COLUMN log_status      FORMAT a75                HEADING 'Log Status'      ENTMAP off
COLUMN bytes           FORMAT 999,999,999,999    HEADING 'Bytes'           ENTMAP off
COLUMN archived        FORMAT a75                HEADING 'Archived?'       ENTMAP off

BREAK ON groupno

SELECT
    '<div align="center"><font color="#336699"><b>' || f.group# || '</b></font></div>'               groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    v$logfile  f
  , v$log      l
WHERE
    f.group# = l.group#
ORDER BY
    f.group#
  , f.member;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - REDO LOG SWITCHES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="redo_log_switches"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Switches</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL FORMAT 999,999,999      HEADING 'Total'       ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' avg label '<font color="#990000"><b>Average:</b></font>' OF total ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history  a
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                         <<<<<     JOBS    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                                 - JOBS -                                   |
-- +----------------------------------------------------------------------------+

prompt <a name="jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job_id     FORMAT a75             HEADING 'Job ID'           ENTMAP off
COLUMN username   FORMAT a75             HEADING 'User'             ENTMAP off
COLUMN what       FORMAT a175            HEADING 'What'             ENTMAP off
COLUMN next_date  FORMAT a110            HEADING 'Next Run Date'    ENTMAP off
COLUMN interval   FORMAT a75             HEADING 'Interval'         ENTMAP off
COLUMN last_date  FORMAT a110            HEADING 'Last Run Date'    ENTMAP off
COLUMN failures   FORMAT a75             HEADING 'Failures'         ENTMAP off
COLUMN broken     FORMAT a75             HEADING 'Broken?'          ENTMAP off

SELECT
    DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || job || '</div></font></b>'
            , '<b><font color="#336699"><div align="center">' || job || '</div></font></b>')    job_id
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || log_user || '</font></b>'
            , log_user )    username
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || what || '</font></b>'
            , what )        what
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')      next_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000">' || interval || '</font></b>'
            , interval )    interval
  , DECODE(   broken
            , 'Y'
            , '<div nowrap align="right"><b><font color="#990000">' || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</font></b></div>'
            , '<div nowrap align="right">'                          || NVL(TO_CHAR(last_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>')    last_date  
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || failures || '</div></font></b>'
            , '<div align="center">'                          || failures || '</div>')    failures
  , DECODE(   broken
            , 'Y'
            , '<b><font color="#990000"><div align="center">' || broken || '</div></font></b>'
            , '<div align="center">'                          || broken || '</div>')      broken
FROM
    dba_jobs
ORDER BY
    job;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     STORAGE    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespaces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                   HEADING 'Status'            ENTMAP off
COLUMN name                                     HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                   HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                   HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                    HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999   HEADING 'Tablespace Size'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999   HEADING 'Free (in bytes)'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999   HEADING 'Used (in bytes)'   ENTMAP off
COLUMN pct_used                                 HEADING 'Pct. Used'         ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF ts_size used free ON report

SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name || '</font></b>'                               name
  , d.contents                                          type
  , d.extent_management                                 extent_mgt
  , d.segment_space_management                          segment_mgt
  , NVL(a.bytes, 0)                                     ts_size
  , NVL(f.bytes, 0)                                     free
  , NVL(a.bytes - NVL(f.bytes, 0), 0)                   used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM 
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_data_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes) bytes
      from dba_free_space
      group by tablespace_name
    ) f
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = f.tablespace_name(+)
  AND NOT (
    d.extent_management like 'LOCAL'
    AND
    d.contents like 'TEMPORARY'
  )
UNION ALL 
SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name  || '</font></b>'                              name
  , d.contents                                   type
  , d.extent_management                          extent_mgt
  , d.segment_space_management                   segment_mgt
  , NVL(a.bytes, 0)                              ts_size
  , NVL(a.bytes - NVL(t.bytes,0), 0)             free
  , NVL(t.bytes, 0)                              used
  , '<div align="right"><b>' || 
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_temp_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes_cached) bytes
      from v$temp_extent_pool
      group by tablespace_name
    ) t
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = t.tablespace_name(+)
  AND d.extent_management like 'LOCAL'
  AND d.contents like 'TEMPORARY'
ORDER BY
    2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - DATA FILES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="data_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace                                   HEADING 'Tablespace Name / File Class'  ENTMAP off
COLUMN filename                                     HEADING 'Filename'                      ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999,999   HEADING 'File Size'                     ENTMAP off
COLUMN autoextensible                               HEADING 'Autoextensible'                ENTMAP off
COLUMN increment_by    FORMAT 999,999,999           HEADING 'Next'                          ENTMAP off
COLUMN maxbytes        FORMAT 999,999,999,999,999   HEADING 'Max'                           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF filesize ON report

SELECT /*+ ordered */
    '<font color="#336699"><b>' || d.tablespace_name  || '</b></font>'  tablespace
  , '<tt>' || d.file_name || '</tt>'                                    filename
  , d.bytes                                                             filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by * e.value                                            increment_by
  , d.maxbytes                                                          maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    '<font color="#336699"><b>' || d.tablespace_name || '</b></font>'   tablespace 
  , '<tt>' || d.file_name  || '</tt>'                                   filename
  , d.bytes                                                             filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by * e.value                                            increment_by
  , d.maxbytes                                                          maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
UNION
SELECT
    '<font color="#336699"><b>[ ONLINE REDO LOG ]</b></font>'
  , '<tt>' || a.member || '</tt>'
  , b.bytes
  , null
  , null
  , null
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '<font color="#336699"><b>[ CONTROL FILE    ]</b></font>'
  , '<tt>' || a.name || '</tt>'
  , null
  , null
  , null
  , null
FROM
    v$controlfile a
ORDER BY
    1
  , 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - DATABASE GROWTH -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="database_growth"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Growth</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN month        FORMAT a75                     HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999     HEADING 'Growth (bytes)'

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF growth ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || TO_CHAR(creation_time, 'RRRR-MM') || '</b></font></div>' month
  , SUM(bytes)                        growth
FROM     sys.v_$datafile
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - TABLESPACE EXTENTS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespace_extents"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespace Extents</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name                              HEADING 'Tablespace Name'         ENTMAP off
COLUMN largest_ext     FORMAT 999,999,999,999,999   HEADING 'Largest Extent'          ENTMAP off
COLUMN smallest_ext    FORMAT 999,999,999,999,999   HEADING 'Smallest Extent'         ENTMAP off
COLUMN total_free      FORMAT 999,999,999,999,999   HEADING 'Total Free'              ENTMAP off
COLUMN pieces          FORMAT 999,999,999,999,999   HEADING 'Number of Free Extents'  ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF largest_ext smallest_ext total_free pieces ON report

SELECT 
    '<b><font color="#336699">' || tablespace_name || '</font></b>' tablespace_name
  , max(bytes)       largest_ext
  , min(bytes)       smallest_ext
  , sum(bytes)       total_free
  , count(*)         pieces
FROM
    dba_free_space
GROUP BY
    tablespace_name
ORDER BY
    tablespace_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - TABLESPACE TO OWNER  -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespace_to_owner"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespace to Owner</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name  FORMAT a75                  HEADING 'Tablespace Name'  ENTMAP off
COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN segment_type     FORMAT a75                  HEADING 'Segment Type'     ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size (in Bytes)'  ENTMAP off
COLUMN seg_count        FORMAT 999,999,999,999      HEADING 'Segment Count'    ENTMAP off

BREAK ON report ON tablespace_name
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF seg_count bytes ON report

SELECT
    '<font color="#336699"><b>' || tablespace_name || '</b></font>'  tablespace_name
  , '<div align="right">'       || owner           || '</div>'       owner
  , '<div align="right">'       || segment_type    || '</div>'       segment_type
  , sum(bytes)                                                       bytes
  , count(*)                                                         seg_count
FROM
    dba_segments
GROUP BY
    tablespace_name
  , owner
  , segment_type
ORDER BY
    tablespace_name
  , owner
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - OWNER TO TABLESPACE -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="owner_to_tablespace"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Owner to Tablespace</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name  FORMAT a75                  HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_type     FORMAT a75                  HEADING 'Segment Type'     ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size (in Bytes)'  ENTMAP off
COLUMN seg_count        FORMAT 999,999,999,999      HEADING 'Segment Count'    ENTMAP off

BREAK ON report ON owner
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF seg_count bytes ON report

SELECT
    '<font color="#336699"><b>'  || owner           || '</b></font>' owner
  , '<div align="right">'        || tablespace_name || '</div>'      tablespace_name
  , '<div align="right">'        || segment_type    || '</div>'      segment_type
  , sum(bytes)                                                       bytes
  , count(*)                                                         seg_count
FROM
    dba_segments
GROUP BY
    owner
  , tablespace_name
  , segment_type
ORDER BY
    owner
  , tablespace_name
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                   <<<<<     UNDO Segments     >>>>>                        |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                              - UNDO SEGMENTS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Segments</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN roll_name                           HEADING 'UNDO Segment Name'    ENTMAP off
COLUMN tablespace                          HEADING 'Tablspace'            ENTMAP off
COLUMN in_extents                          HEADING 'Init/Next Extents'    ENTMAP off
COLUMN m_extents                           HEADING 'Min/Max Extents'      ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN wraps       FORMAT 999,999,999      HEADING 'Wraps'                ENTMAP off
COLUMN shrinks     FORMAT 999,999,999      HEADING 'Shrinks'              ENTMAP off
COLUMN opt         FORMAT 999,999,999,999  HEADING 'Opt. Size'            ENTMAP off
COLUMN bytes       FORMAT 999,999,999,999  HEADING 'Bytes'                ENTMAP off
COLUMN extents     FORMAT 999,999,999      HEADING 'Extents'              ENTMAP off

CLEAR COMPUTES BREAKS

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF bytes extents shrinks wraps ON report

SELECT
    '<font color="#336699"><b>' || a.owner || '.' || a.segment_name  || '</b></font>'    roll_name
  , a.tablespace_name                         tablespace
  , '<div align="right">'       ||
    TO_CHAR(a.initial_extent)   || ' / ' ||
    TO_CHAR(a.next_extent)      ||
    '</div>'                                 in_extents
  , '<div align="right">'       ||
    TO_CHAR(a.min_extents)      || ' / ' ||
    TO_CHAR(a.max_extents)      ||
    '</div>'                                 m_extents
  , DECODE(   a.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || a.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || a.status || '</font></b></div>') status
  , b.bytes                                   bytes
  , b.extents                                 extents
  , d.shrinks                                 shrinks
  , d.wraps                                   wraps
  , d.optsize                                 opt
FROM
    dba_rollback_segs a
  , dba_segments b
  , v$rollname c
  , v$rollstat d
WHERE
       a.segment_name = b.segment_name
  AND  a.segment_name = c.name (+)
  AND  c.usn          = d.usn (+)
ORDER BY
    a.segment_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - UNDO SEGMENT CONTENTION -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_segment_contention"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Segment Contention</b></font><hr align="left" width="460">

prompt <b>UNDO statistics from V$ROLLSTAT - (ordered by waits)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN roll_name                             HEADING 'UNDO Segment Name'    ENTMAP off
COLUMN gets             FORMAT 999,999,999   HEADING 'Gets'                 ENTMAP off
COLUMN waits            FORMAT 999,999,999   HEADING 'Waits'                ENTMAP off
COLUMN immediate_misses FORMAT 999,999,999   HEADING 'Immediate Misses'     ENTMAP off
COLUMN hit_ratio                             HEADING 'Hit Ratio'            ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>' OF gets waits ON report

SELECT
    '<font color="#336699"><b>' || b.name || '</b></font>'  roll_name
  , gets                               gets
  , waits                              waits
  , '<div align="right">' || TO_CHAR(ROUND(((gets - waits)*100)/gets, 2)) || '%</div>' hit_ratio
FROM 
    sys.v_$rollstat a
  , sys.v_$rollname b
WHERE
    a.USN = b.USN
ORDER BY
    waits DESC;


prompt 
prompt <b>Wait Statistics</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN class                  HEADING 'Class'    
COLUMN ratio                  HEADING 'Wait Ratio'       

SELECT
    '<font color="#336699"><b>' || w.class || '</b></font>'                            class
  , '<div align="right">' || TO_CHAR(ROUND(100*(w.count/SUM(s.value)),8)) || '%</div>' ratio
FROM
    v$waitstat  w
  , v$sysstat   s
WHERE
      w.class IN (  'system undo header'
                  , 'system undo block'
                  , 'undo header'
                  , 'undo block'
                 )
  AND s.name IN ('db block gets', 'consistent gets')
GROUP BY
    w.class
  , w.count;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                     <<<<<     ARCHIVING    >>>>>                           |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                             - ARCHIVING MODE -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_mode"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Mode</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN db_log_mode                  FORMAT a95                HEADING 'Database Log Mode'            ENTMAP off
COLUMN log_archive_start            FORMAT a95                HEADING 'Automatic Archival'           ENTMAP off
COLUMN oldest_online_log_sequence   FORMAT 999999999999999    HEADING 'Oldest Online Log Sequence'   ENTMAP off
COLUMN current_log_seq              FORMAT 999999999999999    HEADING 'Current Log Sequence'         ENTMAP off

SELECT
    '<div align="center"><font color="#663300"><b>' || d.log_mode           || '</b></font></div>'    db_log_mode
  , '<div align="center"><font color="#663300"><b>' || p.log_archive_start  || '</b></font></div>'    log_archive_start
  , c.current_log_seq                                   current_log_seq
  , o.oldest_online_log_sequence                        oldest_online_log_sequence
FROM
    (select
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Archive Mode'
                 , 'NOARCHIVELOG', 'No Archive Mode'
                 , log_mode
         )   log_mode
     from v$database
    ) d
  , (select
         DECODE(   a.value
                 , 'TRUE', 'Enabled'
                 , 'FALSE', 'Disabled')   log_archive_start
     from
         v$parameter a
     where
           a.name = 'log_archive_start'
    ) p
  , (select a.sequence#   current_log_seq
     from   v$log a
     where  a.status = 'CURRENT'
    ) c
  , (select min(a.sequence#) oldest_online_log_sequence
     from   v$log a
    ) o
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                          - ARCHIVING PARAMETERS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name      HEADING 'Parameter Name'      ENTMAP off
COLUMN value     HEADING 'Parameter Value'     ENTMAP off

SELECT
    '<b><font color="#336699">' || a.name || '</font></b>'    name
  , a.value    value
FROM
    v$parameter a
WHERE
    a.name like 'log_%'
ORDER BY
    a.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                           - ARCHIVING HISTORY -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_history"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving History</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN sequence#        FORMAT a79                   HEADING 'Sequence#'         ENTMAP off
COLUMN name                                          HEADING 'Name'              ENTMAP off
COLUMN first_change#                                 HEADING 'First|Change #'    ENTMAP off
COLUMN first_time       FORMAT a75                   HEADING 'First|Time'        ENTMAP off
COLUMN next_change#                                  HEADING 'Next|Change #'     ENTMAP off
COLUMN next_time        FORMAT a75                   HEADING 'Next|Time'         ENTMAP off
COLUMN log_size         FORMAT 999,999,999,999,999   HEADING 'Size (in bytes)'   ENTMAP off
COLUMN archived         FORMAT a31                   HEADING 'Archived?'         ENTMAP off
COLUMN applied          FORMAT a31                   HEADING 'Applied?'          ENTMAP off
COLUMN deleted          FORMAT a31                   HEADING 'Deleted?'          ENTMAP off
COLUMN status           FORMAT a75                   HEADING 'Status'            ENTMAP off

SELECT
    '<div align="center"><b><font color="#336699">' || sequence# || '</font></b></div>'  sequence#
  , name
  , first_change#
  , '<div align="right" nowrap>' || TO_CHAR(first_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>' first_time
  , next_change#
  , '<div align="right" nowrap>' || TO_CHAR(next_time, 'mm/dd/yyyy HH24:MI:SS')  || '</div>' next_time
  , (blocks * block_size)                           log_size
  , '<div align="center">' || archived || '</div>'  archived
  , '<div align="center">' || applied  || '</div>'  applied
  , '<div align="center">' || deleted  || '</div>'  deleted
  , DECODE(   status
            , 'A', '<div align="center"><b><font color="darkgreen">Available</font></b></div>'
            , 'D', '<div align="center"><b><font color="#663300">Deleted</font></b></div>'
            , 'U', '<div align="center"><b><font color="#990000">Unavailable</font></b></div>'
            , 'X', '<div align="center"><b><font color="#990000">Expired</font></b></div>'
    ) status
FROM
    v$archived_log
WHERE
    status in ('A')
ORDER BY
    sequence#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                        <<<<<     RMAN    >>>>>                             |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                           - RMAN CONFIGURATION -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_configuration"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Configuration</b></font><hr align="left" width="460">

prompt <b>All non-default RMAN configuration settings</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT a130   HEADING 'Name'     ENTMAP off
COLUMN value                  HEADING 'Value'    ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || name || '</font></b></div>'   name
  , value
FROM
    v$rman_configuration
ORDER BY
    name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                              - BACKUP SETS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_sets"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Backup Sets</b></font><hr align="left" width="460">

prompt <b>Available backup sets contained in the control file including available and expired backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                    HEADING 'BS Key'                 ENTMAP off
COLUMN backup_type            FORMAT a70                    HEADING 'Backup Type'            ENTMAP off
COLUMN device_type                                          HEADING 'Device Type'            ENTMAP off
COLUMN controlfile_included   FORMAT a30                    HEADING 'Controlfile Included?'  ENTMAP off
COLUMN spfile_included        FORMAT a30                    HEADING 'SPFILE Included?'       ENTMAP off
COLUMN incremental_level                                    HEADING 'Incremental Level'      ENTMAP off
COLUMN pieces                 FORMAT 999,999,999,999        HEADING '# of Pieces'            ENTMAP off
COLUMN start_time             FORMAT a75                    HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a75                    HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999    HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN tag                                                  HEADING 'Tag'                    ENTMAP off
COLUMN block_size             FORMAT 999,999,999,999,999    HEADING 'Block Size'             ENTMAP off
COLUMN keep                   FORMAT a40                    HEADING 'Keep?'                  ENTMAP off
COLUMN keep_until             FORMAT a75                    HEADING 'Keep Until'             ENTMAP off
COLUMN keep_options           FORMAT a15                    HEADING 'Keep Options'           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF pieces elapsed_seconds ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid || '</b></font></div>'                        bs_key
  , DECODE(backup_type
           , 'L', '<div nowrap><font color="#990000">Archived Redo Logs</font></div>'
           , 'D', '<div nowrap><font color="#000099">Datafile Full Backup</font></div>'
           , 'I', '<div nowrap><font color="darkgreen">Incremental Backup</font></div>')                      backup_type
  , '<div nowrap align="right">' || device_type || '</div>'                                                   device_type
  , '<div align="right">' ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included) || '</div>'                           controlfile_included
  , '<div align="right">' || NVL(sp.spfile_included, '-') || '</div>'                                         spfile_included
  , bs.incremental_level                                                                                      incremental_level
  , bs.pieces                                                                                                 pieces
  , '<div nowrap align="right">' || TO_CHAR(bs.start_time, 'mm/dd/yyyy HH24:MI:SS')      || '</div>'          start_time
  , '<div nowrap align="right">' || TO_CHAR(bs.completion_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'          completion_time
  , bs.elapsed_seconds                                                                                        elapsed_seconds
  , bp.tag                                                                                                    tag
  , bs.block_size                                                                                             block_size
  , '<div align="center">' || bs.keep || '</div>'                                                             keep
  , '<div nowrap align="right">' || NVL(TO_CHAR(bs.keep_until, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'  keep_until
  , bs.keep_options                                                                                           keep_options
FROM
    v$backup_set                           bs
  , (select distinct
         set_stamp
       , set_count
       , tag
       , device_type
     from v$backup_piece
     where status in ('A', 'X'))           bp
 ,  (select distinct set_stamp, set_count, 'YES' spfile_included
     from v$backup_spfile)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bs.set_stamp = sp.set_stamp (+)
  AND bs.set_count = sp.set_count (+)
ORDER BY
    bs.recid;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                             - BACKUP PIECES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_pieces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Backup Pieces</b></font><hr align="left" width="460">

prompt <b>Available backup pieces contained in the control file including available and expired backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key              FORMAT a75                     HEADING 'BS Key'            ENTMAP off
COLUMN piece#                                             HEADING 'Piece #'           ENTMAP off
COLUMN copy#                                              HEADING 'Copy #'            ENTMAP off
COLUMN bp_key                                             HEADING 'BP Key'            ENTMAP off
COLUMN status                                             HEADING 'Status'            ENTMAP off
COLUMN handle                                             HEADING 'Handle'            ENTMAP off
COLUMN start_time          FORMAT a75                     HEADING 'Start Time'        ENTMAP off
COLUMN completion_time     FORMAT a75                     HEADING 'End Time'          ENTMAP off
COLUMN elapsed_seconds     FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'   ENTMAP off
COLUMN deleted             FORMAT a10                     HEADING 'Deleted?'          ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'                bs_key
  , bp.piece#                                                                                          piece#
  , bp.copy#                                                                                           copy#
  , bp.recid                                                                                           bp_key
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')     status
  , handle                                                                                             handle
  , '<div nowrap align="right">' || TO_CHAR(bp.start_time, 'mm/dd/yyyy HH24:MI:SS')      || '</div>'   start_time
  , '<div nowrap align="right">' || TO_CHAR(bp.completion_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'   completion_time
  , bp.elapsed_seconds                                                                                 elapsed_seconds
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
ORDER BY
    bs.recid
  , piece#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                          - BACKUP CONTROL FILES -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Backup Control Files</b></font><hr align="left" width="460">

prompt <b>Available automatic control files within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN controlfile_included   FORMAT a75                     HEADING 'Controlfile Included?'  ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'                      ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included)  ||
    '</b></font></div>'                                                                             controlfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set    bs
  , v$backup_piece  bp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.controlfile_included != 'NO'
ORDER BY
    bs.recid
  , piece#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                             - BACKUP SPFILE -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_spfile"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Backup SPFILE</b></font><hr align="left" width="460">

prompt <b>Available automatic SPFILE backups within all available (and expired) backup sets</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN bs_key                 FORMAT a75                     HEADING 'BS Key'                 ENTMAP off
COLUMN piece#                                                HEADING 'Piece #'                ENTMAP off
COLUMN copy#                                                 HEADING 'Copy #'                 ENTMAP off
COLUMN bp_key                                                HEADING 'BP Key'                 ENTMAP off
COLUMN spfile_included        FORMAT a75                     HEADING 'SPFILE Included?'       ENTMAP off
COLUMN status                                                HEADING 'Status'                 ENTMAP off
COLUMN handle                                                HEADING 'Handle'                 ENTMAP off
COLUMN start_time             FORMAT a40                     HEADING 'Start Time'             ENTMAP off
COLUMN completion_time        FORMAT a40                     HEADING 'End Time'               ENTMAP off
COLUMN elapsed_seconds        FORMAT 999,999,999,999,999     HEADING 'Elapsed Seconds'        ENTMAP off
COLUMN deleted                FORMAT a10                     HEADING 'Deleted?'               ENTMAP off

BREAK ON bs_key

SELECT
    '<div align="center"><font color="#336699"><b>' || bs.recid  || '</b></font></div>'             bs_key
  , bp.piece#                                                                                       piece#
  , bp.copy#                                                                                        copy#
  , bp.recid                                                                                        bp_key
  , '<div align="center"><font color="#663300"><b>'  ||
    NVL(sp.spfile_included, '-')                     ||
    '</b></font></div>'                                                                             spfile_included
  , DECODE(   status
            , 'A', '<div nowrap align="center"><font color="darkgreen"><b>Available</b></font></div>'
            , 'D', '<div nowrap align="center"><font color="#000099"><b>Deleted</b></font></div>'
            , 'X', '<div nowrap align="center"><font color="#990000"><b>Expired</b></font></div>')  status
  , handle                                                                                          handle
FROM
    v$backup_set                            bs
  , v$backup_piece                          bp
  ,  (select distinct set_stamp, set_count, 'YES' spfile_included
      from v$backup_spfile)                 sp
WHERE
      bs.set_stamp = bp.set_stamp
  AND bs.set_count = bp.set_count
  AND bp.status IN ('A', 'X')
  AND bs.set_stamp = sp.set_stamp
  AND bs.set_count = sp.set_count
ORDER BY
    bs.recid
  , piece#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                    <<<<<     PERFORMANCE    >>>>>                          |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                             - SGA INFORMATION -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA Information</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name    FORMAT a79               HEADING 'Pool Name'   ENTMAP off
COLUMN value   FORMAT 999,999,999,999   HEADING 'Bytes'       ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF value ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || name || '</b></font></div>'  name
  , value
FROM
    v$sga;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - DB BUFFER CACHE HIT RATIO -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="db_buffer_cache_hit_ratio"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>DB Buffer Cache Hit Ratio</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN consistent_gets   FORMAT 999,999,999,999,999,999   HEADING 'Consistent Gets'  ENTMAP off
COLUMN db_block_gets     FORMAT 999,999,999,999,999,999   HEADING 'DB Block Gets'    ENTMAP off
COLUMN phys_reads        FORMAT 999,999,999,999,999,999   HEADING 'Physical Reads'   ENTMAP off
COLUMN db_hit_ratio                                       HEADING 'Hit Ratio'        ENTMAP off

SELECT
    SUM(DECODE(name, 'consistent gets', value, 0))   consistent_gets
  , SUM(DECODE(name, 'db block gets', value, 0))     db_block_gets
  , SUM(DECODE(name, 'physical reads', value, 0))    phys_reads
  , '<div align="right">' ||
    TO_CHAR(ROUND((SUM(DECODE(name, 'consistent gets', value, 0)) +
                       SUM(DECODE(name, 'db block gets', value, 0)) -
                       SUM(DECODE(name, 'physical reads', value, 0))) /
                      (SUM(DECODE(name, 'consistent gets', value, 0)) +
                       SUM(DECODE(name, 'db block gets', value, 0)))*100, 2))  ||
    '%</div>'   db_hit_ratio
FROM v$sysstat;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - DICTIONARY CACHE HIT RATIO -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="dictionary_cache_hit_ratio"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dictionary Cache Hit Ratio</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN gets          FORMAT 999,999,999,999,999,999  HEADING 'Misses'       ENTMAP off
COLUMN misses        FORMAT 999,999,999,999,999,999  HEADING 'Gets'         ENTMAP off
COLUMN dc_hit_ratio                                  HEADING 'Hit Ratio'    ENTMAP off

SELECT
    SUM(gets)       gets
  , SUM(getmisses)  misses
  , '<div align="right">' ||
    TO_CHAR(ROUND((((SUM(gets)-SUM(getmisses))/SUM(gets))*100), 2)) ||
    '%</div>'       dc_hit_ratio
FROM
    v$rowcache;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - LIBRARY CACHE HIT RATIO -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="library_cache_hit_ratio"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Library Cache Hit Ratio</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN pins            FORMAT 999,999,999,999,999,999  HEADING 'Pins - (Executions)'      ENTMAP off
COLUMN reloads         FORMAT 999,999,999,999,999,999  HEADING 'Reloads - (Cache Miss)'   ENTMAP off
COLUMN lc_hit_ratio                                    HEADING 'Hit Ratio'                ENTMAP off 

SELECT
    SUM(pins)      pins
  , SUM(reloads)   reloads
  , '<div align="right">' ||
    TO_CHAR(ROUND((((SUM(pins)-SUM(reloads))/SUM(pins))*100),2)) ||
    '%</div>'      lc_hit_ratio
FROM
    v$librarycache;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - LATCH CONTENTION -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="latch_contention"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Latch Contention</b></font><hr align="left" width="460">

prompt <b>Latches with "gets", "misses", "sleeps", "immediate gets", or "immediate misses" greater than 0 - (ordered by misses)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN latch_name        FORMAT a110                      HEADING 'Latch Name'              ENTMAP off
COLUMN gets              FORMAT 999,999,999,999,999,999   HEADING 'Gets'                    ENTMAP off
COLUMN misses            FORMAT 999,999,999,999,999,999   HEADING 'Misses'                  ENTMAP off
COLUMN sleeps            FORMAT 999,999,999,999,999,999   HEADING 'Sleeps'                  ENTMAP off
COLUMN miss_ratio                                         HEADING 'Willing to Wait Ratio'   ENTMAP off
COLUMN imm_gets          FORMAT 999,999,999,999,999,999   HEADING 'Immediate Gets'          ENTMAP off
COLUMN imm_misses        FORMAT 999,999,999,999,999,999   HEADING 'Immediate Misses'        ENTMAP off
COLUMN imm_miss_ratio                                     HEADING 'Immediate Ratio'         ENTMAP off

SELECT
    '<b><font color="#336699">' || SUBSTR(a.name,1,40) || '</font></b>'         latch_name
  , gets                         gets
  , misses                       misses
  , sleeps                       sleeps
  , '<div align="right">' || ROUND((misses/(gets+.001))*100, 4) || '%</div>'     miss_ratio
  , immediate_gets               imm_gets
  , immediate_misses             imm_misses
  , '<div align="right">' || ROUND((immediate_misses/(immediate_gets+.001))*100, 4) || '%</div>'  imm_miss_ratio
FROM
    v$latch      a
  , v$latchname  b
WHERE
      a.latch# = b.latch#
  AND (    gets > 0
        OR misses > 0
        OR sleeps > 0
        OR immediate_gets > 0
        OR immediate_misses > 0
  )
ORDER BY
    misses DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - SYSTEM WAIT STATISTICS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="system_wait_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>System Wait Statistics</b></font><hr align="left" width="460">

prompt <b>Classes with counts greater than 0</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN class    FORMAT A95              HEADING 'Class'   ENTMAP off
COLUMN count    FORMAT 99999999999990   HEADING 'Count'   ENTMAP off

SELECT
    '<b><font color="#336699">' || class || '</font></b>'  class
  , count
FROM
    v$waitstat 
WHERE
    count > 0
ORDER BY
    2 DESC
  , 1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - SYSTEM STATISTICS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="system_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>System Statistics</b></font><hr align="left" width="460">

prompt <b>Statistics with values greater than 0</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT A95                                HEADING 'Name'     ENTMAP off
COLUMN value    FORMAT 999,999,999,999,999,999,999,990    HEADING 'Value'    ENTMAP off

SELECT
    '<b><font color="#336699">' || name || '</font></b>'  name
  , value
FROM
    v$sysstat 
WHERE
    value > 0
ORDER BY
    2 DESC
  , 1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - SYSTEM EVENT STATISTICS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="system_event_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>System Event Statistics</b></font><hr align="left" width="460">

prompt <b>Non-idle events with total waits greater than 0 - (ordered by "Time Waited")</b>
prompt 

prompt -
<b>EVENT:</b> The name of the wait event.<br> -
<b>TOTAL_WAITS:</b> The total number of waits for this event.<br> -
<b>TOTAL_TIMEOUTS:</b> The total number of timeouts for this event.<br> -
<b>TIME_WAITED:</b> The total amount of time waited for this event, in hundredths of a second.<br> -
<b>AVERAGE_WAIT:</b> The average amount of time waited for this event, in hundredths of a second.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN event             FORMAT a95                       HEADING 'Event'           ENTMAP off
COLUMN total_waits       FORMAT 999,999,999,999,999,999   HEADING 'Total Waits'     ENTMAP off
COLUMN total_timeouts    FORMAT 999,999,999,999,999,999   HEADING 'Total Timeouts'  ENTMAP off
COLUMN time_waited       FORMAT 999,999,999,999,999,999   HEADING 'Time Waited'     ENTMAP off
COLUMN average_wait      FORMAT 999,999,999,999,999,999   HEADING 'Average Wait'    ENTMAP off

SELECT
    '<b><font color="#336699">' || event || '</font></b>'  event
  , total_waits
  , total_timeouts
  , time_waited
  , average_wait
FROM
    v$system_event 
WHERE
      total_waits > 0
  AND event NOT IN (   'PX Idle Wait'
                     , 'pmon timer'
                     , 'smon timer'
                     , 'rdbms ipc message'
                     , 'parallel dequeue wait'
                     , 'parallel query dequeue'
                     , 'virtual circuit'
                     , 'SQL*Net message from client'
                     , 'SQL*Net message to client'
                     , 'SQL*Net more data to client'
                     , 'client message','Null event'
                     , 'WMON goes to sleep'
                     , 'virtual circuit status'
                     , 'dispatcher timer'
                     , 'pipe get'
                     , 'slave wait'
                     , 'KXFX: execution message dequeue - Slaves'
                     , 'parallel query idle wait - Slaves'
                     , 'lock manager wait for remote message') 
ORDER BY
    time_waited DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - FILE I/O STATISTICS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="file_io_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>File I/O Statistics</b></font><hr align="left" width="460">

prompt <b>Ordered by "Physical Reads" since last startup of the Oracle instance</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name   FORMAT a50                   HEAD 'Tablespace'       ENTMAP off
COLUMN fname                                          HEAD 'File Name'        ENTMAP off
COLUMN phyrds            FORMAT 999,999,999,999,999   HEAD 'Physical Reads'   ENTMAP off
COLUMN phywrts           FORMAT 999,999,999,999,999   HEAD 'Physical Writes'  ENTMAP off
COLUMN read_pct                                       HEAD 'Read Pct.'        ENTMAP off
COLUMN write_pct                                      HEAD 'Write Pct.'       ENTMAP off
COLUMN total_io          FORMAT 999,999,999,999,999   HEAD 'Total I/O'        ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF phyrds phywrts total_io ON report

SELECT
    '<font color="#336699"><b>' || df.tablespace_name || '</b></font>'                      tablespace_name
  , df.file_name                             fname
  , fs.phyrds                                phyrds
  , '<div align="right">' || ROUND((fs.phyrds * 100) / (fst.pr + tst.pr), 2) || '%</div>'   read_pct
  , fs.phywrts                               phywrts
  , '<div align="right">' || ROUND((fs.phywrts * 100) / (fst.pw + tst.pw), 2) || '%</div>'   write_pct
  , (fs.phyrds + fs.phywrts)                 total_io
FROM
    sys.dba_data_files df
  , v$filestat         fs
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    df.file_id = fs.file#
UNION
SELECT
    '<font color="#336699"><b>' || tf.tablespace_name || '</b></font>'                     tablespace_name
  , tf.file_name                           fname
  , ts.phyrds                              phyrds
  , '<div align="right">' || ROUND((ts.phyrds * 100) / (fst.pr + tst.pr), 2) || '%</div>'  read_pct
  , ts.phywrts                             phywrts
  , '<div align="right">' || ROUND((ts.phywrts * 100) / (fst.pw + tst.pw), 2) || '%</div>' write_pct
  , (ts.phyrds + ts.phywrts)                 total_io
FROM
    sys.dba_temp_files  tf
  , v$tempstat          ts
  , (select sum(f.phyrds) pr, sum(f.phywrts) pw from v$filestat f) fst
  , (select sum(t.phyrds) pr, sum(t.phywrts) pw from v$tempstat t) tst
WHERE
    tf.file_id = ts.file#
ORDER BY phyrds DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - FILE I/O TIMINGS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="file_io_timings"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>File I/O Timings</b></font><hr align="left" width="460">

prompt <b>Average time (in milliseconds) for an I/O call per datafile since last startup of the Oracle instance - (ordered by Physical Reads)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN fname                                           HEAD 'File Name'                                      ENTMAP off
COLUMN phyrds            FORMAT 999,999,999,999,999    HEAD 'Physical Reads'                                 ENTMAP off
COLUMN read_rate         FORMAT 999,999,999,999,999.99 HEAD 'Average Read Time<br>(milliseconds per read)'   ENTMAP off
COLUMN phywrts           FORMAT 999,999,999,999,999    HEAD 'Physical Writes'                                ENTMAP off
COLUMN write_rate        FORMAT 999,999,999,999,999.99 HEAD 'Average Write Time<br>(milliseconds per write)' ENTMAP off

BREAK ON REPORT
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF phyrds phywrts ON report
COMPUTE avg LABEL '<font color="#990000"><b>Average: </b></font>' OF read_rate write_rate ON report

SELECT
    '<b><font color="#336699">' || d.name || '</font></b>'  fname
  , s.phyrds                                     phyrds
  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2)   read_rate
  , s.phywrts                                    phywrts
  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2)  write_rate
FROM
    v$filestat  s
  , v$datafile  d
WHERE
  s.file# = d.file#
UNION
SELECT
    '<b><font color="#336699">' || t.name || '</font></b>'  fname
  , s.phyrds                                     phyrds
  , ROUND((s.readtim/GREATEST(s.phyrds,1)), 2)   read_rate
  , s.phywrts                                    phywrts
  , ROUND((s.writetim/GREATEST(s.phywrts,1)),2)  write_rate
FROM
    v$tempstat  s
  , v$tempfile  t
WHERE
  s.file# = t.file#
ORDER BY
    2 DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - AVERAGE OVERALL I/O PER SECOND -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="average_overall_io_per_sec"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Average Overall I/O per Second</b></font><hr align="left" width="460">

prompt <b>Average overall I/O calls (physical read/write calls) since last startup of the Oracle instance</b>

CLEAR COLUMNS BREAKS COMPUTES

DECLARE

CURSOR get_file_io IS
  SELECT
      NVL(SUM(a.phyrds + a.phywrts), 0)  sum_datafile_io
    , TO_NUMBER(null)                    sum_tempfile_io
  FROM
      v$filestat a
  UNION
  SELECT
      TO_NUMBER(null)                    sum_datafile_io
    , NVL(SUM(b.phyrds + b.phywrts), 0)  sum_tempfile_io
  FROM
      v$tempstat b;

current_time           DATE;
elapsed_time_seconds   NUMBER;
sum_datafile_io        NUMBER;
sum_datafile_io2       NUMBER;
sum_tempfile_io        NUMBER;
sum_tempfile_io2       NUMBER;
total_io               NUMBER;
datafile_io_per_sec    NUMBER;
tempfile_io_per_sec    NUMBER;
total_io_per_sec       NUMBER;

BEGIN
    OPEN get_file_io;
    FOR i IN 1..2 LOOP
      FETCH get_file_io INTO sum_datafile_io, sum_tempfile_io;
      IF i = 1 THEN
        sum_datafile_io2 := sum_datafile_io;
      ELSE
        sum_tempfile_io2 := sum_tempfile_io;
      END IF;
    END LOOP;

    total_io := sum_datafile_io2 + sum_tempfile_io2;
    SELECT sysdate INTO current_time FROM dual;
    SELECT CEIL ((current_time - startup_time)*(60*60*24)) INTO elapsed_time_seconds FROM v$instance;

    datafile_io_per_sec := sum_datafile_io2/elapsed_time_seconds;
    tempfile_io_per_sec := sum_tempfile_io2/elapsed_time_seconds;
    total_io_per_sec    := total_io/elapsed_time_seconds;

    DBMS_OUTPUT.PUT_LINE('<table width="90%" border="1">');

    DBMS_OUTPUT.PUT_LINE('<tr><th align="left" width="20%">Elapsed Time (in seconds)</th><td width="80%">' || TO_CHAR(elapsed_time_seconds, '9,999,999,999,999') || '</td></tr>');
    DBMS_OUTPUT.PUT_LINE('<tr><th align="left" width="20%">Datafile I/O Calls per Second</th><td width="80%">' || TO_CHAR(datafile_io_per_sec, '9,999,999,999,999') || '</td></tr>');
    DBMS_OUTPUT.PUT_LINE('<tr><th align="left" width="20%">Tempfile I/O Calls per Second</th><td width="80%">' || TO_CHAR(tempfile_io_per_sec, '9,999,999,999,999') || '</td></tr>');
    DBMS_OUTPUT.PUT_LINE('<tr><th align="left" width="20%">Total I/O Calls per Second</th><td width="80%">' || TO_CHAR(total_io_per_sec, '9,999,999,999,999') || '</td></tr>');

    DBMS_OUTPUT.PUT_LINE('</table>');
END;
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - REDO LOG CONTENTION -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="redo_log_contention"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Contention</b></font><hr align="left" width="460">

prompt <b>All latches like redo% - (ordered by misses)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name             FORMAT a95                        HEADING 'Latch Name'        ENTMAP off
COLUMN gets             FORMAT 999,999,999,999,999,999    HEADING 'Gets'              ENTMAP off
COLUMN misses           FORMAT 999,999,999,999            HEADING 'Misses'            ENTMAP off
COLUMN sleeps           FORMAT 999,999,999,999            HEADING 'Sleeps'            ENTMAP off
COLUMN immediate_gets   FORMAT 999,999,999,999,999,999    HEADING 'Immediate Gets'    ENTMAP off
COLUMN immediate_misses FORMAT 999,999,999,999            HEADING 'Immediate Misses'  ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF gets misses sleeps immediate_gets immediate_misses ON report

SELECT 
    '<div align="left"><font color="#336699"><b>' || INITCAP(name) || '</b></font></div>' name
  , gets
  , misses
  , sleeps
  , immediate_gets
  , immediate_misses
FROM sys.v_$latch
WHERE name LIKE 'redo%'
ORDER BY 1;



prompt 
prompt <b>System statistics like redo%</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name    FORMAT a95                    HEADING 'Statistics Name'
COLUMN value   FORMAT 999,999,999,999,999    HEADING 'Value'

SELECT
    '<div align="left"><font color="#336699"><b>' || INITCAP(name) || '</b></font></div>' name
  , value
FROM v$sysstat
WHERE name LIKE 'redo%'
ORDER BY 1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - FULL TABLE SCANS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="full_table_scans"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Full Table Scans</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN large_table_scans   FORMAT 999,999,999,999,999  HEADING 'Large Table Scans'   ENTMAP off
COLUMN small_table_scans   FORMAT 999,999,999,999,999  HEADING 'Small Table Scans'   ENTMAP off
COLUMN pct_large_scans                                 HEADING 'Pct. Large Scans'    ENTMAP off

SELECT
    a.value large_table_scans
  , b.value small_table_scans
  , '<div align="right">' || ROUND(100*a.value/DECODE((a.value+b.value),0,1,(a.value+b.value)),2) || '%</div>' pct_large_scans
FROM
    v$sysstat  a
  , v$sysstat  b
WHERE
      a.name = 'table scans (long tables)'
  AND b.name = 'table scans (short tables)';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                - SORTS -                                   |
-- +----------------------------------------------------------------------------+

prompt <a name="sorts"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Sorts</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN disk_sorts     FORMAT 999,999,999,999,999    HEADING 'Disk Sorts'       ENTMAP off
COLUMN memory_sorts   FORMAT 999,999,999,999,999    HEADING 'Memory Sorts'     ENTMAP off
COLUMN pct_disk_sorts                               HEADING 'Pct. Disk Sorts'  ENTMAP off

SELECT
    a.value   disk_sorts
  , b.value   memory_sorts
  , '<div align="right">' || ROUND(100*a.value/DECODE((a.value+b.value),0,1,(a.value+b.value)),2) || '%</div>' pct_disk_sorts
FROM
    v$sysstat  a
  , v$sysstat  b
WHERE
      a.name = 'sorts (disk)'
  AND b.name = 'sorts (memory)';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                               - OUTLINES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_outlines"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Outlines</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN category       FORMAT a125    HEADING 'Category'     ENTMAP off
COLUMN owner          FORMAT a125    HEADING 'Owner'        ENTMAP off
COLUMN name           FORMAT a125    HEADING 'Name'         ENTMAP off
COLUMN used                          HEADING 'Used?'        ENTMAP off
COLUMN timestamp      FORMAT a125    HEADING 'Time Stamp'   ENTMAP off
COLUMN version                       HEADING 'Version'      ENTMAP off
COLUMN sql_text                      HEADING 'SQL Text'     ENTMAP off

SELECT
    '<div nowrap><font color="#336699"><b>' || category || '</b></font></div>' category
  , owner
  , name
  , used
  , '<div nowrap align="right">' || TO_CHAR(timestamp, 'mm/dd/yyyy HH24:MI:SS') || '</div>' timestamp
  , version
  , sql_text
FROM
    dba_outlines
ORDER BY
    category
  , owner
  , name;
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - OUTLINE HINTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_outline_hints"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Outline Hints</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN category       FORMAT a125    HEADING 'Category'        ENTMAP off
COLUMN owner          FORMAT a125    HEADING 'Owner'           ENTMAP off
COLUMN name           FORMAT a125    HEADING 'Name'            ENTMAP off
COLUMN node                          HEADING 'Node'            ENTMAP off
COLUMN join_pos                      HEADING 'Join Position'   ENTMAP off
COLUMN hint                          HEADING 'Hint'            ENTMAP off

BREAK ON category ON owner ON name

SELECT
    '<div nowrap><font color="#336699"><b>' || a.category || '</b></font></div>' category
  , a.owner                                           owner
  , a.name                                            name
  , '<div align="center">' || b.node || '</div>'      node
  , '<div align="center">' || b.join_pos || '</div>'  join_pos
  , b.hint                                            hint
FROM
    dba_outlines       a
  , dba_outline_hints  b
WHERE
      a.owner = b.owner
  AND b.name  = b.name
ORDER BY
    category
  , owner
  , name;
  
prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                - SQL STATEMENTS WITH MOST BUFFER GETS -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_with_most_buffer_gets"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements With Most Buffer Gets</b></font><hr align="left" width="460">

prompt <b>Top 100 SQL statements with buffer gets greater than 1000</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username        FORMAT a75                   HEADING 'Username'                 ENTMAP off
COLUMN buffer_gets     FORMAT 999,999,999,999,999   HEADING 'Buffer Gets'              ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'               ENTMAP off
COLUMN gets_per_exec   FORMAT 999,999,999,999,999   HEADING 'Buffer Gets / Execution'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'                 ENTMAP off

SELECT 
    '<font color="#336699"><b>' || UPPER(b.username) || '</b></font>' username
  , a.buffer_gets              buffer_gets
  , a.executions               executions
  , (a.buffer_gets / decode(a.executions, 0, 1, a.executions))  gets_per_exec
  , a.sql_text                 sql_text
FROM 
    (SELECT ai.buffer_gets, ai.executions, ai.sql_text, ai.parsing_user_id
     FROM sys.v_$sqlarea ai
     ORDER BY ai.buffer_gets
    ) a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.buffer_gets > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
  AND rownum < 101
ORDER BY
    a.buffer_gets DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                 - SQL STATEMENTS WITH MOST DISK READS -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="sql_statements_with_most_disk_reads"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SQL Statements With Most Disk Reads</b></font><hr align="left" width="460">

prompt <b>Top 100 SQL statements with disk reads greater than 1000</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username        FORMAT a75                   HEADING 'Username'           ENTMAP off
COLUMN disk_reads      FORMAT 999,999,999,999,999   HEADING 'Disk Reads'         ENTMAP off
COLUMN executions      FORMAT 999,999,999,999,999   HEADING 'Executions'         ENTMAP off
COLUMN reads_per_exec  FORMAT 999,999,999,999,999   HEADING 'Reads / Execution'  ENTMAP off
COLUMN sql_text                                     HEADING 'SQL Text'           ENTMAP off


SELECT 
    '<font color="#336699"><b>' || UPPER(b.username) || '</b></font>' username
  , a.disk_reads       disk_reads
  , a.executions       executions
  , (a.disk_reads / decode(a.executions, 0, 1, a.executions))  reads_per_exec
  , a.sql_text         sql_text
FROM 
    (SELECT ai.disk_reads, ai.executions, ai.sql_text, ai.parsing_user_id
     FROM sys.v_$sqlarea ai
     ORDER BY ai.buffer_gets
    ) a
  , dba_users b
WHERE
      a.parsing_user_id = b.user_id 
  AND a.disk_reads > 1000
  AND b.username NOT IN ('SYS','SYSTEM')
  AND rownum < 101
ORDER BY
    a.disk_reads DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - TOP 10 TABLES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="top_10_tables"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 10 Tables</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN ctyp      FORMAT a79                  HEADING 'Command Type'          ENTMAP off
COLUMN obj       FORMAT a30                  HEADING 'Object Name'           ENTMAP off
COLUMN noe       FORMAT 999,999,999,999,999  HEADING 'Number of Executions'  ENTMAP off
COLUMN gets      FORMAT 999,999,999,999,999  HEADING 'Buffer Gets'           ENTMAP off
COLUMN rowp      FORMAT 999,999,999,999,999  HEADING 'Rows Processed'        ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF noe gets rowp ON report

SELECT
    '<div nowrap><font color="#336699"><b>' || ctyp  || '</b></font></div>'   ctyp
  , obj
  , 0 - exem noe
  , gets
  , rowp
FROM (
    select distinct exem, ctyp, obj, gets, rowp 
    from (select
              DECODE(   s.command_type
                      , 2,  'INSERT INTO '
                      , 3,  'SELECT FROM '
                      , 6,  'UPDATE  OF  '
                      , 7,  'DELETE FROM '
                      , 26, 'LOCK    OF  ')   ctyp
            , o.owner || '.' || o.name        obj
            , SUM(0 - s.executions)           exem
            , SUM(s.buffer_gets)              gets
            , SUM(s.rows_processed)           rowp
          from
              v$sql                s
            , v$object_dependency  d
            , v$db_object_cache    o 
          where
                s.command_type  IN (2,3,6,7,26) 
            and d.from_address  = s.address 
            and d.to_owner      = o.owner 
            and d.to_name       = o.name   
            and o.type          = 'TABLE' 
          group by
              s.command_type
            , o.owner
            , o.name
    )
)
WHERE rownum <= 10;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - TOP 10 PROCEDURES -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="top_10_procedures"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 10 Procedures</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN ptyp      FORMAT a79                   HEADING 'Object Type'            ENTMAP off
COLUMN obj       FORMAT a42                   HEADING 'Object Name'            ENTMAP off
COLUMN noe       FORMAT 999,999,999,999,999   HEADING 'Number of Executions'   ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF noe ON report

SELECT
    '<div nowrap><font color="#336699"><b>' || ptyp || '</b></font></div>'  ptyp
  , obj
  , 0 - exem noe
FROM ( select distinct exem, ptyp, obj  
       from ( select
                  o.type                    ptyp
                , o.owner || '.' || o.name  obj
                , 0 - o.executions          exem
              from  v$db_object_cache O 
              where o.type in (   'FUNCTION'
                                , 'PACKAGE'
                                , 'PACKAGE BODY'
                                , 'PROCEDURE'
                                , 'TRIGGER')
	   )
     )
WHERE rownum <= 10;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                     <<<<<     STATSPACK    >>>>>                           |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                              - STATSPACK LIST -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sp_list"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Statspack List</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN snap_id          FORMAT a75    HEAD 'Snap ID'         ENTMAP off
COLUMN snap_time        FORMAT a75    HEAD 'Statspack Snap Time'       ENTMAP off
COLUMN startup_time     FORMAT a75    HEAD 'Database Startup Time'    ENTMAP off

BREAK ON startup_time SKIP 1

SELECT
    '<div align="center"><font color="#336699"><b>' || a.snap_id || '</b></font></div>'           snap_id
  , '<div nowrap align="right">' || TO_CHAR(a.startup_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  startup_time
  , '<div nowrap align="right">' || TO_CHAR(a.snap_time, 'mm/dd/yyyy HH24:MI:SS')    || '</div>'  snap_time
FROM
    stats$snapshot  a
  , v$database      b
ORDER BY
    a.snap_id
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - STATSPACK PARAMETERS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="sp_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Statspack Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               FORMAT a75           HEAD 'Database|Name'       ENTMAP off
COLUMN snap_level         FORMAT 999999        HEAD 'Snap|Level'          ENTMAP off
COLUMN num_sql            FORMAT 999,999       HEAD 'Number|SQL'          ENTMAP off
COLUMN executions_th      FORMAT 999,999       HEAD 'Executions|(TH)'     ENTMAP off
COLUMN parse_calls_th     FORMAT 999,999       HEAD 'Parse|Calls|(TH)'    ENTMAP off
COLUMN disk_reads_th      FORMAT 999,999       HEAD 'Disk|Reads|(TH)'     ENTMAP off
COLUMN buffer_gets_th     FORMAT 999,999       HEAD 'Buffer|Gets|(TH)'    ENTMAP off
COLUMN sharable_mem_th    FORMAT 999,999,999   HEAD 'Sharable|Mem.|(TH)'  ENTMAP off
COLUMN version_count_th                        HEAD 'Version|Count|(TH)'  ENTMAP off
COLUMN pin_statspack                           HEAD 'Pin|Statspack'       ENTMAP off
COLUMN all_init                                HEAD 'All|Init'            ENTMAP off
COLUMN last_modified      FORMAT a75           HEAD 'Last|Modified'       ENTMAP off

SELECT
    '<font color="#336699"><b>' || b.name || '</b></font>' name
  , a.snap_level
  , a.num_sql
  , a.executions_th
  , a.parse_calls_th
  , a.disk_reads_th
  , a.buffer_gets_th
  , a.sharable_mem_th
  , a.version_count_th
  , '<div nowrap align="center">' || a.pin_statspack  || '</div>'  pin_statspack
  , '<div nowrap align="center">' || a.all_init       || '</div>'  all_init
  , '<div nowrap align="right">' || TO_CHAR(a.last_modified, 'mm/dd/yyyy HH24:MI:SS') || '</div>' last_modified
FROM
    stats$statspack_parameter  a
  , v$database                 b
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     SESSIONS    >>>>>                           |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                          - CURRENT SESSIONS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="current_sessions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Current Sessions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN count       FORMAT a45  HEADING 'Current No. of Processes'   ENTMAP off
COLUMN value       FORMAT a45  HEADING 'Max No. of Processes'       ENTMAP off
COLUMN pct_usage   FORMAT a45  HEADING '% Usage'                    ENTMAP off

SELECT
    '<div align="center">' || TO_char(a.count)  || '</div>'  count
  , '<div align="center">' || b.value           || '</div>'  value
  , '<div align="center">' || TO_CHAR(ROUND(100*(a.count / b.value), 2)) || '%</div>'  pct_usage
FROM
    (select count(*) count from v$session) a
  , (select value from v$parameter where name='processes') b;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - USER SESSION MATRIX -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="user_session_matrix"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>User Session Matrix</b></font><hr align="left" width="460">

prompt <b>User sessions (including SYS and background processes)</b>

COLUMN username          FORMAT a79               HEADING 'Oracle User'             ENTMAP off
COLUMN num_user_sess     FORMAT 999,999,999,999   HEADING 'Total Number of Logins'  ENTMAP off
COLUMN count_a           FORMAT 999,999,999       HEADING 'Active Logins'           ENTMAP off
COLUMN count_i           FORMAT 999,999,999       HEADING 'Inactive Logins'         ENTMAP off
COLUMN count_k           FORMAT 999,999,999       HEADING 'Killed Logins'           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF num_user_sess count_a count_i count_k ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || NVL(sess.username, '[B.G. Process]') || '</b></font></div>' username
  , count(*) num_user_sess
  , NVL(act.count, 0)    count_a
  , NVL(inact.count, 0)  count_i
  , NVL(killed.count, 0) count_k
FROM 
    v$session sess
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username
     FROM      v$session
     WHERE     status = 'ACTIVE'
     GROUP BY  username)   act
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username
     FROM      v$session
     WHERE     status = 'INACTIVE'
     GROUP BY  username) inact
  , (SELECT    count(*) count, nvl(username, '[B.G. Process]') username
     FROM      v$session
     WHERE     status = 'KILLED'
     GROUP BY  username) killed
WHERE
         nvl(sess.username, '[B.G. Process]') = act.username (+)
     and nvl(sess.username, '[B.G. Process]') = inact.username (+)
     and nvl(sess.username, '[B.G. Process]') = killed.username (+)
GROUP BY 
    sess.username
  , act.count
  , inact.count
  , killed.count
ORDER BY
    username;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                     <<<<<     SECURITY    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                             - USER ACCOUNTS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="user_accounts"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>User Accounts</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username              FORMAT a75    HEAD 'Username'        ENTMAP off
COLUMN account_status        FORMAT a75    HEAD 'Account Status'  ENTMAP off
COLUMN expiry_date           FORMAT a75    HEAD 'Expire Date'     ENTMAP off
COLUMN default_tablespace    FORMAT a75    HEAD 'Default Tbs.'    ENTMAP off
COLUMN temporary_tablespace  FORMAT a75    HEAD 'Temp Tbs.'       ENTMAP off
COLUMN created               FORMAT a75    HEAD 'Created On'      ENTMAP off
COLUMN profile               FORMAT a75    HEAD 'Profile'         ENTMAP off
COLUMN sysdba                FORMAT a75    HEAD 'SYSDBA'          ENTMAP off
COLUMN sysoper               FORMAT a75    HEAD 'SYSOPER'         ENTMAP off

SELECT distinct
    '<b><font color="#336699">' || a.username || '</font></b>'                                            username
  , DECODE(   a.account_status
            , 'OPEN'
            , '<div align="left"><b><font color="darkgreen">' || a.account_status || '</font></b></div>'
            , '<div align="left"><b><font color="#663300">'   || a.account_status || '</font></b></div>') account_status
  , '<div nowrap align="right">' || NVL(TO_CHAR(a.expiry_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'           expiry_date
  , a.default_tablespace                                                                                  default_tablespace
  , a.temporary_tablespace                                                                                temporary_tablespace
  , '<div nowrap align="right">' || TO_CHAR(a.created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'               created
  , a.profile                                        profile
  , '<div nowrap align="center">' || NVL(DECODE(p.sysdba,'TRUE', 'TRUE',''), '<br>') || '</div>'   sysdba
  , '<div nowrap align="center">' || NVL(DECODE(p.sysoper,'TRUE','TRUE',''), '<br>') || '</div>'   sysoper
FROM
    dba_users       a
  , v$pwfile_users  p
WHERE
    p.username (+) = a.username 
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - USERS WITH DBA PRIVILEGES -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_dba_privileges"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With DBA Privileges</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN grantee        FORMAT a70   HEADING 'Grantee'         ENTMAP off
COLUMN granted_role   FORMAT a30   HEADING 'Granted Role'    ENTMAP off
COLUMN admin_option   FORMAT a40   HEADING 'Admin. Option?'  ENTMAP off
COLUMN default_role   FORMAT a40   HEADING 'Default Role?'   ENTMAP off

SELECT
    '<b><font color="#336699">' || grantee       || '</font></b>'  grantee
  , '<div align="center">'      || granted_role  || '</div>'  granted_role
  , '<div align="center">'      || admin_option  || '</div>'  admin_option
  , '<div align="center">'      || default_role  || '</div>'  default_role
FROM
    dba_role_privs
WHERE
    granted_role = 'DBA'
ORDER BY
    grantee
  , granted_role;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                 - ROLES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="roles"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Roles</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN role             FORMAT a70    HEAD 'Role Name'       ENTMAP off
COLUMN grantee          FORMAT a30    HEAD 'Grantee'         ENTMAP off
COLUMN admin_option     FORMAT a40    HEAD 'Admin Option?'   ENTMAP off
COLUMN default_role     FORMAT a40    HEAD 'Default Role?'   ENTMAP off

BREAK ON role

SELECT
   '<b><font color="#336699">' ||  b.role         || '</font></b>'          role
  , a.grantee                                                               grantee
  , '<div align="center">'     || NVL(a.admin_option, '<br>')  || '</div>'  admin_option
  , '<div align="center">'     || NVL(a.default_role, '<br>')  || '</div>'  default_role
FROM
    dba_role_privs  a
  , dba_roles       b
WHERE
    granted_role(+) = b.role
ORDER BY
    b.role
  , a.grantee;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - DEFAULT PASSWORDS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="default_passwords"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Default Passwords</b></font><hr align="left" width="460">

prompt <b>User(s) with default password</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                      HEADING 'Username'        ENTMAP off
COLUMN account_status   FORMAT a75   HEADING 'Account Status'  ENTMAP off

SELECT
    '<b><font color="#336699">' || username        || '</font></b>'        username
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="left"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="left"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM dba_users
WHERE password IN (
    'E066D214D5421CCC'   -- dbsnmp
  , '24ABAB8B06281B4C'   -- ctxsys
  , '72979A94BAD2AF80'   -- mdsys
  , 'C252E8FA117AF049'   -- odm
  , 'A7A32CD03D3CE8D5'   -- odm_mtr
  , '88A2B2C183431F00'   -- ordplugins
  , '7EFA02EC7EA6B86F'   -- ordsys
  , '4A3BA55E08595C81'   -- outln
  , 'F894844C34402B67'   -- scott
  , '3F9FBD883D787341'   -- wk_proxy
  , '79DF7A1BD138CF11'   -- wk_sys
  , '7C9BA362F8314299'   -- wmsys
  , '88D8364765FCE6AF'   -- xdb
  , 'F9DA8977092B7B81'   -- tracesvr
  , '9300C0977D7DC75E'   -- oas_public
  , 'A97282CE3D94E29E'   -- websys
  , 'AC9700FD3F1410EB'   -- lbacsys
  , 'E7B5D92911C831E1'   -- rman
  , 'AC98877DE1297365'   -- perfstat
  , 'D4C5016086B2DC6A'   -- sys
  , 'D4DF7931AB130E37')  -- system
ORDER BY username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                              - DB LINKS -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="db_links"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>DB Links</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner        FORMAT a75    HEADING 'Owner'           ENTMAP off
COLUMN db_link      FORMAT a75    HEADING 'DB Link Name'    ENTMAP off
COLUMN username                   HEADING 'Username'        ENTMAP off
COLUMN host                       HEADING 'Host'            ENTMAP off
COLUMN created      FORMAT a75    HEADING 'Created'         ENTMAP off

BREAK ON owner

SELECT
    '<b><font color="#336699">' || owner || '</font></b>'  owner
  , db_link
  , username
  , host
  , '<div nowrap align="right">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>' created
FROM dba_db_links
ORDER BY owner, db_link;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     OBJECTS    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                            - OBJECT SUMMARY -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="object_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Object Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a60               HEADING 'Owner'           ENTMAP off
COLUMN object_type     FORMAT a25               HEADING 'Object Type'     ENTMAP off
COLUMN obj_count       FORMAT 999,999,999,999   HEADING 'Object Count'    ENTMAP off

BREAK ON report ON owner SKIP 2
-- compute sum label ""               of obj_count on owner
-- compute sum label '<font color="#990000"><b>Grand Total: </b></font>' of obj_count on report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF obj_count ON report

SELECT
    '<b><font color="#336699">' || owner || '</font></b>'  owner
  , object_type                                            object_type
  , count(*)                                               obj_count
FROM
    dba_objects
GROUP BY
    owner
  , object_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - SEGMENT SUMMARY -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="segment_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Segment Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a50                    HEADING 'Owner'             ENTMAP off
COLUMN segment_type    FORMAT a25                    HEADING 'Segment Type'      ENTMAP off
COLUMN seg_count       FORMAT 999,999,999,999        HEADING 'Segment Count'     ENTMAP off
COLUMN bytes           FORMAT 999,999,999,999,999    HEADING 'Size (in Bytes)'   ENTMAP off

BREAK ON report ON owner SKIP 2
-- COMPUTE sum LABEL ""                                                  OF seg_count bytes ON owner
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF seg_count bytes ON report

SELECT
    '<b><font color="#336699">' || owner || '</font></b>'  owner
  , segment_type        segment_type
  , count(*)            seg_count
  , sum(bytes)          bytes
FROM
    dba_segments
GROUP BY
    owner
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - TOP 200 SEGMENTS (BY SIZE) -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="top_200_segments_by_size"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 200 Segments (by size)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                               HEADING 'Owner'            ENTMAP off
COLUMN segment_name                                        HEADING 'Segment Name'     ENTMAP off
COLUMN partition_name                                      HEADING 'Partition Name'   ENTMAP off
COLUMN segment_type                                        HEADING 'Segment Type'     ENTMAP off
COLUMN tablespace_name                                     HEADING 'Tablespace Name'  ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999,999  HEADING 'Size (in bytes)'  ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999,999  HEADING 'Extents'          ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF bytes extents ON report

SELECT
    a.owner
  , a.segment_name
  , a.partition_name
  , a.segment_type
  , a.tablespace_name
  , a.bytes
  , a.extents
FROM
    (select
         b.owner
       , b.segment_name
       , b.partition_name
       , b.segment_type
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments b
     order by
         b.bytes desc
    ) a
WHERE
    rownum < 200;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - TOP 200 SEGMENTS (BY EXTENTS) -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="top_200_segments_by_extents"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 200 Segments (by number of extents)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                               HEADING 'Owner'            ENTMAP off
COLUMN segment_name                                        HEADING 'Segment Name'     ENTMAP off
COLUMN partition_name                                      HEADING 'Partition Name'   ENTMAP off
COLUMN segment_type                                        HEADING 'Segment Type'     ENTMAP off
COLUMN tablespace_name                                     HEADING 'Tablespace Name'  ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999,999  HEADING 'Extents'          ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999,999  HEADING 'Size (in bytes)'  ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF extents bytes ON report

SELECT
    a.owner
  , a.segment_name
  , a.partition_name
  , a.segment_type
  , a.tablespace_name
  , a.extents
  , a.bytes
FROM
    (select
         b.owner
       , b.segment_name
       , b.partition_name
       , b.segment_type
       , b.tablespace_name
       , b.bytes
       , b.extents
     from
         dba_segments b
     order by
         b.extents desc
    ) a
WHERE
    rownum < 200;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DIRECTORIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directories"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directories</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner               HEADING 'Owner'             ENTMAP off
COLUMN directory_name      HEADING 'Directory Name'    ENTMAP off
COLUMN directory_path      HEADING 'Directory Path'    ENTMAP off

SELECT
    owner
  , directory_name
  , '<tt>' || directory_path || '</tt>' directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                             - LIBRARIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_libraries"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Libraries</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                        HEADING 'Owner'             ENTMAP off
COLUMN library_name                 HEADING 'Library Name'      ENTMAP off
COLUMN file_spec                    HEADING 'File Spec'         ENTMAP off
COLUMN dynamic        FORMAT a40    HEADING 'Dynamic?'          ENTMAP off
COLUMN status         FORMAT a75    HEADING 'Status'            ENTMAP off

SELECT
    owner
  , library_name
  , file_spec
  , '<div align="center">' || dynamic || '</div>'  dynamic
  , DECODE(   status
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || status || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || status || '</b></font></div>' ) status
FROM
    dba_libraries
ORDER BY
    owner
  , library_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                               - TYPES -                                    |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_types"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Types</b></font><hr align="left" width="460">

prompt <b>Excluding the SYS, SYSTEM, and XDB schemas</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75        HEADING 'Owner'              ENTMAP off
COLUMN type_name          FORMAT a75        HEADING 'Type Name'          ENTMAP off
COLUMN typecode           FORMAT a75        HEADING 'Type Code'          ENTMAP off
COLUMN attributes         FORMAT a75        HEADING 'Num. Attributes'    ENTMAP off
COLUMN methods            FORMAT a75        HEADING 'Num. Methods'       ENTMAP off
COLUMN predefined         FORMAT a75        HEADING 'Predefined?'        ENTMAP off
COLUMN incomplete         FORMAT a75        HEADING 'Incomplete?'        ENTMAP off
COLUMN final              FORMAT a75        HEADING 'Final?'             ENTMAP off
COLUMN instantiable       FORMAT a75        HEADING 'Instantiable?'      ENTMAP off
COLUMN supertype_owner    FORMAT a75        HEADING 'Super Owner'        ENTMAP off
COLUMN supertype_name     FORMAT a75        HEADING 'Super Name'         ENTMAP off
COLUMN local_attributes   FORMAT a75        HEADING 'Local Attributes'   ENTMAP off
COLUMN local_methods      FORMAT a75        HEADING 'Local Methods'      ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || t.owner || '</b></font></div>'    owner
  , '<div nowrap>'                || t.type_name                                          || '</div>'   type_name
  , '<div nowrap>'                || t.typecode                                           || '</div>'   typecode
  , '<div nowrap align="right">'  || TO_CHAR(t.attributes, '999,999')                     || '</div>'   attributes
  , '<div nowrap align="right">'  || TO_CHAR(t.methods, '999,999')                        || '</div>'   methods
  , '<div nowrap align="center">' || t.predefined                                         || '</div>'   predefined
  , '<div nowrap align="center">' || t.incomplete                                         || '</div>'   incomplete
  , '<div nowrap align="center">' || t.final                                              || '</div>'   final
  , '<div nowrap align="center">' || t.instantiable                                       || '</div>'   instantiable
  , '<div nowrap align="left">'   || NVL(t.supertype_owner, '<br>')                       || '</div>'   supertype_owner
  , '<div nowrap align="left">'   || NVL(t.supertype_name, '<br>')                        || '</div>'   supertype_name
  , '<div nowrap align="right">'  || NVL(TO_CHAR(t.local_attributes, '999,999'), '<br>')  || '</div>'   local_attributes
  , '<div nowrap align="right">'  || NVL(TO_CHAR(t.local_methods, '999,999'), '<br>')     || '</div>'   local_methods
FROM
    dba_types  t
WHERE
    t.owner NOT IN ('SYS', 'SYSTEM', 'XDB')
ORDER BY
    t.owner
  , t.type_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - TYPE ATTRIBUTES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_type_attributes"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Type Attributes</b></font><hr align="left" width="460">

prompt <b>Excluding the SYS, SYSTEM, and XDB schemas</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                FORMAT a75        HEADING 'Owner'                ENTMAP off
COLUMN type_name            FORMAT a75        HEADING 'Type Name'            ENTMAP off
COLUMN typecode             FORMAT a75        HEADING 'Type Code'            ENTMAP off
COLUMN attribute_name       FORMAT a75        HEADING 'Attribute Name'       ENTMAP off
COLUMN attribute_datatype   FORMAT a75        HEADING 'Attribute Data Type'  ENTMAP off
COLUMN inherited            FORMAT a75        HEADING 'Inherited?'           ENTMAP off

BREAK ON report ON owner ON type_name ON typecode

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || t.owner || '</b></font></div>'    owner
  , '<div nowrap>' || t.type_name   || '</div>'               type_name
  , '<div nowrap>' || t.typecode    || '</div>'               typecode
  , '<div nowrap>' || a.attr_name   || '</div>'               attribute_name
  , (CASE
       WHEN (a.length IS NOT NULL)
           THEN a.attr_type_name || '(' || a.length || ')'
       WHEN (a.attr_type_name='NUMBER' AND (a.precision IS NOT NULL AND a.scale IS NOT NULL))
           THEN a.attr_type_name || '(' || a.precision || ',' || a.scale || ')'
       WHEN (a.attr_type_name='NUMBER' AND (a.precision IS NOT NULL AND a.scale IS NULL))
           THEN a.attr_type_name || '(' || a.precision || ')'
       ELSE
           a.attr_type_name
     END)                                                     attribute_datatype
  , '<div nowrap align="center">' || a.inherited || '</div>'  inherited
FROM
    dba_types        t
  , dba_type_attrs   a
WHERE
      t.owner       = a.owner
  AND t.type_name   = a.type_name
  AND t.owner NOT IN ('SYS', 'SYSTEM', 'XDB')
ORDER BY
    t.owner
  , t.type_name
  , t.typecode
  , a.attr_no;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                             - TYPE METHODS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_type_methods"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Type Methods</b></font><hr align="left" width="460">

prompt <b>Excluding the SYS, SYSTEM, and XDB schemas</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75        HEADING 'Owner'              ENTMAP off
COLUMN type_name          FORMAT a75        HEADING 'Type Name'          ENTMAP off
COLUMN typecode           FORMAT a75        HEADING 'Type Code'          ENTMAP off
COLUMN method_name        FORMAT a75        HEADING 'Method Name'        ENTMAP off
COLUMN method_type        FORMAT a75        HEADING 'Method Type'        ENTMAP off
COLUMN num_parameters     FORMAT a75        HEADING 'Num. Parameters'    ENTMAP off
COLUMN results            FORMAT a75        HEADING 'Results'            ENTMAP off
COLUMN final              FORMAT a75        HEADING 'Final?'             ENTMAP off
COLUMN instantiable       FORMAT a75        HEADING 'Instantiable?'      ENTMAP off
COLUMN overriding         FORMAT a75        HEADING 'Overriding?'        ENTMAP off
COLUMN inherited          FORMAT a75        HEADING 'Inherited?'         ENTMAP off

BREAK ON report ON owner ON type_name ON typecode

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || t.owner || '</b></font></div>'    owner
  , '<div nowrap>'                || t.type_name                       || '</div>'  type_name
  , '<div nowrap>'                || t.typecode                        || '</div>'  typecode
  , '<div nowrap>'                || m.method_name                     || '</div>'  method_name
  , '<div nowrap>'                || m.method_type                     || '</div>'  method_type
  , '<div nowrap align="right">'  || TO_CHAR(m.parameters, '999,999')  || '</div>'  num_parameters
  , '<div nowrap align="right">'  || TO_CHAR(m.results, '999,999')     || '</div>'  results
  , '<div nowrap align="center">' || m.final                           || '</div>'  final
  , '<div nowrap align="center">' || m.instantiable                    || '</div>'  instantiable
  , '<div nowrap align="center">' || m.overriding                      || '</div>'  overriding
  , '<div nowrap align="center">' || m.inherited                       || '</div>'  inherited
FROM
    dba_types          t
  , dba_type_methods   m
WHERE
      t.owner       = m.owner
  AND t.type_name   = m.type_name
  AND t.owner NOT IN ('SYS', 'SYSTEM', 'XDB')
ORDER BY
    t.owner
  , t.type_name
  , t.typecode
  , m.method_no;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                              - COLLECTIONS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_collections"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Collections</b></font><hr align="left" width="460">
prompt <b>Excluding the SYS, SYSTEM, and XDB schemas</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                FORMAT a75        HEADING 'Owner'              ENTMAP off
COLUMN type_name            FORMAT a75        HEADING 'Type Name'          ENTMAP off
COLUMN coll_type            FORMAT a75        HEADING 'Collection Type'    ENTMAP off
COLUMN upper_bound          FORMAT a75        HEADING 'VARRAY Limit'       ENTMAP off
COLUMN elem_type_owner      FORMAT a75        HEADING 'Element Type Owner' ENTMAP off
COLUMN elem_datatype        FORMAT a75        HEADING 'Element Data Type'  ENTMAP off
COLUMN character_set_name   FORMAT a75        HEADING 'Character Set'      ENTMAP off
COLUMN elem_storage         FORMAT a75        HEADING 'Element Storage'    ENTMAP off
COLUMN nulls_stored         FORMAT a75        HEADING 'Nulls Stored?'      ENTMAP off

BREAK ON report ON owner ON type_name

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || c.owner || '</b></font></div>'    owner
  , '<div nowrap>'                  || c.type_name                                           || '</div>'  type_name
  , '<div nowrap>'                  || c.coll_type                                           || '</div>'  coll_type
  , '<div nowrap align="right">'    || NVL(TO_CHAR(c.upper_bound, '9,999,999,999'), '<br>')  || '</div>'  upper_bound
  , '<div nowrap>'                  || NVL(c.elem_type_owner, '<br>')                        || '</div>'  elem_type_owner
  , (CASE
       WHEN (c.length IS NOT NULL)
           THEN c.elem_type_name || '(' || c.length || ')'
       WHEN (c.elem_type_name='NUMBER' AND (c.precision IS NOT NULL AND c.scale IS NOT NULL))
           THEN c.elem_type_name || '(' || c.precision || ',' || c.scale || ')'
       WHEN (c.elem_type_name='NUMBER' AND (c.precision IS NOT NULL AND c.scale IS NULL))
           THEN c.elem_type_name || '(' || c.precision || ')'
       ELSE
           c.elem_type_name
     END)                                    elem_datatype
  , '<div nowrap>'                  || NVL(c.character_set_name, '<br>')                     || '</div>'  character_set_name
  , '<div nowrap>'                  || NVL(c.elem_storage, '<br>')                           || '</div>'  elem_storage
  , '<div nowrap align="center">'   || c.nulls_stored                                        || '</div>'  nulls_stored
FROM
    dba_coll_types  c
WHERE
    c.owner NOT IN ('SYS', 'SYSTEM', 'XDB')
ORDER BY
    c.owner
  , c.type_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - LOB SEGMENTS -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_lob_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>LOB Segments</b></font><hr align="left" width="460">

prompt <b>Excluding the SYS, SYSTEM, and XDB schemas</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75        HEADING 'Owner'              ENTMAP off
COLUMN table_name         FORMAT a75        HEADING 'Table Name'         ENTMAP off
COLUMN column_name        FORMAT a75        HEADING 'Column Name'        ENTMAP off
COLUMN segment_name       FORMAT a125       HEADING 'LOB Segment Name'   ENTMAP off
COLUMN tablespace_name    FORMAT a75        HEADING 'Tablespace Name'    ENTMAP off
COLUMN lob_segment_bytes  FORMAT a75        HEADING 'Segment Size'       ENTMAP off
COLUMN index_name         FORMAT a125       HEADING 'LOB Index Name'     ENTMAP off
COLUMN in_row             FORMAT a75        HEADING 'In Row?'            ENTMAP off

BREAK ON report ON owner ON table_name

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || l.owner || '</b></font></div>'    owner
  , '<div nowrap>' || l.table_name        || '</div>'       table_name
  , '<div nowrap>' || l.column_name       || '</div>'       column_name
  , '<div nowrap>' || l.segment_name      || '</div>'       segment_name
  , '<div nowrap>' || s.tablespace_name   || '</div>'       tablespace_name
  , '<div nowrap align="right">' || TO_CHAR(s.bytes, '999,999,999,999,999') || '</div>'  lob_segment_bytes
  , '<div nowrap>' || l.index_name        || '</div>'       index_name
  , '<div nowrap align="center">' || l.in_row || '</div>'   in_row
FROM
    dba_lobs     l
  , dba_segments s
WHERE
      l.owner = s.owner
  AND l.segment_name = s.segment_name
  AND l.owner NOT IN ('SYS', 'SYSTEM', 'XDB')
ORDER BY
    l.owner
  , l.table_name
  , l.column_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - OBJECTS UNABLE TO EXTEND -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="objects_unable_to_extend"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Objects Unable to Extend</b></font><hr align="left" width="460">

prompt <b>Segments that cannot extend because of MAXEXTENTS or not enough space</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                         HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name                               HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_name                                  HEADING 'Segment Name'     ENTMAP off
COLUMN segment_type                                  HEADING 'Segment Type'     ENTMAP off
COLUMN next_extent       FORMAT 999,999,999,999,999  HEADING 'Next Extent'      ENTMAP off
COLUMN max               FORMAT 999,999,999,999,999  HEADING 'Max. Piece Size'  ENTMAP off
COLUMN sum               FORMAT 999,999,999,999,999  HEADING 'Sum of Bytes'     ENTMAP off
COLUMN extents           FORMAT 999,999,999,999,999  HEADING 'Num. of Extents'  ENTMAP off
COLUMN max_extents       FORMAT 999,999,999,999,999  HEADING 'Max Extents'      ENTMAP off

SELECT
    ds.owner              owner
  , ds.tablespace_name    tablespace_name
  , ds.segment_name       segment_name
  , ds.segment_type       segment_type
  , ds.next_extent        next_extent
  , NVL(dfs.max, 0)       max
  , NVL(dfs.sum, 0)       sum
  , ds.extents            extents
  , ds.max_extents        max_extents
FROM 
    dba_segments ds
  , (select
         max(bytes) max
       , sum(bytes) sum
       , tablespace_name
     from
         dba_free_space 
     group by
         tablespace_name
    ) dfs
WHERE
      (ds.next_extent > nvl(dfs.max, 0)
       OR
       ds.extents >= ds.max_extents)
  AND ds.tablespace_name = dfs.tablespace_name (+)
  AND ds.owner NOT IN ('SYS','SYSTEM')
ORDER BY
    ds.owner
  , ds.tablespace_name
  , ds.segment_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |               - OBJECTS WHICH ARE NEARING MAXEXTENTS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="objects_which_are_nearing_maxextents"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Objects Which Are Nearing MAXEXTENTS</b></font><hr align="left" width="460">

prompt <b>Segments where number of EXTENTS is less than 1/2 of MAXEXTENTS</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                          HEADING 'Owner'             ENTMAP off
COLUMN tablespace_name   FORMAT a30                   HEADING 'Tablespace name'   ENTMAP off
COLUMN segment_name      FORMAT a30                   HEADING 'Segment Name'      ENTMAP off
COLUMN segment_type      FORMAT a20                   HEADING 'Segment Type'      ENTMAP off
COLUMN bytes             FORMAT 999,999,999,999,999   HEADING 'Size (in bytes)'   ENTMAP off
COLUMN next_extent       FORMAT 999,999,999,999,999   HEADING 'Next Extent Size'  ENTMAP off
COLUMN pct_increase                                   HEADING '% Increase'        ENTMAP off
COLUMN extents           FORMAT 999,999,999,999,999   HEADING 'Num. of Extents'   ENTMAP off
COLUMN max_extents       FORMAT 999,999,999,999,999   HEADING 'Max Extents'       ENTMAP off
COLUMN pct_util          FORMAT a35                   HEADING '% Utilized'        ENTMAP off

SELECT 
    owner
  , tablespace_name
  , segment_name
  , segment_type
  , bytes
  , next_extent
  , pct_increase
  , extents
  , max_extents
  , '<div align="right">' || ROUND((extents/max_extents)*100, 2) || '%</div>'   pct_util
FROM
    dba_segments
WHERE
      extents > max_extents/2
  AND max_extents != 0
ORDER BY
    (extents/max_extents) DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - INVALID OBJECTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="invalid_objects"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Invalid Objects</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner           FORMAT a65         HEADING 'Owner'         ENTMAP off
COLUMN object_name     FORMAT a30         HEADING 'Object Name'   ENTMAP off
COLUMN object_type     FORMAT a20         HEADING 'Object Type'   ENTMAP off
COLUMN status          FORMAT a75         HEADING 'Status'        ENTMAP off

BREAK ON report
COMPUTE count LABEL '<font color="#990000"><b>Grand Total: </b></font>' OF object_name ON report

SELECT
    owner
  , object_name
  , object_type
  , DECODE(   status
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || status || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || status || '</b></font></div>' ) status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY owner, object_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - PROCEDURAL OBJECT ERRORS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="procedural_object_errors"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Procedural Object Errors</b></font><hr align="left" width="460">

prompt <b>All records from DBA_ERRORS</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN type                 FORMAT a15      HEAD 'Object Type'   ENTMAP off
COLUMN owner                FORMAT a17      HEAD 'Schema'        ENTMAP off
COLUMN name                 FORMAT a30      HEAD 'Object Name'   ENTMAP off
COLUMN sequence             FORMAT 999,999  HEAD 'Sequence'      ENTMAP off
COLUMN line                 FORMAT 999,999  HEAD 'Line'          ENTMAP off
COLUMN position             FORMAT 999,999  HEAD 'Position'      ENTMAP off
COLUMN text                                 HEAD 'Text'          ENTMAP off

SELECT
    type
  , owner
  , name
  , sequence
  , line
  , position
  , text
FROM
    dba_errors
ORDER BY
    1
  , 2
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - OBJECTS WITHOUT STATISTICS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="objects_without_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Objects Without Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner            FORMAT a50    HEAD 'Owner'            ENTMAP off
COLUMN object_type      FORMAT a20    HEAD 'Object Type'      ENTMAP off
COLUMN object_name                    HEAD 'Object Name'      ENTMAP off
COLUMN partition_name   FORMAT a35    HEAD 'Partition Name'   ENTMAP off

BREAK ON report
COMPUTE count LABEL '<font color="#990000"><b>Total: </b></font>' OF object_name ON report

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
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |           - TABLES SUFFERING FROM ROW CHAINING/MIGRATION -                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tables_suffering_from_row_chaining_migration"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tables Suffering From Row Chaining/Migration</b></font><hr align="left" width="460">

prompt <b><font color="#990000">NOTE</font>: Tables must have statistics gathered</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                                          HEADING 'Owner'           ENTMAP off
COLUMN table_name                                     HEADING 'Table Name'      ENTMAP off
COLUMN partition_name                                 HEADING 'Partition Name'  ENTMAP off
COLUMN num_rows           FORMAT 999,999,999,999,999  HEADING 'Total Rows'      ENTMAP off
COLUMN pct_chained_rows   FORMAT a65                  HEADING '% Chained Rows'  ENTMAP off
COLUMN avg_row_length     FORMAT 999,999,999,999,999  HEADING 'Avg Row Length'  ENTMAP off

SELECT
    owner                               owner
  , table_name                          table_name
  , ''                                  partition_name
  , num_rows                            num_rows
  , '<div align="right">' || ROUND((chain_cnt/num_rows)*100, 2) || '%</div>' pct_chained_rows
  , avg_row_len                         avg_row_length
FROM
    (select
         owner
       , table_name
       , chain_cnt
       , num_rows
       , avg_row_len 
     from
         sys.dba_tables 
     where
           chain_cnt is not null 
       and num_rows is not null 
       and chain_cnt > 0 
       and num_rows > 0 
       and owner != 'SYS')  
UNION ALL 
SELECT
    table_owner                         owner
  , table_name                          table_name
  , partition_name                      partition_name
  , num_rows                            num_rows
  , '<div align="right">' || ROUND((chain_cnt/num_rows)*100, 2) || '%</div>' pct_chained_rows
  , avg_row_len                         avg_row_length
FROM
    (select
         table_owner
       , table_name
       , partition_name
       , chain_cnt
       , num_rows
       , avg_row_len 
     from
         sys.dba_tab_partitions 
     where
           chain_cnt is not null 
       and num_rows is not null 
       and chain_cnt > 0 
       and num_rows > 0 
       and table_owner != 'SYS') b 
WHERE
    (chain_cnt/num_rows)*100 > 10;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |             - USERS WITH DEFAULT TABLESPACE - (SYSTEM) -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_default_tablespace_defined_as_system"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With Default Tablespace - (SYSTEM)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                 FORMAT a75    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a125   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a125   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a75    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a75    HEADING 'Account Status'          ENTMAP off

SELECT
    '<font color="#336699"><b>' || username             || '</font></b>'                  username
  , '<div align="left">'        || default_tablespace   || '</div>'                       default_tablespace
  , '<div align="left">'        || temporary_tablespace || '</div>'                       temporary_tablespace
  , '<div align="right">'       || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  created
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="center"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM
    dba_users
WHERE
    default_tablespace = 'SYSTEM'
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |          - Users With Default Temporary Tablespace - (SYSTEM) -            |
-- +----------------------------------------------------------------------------+

prompt <a name="users_with_default_temporary_tablespace_as_system"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Users With Default Temporary Tablespace - (SYSTEM)</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN username                 FORMAT a75    HEADING 'Username'                ENTMAP off
COLUMN default_tablespace       FORMAT a125   HEADING 'Default Tablespace'      ENTMAP off
COLUMN temporary_tablespace     FORMAT a125   HEADING 'Temporary Tablespace'    ENTMAP off
COLUMN created                  FORMAT a75    HEADING 'Created'                 ENTMAP off
COLUMN account_status           FORMAT a75    HEADING 'Account Status'          ENTMAP off

SELECT
    '<font color="#336699"><b>'  || username             || '</font></b>'                  username
  , '<div align="center">'       || default_tablespace   || '</div>'                       default_tablespace
  , '<div align="center">'       || temporary_tablespace || '</div>'                       temporary_tablespace
  , '<div align="right">'        || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  created
  , DECODE(   account_status
            , 'OPEN'
            , '<div align="center"><b><font color="darkgreen">' || account_status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || account_status || '</font></b></div>') account_status
FROM
    dba_users
WHERE
    temporary_tablespace = 'SYSTEM'
ORDER BY
    username;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                  - OBJECTS IN THE SYSTEM TABLESPACE -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="objects_in_the_system_tablespace"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Objects in the SYSTEM Tablespace</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner               FORMAT a75                   HEADING 'Owner'           ENTMAP off
COLUMN segment_name        FORMAT a125                  HEADING 'Segment Name'    ENTMAP off
COLUMN segment_type        FORMAT a75                   HEADING 'Type'            ENTMAP off
COLUMN tablespace_name     FORMAT a125                  HEADING 'Tablespace'      ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999   HEADING 'Bytes|Alloc'     ENTMAP off
COLUMN extents             FORMAT 999,999,999,999,999   HEADING 'Extents'         ENTMAP off
COLUMN max_extents         FORMAT 999,999,999,999,999   HEADING 'Max|Ext'         ENTMAP off
COLUMN initial_extent      FORMAT 999,999,999,999,999   HEADING 'Initial|Ext'     ENTMAP off
COLUMN next_extent         FORMAT 999,999,999,999,999   HEADING 'Next|Ext'        ENTMAP off
COLUMN pct_increase        FORMAT 999,999,999,999,999   HEADING 'Pct|Inc'         ENTMAP off

BREAK ON report
COMPUTE count LABEL '<font color="#990000"><b>Total Count: </b></font>' OF segment_name ON report
COMPUTE sum   LABEL '<font color="#990000"><b>Total Bytes: </b></font>' OF bytes ON report

SELECT
    owner
  , segment_name
  , segment_type
  , tablespace_name
  , bytes
  , extents
  , initial_extent
  , next_extent
  , pct_increase
FROM
    dba_segments
WHERE
      owner NOT IN ('SYS','SYSTEM')
  AND tablespace_name = 'SYSTEM'
ORDER BY
    owner
  , segment_name
  , extents DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |         <<<<<     ONLINE ANALYTICAL PROCESSING - (OLAP)    >>>>>           |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                              - DIMENSIONS -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_dimensions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dimensions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75     HEADING 'Owner'            ENTMAP off
COLUMN dimension_name     FORMAT a75     HEADING 'Dimension Name'   ENTMAP off
COLUMN invalid            FORMAT a75     HEADING 'Invalid?'         ENTMAP off
COLUMN compile_state      FORMAT a75     HEADING 'Compile State'    ENTMAP off
COLUMN revision                          HEADING 'Revision'         ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || dd.owner || '</b></font></div>'    owner
  , dd.dimension_name                                                                   dimension_name
  , '<div align="center">' || dd.invalid  || '</div>'                                   invalid   
  , DECODE(   dd.compile_state
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || dd.compile_state || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || dd.compile_state || '</b></font></div>' ) compile_state
  , '<div align="center">' || dd.revision || '</div>'                                   revision
FROM
    dba_dimensions      dd
ORDER BY
    dd.owner
  , dd.dimension_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - DIMENSION LEVELS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_dimension_levels"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dimension Levels</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75                HEADING 'Owner'            ENTMAP off
COLUMN dimension_name     FORMAT a75                HEADING 'Dimension Name'   ENTMAP off
COLUMN level_name         FORMAT a75                HEADING 'Level Name'       ENTMAP off
COLUMN level_table_name   FORMAT a75                HEADING 'Source Table'     ENTMAP off
COLUMN column_name        FORMAT a75                HEADING 'Column Name(s)'   ENTMAP off
COLUMN key_position       FORMAT a75                HEADING 'Column Position'  ENTMAP off

BREAK ON owner ON dimension_name ON level_name ON level_table_name

SELECT
    '<div align="left"><font color="#336699"><b>' || d.owner || '</b></font></div>'  owner
  , d.dimension_name                                    dimension_name
  , l.level_name                                        level_name
  , l.detailobj_owner || '.' || l.detailobj_name        level_table_name
  , k.column_name                                       column_name
  , '<div align="center">' || TO_CHAR(k.key_position, '999,999') || '</div>'  key_position
FROM
    dba_dimensions          d
  , dba_dim_levels          l
  , dba_dim_level_key       k
WHERE
      d.owner          = l.owner
  AND d.dimension_name = l.dimension_name
  AND d.owner          = k.owner
  AND d.dimension_name = k.dimension_name
  AND l.level_name     = k.level_name
ORDER by
    l.owner
  , l.dimension_name
  , l.level_name
  , level_table_name
  , k.key_position;



prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - DIMENSION ATTRIBUTES -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_dimension_attributes"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dimension Attributes</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75     HEADING 'Owner'                    ENTMAP off
COLUMN dimension_name     FORMAT a75     HEADING 'Dimension Name'           ENTMAP off
COLUMN level_name         FORMAT a75     HEADING 'Level Name'               ENTMAP off
COLUMN level_table_name   FORMAT a75     HEADING 'Source Table'             ENTMAP off
COLUMN column_name        FORMAT a75     HEADING 'Attribute Source Column'  ENTMAP off
COLUMN inferred           FORMAT a75     HEADING 'Inferred?'                ENTMAP off

BREAK ON report ON owner ON dimension_name ON level_name

SELECT
    '<div align="left"><font color="#336699"><b>' || d.owner || '</b></font></div>'  owner
  , d.dimension_name                                 dimension_name
  , l.level_name                                     level_name
  , l.detailobj_owner || '.' || l.detailobj_name     level_table_name
  , a.column_name                                    column_name
  , '<div align="center">' || a.inferred  || '</div>'  inferred
FROM
    dba_dimensions          d
  , dba_dim_levels          l
  , dba_dim_attributes      a
WHERE
      d.owner          = l.owner
  AND d.dimension_name = l.dimension_name
  AND d.owner          = a.owner
  AND d.dimension_name = a.dimension_name
  AND l.level_name     = a.level_name
ORDER by
    l.owner
  , l.dimension_name
  , l.level_name
  , level_table_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - DIMENSION HIERARCHIES -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_dimension_hierarchies"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Dimension Hierarchies</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a75              HEADING 'Owner'                ENTMAP off
COLUMN dimension_name     FORMAT a75              HEADING 'Dimension Name'       ENTMAP off
COLUMN hierarchy_name     FORMAT a75              HEADING 'Hierarchy Name'       ENTMAP off
COLUMN parent_level_name  FORMAT a75              HEADING 'Parent Level'         ENTMAP off
COLUMN child_level_name   FORMAT a75              HEADING 'Child Level'          ENTMAP off
COLUMN position           FORMAT a75              HEADING 'Position'             ENTMAP off
COLUMN join_key_id        FORMAT a75              HEADING 'Join Key ID'          ENTMAP off

BREAK ON owner ON dimension_name ON hierarchy_name

SELECT
    '<div align="left"><font color="#336699"><b>' || d.owner || '</b></font></div>'  owner
  , d.dimension_name                                                      dimension_name
  , h.hierarchy_name                                                      hierarchy_name
  , c.parent_level_name                                                   parent_level_name
  , c.child_level_name                                                    child_level_name
  , '<div align="center">' || TO_CHAR(c.position, '999,999') || '</div>'  position
  , '<div align="center">' || NVL(c.join_key_id,'<br>')      || '</div>'  join_key_id
FROM
    dba_dimensions          d
  , dba_dim_hierarchies     h
  , dba_dim_child_of        c
WHERE
      d.owner          = h.owner
  AND d.dimension_name = h.dimension_name
  AND d.owner          = c.owner
  AND d.dimension_name = c.dimension_name
  AND h.hierarchy_name = c.hierarchy_name
ORDER BY
    d.owner
  , d.dimension_name
  , h.hierarchy_name
  , c.position DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                 - CUBES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_cubes"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Cubes</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                    FORMAT a75                 HEADING 'Owner'            ENTMAP off
COLUMN cube_name                FORMAT a75                 HEADING 'Cube Name'        ENTMAP off
COLUMN invalid                  FORMAT a75                 HEADING 'Valid?'           ENTMAP off
COLUMN display_name             FORMAT a75                 HEADING 'Display Name'     ENTMAP off
COLUMN description              FORMAT a275                HEADING 'Description'      ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || c.owner || '</b></font></div>'  owner
  , c.cube_name                                                                      cube_name
  , DECODE(   c.invalid
            , 'N'
            , '<div align="center"><font color="darkgreen"><b>Yes</b></font></div>'
            , '<div align="center"><font color="#990000"><b>No</b></font></div>' )   invalid
  , c.display_name                                                                   display_name 
  , REPLACE(REPLACE(c.description, '<', '\&lt;'), '>', '\&gt;')                      description
FROM
    dba_olap_cubes   c
ORDER BY
    c.owner
  , c.cube_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - MATERIALIZED VIEWS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_olap_materialized_views"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Materialized Views</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                FORMAT a75     HEADING 'Owner'               ENTMAP off
COLUMN mview_name           FORMAT a75     HEADING 'MView|Name'          ENTMAP off
COLUMN master_link          FORMAT a75     HEADING 'Master|Link'         ENTMAP off
COLUMN updatable            FORMAT a75     HEADING 'Updatable?'          ENTMAP off
COLUMN update_log           FORMAT a75     HEADING 'Update|Log'          ENTMAP off
COLUMN rewrite_enabled      FORMAT a75     HEADING 'Rewrite|Enabled?'    ENTMAP off
COLUMN refresh_mode         FORMAT a75     HEADING 'Refresh|Mode'        ENTMAP off
COLUMN refresh_method       FORMAT a75     HEADING 'Refresh|Method'      ENTMAP off
COLUMN build_mode           FORMAT a75     HEADING 'Build|Mode'          ENTMAP off
COLUMN fast_refreshable     FORMAT a75     HEADING 'Fast|Refreshable'    ENTMAP off
COLUMN last_refresh_type    FORMAT a75     HEADING 'Last Refresh|Type'   ENTMAP off
COLUMN last_refresh_date    FORMAT a75     HEADING 'Last Refresh|Date'   ENTMAP off
COLUMN staleness            FORMAT a75     HEADING 'Staleness'           ENTMAP off
COLUMN compile_state        FORMAT a75     HEADING 'Compile State'       ENTMAP off

BREAK ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || m.owner || '</b></font></div>'                    owner
  , m.mview_name                                                                                       mview_name
  , m.master_link                                                                                      master_link
  , '<div align="center">' || NVL(m.updatable,'<br>')        || '</div>'                               updatable
  , update_log                                                                                         update_log
  , '<div align="center">' || NVL(m.rewrite_enabled,'<br>')  || '</div>'                               rewrite_enabled
  , m.refresh_mode                                                                                     refresh_mode
  , m.refresh_method                                                                                   refresh_method
  , m.build_mode                                                                                       build_mode
  , m.fast_refreshable                                                                                 fast_refreshable
  , m.last_refresh_type                                                                                last_refresh_type
  , '<div nowrap align="right">' || TO_CHAR(m.last_refresh_date, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  last_refresh_date
  , m.staleness                                                                                        staleness
  , DECODE(   m.compile_state
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || m.compile_state || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || m.compile_state || '</b></font></div>' ) compile_state
FROM
  dba_mviews     m 
ORDER BY
    owner
  , mview_name
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - MATERIALIZED VIEW LOGS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_olap_materialized_view_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Materialized View Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN log_owner            FORMAT a75     HEADING 'Log Owner'            ENTMAP off
COLUMN log_table            FORMAT a75     HEADING 'Log Table'            ENTMAP off
COLUMN master               FORMAT a75     HEADING 'Master'               ENTMAP off
COLUMN log_trigger          FORMAT a75     HEADING 'Log Trigger'          ENTMAP off
COLUMN rowids               FORMAT a75     HEADING 'Rowids?'              ENTMAP off
COLUMN primary_key          FORMAT a75     HEADING 'Primary Key?'         ENTMAP off
COLUMN object_id            FORMAT a75     HEADING 'Object ID?'           ENTMAP off
COLUMN filter_columns       FORMAT a75     HEADING 'Filter Columns?'      ENTMAP off
COLUMN sequence             FORMAT a75     HEADING 'Sequence?'            ENTMAP off
COLUMN include_new_values   FORMAT a75     HEADING 'Include New Values?'  ENTMAP off

BREAK ON log_owner

SELECT
    '<div align="left"><font color="#336699"><b>' || ml.log_owner || '</b></font></div>'       log_owner
  , ml.log_table                                                              log_table
  , ml.master                                                                 master
  , ml.log_trigger                                                            log_trigger
  , '<div align="center">' || NVL(ml.rowids,'<br>')              || '</div>'  rowids
  , '<div align="center">' || NVL(ml.primary_key,'<br>')         || '</div>'  primary_key
  , '<div align="center">' || NVL(ml.object_id,'<br>')           || '</div>'  object_id
  , '<div align="center">' || NVL(ml.filter_columns,'<br>')      || '</div>'  filter_columns
  , '<div align="center">' || NVL(ml.sequence,'<br>')            || '</div>'  sequence
  , '<div align="center">' || NVL(ml.include_new_values,'<br>')  || '</div>'  include_new_values
FROM
    dba_mview_logs  ml
ORDER BY
    ml.log_owner
  , ml.master;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                     <<<<<     NETWORKING    >>>>>                          |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                     - MTS DISPATCHER STATISTICS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="mts_dispatcher_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>MTS Dispatcher Statistics</b></font><hr align="left" width="460">

prompt <b>Dispatcher rate</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                         HEADING 'Name'                  ENTMAP off
COLUMN avg_loop_rate                HEADING 'Avg|Loop|Rate'         ENTMAP off
COLUMN avg_event_rate               HEADING 'Avg|Event|Rate'        ENTMAP off
COLUMN avg_events_per_loop          HEADING 'Avg|Events|Per|Loop'   ENTMAP off
COLUMN avg_msg_rate                 HEADING 'Avg|Msg|Rate'          ENTMAP off
COLUMN avg_svr_buf_rate             HEADING 'Avg|Svr|Buf|Rate'      ENTMAP off
COLUMN avg_svr_byte_rate            HEADING 'Avg|Svr|Byte|Rate'     ENTMAP off
COLUMN avg_svr_byte_per_buf         HEADING 'Avg|Svr|Byte|Per|Buf'  ENTMAP off
COLUMN avg_clt_buf_rate             HEADING 'Avg|Clt|Buf|Rate'      ENTMAP off
COLUMN avg_clt_byte_rate            HEADING 'Avg|Clt|Byte|Rate'     ENTMAP off
COLUMN avg_clt_byte_per_buf         HEADING 'Avg|Clt|Byte|Per|Buf'  ENTMAP off
COLUMN avg_buf_rate                 HEADING 'Avg|Buf|Rate'          ENTMAP off
COLUMN avg_byte_rate                HEADING 'Avg|Byte|Rate'         ENTMAP off
COLUMN avg_byte_per_buf             HEADING 'Avg|Byte|Per|Buf'      ENTMAP off
COLUMN avg_in_connect_rate          HEADING 'Avg|In|Connect|Rate'   ENTMAP off
COLUMN avg_out_connect_rate         HEADING 'Avg|Out|Connect|Rate'  ENTMAP off
COLUMN avg_reconnect_rate           HEADING 'Avg|Reconnect|Rate'    ENTMAP off

SELECT
    name
  , avg_loop_rate
  , avg_event_rate
  , avg_events_per_loop
  , avg_msg_rate
  , avg_svr_buf_rate
  , avg_svr_byte_rate
  , avg_svr_byte_per_buf
  , avg_clt_buf_rate
  , avg_clt_byte_rate
  , avg_clt_byte_per_buf
  , avg_buf_rate
  , avg_byte_rate
  , avg_byte_per_buf
  , avg_in_connect_rate
  , avg_out_connect_rate
  , avg_reconnect_rate
FROM
    v$dispatcher_rate
ORDER BY
    name;



COLUMN protocol           HEADING 'Protocol'         ENTMAP off
COLUMN total_busy_rate    HEADING 'Total Busy Rate'  ENTMAP off

prompt <b>Dispatcher busy rate</b>

SELECT
    a.network protocol
  , (SUM(a.BUSY) / (SUM(a.BUSY) + SUM(a.IDLE))) total_busy_rate
FROM
    v$dispatcher a
GROUP BY
    a.network;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |             - MTS DISPATCHER RESPONSE QUEUE WAIT STATS -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="mts_dispatcher_response_queue_wait_stats"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>MTS Dispatcher Response Queue Wait Stats</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN type        HEADING 'Type'                         ENTMAP off
COLUMN avg_wait    HEADING 'Avg Wait Time Per Response'   ENTMAP off

SELECT
    a.type
  , DECODE( SUM(a.totalq), 0, 'NO RESPONSES', SUM(a.wait)/SUM(a.totalq) || ' HUNDREDTHS OF SECONDS') avg_wait
FROM
    v$queue a
WHERE
    a.type='DISPATCHER'
GROUP BY
    a.type;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



-- +----------------------------------------------------------------------------+
-- |                  - MTS SHARED SERVER WAIT STATISTICS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="mts_shared_server_wait_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>MTS Shared Server Wait Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN avg_wait        HEADING 'Average Wait Time Per Request'  ENTMAP off

SELECT
    DECODE(a.totalq, 0, 'No Requests', a.wait/a.totalq || ' HUNDREDTHS OF SECONDS') avg_wait
FROM
    v$queue a
WHERE
    a.type='COMMON';

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     REPLICATION    >>>>>                        |
-- |                                                                            |
-- +============================================================================+


-- +----------------------------------------------------------------------------+
-- |                         - REPLICATION SUMMARY -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="replication_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Replication Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN gname                HEADING 'Current Database Name'       ENTMAP off
COLUMN admin_request        HEADING '# Admin. Requests'           ENTMAP off
COLUMN status               HEADING '# Admin. Request Errors'     ENTMAP off
COLUMN df_txn               HEADING '# Def. Trans'                ENTMAP off
COLUMN df_error             HEADING '# Def. Tran Errors'          ENTMAP off
COLUMN complete             HEADING '# Complete Trans in Queue'   ENTMAP off

SELECT
    g.global_name           gname
  , d.admin_request         admin_request
  , e.status                status
  , dt.tran                 df_txn
  , de.error                df_error
  , c.complete              complete
FROM
    (select global_name from global_name)  g
  , (select count(id) admin_request 
     from sys.dba_repcatlog)               d
  , (select count(status) status 
     from sys.dba_repcatlog 
     where status = 'ERROR')               e
  , (select count(*) tran 
     from deftrandest)                     dt
  , (select count(*) error 
	from deferror)                     de
  , (select count(a.deferred_tran_id) complete 
     from deftran a 
     where a.deferred_tran_id not in 
           (select b.deferred_tran_id 
            from deftrandest b)
    )                                      c
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - DEFERRED TRANSACTIONS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="deferred_transactions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Deferred Transactions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN source          HEADING 'Source'              ENTMAP off
COLUMN dest            HEADING 'Target'              ENTMAP off
COLUMN trans           HEADING '# Def. Trans'        ENTMAP off
COLUMN errors          HEADING '# Def. Tran Errors'  ENTMAP off

SELECT
    source
  , dest
  , trans
  , errors
FROM
    (select
         e.origin_tran_db   source
       , e.destination      dest
       , 'n/a'              trans
       , to_char(count(*))  errors
     from
         deferror e 
     group by
         e.origin_tran_db
       , e.destination 
     union  
     select
         g.global_name      source
       , d.dblink           dest
       , to_char(count(*))  trans
       , 'n/a'              errors
     from
         (select global_name from global_name)  g
       ,  deftran                               t
       ,  deftrandest                           d 
     where
          d.deferred_tran_id = t.deferred_tran_id 
     group by
          g.global_name, d.dblink 
     );

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - ADMINISTRATIVE REQUEST JOBS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="administrative_request_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Administrative Request Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job                          HEADING 'Job ID'             ENTMAP off
COLUMN priv_user                    HEADING 'Privilege Schema'   ENTMAP off
COLUMN what            FORMAT a175  HEADING 'Definition'         ENTMAP off
COLUMN status                       HEADING 'Status'             ENTMAP off
COLUMN next_date       FORMAT a75   HEADING 'Start'              ENTMAP off
COLUMN interval                     HEADING 'Interval'           ENTMAP off

SELECT
    job                                            job
  , priv_user                                      priv_user
  , what                                           what
  , DECODE(broken, 'Y', 'Broken', 'Normal')        status
  , '<div nowrap align="right">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , interval
FROM
    sys.dba_jobs 
WHERE
    what LIKE '%dbms_repcat.do_deferred_repcat_admin%' 
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - INITIALIZATION PARAMETERS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="rep_initialization_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Initialization Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN pname             FORMAT a75  HEADING 'Parameter Name'    ENTMAP off
COLUMN value             FORMAT a75  HEADING 'Value'             ENTMAP off
COLUMN isdefault         FORMAT a75  HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable  FORMAT a75  HEADING 'Is Dynamic?'       ENTMAP off

SELECT
    DECODE(   isdefault
            , 'FALSE'
            , '<b><font color="#336699">' || SUBSTR(name,0,512) || '</font></b>'
            , '<b><font color="#336699">' || SUBSTR(name,0,512) || '</font></b>' ) pname
  , DECODE(   isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || SUBSTR(value,0,512) || '</b></font>'
            , SUBSTR(value,0,512) ) value
  , DECODE(   isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || isdefault || '</b></font></div>'
            , '<div align="right">' || isdefault || '</div>') isdefault
  , DECODE(   isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || issys_modifiable || '</b></font></div>'
            , '<div align="right">' || issys_modifiable || '</div>') issys_modifiable
FROM
    v$parameter 
WHERE
    name IN (   'compatible'
              , 'commit_point_strength'
              , 'dblink_encrypt_login'
              , 'distributed_lock_timeout'
              , 'distributed_recovery_connection_hold_time'
              , 'distributed_transactions'
              , 'global_names'
              , 'job_queue_interval'
              , 'job_queue_processes'
              , 'max_transaction_branches'
              , 'open_links'
              , 'open_links_per_instance'
              , 'parallel_automatic_tuning'
              , 'parallel_max_servers'
              , 'parallel_min_servers'
              , 'parallel_server_idle_time'
              , 'processes'
              , 'remote_dependencies_mode'
              , 'replication_dependency_tracking'
              , 'shared_pool_size'
              , 'utl_file_dir'
  )
ORDER BY name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - (SCHEDULE) - PURGE JOBS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="schedule_purge_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Schedule) - Purge Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job                          HEADING 'Job ID'            ENTMAP off
COLUMN priv_user                    HEADING 'Privilege Schema'  ENTMAP off
COLUMN status                       HEADING 'Status'            ENTMAP off
COLUMN next_date       FORMAT a75   HEADING 'Start'             ENTMAP off
COLUMN interval                     HEADING 'Interval'          ENTMAP off

SELECT
    j.job                                           job
  , j.priv_user                                     priv_user
  , decode(broken, 'Y', 'Broken', 'Normal')         status
  , '<div nowrap align="right">' || NVL(TO_CHAR(s.next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , s.interval                                      interval 
FROM
    sys.defschedule   s
  , sys.dba_jobs      j 
WHERE
      s.dblink = (select global_name from global_name) 
  AND s.interval is not null AND s.job = j.job 
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - (SCHEDULE) - PUSH JOBS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="schedule_push_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Schedule) - Push Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job                         HEADING 'Job ID'             ENTMAP off
COLUMN priv_user                   HEADING 'Privilege Schema'   ENTMAP off
COLUMN dblink                      HEADING 'Target'             ENTMAP off
COLUMN broken                      HEADING 'Status'             ENTMAP off
COLUMN next_date      FORMAT a75   HEADING 'Start'              ENTMAP off
COLUMN interval                    HEADING 'Interval'           ENTMAP off

SELECT
    j.job                                          job
  , j.priv_user                                    priv_user
  , s.dblink                                       dblink
  , decode(j.broken, 'Y', 'Broken', 'Normal')      broken
  , '<div nowrap align="right">' || NVL(TO_CHAR(s.next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , s.interval                                     interval
FROM
    sys.defschedule  s
  , sys.dba_jobs     j 
WHERE
      s.dblink != (select global_name from global_name) 
  AND s.interval is not null
  AND s.job = j.job 
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - (SCHEDULE) - REFRESH JOBS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="schedule_refresh_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Schedule) - Refresh Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN job                           HEADING 'Job ID'             ENTMAP off
COLUMN priv_user                     HEADING 'Privilege Schema'   ENTMAP off
COLUMN refresh_group                 HEADING 'Refresh Group'      ENTMAP off
COLUMN broken                        HEADING 'Status'             ENTMAP off
COLUMN next_date         FORMAT a75  HEADING 'Start'              ENTMAP off
COLUMN interval                      HEADING 'Interval'           ENTMAP off

SELECT
    j.job                                          job
  , j.priv_user                                    priv_user
  , r.rowner || '.' || r.rname                     refresh_group
  , decode(j.broken, 'Y', 'Broken', 'Normal')      broken
  , '<div nowrap align="right">' || NVL(TO_CHAR(j.next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , j.interval                                     interval
FROM
    sys.dba_refresh  r
  , sys.dba_jobs     j
WHERE
    r.job = j.job 
order by
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - (MULTI-MASTER) - MASTER GROUPS -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="multimaster_master_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Multi-Master) - Master Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            HEADING 'Master Group'             ENTMAP off
COLUMN num_def_trans                   HEADING '# Def. Trans'             ENTMAP off
COLUMN num_tran_errors                 HEADING '# Def. Tran Errors'       ENTMAP off
COLUMN num_admin_requests              HEADING '# Admin. Requests'        ENTMAP off
COLUMN num_admin_request_errors        HEADING '# Admin. Request Errors'  ENTMAP off

SELECT
    g.gname          name
  , NVL(t.cnt1, 0)   num_def_trans
  , NVL(ie.cnt2, 0)  num_tran_errors
  , NVL(a.cnt3, 0)   num_admin_requests
  , NVL(b.cnt4, 0)   num_admin_request_errors
FROM 
    (select distinct gname 
     from dba_repgroup 
     where master='Y')                             g
  , (select
         rog                        rog
       , count(dt.deferred_tran_id) cnt1 
     from (select distinct
               ro.gname            rog
             , d.deferred_tran_id  dft 
           from
               dba_repobject  ro
             , defcall        d
             , deftrANDest    td 
           where
                 ro.sname = d.schemaname 
             AND ro.oname = d.packagename 
             AND ro.type in ('TABLE', 'PACKAGE', 'SNAPSHOT') 
             AND td.deferred_tran_id = d.deferred_tran_id 
          ) t0, deftrANDest dt 
     where
         dt.deferred_tran_id = dft 
     group by rog 
    )                                              t
  , (select distinct
         ro.gname
       , count(distinct e.deferred_tran_id) cnt2 
     from
         dba_repobject  ro
       , defcall        d
       , deferror       e 
     where
           ro.sname = d.schemaname 
       AND ro.oname = d.packagename 
       AND ro.type in ('TABLE', 'PACKAGE', 'SNAPSHOT') 
       AND e.deferred_tran_id = d.deferred_tran_id 
       AND e.callno = d.callno 
     group by ro.gname 
    )                                              ie
  , (select gname, count(*) cnt3 
     from dba_repcatlog 
     group by gname 
    )                                              a
  , (select gname, count(*) cnt4 
     from dba_repcatlog  
     where status = 'ERROR' 
     group BY gname 
    )                                              b 
WHERE
      g.gname = ie.gname (+) 
  AND g.gname = t.rog (+) 
  AND g.gname = a.gname (+) 
  AND g.gname = b.gname (+) 
ORDER BY
    g.gname;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |               - (MULTI-MASTER) - MASTER GROUPS AND SITES -                 |
-- +----------------------------------------------------------------------------+

prompt <a name="multimaster_master_groups_and_sites"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Multi-Master) - Master Groups and Sites</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN master_group                  HEADING 'Master Group'            ENTMAP off
COLUMN sites                         HEADING 'Sites'                   ENTMAP off
COLUMN master_definition_site        HEADING 'Master Definition Site'  ENTMAP off

SELECT
    gname                                     master_group
  , dblink                                    sites
  , DECODE(masterdef, 'Y', 'YES', 'N', 'NO')  master_definition_site
FROM
    sys.dba_repsites
WHERE
      master = 'Y' 
  AND gname NOT IN (
                      SELECT gname from sys.dba_repsites 
                      WHERE snapmaster = 'Y'
                    )
ORDER BY
    gname;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |               - (MATERIALIZED VIEW) - MASTER SITE SUMMARY -                |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_master_site_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Master Site Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN mgroup          HEADING '# of Master Groups'          ENTMAP off
COLUMN mvgroup         HEADING '# of Registered MV Groups'   ENTMAP off
COLUMN mv              HEADING '# of Registered MVs'         ENTMAP off
COLUMN mvlog           HEADING '# of MV Logs'                ENTMAP off
COLUMN template        HEADING '# of Templates'              ENTMAP off

SELECT
    a.mgroup      mgroup
  , b.mvgroup     mvgroup
  , c.mv          mv
  , d.mvlog       mvlog
  , e.template    template
FROM 
    (select count(g.gname) mgroup 
     from sys.dba_repgroup g, sys.dba_repsites s 
     where g.master = 'Y' 
       and s.master = 'Y' 
       and g.gname = s.gname 
       and s.my_dblink = 'Y')                      a
  , (select count(*) mvGROUP 
     from sys.dba_registered_snapshot_groups)      b
  , (select count(*) mv 
     from sys.dba_registered_snapshots)            c
  , (select count(*) mvlog 
     from sys.dba_snapshot_logs)                   d
  , (select count(*) template 
     from sys.dba_repcat_refresh_templates)        e
/



COLUMN log_table                       HEADING 'Log Table'         ENTMAP off
COLUMN log_owner                       HEADING 'Log Owner'         ENTMAP off
COLUMN master                          HEADING 'Master'            ENTMAP off
COLUMN rowids           FORMAT a10     HEADING 'Row ID'            ENTMAP off
COLUMN primary_key      FORMAT a13     HEADING 'Primary Key'       ENTMAP off
COLUMN filter_columns   FORMAT a15     HEADING 'Filter Columns'    ENTMAP off

SELECT distinct
    log_table
  , log_owner
  , master
  , rowids
  , primary_key
  , filter_columns
FROM
    sys.dba_snapshot_logs 
ORDER BY
    1
/



COLUMN ref_temp_name           HEADING 'Refresh Template Name'      ENTMAP off
COLUMN owner                   HEADING 'Owner'                      ENTMAP off
COLUMN public_template         HEADING 'Public'                     ENTMAP off
COLUMN instantiated            HEADING '# of Instantiated Sites'    ENTMAP off
COLUMN template_comment        HEADING 'Comment'                    ENTMAP off

SELECT distinct 
    rt.refresh_template_name                   ref_temp_name
  , owner                                      owner
  , decode(public_template, 'Y', 'YES', 'NO')  public_template
  , rs.instantiated                            instantiated
  , rt.template_comment                        template_comment
FROM
    sys.dba_repcat_refresh_templates rt
  , (SELECT y.refresh_template_name, count(x.status) instantiated  
     FROM sys.dba_repcat_template_sites x, sys.dba_repcat_refresh_templates y 
     WHERE x.refresh_template_name(+) = y.refresh_template_name 
     GROUP BY y.refresh_template_name) rs 
WHERE
    rt.refresh_template_name(+) = rs.refresh_template_name 
ORDER BY
    1
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |               - (MATERIALIZED VIEW) - MASTER SITE LOGS -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_master_site_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Master Site Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN log_table                       HEADING 'Log Table'         ENTMAP off
COLUMN log_owner                       HEADING 'Log Owner'         ENTMAP off
COLUMN master                          HEADING 'Master'            ENTMAP off
COLUMN rowids           FORMAT a10     HEADING 'Row ID'            ENTMAP off
COLUMN primary_key      FORMAT a13     HEADING 'Primary Key'       ENTMAP off
COLUMN filter_columns   FORMAT a15     HEADING 'Filter Columns'    ENTMAP off

SELECT distinct 
    log_table
  , log_owner
  , master
  , rowids
  , primary_key
  , filter_columns
FROM
    sys.dba_snapshot_logs 
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |             - (MATERIALIZED VIEW) - MASTER SITE TEMPLATES -                |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_master_site_templates"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Master Site Templates</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN refresh_template_name        HEADING 'Refresh Template Name'     ENTMAP off
COLUMN owner                        HEADING 'Owner'                     ENTMAP off
COLUMN public_template              HEADING 'Public'                    ENTMAP off
COLUMN instantiated                 HEADING '# of Instantiated Sites'   ENTMAP off
COLUMN template_comment             HEADING 'Comment'                   ENTMAP off

SELECT distinct
    rt.refresh_template_name                   refresh_template_name
  , owner                                      owner
  , decode(public_template, 'Y', 'YES', 'NO')  public_template
  , rs.instantiated                            instantiated
  , rt.template_comment                        template_comment
FROM
    sys.dba_repcat_refresh_templates rt
  , ( SELECT y.refresh_template_name, count(x.status) instantiated  
      FROM sys.dba_repcat_template_sites x, sys.dba_repcat_refresh_templates y 
      WHERE x.refresh_template_name(+) = y.refresh_template_name 
      GROUP BY y.refresh_template_name
    ) rs 
WHERE
    rt.refresh_template_name(+) = rs.refresh_template_name 
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - (MATERIALIZED VIEW) - SUMMARY -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN mvgroup        HEADING '# of Materialized View Groups'  ENTMAP off
COLUMN mv             HEADING '# of Materialized Views'        ENTMAP off
COLUMN rgroup         HEADING '# of Refresh Groups'            ENTMAP off

SELECT
    a.mvgroup    mvgroup
  , b.mv         mv
  , c.rgroup     rgroup
FROM
    (  select count(s.gname) mvgroup 
       from sys.dba_repsites s 
       where s.snapmaster = 'Y')         a
  , (  select count(*) mv 
       from sys.dba_snapshots)           b
  , (  select count(*) rgroup
       from sys.dba_refresh)             c
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - (MATERIALIZED VIEW) - GROUPS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN gname              HEADING 'Name'           ENTMAP off
COLUMN dblink             HEADING 'Master'         ENTMAP off
COLUMN propagation        HEADING 'Propagation'    ENTMAP off
COLUMN remark             HEADING 'Remark'         ENTMAP off

SELECT
    s.gname                                      gname
  , s.dblink                                     dblink
  , decode(s.prop_updates, 0, 'Async', 'Sync')   propagation
  , g.schema_comment                             remark
FROM
    sys.dba_repsites  s
  , sys.dba_repgroup  g
WHERE
      s.gname = g.gname
  and s.snapmaster = 'Y'
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |              - (MATERIALIZED VIEW) - MATERIALIZED VIEWS -                  |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_materialized_views"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Materialized Views</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                      HEADING 'Owner'           ENTMAP off
COLUMN name                       HEADING 'Name'            ENTMAP off
COLUMN master_owner               HEADING 'Master Owner'    ENTMAP off
COLUMN master_table               HEADING 'Master Table'    ENTMAP off
COLUMN master_link                HEADING 'Master Link'     ENTMAP off
COLUMN type                       HEADING 'Type'            ENTMAP off
COLUMN updatable      FORMAT a11  HEADING 'Updatable?'      ENTMAP off
COLUMN can_use_log    FORMAT a13  HEADING 'Can Use Log?'    ENTMAP off
COLUMN last_refresh   FORMAT a75  HEADING 'Last Refresh'    ENTMAP off

SELECT
    s.owner                                                                         owner
  , s.name                                                                          name
  , s.master_owner                                                                  master_owner
  , s.master                                                                        master_table
  , s.master_link                                                                   master_link
  , nls_initcap(s.type)                                                             type
  , '<div align="center">' || DECODE(s.updatable, 'YES', 'YES', 'NO')  || '</div>'  updatable
  , '<div align="center">' || DECODE(s.can_use_log,'YES', 'YES', 'NO') || '</div>'  can_use_log
  , '<div nowrap align="right">' || NVL(TO_CHAR(m.last_refresh_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   last_refresh
FROM
    sys.dba_snapshots  s
  , sys.dba_mviews     m 
WHERE
      s.name = m.mview_name 
  AND s.owner = m.owner
ORDER BY
    1
  , 2
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                 - (MATERIALIZED VIEW) - REFRESH GROUPS -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_refresh_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Refresh Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         FORMAT a75   HEADING 'Owner'        ENTMAP off
COLUMN name          FORMAT a75   HEADING 'Name'         ENTMAP off
COLUMN broken        FORMAT a75   HEADING 'Broken?'      ENTMAP off
COLUMN next_date     FORMAT a75   HEADING 'Next Date'    ENTMAP off
COLUMN interval      FORMAT a75   HEADING 'Interval'     ENTMAP off

SELECT
    '<div align="left">'   || rowner || '</div>'  owner
  , '<div align="left">'   || rname  || '</div>'  name
  , '<div align="center">' || broken || '</div>'  broken
  , '<div nowrap align="right">' || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , interval                                      interval
FROM
    sys.dba_refresh 
ORDER BY
    1
  , 2
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>








-- +----------------------------------------------------------------------------+
-- |                            - END OF REPORT -                               |
-- +----------------------------------------------------------------------------+

SPOOL OFF

SET MARKUP HTML OFF

SET TERMOUT ON

prompt 
prompt Output written to: &FileName._&_dbname._&_spool_time..html

EXIT;
