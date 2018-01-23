-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : help.sql                                                        |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : A utility script used to print out the names of all Oracle SQL  |
-- |            scripts that can be executed from SQL*Plus.                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

prompt 
prompt ========================================
prompt Automatic Shared Memory Management
prompt ========================================
prompt asmm_components.sql


prompt 
prompt ========================================
prompt Automatic Storage Management
prompt ========================================
prompt asm_alias.sql
prompt asm_clients.sql
prompt asm_diskgroups.sql
prompt asm_disks.sql
prompt asm_disks_perf.sql
prompt asm_drop_files.sql
prompt asm_files.sql
prompt asm_files2.sql
prompt asm_files_10g.sql
prompt asm_templates.sql


prompt 
prompt ========================================
prompt Automatic Workload Repository
prompt ========================================
prompt awr_snapshots_dbtime.sql
prompt awr_snapshots_dbtime_xls.sql


prompt 
prompt ========================================
prompt Data Pump
prompt ========================================
prompt dpump_jobs.sql
prompt dpump_progress.sql
prompt dpump_sessions.sql


prompt 
prompt ========================================
prompt Database Administration
prompt ========================================
prompt dba_blocks_used_by_table.sql
prompt dba_column_constraints.sql
prompt dba_compare_schemas.sql
prompt dba_controlfile_records.sql
prompt dba_controlfiles.sql
prompt dba_cr_init.sql
prompt dba_db_growth.sql
prompt dba_directories.sql
prompt dba_errors.sql
prompt dba_file_space_usage.sql
prompt dba_file_space_usage_7.sql
prompt dba_file_use.sql
prompt dba_file_use_7.sql
prompt dba_files.sql
prompt dba_files_all.sql
prompt dba_free_space_frag.sql
prompt dba_highwater_mark.sql
prompt dba_index_fragmentation.sql
prompt dba_index_schema_fragmentation_report.sql
prompt dba_index_stats.sql
prompt dba_invalid_objects.sql
prompt dba_invalid_objects_summary.sql
prompt dba_jobs.sql
prompt dba_object_cache.sql
prompt dba_object_search.sql
prompt dba_object_summary.sql
prompt dba_options.sql
prompt dba_owner_to_tablespace.sql
prompt dba_plsql_package_size.sql
prompt dba_query_hidden_parameters.sql
prompt dba_random_number.sql
prompt dba_rebuild_indexes.sql
prompt dba_recompile_invalid_objects.sql
prompt dba_registry.sql
prompt dba_related_child_tables.sql
prompt dba_row_size.sql
prompt dba_segment_summary.sql
prompt dba_snapshot_database_10g.sql
prompt dba_snapshot_database_8i.sql
prompt dba_snapshot_database_9i.sql
prompt dba_table_info.sql
prompt dba_tables_all.sql
prompt dba_tables_current_user.sql
prompt dba_tables_query_user.sql
prompt dba_tablespace_mapper.sql
prompt dba_tablespace_to_owner.sql
prompt dba_tablespaces.sql
prompt dba_tablespaces_7.sql
prompt dba_tablespaces_8i.sql
prompt dba_top_segments.sql
prompt help.sql


prompt 
prompt ========================================
prompt Database Resource Manager
prompt ========================================
prompt rsrc_plan_status_detail.sql
prompt rsrc_plan_status_summary.sql


prompt 
prompt ========================================
prompt Examples
prompt ========================================
prompt example_create_clob.sql
prompt example_create_clob_8.sql
prompt example_create_dimension.sql
prompt example_create_emp_dept_custom.sql
prompt example_create_emp_dept_original.sql
prompt example_create_index.sql
prompt example_create_index_organized_table.sql
prompt example_create_materialized_view.sql
prompt example_create_not_null_constraints.sql
prompt example_create_primary_foreign_key.sql
prompt example_create_profile_password_parameters.sql
prompt example_create_profile_resource_parameters.sql
prompt example_create_resource_plan_multi_resource_plan_9i.sql
prompt example_create_sequence.sql
prompt example_create_table.sql
prompt example_create_table_buffer_pools.sql
prompt example_create_tablespace.sql
prompt example_create_temporary_tables.sql
prompt example_create_user_tables.sql
prompt example_database_resource_manager_setup.sql
prompt example_drop_unused_column.sql
prompt example_lob_demonstration.sql
prompt example_move_table.sql
prompt example_partition_range_date_oracle_8.sql
prompt example_partition_range_number_oracle_8.sql
prompt example_transport_tablespace.sql


prompt 
prompt ========================================
prompt Flash Recovery Area
prompt ========================================
prompt fra_alerts.sql
prompt fra_files.sql
prompt fra_status.sql


prompt 
prompt ========================================
prompt Flashback Database
prompt ========================================
prompt fdb_log_files.sql
prompt fdb_redo_time_matrix.sql
prompt fdb_status.sql


prompt 
prompt ========================================
prompt LOBs
prompt ========================================
prompt lob_dump_blob.sql
prompt lob_dump_clob.sql
prompt lob_dump_nclob.sql
prompt lob_fragmentation_user.sql


prompt 
prompt ========================================
prompt Locks
prompt ========================================
prompt locks_blocking.sql
prompt locks_blocking2.sql
prompt locks_dml_ddl.sql
prompt locks_dml_lock_time.sql


prompt 
prompt ========================================
prompt Multi Threaded Server
prompt ========================================
prompt mts_dispatcher_status.sql
prompt mts_dispatcher_utilization.sql
prompt mts_queue_information.sql
prompt mts_shared_server_statistics.sql
prompt mts_shared_server_utilization.sql
prompt mts_user_connections.sql


prompt 
prompt ========================================
prompt Oracle Applications
prompt ========================================
prompt erp_conc_manager_job_status.sql
prompt erp_conc_manager_job_status2.sql
prompt erp_conc_manager_user_query.sql


prompt 
prompt ========================================
prompt Oracle Wait Interface
prompt ========================================
prompt owi_event_names.sql


prompt 
prompt ========================================
prompt PL SQL
prompt ========================================
prompt plsql_random_numbers.sql
prompt plsql_webdba_utl_pkg.sql


prompt 
prompt ========================================
prompt RMAN
prompt ========================================
prompt rman_backup_pieces.sql
prompt rman_backup_sets.sql
prompt rman_backup_sets_8i.sql
prompt rman_configuration.sql
prompt rman_controlfiles.sql
prompt rman_progress.sql
prompt rman_spfiles.sql


prompt 
prompt ========================================
prompt RMAN Recovery Catalog
prompt ========================================
prompt rc_databases.sql


prompt 
prompt ========================================
prompt Real Application Clusters
prompt ========================================
prompt rac_instances.sql


prompt 
prompt ========================================
prompt Security
prompt ========================================
prompt sec_default_passwords.sql
prompt sec_roles.sql
prompt sec_users.sql


prompt 
prompt ========================================
prompt Session Management
prompt ========================================
prompt sess_current_user_transactions.sql
prompt sess_query_sql.sql
prompt sess_uncommited_transactions.sql
prompt sess_user_sessions.sql
prompt sess_user_stats.sql
prompt sess_user_trace_file_location.sql
prompt sess_users.sql
prompt sess_users_8i.sql
prompt sess_users_active.sql
prompt sess_users_active_8i.sql
prompt sess_users_active_sql.sql
prompt sess_users_by_cpu.sql
prompt sess_users_by_cursors.sql
prompt sess_users_by_io.sql
prompt sess_users_by_memory.sql
prompt sess_users_by_transactions.sql
prompt sess_waiting.sql
prompt sess_waiting_8i.sql


prompt 
prompt ========================================
prompt Statspack
prompt ========================================
prompt sp_auto.sql
prompt sp_auto_15.sql
prompt sp_auto_30.sql
prompt sp_auto_5.sql
prompt sp_list.sql
prompt sp_parameters.sql
prompt sp_purge.sql
prompt sp_purge_30_days_10g.sql
prompt sp_purge_30_days_9i.sql
prompt sp_purge_n_days_10g.sql
prompt sp_purge_n_days_9i.sql
prompt sp_snap.sql
prompt sp_statspack_custom_pkg_10g.sql
prompt sp_statspack_custom_pkg_9i.sql
prompt sp_trunc.sql


prompt 
prompt ========================================
prompt Temporary Tablespace
prompt ========================================
prompt temp_sort_segment.sql
prompt temp_sort_users.sql
prompt temp_status.sql


prompt 
prompt ========================================
prompt Tuning
prompt ========================================
prompt perf_db_block_buffer_usage.sql
prompt perf_explain_plan.sql
prompt perf_file_io.sql
prompt perf_file_io_7.sql
prompt perf_file_io_efficiency.sql
prompt perf_file_waits.sql
prompt perf_hit_ratio_by_session.sql
prompt perf_hit_ratio_system.sql
prompt perf_log_switch_history_bytes_daily_all.sql
prompt perf_log_switch_history_count_daily.sql
prompt perf_log_switch_history_count_daily_7.sql
prompt perf_log_switch_history_count_daily_all.sql
prompt perf_lru_latch_contention.sql
prompt perf_objects_without_statistics.sql
prompt perf_performance_snapshot.sql
prompt perf_redo_log_contention.sql
prompt perf_sga_free_pool.sql
prompt perf_sga_usage.sql
prompt perf_shared_pool_memory.sql
prompt perf_top_10_procedures.sql
prompt perf_top_10_tables.sql
prompt perf_top_sql_by_buffer_gets.sql
prompt perf_top_sql_by_disk_reads.sql


prompt 
prompt ========================================
prompt Undo Segments
prompt ========================================
prompt rollback_segments.sql
prompt rollback_users.sql
prompt undo_contention.sql
prompt undo_segments.sql
prompt undo_users.sql


prompt 
prompt ========================================
prompt Workspace Manager
prompt ========================================
prompt wm_create_workspace.sql
prompt wm_disable_versioning.sql
prompt wm_enable_versioning.sql
prompt wm_freeze_workspace.sql
prompt wm_get_workspace.sql
prompt wm_goto_workspace.sql
prompt wm_merge_workspace.sql
prompt wm_refresh_workspace.sql
prompt wm_remove_workspace.sql
prompt wm_rollback_workspace.sql
prompt wm_unfreeze_workspace.sql
prompt wm_workspaces.sql
