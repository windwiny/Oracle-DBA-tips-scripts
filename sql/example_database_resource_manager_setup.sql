-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_database_resource_manager_setup.sql                     |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL syntax used setup and configure database resource   |
-- |            manager (DRM).                                                  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

connect system/manager

set serveroutput on

Prompt ====================
Prompt Clean-Up DRM Area...
Prompt ====================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

alter system set resource_manager_plan=system_plan;

exec DBMS_RESOURCE_MANAGER.create_pending_area;
-- exec dbms_resource_manager.DELETE_PLAN_CASCADE('daytime_plan');
-- exec dbms_resource_manager.DELETE_PLAN_CASCADE('night_weekend_plan');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('daytime_plan', 'oltp_group');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('daytime_plan', 'batch_group');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('daytime_plan', 'other_groups');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('night_weekend_plan', 'oltp_group');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('night_weekend_plan', 'batch_group');
exec dbms_resource_manager.DELETE_PLAN_DIRECTIVE('night_weekend_plan', 'other_groups');
exec dbms_resource_manager.DELETE_PLAN('daytime_plan');
exec dbms_resource_manager.DELETE_PLAN('night_weekend_plan');
exec dbms_resource_manager.DELETE_CONSUMER_GROUP('oltp_group');
exec dbms_resource_manager.DELETE_CONSUMER_GROUP('batch_group');
exec DBMS_RESOURCE_MANAGER.validate_pending_area;
exec DBMS_RESOURCE_MANAGER.submit_pending_area;



Prompt ========================
Prompt Creating Pending Area...
Prompt ========================
Prompt 
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.create_pending_area;


Prompt ================================
Prompt Create Resource Plan Template...
Prompt ================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.create_plan('daytime_plan', 'Plan for daytime processing');
exec DBMS_RESOURCE_MANAGER.create_plan('night_weekend_plan', 'Plan for nights and weekends');


Prompt ==========================================
Prompt Create Resource Consumer Group Template...
Prompt ==========================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.create_consumer_group('oltp_group', 'data entry specialist');
exec DBMS_RESOURCE_MANAGER.create_consumer_group('batch_group', 'nightly batch jobs');



Prompt ==================================
Prompt Create Resource Plan Directives...
Prompt ==================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.create_plan_directive('daytime_plan', 'oltp_group', 'Daytime rule for oltp_group users', cpu_p1 => 90, parallel_degree_limit_p1 => 0);

exec DBMS_RESOURCE_MANAGER.create_plan_directive('daytime_plan', 'batch_group', 'Daytime rule for batch_group users', cpu_p1 => 10, parallel_degree_limit_p1 => 0);

exec DBMS_RESOURCE_MANAGER.create_plan_directive('daytime_plan', 'other_groups', 'Daytime rules for all other users/groups', cpu_p2 => 100, parallel_degree_limit_p1 => 0);

exec DBMS_RESOURCE_MANAGER.create_plan_directive('night_weekend_plan', 'oltp_group', 'Night/Weekend rule for oltp_group users', cpu_p1 => 10, parallel_degree_limit_p1 => 0);

exec DBMS_RESOURCE_MANAGER.create_plan_directive('night_weekend_plan', 'batch_group', 'Night/Weekend rule for batch_group users', cpu_p1 => 90, parallel_degree_limit_p1 => 0);
	
exec DBMS_RESOURCE_MANAGER.create_plan_directive('night_weekend_plan', 'other_groups', 'Night/Weekend rules for all other users/groups', cpu_p2 => 100, parallel_degree_limit_p1 => 0);



Prompt ==================================
Prompt Confirm (Validate) Pending Area...
Prompt ==================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.validate_pending_area;


Prompt ======================
Prompt Submit Pending Area...
Prompt ======================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.submit_pending_area;
-- exec DBMS_RESOURCE_MANAGER.clear_pending_area;


Prompt =========================================================================
Prompt ALLOW USER SCOTT TO SWITCH BETWEEN (oltp_group and batch_group) GROUPS...
Prompt =========================================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER_PRIVS.grant_switch_consumer_group('scott', 'oltp_group', FALSE);
exec DBMS_RESOURCE_MANAGER_PRIVS.grant_switch_consumer_group('scott', 'batch_group', FALSE);


Prompt =========================================================
Prompt ASSIGN USER SCOTT TO INITIAL CONSUMER GROUP OF oltp_group...
Prompt =========================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.set_initial_consumer_group('scott', 'oltp_group');


Prompt ==============================================
Prompt SWITCH USER SCOTT INTO THE oltp_group GROUP...
Prompt ==============================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_RESOURCE_MANAGER.switch_consumer_group_for_user('scott', 'oltp_group');


Prompt ==============================
Prompt Switch to DAYTIME_PLAN plan...
Prompt ==============================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

ALTER SYSTEM SET resource_manager_plan=daytime_plan;


