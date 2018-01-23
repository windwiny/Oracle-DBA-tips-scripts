-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_snapshot_database_10g.sql                                   |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format) on  |
-- |            all database metrics including installed options, storage,      |
-- |            performance data, and security.                                 |
-- | VERSION  : This script was designed for Oracle Database 10g Release 2.     |
-- |            Although this script will also work with Oracle Database 10g    |
-- |            Release 1, several sections will error out from missing tables  |
-- |            or columns.                                                     |
-- | USAGE    :                                                                 |
-- |                                                                            |
-- |    sqlplus -s <dba>/<password>@<TNS string> @dba_snapshot_database_10g.sql |
-- |                                                                            |
-- | TESTING  : This script has been successfully tested on the following       |
-- |            platforms:                                                      |
-- |                                                                            |
-- |              Linux      : Oracle Database 10.2.0.3.0                       |
-- |              Linux      : Oracle RAC 10.2.0.3.0                            |
-- |              Solaris    : Oracle Database 10.2.0.2.0                       |
-- |              Solaris    : Oracle Database 10.2.0.3.0                       |
-- |              Windows XP : Oracle Database 10.2.0.3.0                       |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

prompt 
prompt +-----------------------------------------------------------------------------------------+
prompt |                             Snapshot Database 10g Release 2                             |
prompt |-----------------------------------------------------------------------------------------+
prompt | Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved. (www.idevelopment.info) |
prompt +-----------------------------------------------------------------------------------------+
prompt
prompt Creating database report.
prompt This script must be run as a user with SYSDBA privileges.
prompt This process can take several minutes to complete.
prompt 

define reportHeader="<font size=+3 color=darkgreen><b>Snapshot Database 10<i>g</i> Release 2</b></font><hr>Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved. (<a target=""_blank"" href=""http://www.idevelopment.info"">www.idevelopment.info</a>)<p>"


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

define fileName=dba_snapshot_database_10g
define versionNumber=5.3


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone
FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN platform_id NEW_VALUE _platform_id NOPRINT
SELECT platform_id platform_id FROM v$database;

COLUMN platform_name NEW_VALUE _platform_name NOPRINT
SELECT platform_name platform_name FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

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

prompt <a name=top></a>
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
<td nowrap align="center" width="25%"><a class="link" href="#feature_usage_statistics">Feature Usage Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#high_water_mark_statistics">High Water Mark Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#instance_overview">Instance Overview</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_overview">Database Overview</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#initialization_parameters">Initialization Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#control_files">Control Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#control_file_records">Control File Records</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#online_redo_logs">Online Redo Logs</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_switches">Redo Log Switches</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#outstanding_alerts">Outstanding Alerts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#statistics_level">Statistics Level</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Scheduler / Jobs</th></tr> -
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
<td nowrap align="center" width="25%"><a class="link" href="#undo_retention_parameters">UNDO Retention Parameters</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Backups</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_jobs">RMAN Backup Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_configuration">RMAN Configuration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_sets">RMAN Backup Sets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_pieces">RMAN Backup Pieces</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_control_files">RMAN Backup Control Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_spfile">RMAN Backup SPFILE</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_mode">Archiving Mode</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archive_destinations">Archive Destinations</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_instance_parameters">Archiving Instance Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_history">Archiving History</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flash_recovery_area_parameters">Flash Recovery Area Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flash_recovery_area_status">Flash Recovery Area Status</a></td> -
</tr>


prompt -
<tr><th colspan="4">Flashback Technologies</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_retention_parameters">UNDO Retention Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_parameters">Flashback Database Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_status">Flashback Database Status</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_redo_time_matrix">Flashback Database Redo Time Matrix</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_recycle_bin">Recycle Bin</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Performance</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_information">SGA Information</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_target_advice">SGA Target Advice</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_asmm_dynamic_components">SGA (ASMM) Dynamic Components</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#pga_target_advice">PGA Target Advice</a></td> -
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
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_traces">Enabled Traces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_aggregations">Enabled Aggregations</a></td> -
</tr>


prompt -
<tr><th colspan="4">Automatic Workload Repository - (AWR)</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_workload_repository_information">Workload Repository Information</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_settings">AWR Snapshot Settings</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_list">AWR Snapshot List</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_size_estimates">AWR Snapshot Size Estimates</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_baselines">AWR Baselines</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr> -
<tr><th colspan="4">Sessions</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#current_sessions">Current Sessions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#user_session_matrix">User Session Matrix</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_traces">Enabled Traces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_aggregations">Enabled Aggregations</a></td> -
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
<td nowrap align="center" width="25%"><a class="link" href="#top_100_segments_by_size">Top 100 Segments (by size)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_100_segments_by_extents">Top 100 Segments (by number of extents)</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directories">Directories</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directory_privileges">Directory Privileges</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_libraries">Libraries</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_types">Types</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_attributes">Type Attributes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_methods">Type Methods</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_collections">Collections</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_lob_segments">LOB Segments</a></td> -
</tr>


prompt -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_unable_to_extend">Objects Unable to Extend</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_which_are_nearing_maxextents">Objects Which Are Nearing MAXEXTENTS</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#invalid_objects">Invalid Objects</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#procedural_object_errors">Procedural Object Errors</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_without_statistics">Objects Without Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#tables_suffering_from_row_chaining_migration">Tables Suffering From Row Chaining/Migration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_tablespace_defined_as_system">Users With Default Tablespace - (SYSTEM)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_temporary_tablespace_as_system">Users With Default Temp Tablespace - (SYSTEM)</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_in_the_system_tablespace">Objects in the SYSTEM Tablespace</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_recycle_bin">Recycle Bin</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
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
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_view_refresh_groups">Materialized View Refresh Groups</a></td> -
</tr>


prompt -
<tr><th colspan="4">Data Pump</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_jobs">Data Pump Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_sessions">Data Pump Sessions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_job_progress">Data Pump Job Progress</a></td> -
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


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database and Instance Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - REPORT HEADER -                               |
-- +----------------------------------------------------------------------------+

prompt 
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Header</b></font><hr align="left" width="460">

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_dbname._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Snapshot Database Version</th><td width="80%"><tt>&versionNumber</tt></td></tr> -
<tr><th align="left" width="20%">Run Date / Time / Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Platform Name / ID</th><td width="80%"><tt>&_platform_name / &_platform_id</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Database Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
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

COLUMN comp_id       FORMAT a75   HEADING 'Component ID'       ENTMAP off
COLUMN comp_name     FORMAT a75   HEADING 'Component Name'     ENTMAP off
COLUMN version                    HEADING 'Version'            ENTMAP off
COLUMN status        FORMAT a75   HEADING 'Status'             ENTMAP off
COLUMN modified      FORMAT a75   HEADING 'Modified'           ENTMAP off
COLUMN control                    HEADING 'Control'            ENTMAP off
COLUMN schema                     HEADING 'Schema'             ENTMAP off
COLUMN procedure                  HEADING 'Procedure'          ENTMAP off

SELECT
    '<font color="#336699"><b>' || comp_id    || '</b></font>' comp_id
  , '<div nowrap>' || comp_name || '</div>'                    comp_name
  , version
  , DECODE(   status
            , 'VALID',   '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INVALID', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,            '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , '<div nowrap align="right">' || modified || '</div>'                      modified
  , control
  , schema
  , procedure
FROM dba_registry
ORDER BY comp_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - FEATURE USAGE STATISTICS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="feature_usage_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Feature Usage Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN feature_name          FORMAT a115    HEADING 'Feature|Name'
COLUMN version               FORMAT a75     HEADING 'Version'
COLUMN detected_usages       FORMAT a75     HEADING 'Detected|Usages'
COLUMN total_samples         FORMAT a75     HEADING 'Total|Samples'
COLUMN currently_used        FORMAT a60     HEADING 'Currently|Used'
COLUMN first_usage_date      FORMAT a95     HEADING 'First Usage|Date'
COLUMN last_usage_date       FORMAT a95     HEADING 'Last Usage|Date'
COLUMN last_sample_date      FORMAT a95     HEADING 'Last Sample|Date'
COLUMN next_sample_date      FORMAT a95     HEADING 'Next Sample|Date'

SELECT
    '<div align="left"><font color="#336699"><b>' || name || '</b></font></div>'      feature_name
  , DECODE(   detected_usages
            , 0
            , version 
            , '<font color="#663300"><b>' || version || '</b></font>')                  version
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(detected_usages), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(detected_usages), '<br>') || '</b></font></div>') detected_usages
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(total_samples), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(total_samples), '<br>') || '</b></font></div>')   total_samples
  , DECODE(   detected_usages
            , 0
            , '<div align="center">' || NVL(currently_used, '<br>') || '</div>'
            , '<div align="center"><font color="#663300"><b>' || NVL(currently_used, '<br>') || '</b></font></div>')           currently_used
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(first_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(first_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   first_usage_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(last_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(last_usage_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')    last_usage_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR(last_sample_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR(last_sample_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   last_sample_date
  , DECODE(   detected_usages
            , 0
            , '<div align="right">' || NVL(TO_CHAR((last_sample_date+SAMPLE_INTERVAL/60/60/24), 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'
            , '<div align="right"><font color="#663300"><b>' || NVL(TO_CHAR((last_sample_date+SAMPLE_INTERVAL/60/60/24), 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</b></font></div>')   next_sample_date
FROM dba_feature_usage_statistics
ORDER BY name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - HIGH WATER MARK STATISTICS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="high_water_mark_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>High Water Mark Statistics</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN statistic_name        FORMAT a115                    HEADING 'Statistic Name'
COLUMN version               FORMAT a62                     HEADING 'Version'
COLUMN highwater             FORMAT 9,999,999,999,999,999   HEADING 'Highwater'
COLUMN last_value            FORMAT 9,999,999,999,999,999   HEADING 'Last Value'
COLUMN description           FORMAT a120                    HEADING 'Description'

SELECT
    '<div align="left"><font color="#336699"><b>' || name || '</b></font></div>'  statistic_name
  , '<div align="right">' || version || '</div>'                                  version
  , highwater                                                                     highwater
  , last_value                                                                    last_value
  , description                                                                   description
FROM dba_high_water_mark_statistics
ORDER BY name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - INSTANCE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="instance_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Instance Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print       FORMAT a75    HEADING 'Instance|Name'       ENTMAP off
COLUMN instance_number_print     FORMAT a75    HEADING 'Instance|Num'        ENTMAP off
COLUMN thread_number_print                     HEADING 'Thread|Num'          ENTMAP off
COLUMN host_name_print           FORMAT a75    HEADING 'Host|Name'           ENTMAP off
COLUMN version                                 HEADING 'Oracle|Version'      ENTMAP off
COLUMN start_time                FORMAT a75    HEADING 'Start|Time'          ENTMAP off
COLUMN uptime                                  HEADING 'Uptime|(in days)'    ENTMAP off
COLUMN parallel                  FORMAT a75    HEADING 'Parallel - (RAC)'    ENTMAP off
COLUMN instance_status           FORMAT a75    HEADING 'Instance|Status'     ENTMAP off
COLUMN database_status           FORMAT a75    HEADING 'Database|Status'     ENTMAP off
COLUMN logins                    FORMAT a75    HEADING 'Logins'              ENTMAP off
COLUMN archiver                  FORMAT a75    HEADING 'Archiver'            ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || instance_name || '</b></font></div>'         instance_name_print
  , '<div align="center">' || instance_number || '</div>'                                           instance_number_print
  , '<div align="center">' || thread#         || '</div>'                                           thread_number_print
  , '<div align="center">' || host_name       || '</div>'                                           host_name_print
  , '<div align="center">' || version         || '</div>'                                           version
  , '<div align="center">' || TO_CHAR(startup_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , ROUND(TO_CHAR(SYSDATE-startup_time), 2)                                                         uptime
  , '<div align="center">' || parallel        || '</div>'                                           parallel
  , '<div align="center">' || status          || '</div>'                                           instance_status
  , '<div align="center">' || logins          || '</div>'                                           logins
  , DECODE(   archiver
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || archiver || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || archiver || '</font></b></div>') archiver
FROM gv$instance
ORDER BY instance_number;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="database_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            FORMAT a75     HEADING 'Database|Name'              ENTMAP off
COLUMN dbid                                           HEADING 'Database|ID'                ENTMAP off
COLUMN db_unique_name                                 HEADING 'Database|Unique Name'       ENTMAP off
COLUMN creation_date                                  HEADING 'Creation|Date'              ENTMAP off
COLUMN platform_name_print                            HEADING 'Platform|Name'              ENTMAP off
COLUMN current_scn                                    HEADING 'Current|SCN'                ENTMAP off
COLUMN log_mode                                       HEADING 'Log|Mode'                   ENTMAP off
COLUMN open_mode                                      HEADING 'Open|Mode'                  ENTMAP off
COLUMN force_logging                                  HEADING 'Force|Logging'              ENTMAP off
COLUMN flashback_on                                   HEADING 'Flashback|On?'              ENTMAP off
COLUMN controlfile_type                               HEADING 'Controlfile|Type'           ENTMAP off
COLUMN last_open_incarnation_number                   HEADING 'Last Open|Incarnation Num'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>'  || name  || '</b></font></div>'          name
  , '<div align="center">' || dbid                   || '</div>'                              dbid
  , '<div align="center">' || db_unique_name         || '</div>'                              db_unique_name
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'           creation_date
  , '<div align="center">' || platform_name          || '</div>'                              platform_name_print
  , '<div align="center">' || current_scn            || '</div>'                              current_scn
  , '<div align="center">' || log_mode               || '</div>'                              log_mode
  , '<div align="center">' || open_mode              || '</div>'                              open_mode
  , '<div align="center">' || force_logging          || '</div>'                              force_logging
  , '<div align="center">' || flashback_on           || '</div>'                              flashback_on
  , '<div align="center">' || controlfile_type       || '</div>'                              controlfile_type
  , '<div align="center">' || last_open_incarnation# || '</div>'                              last_open_incarnation_number
FROM v$database;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - INITIALIZATION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="initialization_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Initialization Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN spfile  HEADING 'SPFILE Usage'

SELECT
  'This database '||
  DECODE(   (1-SIGN(1-SIGN(count(*) - 0)))
          , 1
          , '<font color="#663300"><b>IS</b></font>'
          , '<font color="#990000"><b>IS NOT</b></font>') ||
  ' using an SPFILE.'spfile
FROM v$spparameter
WHERE value IS NOT null;


COLUMN pname                FORMAT a75    HEADING 'Parameter Name'    ENTMAP off
COLUMN instance_name_print  FORMAT a45    HEADING 'Instance Name'     ENTMAP off
COLUMN value                FORMAT a75    HEADING 'Value'             ENTMAP off
COLUMN isdefault            FORMAT a75    HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable     FORMAT a75    HEADING 'Is Dynamic?'       ENTMAP off

BREAK ON report ON pname

SELECT
    DECODE(   p.isdefault
            , 'FALSE'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>' )    pname
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || i.instance_name || '</b></font>'
            , i.instance_name )                                                         instance_name_print
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || SUBSTR(p.value,0,512) || '</b></font>'
            , SUBSTR(p.value,0,512) ) value
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="center"><font color="#663300"><b>' || p.isdefault || '</b></font></div>'
            , '<div align="center">'                          || p.isdefault || '</div>')                         isdefault
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || p.issys_modifiable || '</b></font></div>'
            , '<div align="right">'                          || p.issys_modifiable || '</div>')                  issys_modifiable
FROM
    gv$parameter p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    p.name
  , i.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - CONTROL FILES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                           HEADING 'Controlfile Name'  ENTMAP off
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP off
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'                                                                      name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
  , '<div align="right">' || TO_CHAR(block_size *  file_size_blks, '999,999,999,999') || '</div>'    file_size
FROM 
    v$controlfile c
ORDER BY
    c.name;

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

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>'   of record_size records_total bytes_alloc records_used bytes_used ON report
COMPUTE avg LABEL '<font color="#990000"><b>Average: </b></font>' of pct_used      ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || type || '</b></font></div>'  type
  , record_size                                       record_size
  , records_total                                     records_total
  , (records_total * record_size)                     bytes_alloc
  , records_used                                      records_used
  , (records_used * record_size)                      bytes_used
  , NVL(records_used/records_total * 100, 0)          pct_used
  , first_index                                       first_index
  , last_index                                        last_index
  , last_recid                                        last_recid
FROM v$controlfile_record_section
ORDER BY type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a95                HEADING 'Instance Name'    ENTMAP off
COLUMN thread_number_print  FORMAT a95                HEADING 'Thread Number'    ENTMAP off
COLUMN groupno                                        HEADING 'Group Number'     ENTMAP off
COLUMN member                                         HEADING 'Member'           ENTMAP off
COLUMN redo_file_type       FORMAT a75                HEADING 'Redo Type'        ENTMAP off
COLUMN log_status           FORMAT a75                HEADING 'Log Status'       ENTMAP off
COLUMN bytes                FORMAT 999,999,999,999    HEADING 'Bytes'            ENTMAP off
COLUMN archived             FORMAT a75                HEADING 'Archived?'        ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">' || i.thread# || '</div>'                                                  thread_number_print
  , f.group#                                                                                         groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    gv$logfile  f
  , gv$log      l
  , gv$instance i
WHERE
      f.group#  = l.group#
  AND l.thread# = i.thread#
  AND i.inst_id = f.inst_id
  AND f.inst_id = l.inst_id
ORDER BY
    i.instance_name
  , f.group#
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
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - OUTSTANDING ALERTS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="outstanding_alerts"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Outstanding Alerts</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN severity          FORMAT a75       HEADING 'Severity'        ENTMAP off
COLUMN target_name       FORMAT a75       HEADING 'Target Name'     ENTMAP off
COLUMN target_type       FORMAT a75       HEADING 'Target Type'     ENTMAP off
COLUMN category          FORMAT a75       HEADING 'Category'        ENTMAP off
COLUMN name              FORMAT a75       HEADING 'Name'            ENTMAP off
COLUMN message           FORMAT a125      HEADING 'Message'         ENTMAP off
COLUMN alert_triggered   FORMAT a75       HEADING 'Alert Triggered' ENTMAP off

SELECT
    DECODE(   alert_state
            , 'Critical'
            , '<div align="center"><b><font color="#990000">' || alert_state || '</font></b></div>'
            , '<div align="center"><b><font color="#336699">' || alert_state || '</font></b></div>')  severity
  , target_name                                                   target_name
  , (CASE target_type
         WHEN 'oracle_listener' THEN 'Oracle Listener'
         WHEN 'rac_database'    THEN 'Cluster Database'
         WHEN 'cluster'         THEN 'Clusterware'
         WHEN 'host'            THEN 'Host'
         WHEN 'osm_instance'    THEN 'OSM Instance'
         WHEN 'oracle_database' THEN 'Database Instance'
         WHEN 'oracle_emd'      THEN 'Oracle EMD'
         WHEN 'oracle_emrep'    THEN 'Oracle EMREP'
     ELSE
          target_type
     END)                                                         target_type
  , metric_label                                                  category
  , column_label                                                  name
  , message                                                       message
  , '<div nowrap align="right">' || TO_CHAR(collection_timestamp, 'mm/dd/yyyy HH24:MI:SS') || '</div>'  alert_triggered
FROM
    mgmt$alert_current
ORDER BY
    alert_state
  , collection_timestamp;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - STATISTICS LEVEL -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="statistics_level"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Statistics Level</b></font><hr align="left" width="460">

prompt "Automatic Database Management" was first introduced in Oracle10<i>g</i> where the Oracle database
prompt can now automatically perform many of the routine monitoring and administrative activities that had
prompt to be manually executed by the DBA in previous versions. Several of the new components that make
prompt up this new feature include (1) Automatic Workload Repository (2) Automatic Database Diagnostic
prompt Monitoring (3) Automatic Shared Memory Management and (4) Automatic UNDO Retention Tuning. All
prompt of these new components can only be enabled when the STATISTICS_LEVEL initialization parameter
prompt is set to TYPICAL (the default) or ALL. A value of BASIC turns off these components and disables
prompt all self-tuning capabilities of the database. The view V$STATISTICS_LEVEL shows the statistic 
prompt component, description, and at what level of the STATISTICS_LEVEL parameter the
prompt component is enabled.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print     FORMAT a95    HEADING 'Instance Name'         ENTMAP off
COLUMN statistics_name         FORMAT a95    HEADING 'Statistics Name'       ENTMAP off
COLUMN session_status          FORMAT a95    HEADING 'Session Status'        ENTMAP off
COLUMN system_status           FORMAT a95    HEADING 'System Status'         ENTMAP off
COLUMN activation_level        FORMAT a95    HEADING 'Activation Level'      ENTMAP off
COLUMN statistics_view_name    FORMAT a95    HEADING 'Statistics View Name'  ENTMAP off
COLUMN session_settable        FORMAT a95    HEADING 'Session Settable?'     ENTMAP off

BREAK ON report ON instance_name_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name    || '</b></font></div>'               instance_name_print
  , '<div align="left" nowrap>'                     || s.statistics_name  || '</div>'                          statistics_name
  , DECODE(   s.session_status
            , 'ENABLED'
            , '<div align="center"><b><font color="darkgreen">' || s.session_status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || s.session_status || '</font></b></div>')    session_status
  , DECODE(   s.system_status
            , 'ENABLED'
            , '<div align="center"><b><font color="darkgreen">' || s.system_status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || s.system_status || '</font></b></div>')     system_status
  , (CASE s.activation_level
         WHEN 'TYPICAL' THEN '<div align="center"><b><font color="darkgreen">' || s.activation_level || '</font></b></div>'
         WHEN 'ALL'     THEN '<div align="center"><b><font color="darkblue">'  || s.activation_level || '</font></b></div>'
         WHEN 'BASIC'   THEN '<div align="center"><b><font color="#990000">'   || s.activation_level || '</font></b></div>'
     ELSE
         '<div align="center"><b><font color="#663300">'   || s.activation_level || '</font></b></div>'
     END)                                                      activation_level
  , s.statistics_view_name                                     statistics_view_name
  , '<div align="center">' || s.session_settable || '</div>'   session_settable
FROM
    gv$statistics_level s
  , gv$instance  i
WHERE
      s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.statistics_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                  <<<<<     SCHEDULER / JOBS     >>>>>                      |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Scheduler / Jobs</u></b></font></center>


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
            , '<b><font color="#990000"><div align="center">' || NVL(failures, 0) || '</div></font></b>'
            , '<div align="center">'                          || NVL(failures, 0) || '</div>')    failures
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


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Storage</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespaces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name                                    HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'Tablespace Size'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'Free (in bytes)'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'Used (in bytes)'   ENTMAP off
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF ts_size used free ON report

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
ORDER BY 2;

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
COLUMN increment_by    FORMAT 999,999,999,999,999   HEADING 'Next'                          ENTMAP off
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

COLUMN month        FORMAT a75                  HEADING 'Month'
COLUMN growth       FORMAT 999,999,999,999,999  HEADING 'Growth (bytes)'

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

break on report
compute sum label '<font color="#990000"><b>Total:</b></font>' of largest_ext smallest_ext total_free pieces on report

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
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' of seg_count bytes ON report

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

break on report on owner
compute sum label '<font color="#990000"><b>Total: </b></font>' of seg_count bytes on report

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


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>UNDO Segments</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                       - UNDO RETENTION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_retention_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Retention Parameters</b></font><hr align="left" width="460">

prompt <b>undo_retention is specified in minutes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'undo_retention' THEN '<div nowrap align="right">' || TO_CHAR(TO_NUMBER(p.value)/60, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || p.value || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name LIKE 'undo%'
ORDER BY
    i.instance_name
  , p.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - UNDO SEGMENTS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Segments</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a75              HEADING 'Instance Name'      ENTMAP off
COLUMN tablespace    FORMAT a85              HEADING 'Tablspace'          ENTMAP off
COLUMN roll_name                             HEADING 'UNDO Segment Name'  ENTMAP off
COLUMN in_extents                            HEADING 'Init/Next Extents'  ENTMAP off
COLUMN m_extents                             HEADING 'Min/Max Extents'    ENTMAP off
COLUMN status                                HEADING 'Status'             ENTMAP off
COLUMN wraps         FORMAT 999,999,999      HEADING 'Wraps'              ENTMAP off
COLUMN shrinks       FORMAT 999,999,999      HEADING 'Shrinks'            ENTMAP off
COLUMN opt           FORMAT 999,999,999,999  HEADING 'Opt. Size'          ENTMAP off
COLUMN bytes         FORMAT 999,999,999,999  HEADING 'Bytes'              ENTMAP off
COLUMN extents       FORMAT 999,999,999      HEADING 'Extents'            ENTMAP off

CLEAR COMPUTES BREAKS

BREAK ON report ON instance_name ON tablespace
-- COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF bytes extents shrinks wraps ON report

SELECT
    '<div nowrap><font color="#336699"><b>' ||  NVL(i.instance_name, '<br>')     || '</b></font></div>'  instance_name
  , '<div nowrap><font color="#336699"><b>' ||  a.tablespace_name                || '</b></font></div>'  tablespace
  , '<div nowrap>'                          ||  a.owner || '.' || a.segment_name || '</div>'             roll_name
  , '<div align="right">'     ||
    TO_CHAR(a.initial_extent) || ' / ' ||
    TO_CHAR(a.next_extent)    ||
    '</div>'                                                                in_extents
  , '<div align="right">'     ||
    TO_CHAR(a.min_extents)    || ' / ' ||
    TO_CHAR(a.max_extents)    ||
    '</div>'                                                                m_extents
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
  , gv$parameter p
  , gv$instance  i
WHERE
       a.segment_name  = b.segment_name
  AND  a.segment_name  = c.name (+)
  AND  c.usn           = d.usn (+)
  AND  p.name (+)      = 'undo_tablespace'
  AND  p.value (+)     = a.tablespace_name
  AND  p.inst_id       = i.inst_id (+)
ORDER BY
    a.tablespace_name
  , a.segment_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - UNDO SEGMENT CONTENTION -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="undo_segment_contention"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>UNDO Segment Contention</b></font><hr align="left" width="460">

prompt <b>UNDO statistics from V$ROLLSTAT - (ordered by waits)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN roll_name                             HEADING 'UNDO Segment Name'   ENTMAP off
COLUMN gets             FORMAT 999,999,999   HEADING 'Gets'                ENTMAP off
COLUMN waits            FORMAT 999,999,999   HEADING 'Waits'               ENTMAP off
COLUMN immediate_misses FORMAT 999,999,999   HEADING 'Immediate Misses'    ENTMAP off
COLUMN hit_ratio                             HEADING 'Hit Ratio'           ENTMAP off

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
prompt <b>Wait statistics</b>

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
-- |                      <<<<<     BACKUPS     >>>>>                           |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Backups</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP JOBS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Jobs</b></font><hr align="left" width="460">

prompt <b>Last 10 RMAN backup jobs</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN backup_name           FORMAT a130   HEADING 'Backup Name'          ENTMAP off
COLUMN start_time            FORMAT a75    HEADING 'Start Time'           ENTMAP off
COLUMN elapsed_time          FORMAT a75    HEADING 'Elapsed Time'         ENTMAP off
COLUMN status                              HEADING 'Status'               ENTMAP off
COLUMN input_type                          HEADING 'Input Type'           ENTMAP off
COLUMN output_device_type                  HEADING 'Output Devices'       ENTMAP off
COLUMN input_size                          HEADING 'Input Size'           ENTMAP off
COLUMN output_size                         HEADING 'Output Size'          ENTMAP off
COLUMN output_rate_per_sec                 HEADING 'Output Rate Per Sec'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || r.command_id                                   || '</font></b></div>'  backup_name
  , '<div nowrap align="right">'            || TO_CHAR(r.start_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , '<div nowrap align="right">'            || r.time_taken_display                           || '</div>'             elapsed_time
  , DECODE(   r.status
            , 'COMPLETED'
            , '<div align="center"><b><font color="darkgreen">' || r.status || '</font></b></div>'
            , 'RUNNING'
            , '<div align="center"><b><font color="#000099">'   || r.status || '</font></b></div>'
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || r.status || '</font></b></div>'
            , '<div align="center"><b><font color="#663300">'   || r.status || '</font></b></div>'
    )                                                                                       status
  , r.input_type                                                                            input_type
  , r.output_device_type                                                                    output_device_type
  , '<div nowrap align="right">' || r.input_bytes_display           || '</div>'  input_size
  , '<div nowrap align="right">' || r.output_bytes_display          || '</div>'  output_size
  , '<div nowrap align="right">' || r.output_bytes_per_sec_display  || '</div>'  output_rate_per_sec
FROM
    (select
         command_id
       , start_time
       , time_taken_display
       , status
       , input_type
       , output_device_type
       , input_bytes_display
       , output_bytes_display
       , output_bytes_per_sec_display
     from v$rman_backup_job_details
     order by start_time DESC
    ) r
WHERE
    rownum < 11; 

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - RMAN CONFIGURATION -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_configuration"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Configuration</b></font><hr align="left" width="460">

prompt <b>All non-default RMAN configuration settings</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name     FORMAT a130   HEADING 'Name'   ENTMAP off
COLUMN value                  HEADING 'Value'  ENTMAP off

SELECT
    '<div nowrap><b><font color="#336699">' || name || '</font></b></div>'   name
  , value
FROM
    v$rman_configuration
ORDER BY
    name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - RMAN BACKUP SETS -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_sets"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Sets</b></font><hr align="left" width="460">

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
  , '<div align="center">' ||
    DECODE(bs.controlfile_included, 'NO', '-', bs.controlfile_included) || '</div>'                           controlfile_included
  , '<div align="center">' || NVL(sp.spfile_included, '-') || '</div>'                                        spfile_included
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
-- |                          - RMAN BACKUP PIECES -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_pieces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Pieces</b></font><hr align="left" width="460">

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
-- |                       - RMAN BACKUP CONTROL FILES -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup Control Files</b></font><hr align="left" width="460">

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
-- |                           - RMAN BACKUP SPFILE -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="rman_backup_spfile"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>RMAN Backup SPFILE</b></font><hr align="left" width="460">

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




-- +----------------------------------------------------------------------------+
-- |                             - ARCHIVING MODE -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_mode"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Mode</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN db_log_mode                  FORMAT a95                HEADING 'Database|Log Mode'             ENTMAP off
COLUMN log_archive_start            FORMAT a95                HEADING 'Automatic|Archival'            ENTMAP off
COLUMN oldest_online_log_sequence   FORMAT 999999999999999    HEADING 'Oldest Online |Log Sequence'   ENTMAP off
COLUMN current_log_seq              FORMAT 999999999999999    HEADING 'Current |Log Sequence'         ENTMAP off

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
         DECODE(   log_mode
                 , 'ARCHIVELOG', 'Enabled'
                 , 'NOARCHIVELOG', 'Disabled')   log_archive_start
     from v$database
    ) p
  , (select a.sequence#   current_log_seq
     from   v$log a
     where  a.status = 'CURRENT'
       and thread# = &_thread_number
    ) c
  , (select min(a.sequence#) oldest_online_log_sequence
     from   v$log a
     where  thread# = &_thread_number
    ) o
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - ARCHIVE DESTINATIONS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="archive_destinations"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archive Destinations</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dest_id                                                HEADING 'Destination|ID'            ENTMAP off
COLUMN dest_name                                              HEADING 'Destination|Name'          ENTMAP off
COLUMN destination                                            HEADING 'Destination'               ENTMAP off
COLUMN status                                                 HEADING 'Status'                    ENTMAP off
COLUMN schedule                                               HEADING 'Schedule'                  ENTMAP off
COLUMN archiver                                               HEADING 'Archiver'                  ENTMAP off
COLUMN log_sequence                 FORMAT 999999999999999    HEADING 'Current Log|Sequence'      ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || a.dest_id || '</b></font></div>'    dest_id
  , a.dest_name                               dest_name
  , a.destination                             destination
  , DECODE(   a.status
            , 'VALID',    '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INACTIVE', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,             '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , DECODE(   a.schedule
            , 'ACTIVE',   '<div align="center"><b><font color="darkgreen">' || schedule || '</font></b></div>'
            , 'INACTIVE', '<div align="center"><b><font color="#990000">'   || schedule || '</font></b></div>'
            ,             '<div align="center"><b><font color="#663300">'   || schedule || '</font></b></div>' ) schedule
  , a.archiver                                archiver
  , a.log_sequence                            log_sequence
FROM
    v$archive_dest a
ORDER BY
    a.dest_id
/


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - ARCHIVING INSTANCE PARAMETERS -                       |
-- +----------------------------------------------------------------------------+

prompt <a name="archiving_instance_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Archiving Instance Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name      HEADING 'Parameter Name'   ENTMAP off
COLUMN value     HEADING 'Parameter Value'  ENTMAP off

SELECT
    '<b><font color="#336699">' || a.name || '</font></b>'    name
  , a.value                                                   value
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

COLUMN thread#          FORMAT a79                   HEADING 'Thread#'           ENTMAP off
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

BREAK ON report ON thread#

SELECT
    '<div align="center"><b><font color="#336699">' || thread#   || '</font></b></div>'  thread#
  , '<div align="center"><b><font color="#336699">' || sequence# || '</font></b></div>'  sequence#
  , name
  , first_change#
  , '<div align="right" nowrap>' || TO_CHAR(first_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>' first_time
  , next_change#
  , '<div align="right" nowrap>' || TO_CHAR(next_time, 'mm/dd/yyyy HH24:MI:SS')  || '</div>' next_time
  , (blocks * block_size)                            log_size
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
    thread#
  , sequence#;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - FLASH RECOVERY AREA PARAMETERS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="flash_recovery_area_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flash Recovery Area Parameters</b></font><hr align="left" width="460">

prompt <b>db_recovery_file_dest_size is specified in bytes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'db_recovery_file_dest_size' THEN '<div nowrap align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || NVL(p.value, '(null)') || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('db_recovery_file_dest_size', 'db_recovery_file_dest')
ORDER BY
    1
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - FLASH RECOVERY AREA STATUS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="flash_recovery_area_status"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flash Recovery Area Status</b></font><hr align="left" width="460">

prompt <b>Current location, disk quota, space in use, space reclaimable by deleting files, and number of files in the Flash Recovery Area</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name               FORMAT a75                  HEADING 'Name'               ENTMAP off
COLUMN space_limit        FORMAT 99,999,999,999,999   HEADING 'Space Limit'        ENTMAP off
COLUMN space_used         FORMAT 99,999,999,999,999   HEADING 'Space Used'         ENTMAP off
COLUMN space_used_pct     FORMAT 999.99               HEADING '% Used'             ENTMAP off
COLUMN space_reclaimable  FORMAT 99,999,999,999,999   HEADING 'Space Reclaimable'  ENTMAP off
COLUMN pct_reclaimable    FORMAT 999.99               HEADING '% Reclaimable'      ENTMAP off
COLUMN number_of_files    FORMAT 999,999              HEADING 'Number of Files'    ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || name || '</b></font></div>'    name
  , space_limit                                                                       space_limit
  , space_used                                                                        space_used
  , ROUND((space_used / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2)        space_used_pct
  , space_reclaimable                                                                 space_reclaimable
  , ROUND((space_reclaimable / DECODE(space_limit, 0, 0.000001, space_limit))*100, 2) pct_reclaimable
  , number_of_files                                                                   number_of_files
FROM
    v$recovery_file_dest
ORDER BY
    name;


CLEAR COLUMNS BREAKS COMPUTES

COLUMN file_type                  FORMAT a75     HEADING 'File Type'
COLUMN percent_space_used                        HEADING 'Percent Space Used'
COLUMN percent_space_reclaimable                 HEADING 'Percent Space Reclaimable'
COLUMN number_of_files            FORMAT 999,999 HEADING 'Number of Files'

SELECT
    '<div align="center"><font color="#336699"><b>' || file_type || '</b></font></div>' file_type
  , percent_space_used                                                                  percent_space_used
  , percent_space_reclaimable                                                           percent_space_reclaimable
  , number_of_files                                                                     number_of_files
FROM
    v$flash_recovery_area_usage;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |               <<<<<     FLASHBACK TECHNOLOGIES     >>>>>                   |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Flashback Technologies</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                     - FLASHBACK DATABASE PARAMETERS -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="flashback_database_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flashback Database Parameters</b></font><hr align="left" width="460">

prompt <b>db_flashback_retention_target is specified in minutes</b>
prompt <b>db_recovery_file_dest_size is specified in bytes</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print   FORMAT a95    HEADING 'Instance Name'     ENTMAP off
COLUMN thread_number_print   FORMAT a95    HEADING 'Thread Number'     ENTMAP off
COLUMN name                  FORMAT a125   HEADING 'Name'              ENTMAP off
COLUMN value                               HEADING 'Value'             ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">'                          || i.thread#       || '</div>'                   thread_number_print
  , '<div nowrap>'                                  || p.name          || '</div>'                   name
  , (CASE p.name
         WHEN 'db_recovery_file_dest_size'    THEN '<div nowrap align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
         WHEN 'db_flashback_retention_target' THEN '<div nowrap align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div nowrap align="right">' || NVL(p.value, '(null)') || '</div>'
     END)                                                                                            value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('db_flashback_retention_target', 'db_recovery_file_dest_size', 'db_recovery_file_dest')
ORDER BY
    1
  , 3;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - FLASHBACK DATABASE STATUS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="flashback_database_status"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flashback Database Status</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dbid                                HEADING 'DB ID'              ENTMAP off
COLUMN name             FORMAT A75         HEADING 'DB Name'            ENTMAP off
COLUMN log_mode         FORMAT A75         HEADING 'Log Mode'           ENTMAP off
COLUMN flashback_on     FORMAT A75         HEADING 'Flashback DB On?'   ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || dbid          || '</b></font></div>'  dbid
  , '<div align="center">'                          || name          || '</div>'             name
  , '<div align="center">'                          || log_mode      || '</div>'             log_mode
  , '<div align="center">'                          || flashback_on  || '</div>'             flashback_on
FROM v$database;

CLEAR COLUMNS BREAKS COMPUTES

COLUMN oldest_flashback_time    FORMAT a125               HEADING 'Oldest Flashback Time'     ENTMAP off
COLUMN oldest_flashback_scn                               HEADING 'Oldest Flashback SCN'      ENTMAP off
COLUMN retention_target         FORMAT 999,999            HEADING 'Retention Target (min)'    ENTMAP off
COLUMN retention_target_hours   FORMAT 999,999            HEADING 'Retention Target (hour)'   ENTMAP off
COLUMN flashback_size           FORMAT 9,999,999,999,999  HEADING 'Flashback Size'            ENTMAP off
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated Flashback Size'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || TO_CHAR(oldest_flashback_time,'mm/dd/yyyy HH24:MI:SS') || '</b></font></div>'  oldest_flashback_time
  , oldest_flashback_scn             oldest_flashback_scn
  , retention_target                 retention_target
  , retention_target/60              retention_target_hours
  , flashback_size                   flashback_size
  , estimated_flashback_size         estimated_flashback_size
FROM
    v$flashback_database_log
ORDER BY
    1;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                  - FLASHBACK DATABASE REDO TIME MATRIX -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="flashback_database_redo_time_matrix"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Flashback Database Redo Time Matrix</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN begin_time               FORMAT a75                HEADING 'Begin Time'               ENTMAP off
COLUMN end_time                 FORMAT a75                HEADING 'End Time'                 ENTMAP off
COLUMN flashback_data           FORMAT 9,999,999,999,999  HEADING 'Flashback Data'           ENTMAP off
COLUMN db_data                  FORMAT 9,999,999,999,999  HEADING 'DB Data'                  ENTMAP off
COLUMN redo_data                FORMAT 9,999,999,999,999  HEADING 'Redo Data'                ENTMAP off
COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated Flashback Size' ENTMAP off

SELECT
    '<div align="right">' || TO_CHAR(begin_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'  begin_time
  , '<div align="right">' || TO_CHAR(end_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'    end_time
  , flashback_data
  , db_data
  , redo_data
  , estimated_flashback_size
FROM
    v$flashback_database_stat
ORDER BY
   begin_time;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                    <<<<<     PERFORMANCE     >>>>>                         |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Performance</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                             - SGA INFORMATION -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA Information</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79                 HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a150                HEADING 'Pool Name'        ENTMAP off
COLUMN value         FORMAT 999,999,999,999,999 HEADING 'Bytes'            ENTMAP off

BREAK ON report ON instance_name
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' OF value ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , '<div align="left"><font color="#336699"><b>' || s.name          || '</b></font></div>'  name
  , s.value                                                                                  value
FROM
    gv$sga       s
  , gv$instance  i
WHERE
    s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.value DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - SGA TARGET ADVICE -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_target_advice"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA Target Advice</b></font><hr align="left" width="460">

prompt Modify the SGA_TARGET parameter (up to the size of the SGA_MAX_SIZE, if necessary) to reduce
prompt the number of "Estimated Physical Reads".

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79     HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a79     HEADING 'Parameter Name'   ENTMAP off
COLUMN value         FORMAT a79     HEADING 'Value'            ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.name    name
  , (CASE p.name
         WHEN 'sga_max_size' THEN '<div align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
         WHEN 'sga_target'   THEN '<div align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div align="right">' || p.value || '</div>'
     END) value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('sga_max_size', 'sga_target')
ORDER BY
    i.instance_name
  , p.name;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name         FORMAT a79                   HEADING 'Instance Name'              ENTMAP off
COLUMN sga_size              FORMAT 999,999,999,999,999   HEADING 'SGA Size'                   ENTMAP off
COLUMN sga_size_factor       FORMAT 999,999,999,999,999   HEADING 'SGA Size Factor'            ENTMAP off
COLUMN estd_db_time          FORMAT 999,999,999,999,999   HEADING 'Estimated DB Time'          ENTMAP off
COLUMN estd_db_time_factor   FORMAT 999,999,999,999,999   HEADING 'Estimated DB Time Factor'   ENTMAP off
COLUMN estd_physical_reads   FORMAT 999,999,999,999,999   HEADING 'Estimated Physical Reads'   ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , s.sga_size
  , s.sga_size_factor
  , s.estd_db_time
  , s.estd_db_time_factor
  , s.estd_physical_reads
FROM
    gv$sga_target_advice s
  , gv$instance  i
WHERE
    s.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , s.sga_size_factor;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - SGA (ASMM) DYNAMIC COMPONENTS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="sga_asmm_dynamic_components"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>SGA (ASMM) Dynamic Components</b></font><hr align="left" width="460">

prompt Provides a summary report of all dynamic components as part of the Automatic Shared Memory
prompt Management (ASMM) configuration. This will display the total real memory allocation for the current
prompt SGA from the V$SGA_DYNAMIC_COMPONENTS view, which contains both manual and autotuned SGA components.
prompt As with the other manageability features of Oracle Database 10g, ASMM requires you to set the 
prompt STATISTICS_LEVEL parameter to at least TYPICAL (the default) before attempting to enable ASMM. ASMM
prompt can be enabled by setting SGA_TARGET to a nonzero value in the initialization parameter file (pfile/spfile).

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name         FORMAT a79                HEADING 'Instance Name'        ENTMAP off
COLUMN component             FORMAT a79                HEADING 'Component Name'       ENTMAP off
COLUMN current_size          FORMAT 999,999,999,999    HEADING 'Current Size'         ENTMAP off
COLUMN min_size              FORMAT 999,999,999,999    HEADING 'Min Size'             ENTMAP off
COLUMN max_size              FORMAT 999,999,999,999    HEADING 'Max Size'             ENTMAP off
COLUMN user_specified_size   FORMAT 999,999,999,999    HEADING 'User Specified|Size'  ENTMAP off
COLUMN oper_count            FORMAT 999,999,999,999    HEADING 'Oper.|Count'          ENTMAP off
COLUMN last_oper_type        FORMAT a75                HEADING 'Last Oper.|Type'      ENTMAP off
COLUMN last_oper_mode        FORMAT a75                HEADING 'Last Oper.|Mode'      ENTMAP off
COLUMN last_oper_time        FORMAT a75                HEADING 'Last Oper.|Time'      ENTMAP off
COLUMN granule_size          FORMAT 999,999,999,999    HEADING 'Granule Size'         ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , sdc.component
  , sdc.current_size
  , sdc.min_size
  , sdc.max_size
  , sdc.user_specified_size
  , sdc.oper_count
  , sdc.last_oper_type
  , sdc.last_oper_mode
  , '<div align="right">' || NVL(TO_CHAR(sdc.last_oper_time, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   last_oper_time
  , sdc.granule_size
FROM
    gv$sga_dynamic_components sdc
  , gv$instance  i
ORDER BY
    i.instance_name
  , sdc.component DESC;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - PGA TARGET ADVICE -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="pga_target_advice"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>PGA Target Advice</b></font><hr align="left" width="460">

prompt The <b>V$PGA_TARGET_ADVICE</b> view predicts how the statistics cache hit percentage and over
prompt allocation count in V$PGASTAT will be impacted if you change the value of the
prompt initialization parameter PGA_AGGREGATE_TARGET. When you set the PGA_AGGREGATE_TARGET and
prompt WORKAREA_SIZE_POLICY to <b>AUTO</b> then the *_AREA_SIZE parameter are automatically ignored and
prompt Oracle will automatically use the computed value for these parameters. Use the results from
prompt the query below to adequately set the initialization parameter PGA_AGGREGATE_TARGET as to avoid
prompt any over allocation. If column ESTD_OVERALLOCATION_COUNT in the V$PGA_TARGET_ADVICE
prompt view (below) is nonzero, it indicates that PGA_AGGREGATE_TARGET is too small to even
prompt meet the minimum PGA memory needs. If PGA_AGGREGATE_TARGET is set within the over
prompt allocation zone, the memory manager will over-allocate memory and actual PGA memory
prompt consumed will be more than the limit you set. It is therefore meaningless to set a
prompt value of PGA_AGGREGATE_TARGET in that zone. After eliminating over-allocations, the
prompt goal is to maximize the PGA cache hit percentage, based on your response-time requirement
prompt and memory constraints.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name FORMAT a79     HEADING 'Instance Name'    ENTMAP off
COLUMN name          FORMAT a79     HEADING 'Parameter Name'   ENTMAP off
COLUMN value         FORMAT a79     HEADING 'Value'            ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.name    name
  , (CASE p.name
         WHEN 'pga_aggregate_target' THEN '<div align="right">' || TO_CHAR(p.value, '999,999,999,999,999') || '</div>'
     ELSE
         '<div align="right">' || p.value || '</div>'
     END) value
FROM
    gv$parameter p
  , gv$instance  i
WHERE
      p.inst_id = i.inst_id
  AND p.name IN ('pga_aggregate_target', 'workarea_size_policy')
ORDER BY
    i.instance_name
  , p.name;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name                  FORMAT a79                   HEADING 'Instance Name'               ENTMAP off
COLUMN pga_target_for_estimate        FORMAT 999,999,999,999,999   HEADING 'PGA Target for Estimate'     ENTMAP off
COLUMN estd_extra_bytes_rw            FORMAT 999,999,999,999,999   HEADING 'Estimated Extra Bytes R/W'   ENTMAP off
COLUMN estd_pga_cache_hit_percentage  FORMAT 999,999,999,999,999   HEADING 'Estimated PGA Cache Hit %'   ENTMAP off
COLUMN estd_overalloc_count           FORMAT 999,999,999,999,999   HEADING 'ESTD_OVERALLOC_COUNT'        ENTMAP off

BREAK ON report ON instance_name

SELECT
    '<div align="left"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'  instance_name
  , p.pga_target_for_estimate
  , p.estd_extra_bytes_rw
  , p.estd_pga_cache_hit_percentage
  , p.estd_overalloc_count
FROM
    gv$pga_target_advice p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    i.instance_name
  , p.pga_target_for_estimate;

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

COLUMN name             FORMAT a95                        HEADING 'Latch Name'
COLUMN gets             FORMAT 999,999,999,999,999,999    HEADING 'Gets'
COLUMN misses           FORMAT 999,999,999,999            HEADING 'Misses'
COLUMN sleeps           FORMAT 999,999,999,999            HEADING 'Sleeps'
COLUMN immediate_gets   FORMAT 999,999,999,999,999,999    HEADING 'Immediate Gets'
COLUMN immediate_misses FORMAT 999,999,999,999            HEADING 'Immediate Misses'

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

COLUMN name    FORMAT a95                   HEADING 'Statistics Name'
COLUMN value   FORMAT 999,999,999,999,999   HEADING 'Value'

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






-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     AUTOMATIC WORKLOAD REPOSITORY - (AWR)     >>>>>           |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Automatic Workload Repository - (AWR)</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                   - WORKLOAD REPOSITORY INFORMATION -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_workload_repository_information"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Workload Repository Information</b></font><hr align="left" width="460">

prompt <b>Instances found in the "Workload Repository"</b>
prompt <b>The instance running this report (&_instance_name) is indicated in "<font color="darkgreen">GREEN</font>"</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dbbid          FORMAT a75           HEAD 'Database ID'      ENTMAP off
COLUMN dbb_name       FORMAT a75           HEAD 'Database Name'    ENTMAP off
COLUMN instt_name     FORMAT a75           HEAD 'Instance Name'    ENTMAP off
COLUMN instt_num      FORMAT 9999999999    HEAD 'Instance Number'  ENTMAP off
COLUMN host           FORMAT a75           HEAD 'Host'             ENTMAP off
COLUMN host_platform  FORMAT a125          HEAD 'Host Platform'    ENTMAP off

SELECT
    DISTINCT (CASE WHEN cd.dbid = wr.dbid
                        AND 
                        cd.name = wr.db_name
                        AND
                        ci.instance_number = wr.instance_number
                        AND
                        ci.instance_name = wr.instance_name
                   THEN '<div align="left"><font color="darkgreen"><b>' || wr.dbid || '</b></font></div>'
                   ELSE '<div align="left"><font color="#663300"><b>'   || wr.dbid || '</b></font></div>'
              END)                  dbbid
  , wr.db_name                      dbb_name
  , wr.instance_name                instt_name
  , wr.instance_number              instt_num
  , wr.host_name                    host
  , cd.platform_name                host_platform
FROM
    dba_hist_database_instance wr
  , v$database cd
  , v$instance ci
ORDER BY
    wr.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                          - AWR SNAPSHOT SETTINGS -                         |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_snapshot_settings"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Snapshot Settings</b></font><hr align="left" width="460">

prompt Use the <b>DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS</b> procedure to modify the interval
prompt of the snapshot generation and how long the snapshots are retained in the Workload Repository. The
prompt default interval is 60 minutes and can be set to a value between 10 minutes and 5,256,000 (1 year).
prompt The default retention period is 10,080 minutes (7 days) and can be set to a value between
prompt 1,440 minutes (1 day) and 52,560,000 minutes (100 years).

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dbbid           FORMAT a75    HEAD 'Database ID'          ENTMAP off
COLUMN dbb_name        FORMAT a75    HEAD 'Database Name'        ENTMAP off
COLUMN snap_interval   FORMAT a75    HEAD 'Snap Interval'        ENTMAP off
COLUMN retention       FORMAT a75    HEAD 'Retention Period'     ENTMAP off
COLUMN topnsql         FORMAT a75    HEAD 'Top N SQL'            ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>' || s.dbid || '</b></font></div>'  dbbid
  , d.name                                                                          dbb_name
  , s.snap_interval                                                                 snap_interval
  , s.retention                                                                     retention
  , s.topnsql                                                                       
FROM
    dba_hist_wr_control   s
  , v$database            d
WHERE
    s.dbid = d.dbid
ORDER BY
    dbbid;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - AWR SNAPSHOT LIST -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_snapshot_list"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Snapshot List</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75               HEADING 'Instance Name'          ENTMAP off
COLUMN snap_id              FORMAT a75               HEADING 'Snap ID'                ENTMAP off
COLUMN startup_time         FORMAT a75               HEADING 'Instance Startup Time'  ENTMAP off
COLUMN begin_interval_time  FORMAT a75               HEADING 'Begin Interval Time'    ENTMAP off
COLUMN end_interval_time    FORMAT a75               HEADING 'End Interval Time'      ENTMAP off
COLUMN elapsed_time         FORMAT 999,999,999.99    HEADING 'Elapsed Time (min)'     ENTMAP off
COLUMN db_time              FORMAT 999,999,999.99    HEADING 'DB Time (min)'          ENTMAP off
COLUMN pct_db_time          FORMAT a75               HEADING '% DB Time'              ENTMAP off
COLUMN cpu_time             FORMAT 999,999,999.99    HEADING 'CPU Time (min)'         ENTMAP off

BREAK ON instance_name_print ON startup_time

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name                                         || '</b></font></div>'  instance_name_print
  , '<div align="center"><font color="#336699"><b>' || s.snap_id                                               || '</b></font></div>'  snap_id
  , '<div nowrap align="right">'                    || TO_CHAR(s.startup_time, 'mm/dd/yyyy HH24:MI:SS')        || '</div>'             startup_time
  , '<div nowrap align="right">'                    || TO_CHAR(s.begin_interval_time, 'mm/dd/yyyy HH24:MI:SS') || '</div>'             begin_interval_time
  , '<div nowrap align="right">'                    || TO_CHAR(s.end_interval_time, 'mm/dd/yyyy HH24:MI:SS')   || '</div>'             end_interval_time
  , ROUND(EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
          EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
          EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
          EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60, 2)                                                    elapsed_time
  , ROUND((e.value - b.value)/1000000/60, 2)                                                                                           db_time
  , '<div align="right">' || 
        ROUND(((((e.value - b.value)/1000000/60) / (EXTRACT(DAY FROM  s.end_interval_time - s.begin_interval_time) * 1440 +
                                                    EXTRACT(HOUR FROM s.end_interval_time - s.begin_interval_time) * 60 +
                                                    EXTRACT(MINUTE FROM s.end_interval_time - s.begin_interval_time) +
                                                    EXTRACT(SECOND FROM s.end_interval_time - s.begin_interval_time) / 60) ) * 100), 2) 
                             || ' %</div>'                                                                                             pct_db_time
FROM
    dba_hist_snapshot       s
  , gv$instance             i
  , dba_hist_sys_time_model e
  , dba_hist_sys_time_model b
WHERE
    i.instance_number   = s.instance_number
  AND e.snap_id         = s.snap_id
  AND b.snap_id         = s.snap_id - 1
  AND e.stat_id         = b.stat_id
  AND e.instance_number = b.instance_number
  AND e.instance_number = s.instance_number
  AND e.stat_name       = 'DB time'
ORDER BY
    i.instance_name
  , s.snap_id;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - AWR SNAPSHOT SIZE ESTIMATES -                       |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_snapshot_size_estimates"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Snapshot Size Estimates</b></font><hr align="left" width="460">

DECLARE

    CURSOR get_instances IS
        SELECT COUNT(DISTINCT instance_number)
        FROM wrm$_database_instance;
  
    CURSOR get_wr_control_info IS
        SELECT snapint_num, retention_num
        FROM wrm$_wr_control;
  
    CURSOR get_snaps IS
        SELECT
            SUM(all_snaps)
          , SUM(good_snaps)
          , SUM(today_snaps)
          , SYSDATE - MIN(begin_interval_time)
        FROM
            (SELECT
                  1 AS all_snaps
                , (CASE WHEN s.status = 0 THEN 1 ELSE 0 END) AS good_snaps
                , (CASE WHEN (s.end_interval_time > SYSDATE - 1) THEN 1 ELSE 0 END) AS today_snaps
                , CAST(s.begin_interval_time AS DATE) AS begin_interval_time
             FROM wrm$_snapshot s
             );

    CURSOR sysaux_occ_usage IS
        SELECT
            occupant_name
          , schema_name
          , space_usage_kbytes/1024 space_usage_mb
        FROM
            v$sysaux_occupants
        ORDER BY
            space_usage_kbytes DESC
          , occupant_name;
  
    mb_format           CONSTANT  VARCHAR2(30)  := '99,999,990.0';
    kb_format           CONSTANT  VARCHAR2(30)  := '999,999,990';
    pct_format          CONSTANT  VARCHAR2(30)  := '990.0';
    snapshot_interval   NUMBER;
    retention_interval  NUMBER;
    all_snaps           NUMBER;
    awr_size            NUMBER;
    snap_size           NUMBER;
    awr_average_size    NUMBER;
    est_today_snaps     NUMBER;
    awr_size_past24     NUMBER;
    good_snaps          NUMBER;
    today_snaps         NUMBER;
    num_days            NUMBER;
    num_instances       NUMBER;

BEGIN

    OPEN get_instances;
    FETCH get_instances INTO num_instances;
    CLOSE get_instances;

    OPEN get_wr_control_info;
    FETCH get_wr_control_info INTO snapshot_interval, retention_interval;
    CLOSE get_wr_control_info;

    OPEN get_snaps;
    FETCH get_snaps INTO all_snaps, good_snaps, today_snaps, num_days;
    CLOSE get_snaps;

    FOR occ_rec IN sysaux_occ_usage
    LOOP
        IF (occ_rec.occupant_name = 'SM/AWR') THEN
            awr_size := occ_rec.space_usage_mb;
        END IF;
    END LOOP;

    snap_size := awr_size/all_snaps;
    awr_average_size := snap_size*86400/snapshot_interval;

    today_snaps := today_snaps / num_instances;

    IF (num_days < 1) THEN
        est_today_snaps := ROUND(today_snaps / num_days);
    ELSE
        est_today_snaps := today_snaps;
    END IF;

    awr_size_past24 := snap_size * est_today_snaps;
    
    DBMS_OUTPUT.PUT_LINE('<table width="90%" border="1">');

    DBMS_OUTPUT.PUT_LINE('<tr><th align="center" colspan="3">Estimates based on ' || ROUND(snapshot_interval/60) || ' minute snapshot intervals</th></tr>');
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/day</td><td align="right">'
                            || TO_CHAR(awr_average_size, mb_format)
                            || ' MB</td><td align="right">(' || TRIM(TO_CHAR(snap_size*1024, kb_format)) || ' K/snap * '
                            || ROUND(86400/snapshot_interval) || ' snaps/day)</td></tr>' );
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_average_size * 7, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per instance</td></tr>' );
    IF (num_instances > 1) THEN
        DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_average_size * 7 * num_instances, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per database</td></tr>' );
    END IF;

    DBMS_OUTPUT.PUT_LINE('<tr><th align="center" colspan="3">Estimates based on ' || ROUND(today_snaps) || ' snaps in past 24 hours</th></tr>');

    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/day</td><td align="right">'
                            || TO_CHAR(awr_size_past24, mb_format)
                            || ' MB</td><td align="right">('
                            || TRIM(TO_CHAR(snap_size*1024, kb_format)) || ' K/snap and '
                            || ROUND(today_snaps) || ' snaps in past '
                            || ROUND(least(num_days*24,24),1) || ' hours)</td></tr>' );
    DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_size_past24 * 7, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per instance</td></tr>' );
    IF (num_instances > 1) THEN
        DBMS_OUTPUT.PUT_LINE('<tr><td>AWR size/wk</td><td align="right">'
                            || TO_CHAR(awr_size_past24 * 7 * num_instances, mb_format)
                            || ' MB</td><td align="right">(size_per_day * 7) per database</td></tr>' );
    END IF;
  
    DBMS_OUTPUT.PUT_LINE('</table>');
    
END;
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                              - AWR BASELINES -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="awr_baselines"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>AWR Baselines</b></font><hr align="left" width="460">

prompt Use the <b>DBMS_WORKLOAD_REPOSITORY.CREATE_BASELINE</b> procedure to create a named baseline.
prompt A baseline (also known as a preserved snapshot set) is a pair of AWR snapshots that represents a
prompt specific period of database usage. The Oracle database server will exempt the AWR snapshots 
prompt assigned to a specific baseline from the automated purge routine. The main purpose of a baseline
prompt is to preserve typical run-time statistics in the AWR repository which can then be compared to 
prompt current performance or similar periods in the past.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN dbbid            FORMAT a75    HEAD 'Database ID'              ENTMAP off
COLUMN dbb_name         FORMAT a75    HEAD 'Database Name'            ENTMAP off
COLUMN baseline_id                    HEAD 'Baseline ID'              ENTMAP off
COLUMN baseline_name    FORMAT a75    HEAD 'Baseline Name'            ENTMAP off
COLUMN start_snap_id                  HEAD 'Beginning Snapshot ID'    ENTMAP off
COLUMN start_snap_time  FORMAT a75    HEAD 'Beginning Snapshot Time'  ENTMAP off
COLUMN end_snap_id                    HEAD 'Ending Snapshot ID'       ENTMAP off
COLUMN end_snap_time    FORMAT a75    HEAD 'Ending Snapshot Time'     ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>' || b.dbid || '</b></font></div>'  dbbid
  , d.name                                                                          dbb_name
  , b.baseline_id                                                                   baseline_id
  , baseline_name                                                                   baseline_name
  , b.start_snap_id                                                                 start_snap_id
  , '<div nowrap align="right">' || TO_CHAR(b.start_snap_time, 'mm/dd/yyyy HH24:MI:SS')  || '</div>'  start_snap_time
  , b.end_snap_id                                                                   end_snap_id
  , '<div nowrap align="right">' || TO_CHAR(b.end_snap_time, 'mm/dd/yyyy HH24:MI:SS')  || '</div>'    end_snap_time
FROM
    dba_hist_baseline   b
  , v$database          d
WHERE
    b.dbid = d.dbid
ORDER BY
    dbbid
  , b.baseline_id;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     SESSIONS    >>>>>                           |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Sessions</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                          - CURRENT SESSIONS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="current_sessions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Current Sessions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a45    HEADING 'Instance Name'              ENTMAP off
COLUMN thread_number_print  FORMAT a45    HEADING 'Thread Number'              ENTMAP off
COLUMN count                FORMAT a45    HEADING 'Current No. of Processes'   ENTMAP off
COLUMN value                FORMAT a45    HEADING 'Max No. of Processes'       ENTMAP off
COLUMN pct_usage            FORMAT a45    HEADING '% Usage'                    ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || a.instance_name  || '</b></font></div>'  instance_name_print
  , '<div align="center">' || a.thread#             || '</div>'  thread_number_print
  , '<div align="center">' || TO_CHAR(a.count)      || '</div>'  count
  , '<div align="center">' || b.value               || '</div>'  value
  , '<div align="center">' || TO_CHAR(ROUND(100*(a.count / b.value), 2)) || '%</div>'  pct_usage
FROM
    (select   count(*) count, a1.inst_id, a2.instance_name, a2.thread#
     from     gv$session a1
            , gv$instance a2
     where    a1.inst_id = a2.inst_id
     group by a1.inst_id
            , a2.instance_name
            , a2.thread#) a
  , (select value, inst_id from gv$parameter where name='processes') b
WHERE
    a.inst_id = b.inst_id
ORDER BY
    a.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - USER SESSION MATRIX -                             |
-- +----------------------------------------------------------------------------+

prompt <a name="user_session_matrix"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>User Session Matrix</b></font><hr align="left" width="460">

prompt <b>User sessions (excluding SYS and background processes)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75               HEADING 'Instance Name'            ENTMAP off
COLUMN thread_number_print  FORMAT a75               HEADING 'Thread Number'            ENTMAP off
COLUMN username             FORMAT a79               HEADING 'Oracle User'              ENTMAP off
COLUMN num_user_sess        FORMAT 999,999,999,999   HEADING 'Total Number of Logins'   ENTMAP off
COLUMN count_a              FORMAT 999,999,999       HEADING 'Active Logins'            ENTMAP off
COLUMN count_i              FORMAT 999,999,999       HEADING 'Inactive Logins'          ENTMAP off
COLUMN count_k              FORMAT 999,999,999       HEADING 'Killed Logins'            ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'                      instance_name_print
  , '<div align="center"><font color="#336699"><b>' || i.thread#       || '</b></font></div>'                      thread_number_print
  , '<div align="left"><font color="#000000">' || NVL(sess.username, '[B.G. Process]') || '</font></div>' username
  , count(*)              num_user_sess
  , NVL(act.count, 0)     count_a
  , NVL(inact.count, 0)   count_i
  , NVL(killed.count, 0)  count_k
FROM 
    gv$session                        sess
  , gv$instance                       i
  , (SELECT    count(*) count, NVL(username, '[B.G. Process]') username, inst_id
     FROM      gv$session
     WHERE     status = 'ACTIVE'
     GROUP BY  username, inst_id)              act
  , (SELECT    count(*) count, NVL(username, '[B.G. Process]') username, inst_id
     FROM      gv$session
     WHERE     status = 'INACTIVE'
     GROUP BY  username, inst_id)              inact
  , (SELECT    count(*) count, NVL(username, '[B.G. Process]') username, inst_id
     FROM      gv$session
     WHERE     status = 'KILLED'
     GROUP BY  username, inst_id)              killed
WHERE
         sess.inst_id                         = i.inst_id
     AND (
           NVL(sess.username, '[B.G. Process]') = act.username (+)
           AND
           sess.inst_id  = act.inst_id (+)
         )
     AND (
           NVL(sess.username, '[B.G. Process]') = inact.username (+)
           AND
           sess.inst_id  = inact.inst_id (+)
         )
     AND (
           NVL(sess.username, '[B.G. Process]') = killed.username (+)
           AND
           sess.inst_id  = killed.inst_id (+)
         )
     AND sess.username NOT IN ('SYS')
GROUP BY
    i.instance_name
  , i.thread#
  , sess.username
  , act.count
  , inact.count
  , killed.count
ORDER BY
    i.instance_name
  , i.thread#
  , sess.username;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - ENABLED TRACES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_enabled_traces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Enabled Traces</b></font><hr align="left" width="460">

prompt <b><u>End-to-End Application Tracing from View DBA_ENABLED_TRACES.</u></b>
prompt   <li> <b>Trace Type:</b> Possible values are CLIENT_ID, SESSION, SERVICE, SERVICE_MODULE, SERVICE_MODULE_ACTION, and DATABASE, based on the type of tracing enabled.
prompt   <li> <b>Primary ID:</b> Specific client identifier (username) or service name.
prompt <p>

prompt <b><u>Application tracing is enabled using the DBMS_MONITOR package and the following procedures:</u></b>
prompt   <li> <b>CLIENT_ID_TRACE_ENABLE:</b> Enable tracing based on client identifier (username).
prompt   <li> <b>CLIENT_ID_TRACE_DISABLE:</b> Disable client identifier tracing.
prompt   <li> <b>SESSION_TRACE_ENABLE:</b> Enable tracing based on SID and SERIAL# of V$SESSION.
prompt   <li> <b>SESSION_TRACE_DISABLE:</b> Disable session tracing.
prompt   <li> <b>SERV_MOD_ACT_TRACE_ENABLE:</b> Enable tracing for a given combination of service name, module, and action.
prompt   <li> <b>SERV_MOD_ACT_TRACE_DISABLE:</b> Disable service, module, and action tracing.
prompt   <li> <b>DATABASE_TRACE_ENABLE:</b> Enable tracing for the entire database.
prompt   <li> <b>DATABASE_TRACE_DISABLE:</b> Disable database tracing.
prompt <p>

prompt <b><font color="#ff0000">Hint</font>:</b> In a shared environment where you have more than one session to trace, it is 
prompt possible to end up with many trace files when tracing is enabled (i.e. connection pools).
prompt Oracle10<i>g</i> introduces the <b>trcsess</b> command-line utility to combine all the relevant
prompt trace files based on a session or client identifier or the service name, module name, and
prompt action name hierarchy combination. The output trace file from the trcsess command can then be
prompt sent to tkprof for a formatted output. Type trcsess at the command-line without any arguments to
prompt show the parameters and usage.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN trace_type           FORMAT a75    HEADING 'Trace Type'         ENTMAP off
COLUMN primary_id           FORMAT a75    HEADING 'Primary ID'         ENTMAP off
COLUMN qualifier_id1        FORMAT a75    HEADING 'Module Name'        ENTMAP off
COLUMN qualifier_id2        FORMAT a75    HEADING 'Action Name'        ENTMAP off
COLUMN waits                FORMAT a75    HEADING 'Waits?'             ENTMAP off
COLUMN binds                FORMAT a75    HEADING 'Binds?'             ENTMAP off
COLUMN instance_name_print  FORMAT a75    HEADING 'Instance Name'      ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>'   || trace_type                 || '</b></font></div>' trace_type
  , '<div align="left">'                            || NVL(primary_id, '<br>')    || '</div>' primary_id
  , '<div align="left">'                            || NVL(qualifier_id1, '<br>') || '</div>' qualifier_id1
  , '<div align="left">'                            || NVL(qualifier_id2, '<br>') || '</div>' qualifier_id2
  , '<div align="center">'                          || waits                      || '</div>' waits
  , '<div align="center">'                          || binds                      || '</div>' binds
  , '<div align="left">'                            || NVL(instance_name, '<br>') || '</div>' instance_name_print
FROM
    dba_enabled_traces
ORDER BY
    trace_type
  , primary_id
  , qualifier_id1
  , qualifier_id2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - ENABLED AGGREGATIONS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_enabled_aggregations"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Enabled Aggregations</b></font><hr align="left" width="460">

prompt <b><u>Statistics Aggregation from View DBA_ENABLED_AGGREGATIONS.</u></b>
prompt   <li> <b>Aggregation Type:</b> Possible values are CLIENT_ID, SERVICE_MODULE, and SERVICE_MODULE_ACTION, based on the type of statistics being gathered.
prompt   <li> <b>Primary ID:</b> Specific client identifier (username) or service name.
prompt <p>

prompt <b><u>Statistics aggregation is enabled using the DBMS_MONITOR package and the following procedures.</u></b>
prompt Note that statistics gathering is global for the database and is persistent across instance starts
prompt and restarts.
prompt   <li> <b>CLIENT_ID_STAT_ENABLE:</b> Enable statistics gathering based on client identifier (username).
prompt   <li> <b>CLIENT_ID_STAT_DISABLE:</b> Disable client identifier statistics gathering.
prompt   <li> <b>SERV_MOD_ACT_STAT_ENABLE:</b> Enable statistics gathering for a given combination of service name, module, and action.
prompt   <li> <b>SERV_MOD_ACT_STAT_DISABLE:</b> Disable service, module, and action statistics gathering.
prompt <p>

prompt <b><font color="#ff0000">Hint</font>:</b> While the DBA_ENABLED_AGGREGATIONS provides global statistics for currently enabled
prompt statistics, several other views can be used to query statistics aggregation values: V$CLIENT_STATS,
prompt V$SERVICE_STATS, V$SERV_MOD_ACT_STATS, and V$SERVICEMETRIC.

CLEAR COLUMNS BREAKS COMPUTES

COLUMN aggregation_type     FORMAT a75    HEADING 'Aggregation Type'   ENTMAP off
COLUMN primary_id           FORMAT a75    HEADING 'Primary ID'         ENTMAP off
COLUMN qualifier_id1        FORMAT a75    HEADING 'Module Name'        ENTMAP off
COLUMN qualifier_id2        FORMAT a75    HEADING 'Action Name'        ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>'   || aggregation_type           || '</b></font></div>' aggregation_type
  , '<div align="left">'                            || NVL(primary_id, '<br>')    || '</div>' primary_id
  , '<div align="left">'                            || NVL(qualifier_id1, '<br>') || '</div>' qualifier_id1
  , '<div align="left">'                            || NVL(qualifier_id2, '<br>') || '</div>' qualifier_id2
FROM
    dba_enabled_aggregations
ORDER BY
    aggregation_type
  , primary_id
  , qualifier_id1
  , qualifier_id2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     SECURITY     >>>>>                          |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Security</u></b></font></center>


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
COLUMN granted_role   FORMAT a35   HEADING 'Granted Role'    ENTMAP off
COLUMN admin_option   FORMAT a75   HEADING 'Admin. Option?'  ENTMAP off
COLUMN default_role   FORMAT a75   HEADING 'Default Role?'   ENTMAP off

SELECT
    '<b><font color="#336699">' || grantee       || '</font></b>'  grantee
  , '<div align="center">'      || granted_role  || '</div>'  granted_role
  , DECODE(   admin_option
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || admin_option || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || admin_option || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || admin_option || '</b></font></div>')   admin_option
  , DECODE(   default_role
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || default_role || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || default_role || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || default_role || '</b></font></div>')   default_role
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
COLUMN grantee          FORMAT a35    HEAD 'Grantee'         ENTMAP off
COLUMN admin_option     FORMAT a75    HEAD 'Admin Option?'   ENTMAP off
COLUMN default_role     FORMAT a75    HEAD 'Default Role?'   ENTMAP off

BREAK ON role

SELECT
   '<b><font color="#336699">' ||  b.role         || '</font></b>'          role
  , a.grantee                                                               grantee
  , DECODE(   a.admin_option
            , null
            , '<br>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || a.admin_option || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || a.admin_option || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || a.admin_option || '</b></font></div>')   admin_option
  , DECODE(   a.default_role
            , null
            , '<br>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || a.default_role || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || a.default_role || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || a.default_role || '</b></font></div>')   default_role
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
ORDER BY
    username;

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
-- |                     <<<<<     OBJECTS     >>>>>                            |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Objects</u></b></font></center>


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
  , object_type
ORDER BY
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
  , segment_type
ORDER BY
    owner
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                    - TOP 100 SEGMENTS (BY SIZE) -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="top_100_segments_by_size"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 100 Segments (by size)</b></font><hr align="left" width="460">

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
    rownum < 100;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                      - TOP 100 SEGMENTS (BY EXTENTS) -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="top_100_segments_by_extents"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Top 100 Segments (by number of extents)</b></font><hr align="left" width="460">

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
    rownum < 100;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DIRECTORIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directories"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directories</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner             FORMAT a75  HEADING 'Owner'             ENTMAP off
COLUMN directory_name    FORMAT a75  HEADING 'Directory Name'    ENTMAP off
COLUMN directory_path                HEADING 'Directory Path'    ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner          || '</b></font></div>'  owner
  , '<b><font color="#663300">'                   || directory_name || '</font></b>'        directory_name
  , '<tt>' || directory_path || '</tt>' directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - DIRECTORY PRIVILEGES -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_directory_privileges"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Directory Privileges</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN table_name    FORMAT a75      HEADING 'Directory Name'    ENTMAP off
COLUMN grantee       FORMAT a75      HEADING 'Grantee'           ENTMAP off
COLUMN privilege     FORMAT a75      HEADING 'Privilege'         ENTMAP off
COLUMN grantable     FORMAT a75      HEADING 'Grantable?'        ENTMAP off

BREAK ON report ON table_name ON grantee

SELECT
    '<b><font color="#336699">' || table_name || '</font></b>'  table_name
  , '<b><font color="#663300">' || grantee    || '</font></b>'  grantee
  , privilege                                                   privilege
  , DECODE(   grantable
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || grantable || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || grantable || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || grantable || '</b></font></div>')   grantable
FROM
    dba_tab_privs
WHERE
    privilege IN ('READ', 'WRITE')
ORDER BY
    table_name
  , grantee
  , privilege;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                             - LIBRARIES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_libraries"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Libraries</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner          FORMAT a75    HEADING 'Owner'             ENTMAP off
COLUMN library_name   FORMAT a75    HEADING 'Library Name'      ENTMAP off
COLUMN file_spec                    HEADING 'File Spec'         ENTMAP off
COLUMN dynamic        FORMAT a75    HEADING 'Dynamic?'          ENTMAP off
COLUMN status         FORMAT a75    HEADING 'Status'            ENTMAP off

BREAK ON report ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner           || '</b></font></div>'  owner
  , '<b><font color="#663300">'                   || library_name    || '</font></b>'        library_name
  , file_spec                                                                                file_spec
  , '<div align="center">' || dynamic || '</div>'                                            dynamic
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

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

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
    t.owner NOT IN (    'CTXSYS'
                      , 'DBSNMP'
                      , 'DMSYS'
                      , 'EXFSYS'
                      , 'IX'
                      , 'LBACSYS'
                      , 'MDSYS'
                      , 'OLAPSYS'
                      , 'ORDSYS'
                      , 'OUTLN'
                      , 'SYS'
                      , 'SYSMAN'
                      , 'SYSTEM'
                      , 'WKSYS'
                      , 'WMSYS'
                      , 'XDB')
ORDER BY
    t.owner
  , t.type_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - TYPE ATTRIBUTES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_type_attributes"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Type Attributes</b></font><hr align="left" width="460">

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

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
  , DECODE(   a.inherited
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || a.inherited || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || a.inherited || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || a.inherited || '</b></font></div>')   inherited
FROM
    dba_types        t
  , dba_type_attrs   a
WHERE
      t.owner       = a.owner
  AND t.type_name   = a.type_name
  AND t.owner NOT IN (    'CTXSYS'
                        , 'DBSNMP'
                        , 'DMSYS'
                        , 'EXFSYS'
                        , 'IX'
                        , 'LBACSYS'
                        , 'MDSYS'
                        , 'OLAPSYS'
                        , 'ORDSYS'
                        , 'OUTLN'
                        , 'SYS'
                        , 'SYSMAN'
                        , 'SYSTEM'
                        , 'WKSYS'
                        , 'WMSYS'
                        , 'XDB')
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

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

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
  , DECODE(   m.inherited
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || m.inherited || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || m.inherited || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || m.inherited || '</b></font></div>')   inherited
FROM
    dba_types          t
  , dba_type_methods   m
WHERE
      t.owner       = m.owner
  AND t.type_name   = m.type_name
  AND t.owner NOT IN (    'CTXSYS'
                        , 'DBSNMP'
                        , 'DMSYS'
                        , 'EXFSYS'
                        , 'IX'
                        , 'LBACSYS'
                        , 'MDSYS'
                        , 'OLAPSYS'
                        , 'ORDSYS'
                        , 'OUTLN'
                        , 'SYS'
                        , 'SYSMAN'
                        , 'SYSTEM'
                        , 'WKSYS'
                        , 'WMSYS'
                        , 'XDB')
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

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

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
  , DECODE(   c.nulls_stored
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || c.nulls_stored || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || c.nulls_stored || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || c.nulls_stored || '</b></font></div>')   nulls_stored
FROM
    dba_coll_types  c
WHERE
    c.owner NOT IN (    'CTXSYS'
                      , 'DBSNMP'
                      , 'DMSYS'
                      , 'EXFSYS'
                      , 'IX'
                      , 'LBACSYS'
                      , 'MDSYS'
                      , 'OLAPSYS'
                      , 'ORDSYS'
                      , 'OUTLN'
                      , 'SYS'
                      , 'SYSMAN'
                      , 'SYSTEM'
                      , 'WKSYS'
                      , 'WMSYS'
                      , 'XDB')
ORDER BY
    c.owner
  , c.type_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - LOB SEGMENTS -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_lob_segments"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>LOB Segments</b></font><hr align="left" width="460">

prompt <b>Excluding all internal system schemas (i.e. CTXSYS, MDSYS, SYS, SYSTEM)</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner              FORMAT a85        HEADING 'Owner'              ENTMAP off
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
  , DECODE(   l.in_row
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || l.in_row || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || l.in_row || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || l.in_row || '</b></font></div>')   in_row
FROM
    dba_lobs     l
  , dba_segments s
WHERE
      l.owner = s.owner
  AND l.segment_name = s.segment_name
  AND l.owner NOT IN (    'CTXSYS'
                        , 'DBSNMP'
                        , 'DMSYS'
                        , 'EXFSYS'
                        , 'IX'
                        , 'LBACSYS'
                        , 'MDSYS'
                        , 'OLAPSYS'
                        , 'ORDSYS'
                        , 'OUTLN'
                        , 'SYS'
                        , 'SYSMAN'
                        , 'SYSTEM'
                        , 'WKSYS'
                        , 'WMSYS'
                        , 'XDB')
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

COLUMN owner             FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name                               HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_name                                  HEADING 'Segment Name'     ENTMAP off
COLUMN segment_type                                  HEADING 'Segment Type'     ENTMAP off
COLUMN next_extent       FORMAT 999,999,999,999,999  HEADING 'Next Extent'      ENTMAP off
COLUMN max               FORMAT 999,999,999,999,999  HEADING 'Max. Piece Size'  ENTMAP off
COLUMN sum               FORMAT 999,999,999,999,999  HEADING 'Sum of Bytes'     ENTMAP off
COLUMN extents           FORMAT 999,999,999,999,999  HEADING 'Num. of Extents'  ENTMAP off
COLUMN max_extents       FORMAT 999,999,999,999,999  HEADING 'Max Extents'      ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || ds.owner || '</b></font></div>'    owner
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

COLUMN owner             FORMAT a75                   HEADING 'Owner'             ENTMAP off
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

COLUMN owner           FORMAT a85         HEADING 'Owner'         ENTMAP off
COLUMN object_name     FORMAT a30         HEADING 'Object Name'   ENTMAP off
COLUMN object_type     FORMAT a20         HEADING 'Object Type'   ENTMAP off
COLUMN status          FORMAT a75         HEADING 'Status'        ENTMAP off

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Grand Total: </b></font>' OF object_name ON report

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , object_name
  , object_type
  , DECODE(   status
            , 'VALID'
            , '<div align="center"><font color="darkgreen"><b>' || status || '</b></font></div>'
            , '<div align="center"><font color="#990000"><b>'   || status || '</b></font></div>' ) status
FROM dba_objects
WHERE status <> 'VALID'
ORDER BY
    owner
  , object_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                     - PROCEDURAL OBJECT ERRORS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="procedural_object_errors"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Procedural Object Errors</b></font><hr align="left" width="460">

prompt <b>All records from DBA_ERRORS</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                FORMAT a85      HEAD 'Schema'        ENTMAP off
COLUMN name                 FORMAT a30      HEAD 'Object Name'   ENTMAP off
COLUMN type                 FORMAT a15      HEAD 'Object Type'   ENTMAP off
COLUMN sequence             FORMAT 999,999  HEAD 'Sequence'      ENTMAP off
COLUMN line                 FORMAT 999,999  HEAD 'Line'          ENTMAP off
COLUMN position             FORMAT 999,999  HEAD 'Position'      ENTMAP off
COLUMN text                                 HEAD 'Text'          ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , name
  , type
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

COLUMN owner            FORMAT a95                HEAD 'Owner'            ENTMAP off
COLUMN object_type      FORMAT a20                HEAD 'Object Type'      ENTMAP off
COLUMN count            FORMAT 999,999,999,999    HEAD 'Count'            ENTMAP off

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Total: </b></font>' OF object_name ON report

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'        owner
  , 'Table'                                                                                     object_type
  , count(*)                                                                                    count
FROM
    sys.dba_tables 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('SYS','SYSTEM') 
  AND partitioned = 'NO'
GROUP BY
    owner
  , 'Table'
UNION 
SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'        owner
  , 'Index'                                                                                     object_type
  , count(*)                                                                                    count
FROM
    sys.dba_indexes 
WHERE
      last_analyzed IS NULL 
  AND owner NOT IN ('SYS','SYSTEM') 
  AND partitioned = 'NO'
GROUP BY
    owner
  , 'Index'
UNION 
SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || table_owner || '</b></font></div>'  owner
  , 'Table Partition'                                                                           object_type
  , count(*)                                                                                    count
FROM
    sys.dba_tab_partitions 
WHERE
      last_analyzed IS NULL 
  AND table_owner NOT IN ('SYS','SYSTEM')
GROUP BY
    table_owner
  , 'Table Partition'
UNION 
SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || index_owner || '</b></font></div>'  owner
  , 'Index Partition'                                                                           object_type
  , count(*)                                                                                    count
FROM
    sys.dba_ind_partitions 
WHERE
      last_analyzed IS NULL 
  AND index_owner NOT IN ('SYS','SYSTEM')
GROUP BY
    index_owner
  , 'Index Partition'
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
-- |          - USERS WITH DEFAULT TEMPORARY TABLESPACE - (SYSTEM) -            |
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

BREAK ON report ON owner
COMPUTE count LABEL '<font color="#990000"><b>Total Count: </b></font>' OF segment_name ON report
COMPUTE sum   LABEL '<font color="#990000"><b>Total Bytes: </b></font>' OF bytes ON report

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
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




-- +----------------------------------------------------------------------------+
-- |                              - RECYCLE BIN -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_recycle_bin"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Recycle Bin</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner               FORMAT a85                   HEADING 'Owner'           ENTMAP off
COLUMN original_name                                    HEADING 'Original|Name'   ENTMAP off
COLUMN type                                             HEADING 'Object|Type'     ENTMAP off
COLUMN object_name                                      HEADING 'Object|Name'     ENTMAP off
COLUMN ts_name                                          HEADING 'Tablespace'      ENTMAP off
COLUMN operation                                        HEADING 'Operation'       ENTMAP off
COLUMN createtime                                       HEADING 'Create|Time'     ENTMAP off
COLUMN droptime                                         HEADING 'Drop|Time'       ENTMAP off
COLUMN can_undrop                                       HEADING 'Can|Undrop?'     ENTMAP off
COLUMN can_purge                                        HEADING 'Can|Purge?'      ENTMAP off
COLUMN bytes               FORMAT 999,999,999,999,999   HEADING 'Bytes'           ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || owner || '</b></font></div>'    owner
  , original_name
  , type
  , object_name
  , ts_name
  , operation
  , '<div nowrap align="right">'  || NVL(createtime, '<br>') || '</div>' createtime
  , '<div nowrap align="right">'  || NVL(droptime, '<br>')   || '</div>' droptime
  , DECODE(   can_undrop
            , null
            , '<BR>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || can_undrop || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || can_undrop || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || can_undrop || '</b></font></div>')   can_undrop
  , DECODE(   can_purge
            , null
            , '<BR>'
            , 'YES'
            , '<div align="center"><font color="darkgreen"><b>' || can_purge || '</b></font></div>'
            , 'NO'
            , '<div align="center"><font color="#990000"><b>'   || can_purge || '</b></font></div>'
            , '<div align="center"><font color="#663300"><b>'   || can_purge || '</b></font></div>')    can_purge
  , (space * p.blocksize) bytes
FROM
    dba_recyclebin r
  , (SELECT value blocksize FROM v$parameter WHERE name='db_block_size') p
ORDER BY
    owner
  , object_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |         <<<<<     ONLINE ANALYTICAL PROCESSING - (OLAP)     >>>>>          |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Online Analytical Processing - (OLAP)</u></b></font></center>


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
            , 'O'
            , '<div align="center"><font color="darkgreen"><b>Yes</b></font></div>'
            , '1'
            , '<div align="center"><font color="#990000"><b>No</b></font></div>'
            , 'Y'
            , '<div align="center"><font color="#990000"><b>No</b></font></div>'
            , 'N'
            , '<div align="center"><font color="darkgreen"><b>Yes</b></font></div>'
            , '<div align="center">' || invalid  || '</div>')   invalid
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




-- +----------------------------------------------------------------------------+
-- |                   - MATERIALIZED VIEW REFRESH GROUPS -                     |
-- +----------------------------------------------------------------------------+

prompt <a name="dba_olap_materialized_view_refresh_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Materialized View Refresh Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         FORMAT a75   HEADING 'Owner'        ENTMAP off
COLUMN name          FORMAT a75   HEADING 'Name'         ENTMAP off
COLUMN broken        FORMAT a75   HEADING 'Broken?'      ENTMAP off
COLUMN next_date     FORMAT a75   HEADING 'Next Date'    ENTMAP off
COLUMN interval      FORMAT a75   HEADING 'Interval'     ENTMAP off

BREAK ON report ON owner

SELECT
    '<div nowrap align="left"><font color="#336699"><b>' || rowner   || '</b></font></div>'  owner
  , '<div align="left">'                                 || rname    || '</div>'             name
  , '<div align="center">'                               || broken   || '</div>'             broken
  , '<div nowrap align="right">'                         || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , '<div nowrap align="right">'                         || interval || '</div>'             interval
FROM
    dba_refresh 
ORDER BY
    rowner
  , rname
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     DATA PUMP     >>>>>                         |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Data Pump</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                           - DATA PUMP JOBS -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_jobs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Jobs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner_name         FORMAT a75            HEADING 'Owner Name'         ENTMAP off
COLUMN job_name           FORMAT a75            HEADING 'Job Name'           ENTMAP off
COLUMN operation          FORMAT a75            HEADING 'Operation'          ENTMAP off
COLUMN job_mode           FORMAT a75            HEADING 'Job Mode'           ENTMAP off
COLUMN state              FORMAT a75            HEADING 'State'              ENTMAP off
COLUMN degree             FORMAT 999,999,999    HEADING 'Degree'             ENTMAP off
COLUMN attached_sessions  FORMAT 999,999,999    HEADING 'Attached Sessions'  ENTMAP off

SELECT
    '<div align="left"><font color="#336699"><b>' || dpj.owner_name || '</b></font></div>'  owner_name
  , dpj.job_name                                                                            job_name
  , dpj.operation                                                                           operation
  , dpj.job_mode                                                                            job_mode
  , dpj.state                                                                               state
  , dpj.degree                                                                              degree
  , dpj.attached_sessions                                                                   attached_sessions
FROM
    dba_datapump_jobs      dpj
ORDER BY
    dpj.owner_name
  , dpj.job_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - DATA PUMP SESSIONS -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_sessions"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Sessions</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75            HEADING 'Instance Name'    ENTMAP off
COLUMN owner_name           FORMAT a75            HEADING 'Owner Name'       ENTMAP off
COLUMN job_name             FORMAT a75            HEADING 'Job Name'         ENTMAP off
COLUMN session_type         FORMAT a75            HEADING 'Session Type'     ENTMAP off
COLUMN sid                                        HEADING 'SID'              ENTMAP off
COLUMN serial_no                                  HEADING 'Serial#'          ENTMAP off
COLUMN oracle_username      FORMAT a75            HEADING 'Oracle Username'  ENTMAP off
COLUMN os_username          FORMAT a75            HEADING 'O/S Username'     ENTMAP off
COLUMN os_pid                                     HEADING 'O/S PID'          ENTMAP off

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name  || '</b></font></div>'  instance_name_print
  , dj.owner_name                                                                               owner_name 
  , dj.job_name                                                                                 job_name
  , ds.type                                                                                     session_type
  , s.sid                                                                                       sid
  , s.serial#                                                                                   serial_no
  , s.username                                                                                  oracle_username
  , s.osuser                                                                                    os_username
  , p.spid                                                                                      os_pid
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$process              p
WHERE
      s.inst_id  = i.inst_id
  AND s.inst_id  = p.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND s.paddr    = p.addr (+)
  AND dj.job_id  = ds.job_id
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - DATA PUMP JOB PROGRESS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="data_pump_job_progress"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Pump Job Progress</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a75                 HEADING 'Instance Name'           ENTMAP off
COLUMN owner_name           FORMAT a75                 HEADING 'Owner Name'              ENTMAP off
COLUMN job_name             FORMAT a75                 HEADING 'Job Name'                ENTMAP off
COLUMN session_type         FORMAT a75                 HEADING 'Session Type'            ENTMAP off
COLUMN start_time                                      HEADING 'Start Time'              ENTMAP off
COLUMN time_remaining       FORMAT 9,999,999,999,999   HEADING 'Time Remaining (min.)'   ENTMAP off
COLUMN sofar                FORMAT 9,999,999,999,999   HEADING 'Bytes Completed So Far'  ENTMAP off
COLUMN totalwork            FORMAT 9,999,999,999,999   HEADING 'Total Bytes for Job'     ENTMAP off
COLUMN pct_completed                                   HEADING '% Completed'             ENTMAP off

BREAK ON report ON instance_name_print ON owner_name ON job_name

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name  || '</b></font></div>'   instance_name_print
  , dj.owner_name                                                                                owner_name 
  , dj.job_name                                                                                  job_name
  , ds.type                                                                                      session_type
  , '<div align="center" nowrap>' || TO_CHAR(sl.start_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'  start_time
  , ROUND(sl.time_remaining/60,0)                                                                time_remaining
  , sl.sofar                                                                                     sofar
  , sl.totalwork                                                                                 totalwork
  , '<div align="right">' || TRUNC(ROUND((sl.sofar/sl.totalwork) * 100, 1)) || '%</div>'         pct_completed
FROM
    gv$datapump_job         dj
  , gv$datapump_session     ds
  , gv$session              s
  , gv$instance             i
  , gv$session_longops      sl
WHERE
      s.inst_id  = i.inst_id
  AND ds.inst_id = i.inst_id
  AND dj.inst_id = i.inst_id
  AND sl.inst_id = i.inst_id
  AND s.saddr    = ds.saddr
  AND dj.job_id  = ds.job_id
  AND sl.sid     = s.sid
  AND sl.serial# = s.serial#
  AND ds.type    = 'MASTER'
ORDER BY
    i.instance_name
  , dj.owner_name
  , dj.job_name
  , ds.type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>






-- +============================================================================+
-- |                                                                            |
-- |                     <<<<<     NETWORKING    >>>>>                          |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Networking</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                     - MTS DISPATCHER STATISTICS -                          |
-- +----------------------------------------------------------------------------+

prompt <a name="mts_dispatcher_statistics"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>MTS Dispatcher Statistics</b></font><hr align="left" width="460">

prompt <b>Dispatcher rate</b>

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                    HEADING 'Name'                  ENTMAP off
COLUMN avg_loop_rate           HEADING 'Avg|Loop|Rate'         ENTMAP off
COLUMN avg_event_rate          HEADING 'Avg|Event|Rate'        ENTMAP off
COLUMN avg_events_per_loop     HEADING 'Avg|Events|Per|Loop'   ENTMAP off
COLUMN avg_msg_rate            HEADING 'Avg|Msg|Rate'          ENTMAP off
COLUMN avg_svr_buf_rate        HEADING 'Avg|Svr|Buf|Rate'      ENTMAP off
COLUMN avg_svr_byte_rate       HEADING 'Avg|Svr|Byte|Rate'     ENTMAP off
COLUMN avg_svr_byte_per_buf    HEADING 'Avg|Svr|Byte|Per|Buf'  ENTMAP off
COLUMN avg_clt_buf_rate        HEADING 'Avg|Clt|Buf|Rate'      ENTMAP off
COLUMN avg_clt_byte_rate       HEADING 'Avg|Clt|Byte|Rate'     ENTMAP off
COLUMN avg_clt_byte_per_buf    HEADING 'Avg|Clt|Byte|Per|Buf'  ENTMAP off
COLUMN avg_buf_rate            HEADING 'Avg|Buf|Rate'          ENTMAP off
COLUMN avg_byte_rate           HEADING 'Avg|Byte|Rate'         ENTMAP off
COLUMN avg_byte_per_buf        HEADING 'Avg|Byte|Per|Buf'      ENTMAP off
COLUMN avg_in_connect_rate     HEADING 'Avg|In|Connect|Rate'   ENTMAP off
COLUMN avg_out_connect_rate    HEADING 'Avg|Out|Connect|Rate'  ENTMAP off
COLUMN avg_reconnect_rate      HEADING 'Avg|Reconnect|Rate'    ENTMAP off

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

COLUMN avg_wait   HEADING 'Average Wait Time Per Request'  ENTMAP off

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


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Replication</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                         - REPLICATION SUMMARY -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="replication_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Replication Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN gname           HEADING 'Current Database Name'       ENTMAP off
COLUMN admin_request   HEADING '# Admin. Requests'           ENTMAP off
COLUMN status          HEADING '# Admin. Request Errors'     ENTMAP off
COLUMN df_txn          HEADING '# Def. Trans'                ENTMAP off
COLUMN df_error        HEADING '# Def. Tran Errors'          ENTMAP off
COLUMN complete        HEADING '# Complete Trans in Queue'   ENTMAP off

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

COLUMN source     HEADING 'Source'              ENTMAP off
COLUMN dest       HEADING 'Target'              ENTMAP off
COLUMN trans      HEADING '# Def. Trans'        ENTMAP off
COLUMN errors     HEADING '# Def. Tran Errors'  ENTMAP off

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

COLUMN pname             FORMAT a55  HEADING 'Parameter Name'    ENTMAP off
COLUMN value             FORMAT a55  HEADING 'Value'             ENTMAP off
COLUMN isdefault         FORMAT a55  HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable  FORMAT a55  HEADING 'Is Dynamic?'       ENTMAP off

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
COLUMN interval          FORMAT a75  HEADING 'Interval'           ENTMAP off

SELECT
    j.job                                          job
  , j.priv_user                                    priv_user
  , r.rowner || '.' || r.rname                     refresh_group
  , decode(j.broken, 'Y', 'Broken', 'Normal')      broken
  , '<div nowrap align="right">' || NVL(TO_CHAR(j.next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , '<div nowrap align="right">' || j.interval                                                 || '</div>'   interval
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

COLUMN name                       HEADING 'Master Group'             ENTMAP off
COLUMN num_def_trans              HEADING '# Def. Trans'             ENTMAP off
COLUMN num_tran_errors            HEADING '# Def. Tran Errors'       ENTMAP off
COLUMN num_admin_requests         HEADING '# Admin. Requests'        ENTMAP off
COLUMN num_admin_request_errors   HEADING '# Admin. Request Errors'  ENTMAP off

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

COLUMN master_group             HEADING 'Master Group'            ENTMAP off
COLUMN sites                    HEADING 'Sites'                   ENTMAP off
COLUMN master_definition_site   HEADING 'Master Definition Site'  ENTMAP off

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

COLUMN mgroup     HEADING '# of Master Groups'          ENTMAP off
COLUMN mvgroup    HEADING '# of Registered MV Groups'   ENTMAP off
COLUMN mv         HEADING '# of Registered MVs'         ENTMAP off
COLUMN mvlog      HEADING '# of MV Logs'                ENTMAP off
COLUMN template   HEADING '# of Templates'              ENTMAP off

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
     from sys.dba_repcat_refresh_templates)        e;



CLEAR COLUMNS BREAKS COMPUTES

COLUMN log_owner        FORMAT a75     HEADING 'Log Owner'         ENTMAP off
COLUMN log_table                       HEADING 'Log Table'         ENTMAP off
COLUMN master                          HEADING 'Master'            ENTMAP off
COLUMN rowids           FORMAT a75     HEADING 'Row ID'            ENTMAP off
COLUMN primary_key      FORMAT a75     HEADING 'Primary Key'       ENTMAP off
COLUMN filter_columns   FORMAT a75     HEADING 'Filter Columns'    ENTMAP off

BREAK ON report ON log_owner

SELECT
    '<div align="left"><font color="#336699"><b>' || log_owner || '</b></font></div>'  log_owner
  , log_table
  , master
  , '<div align="center">' || rowids          || '</div>'   rowids
  , '<div align="center">' || primary_key     || '</div>'   primary_key
  , '<div align="center">' || filter_columns  || '</div>'   filter_columns
FROM
    sys.dba_snapshot_logs 
ORDER BY
    log_owner;


CLEAR COLUMNS BREAKS COMPUTES

COLUMN ref_temp_name      HEADING 'Refresh Template Name'      ENTMAP off
COLUMN owner              HEADING 'Owner'                      ENTMAP off
COLUMN public_template    HEADING 'Public'                     ENTMAP off
COLUMN instantiated       HEADING '# of Instantiated Sites'    ENTMAP off
COLUMN template_comment   HEADING 'Comment'                    ENTMAP off

SELECT
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
    rt.refresh_template_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |               - (MATERIALIZED VIEW) - MASTER SITE LOGS -                   |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_master_site_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Master Site Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN log_owner        FORMAT a75     HEADING 'Log Owner'         ENTMAP off
COLUMN log_table                       HEADING 'Log Table'         ENTMAP off
COLUMN master                          HEADING 'Master'            ENTMAP off
COLUMN rowids           FORMAT a75     HEADING 'Row ID'            ENTMAP off
COLUMN primary_key      FORMAT a75     HEADING 'Primary Key'       ENTMAP off
COLUMN filter_columns   FORMAT a75     HEADING 'Filter Columns'    ENTMAP off

BREAK ON report ON log_owner

SELECT
    '<div align="left"><font color="#336699"><b>' || log_owner || '</b></font></div>'  log_owner
  , log_table
  , master
  , '<div align="center">' || rowids          || '</div>'   rowids
  , '<div align="center">' || primary_key     || '</div>'   primary_key
  , '<div align="center">' || filter_columns  || '</div>'   filter_columns
FROM
    sys.dba_snapshot_logs 
ORDER BY
    log_owner;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |             - (MATERIALIZED VIEW) - MASTER SITE TEMPLATES -                |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_master_site_templates"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Master Site Templates</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner                   HEADING 'Owner'                     ENTMAP off
COLUMN refresh_template_name   HEADING 'Refresh Template Name'     ENTMAP off
COLUMN public_template         HEADING 'Public'                    ENTMAP off
COLUMN instantiated            HEADING '# of Instantiated Sites'   ENTMAP off
COLUMN template_comment        HEADING 'Comment'                   ENTMAP off

BREAK ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || owner || '</b></font></div>'  owner
  , rt.refresh_template_name                                                       refresh_template_name
  , decode(public_template, 'Y', 'YES', 'NO')                                      public_template
  , rs.instantiated                                                                instantiated
  , rt.template_comment                                                            template_comment
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
    owner;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                  - (MATERIALIZED VIEW) - SITE SUMMARY -                    |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_summary"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Summary</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN mvgroup   HEADING '# of Materialized View Groups'  ENTMAP off
COLUMN mv        HEADING '# of Materialized Views'        ENTMAP off
COLUMN rgroup    HEADING '# of Refresh Groups'            ENTMAP off

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
       from sys.dba_refresh)             c;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                 - (MATERIALIZED VIEW) - SITE GROUPS -                      |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN gname         HEADING 'Name'           ENTMAP off
COLUMN dblink        HEADING 'Master'         ENTMAP off
COLUMN propagation   HEADING 'Propagation'    ENTMAP off
COLUMN remark        HEADING 'Remark'         ENTMAP off

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
  AND s.snapmaster = 'Y'
ORDER BY
    s.gname;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |            - (MATERIALIZED VIEW) - SITE MATERIALIZED VIEWS -               |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_materialized_views"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Materialized Views</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner          FORMAT a75  HEADING 'Owner'           ENTMAP off
COLUMN name                       HEADING 'Name'            ENTMAP off
COLUMN master_owner               HEADING 'Master Owner'    ENTMAP off
COLUMN master_table               HEADING 'Master Table'    ENTMAP off
COLUMN master_link                HEADING 'Master Link'     ENTMAP off
COLUMN type                       HEADING 'Type'            ENTMAP off
COLUMN updatable      FORMAT a75  HEADING 'Updatable?'      ENTMAP off
COLUMN can_use_log    FORMAT a75  HEADING 'Can Use Log?'    ENTMAP off
COLUMN last_refresh   FORMAT a75  HEADING 'Last Refresh'    ENTMAP off

BREAK ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || s.owner  || '</b></font></div>'  owner
  , s.name                                                                            name
  , s.master_owner                                                                    master_owner
  , s.master                                                                          master_table
  , s.master_link                                                                     master_link
  , nls_initcap(s.type)                                                               type
  , '<div align="center">' || DECODE(s.updatable, 'YES', 'YES', 'NO')  || '</div>'    updatable
  , '<div align="center">' || DECODE(s.can_use_log,'YES', 'YES', 'NO') || '</div>'    can_use_log
  , '<div nowrap align="right">' || NVL(TO_CHAR(m.last_refresh_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   last_refresh
FROM
    sys.dba_snapshots  s
  , sys.dba_mviews     m 
WHERE
      s.name = m.mview_name 
  AND s.owner = m.owner
ORDER BY
    s.owner
  , s.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |              - (MATERIALIZED VIEW) - SITE REFRESH GROUPS -                 |
-- +----------------------------------------------------------------------------+

prompt <a name="materialized_view_refresh_groups"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>(Materialized View) - Site Refresh Groups</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner         FORMAT a75   HEADING 'Owner'        ENTMAP off
COLUMN name          FORMAT a75   HEADING 'Name'         ENTMAP off
COLUMN broken        FORMAT a75   HEADING 'Broken?'      ENTMAP off
COLUMN next_date     FORMAT a75   HEADING 'Next Date'    ENTMAP off
COLUMN interval      FORMAT a75   HEADING 'Interval'     ENTMAP off

BREAK ON owner

SELECT
    '<div align="left"><font color="#336699"><b>' || rowner   || '</b></font></div>'  owner
  , '<div align="left">'                          || rname    || '</div>'             name
  , '<div align="center">'                        || broken   || '</div>'             broken
  , '<div nowrap align="right">'                  || NVL(TO_CHAR(next_date, 'mm/dd/yyyy HH24:MI:SS'), '<br>') || '</div>'   next_date
  , '<div nowrap align="right">'                  || interval || '</div>'             interval
FROM
    sys.dba_refresh
ORDER BY
    rowner
  , rname;

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
