-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_resource_plan_multi_resource_plan_9i.sql         |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script to create a Multilevel Schema / Resouce Plan |
-- |            configuration in Oracle 9i. It will use default plan and        |
-- |            resource consumer group methods.                                |
-- |                                                                            +---+
-- |                                     [TOP PLAN]                                 |
-- |                                         |                                      |
-- |                          ----------------------------                          |
-- |                        /                              \                        |
-- |                 30% @ level 1                   70% @ level 1                  |
-- |                       |                                |                       |
-- |                  [SUB PLAN 1]                    [SUB PLAN 2]                  |
-- |                       |                                |                       |
-- |                       |                                |                       |
-- |         -------------------------             ----------------------           |
-- |       /               |          \          /          |             \         |
-- |     80% @          20% @       100% @    100% @      60% @          40% @      |
-- |    level 1        level 1      level 2   level 2    level 1        level 1     |
-- |      |                |           |         |          |              |        |
-- | [ONLINE GROUP]  [BATCH GROUP ]  [OTHER GROUPS]   [ONLINE GROUP]  [BATCH GROUP] |
-- | [ SUB PLAN 1 ]  [ SUB PLAN 1 ]                   [ SUB PLAN 2 ]  [ SUB PLAN 2] |
-- |                                                                                |
-- |                                                                            +---+
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

BEGIN

-- +----------------------------------------------------------------------------+
-- | Create Pending Area                                                        |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();


-- +----------------------------------------------------------------------------+
-- | Create three plans - One "Top Plan" and Two "Sub Plans"                    |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.CREATE_PLAN(PLAN => 'TOP_PLAN',  COMMENT => 'Top plan');
DBMS_RESOURCE_MANAGER.CREATE_PLAN(PLAN => 'SUB_PLAN1', COMMENT => 'Sub plan 1');
DBMS_RESOURCE_MANAGER.CREATE_PLAN(PLAN => 'SUB_PLAN2', COMMENT => 'Sub plan 2');


-- +----------------------------------------------------------------------------+
-- | Create all resource consumer groups that will be attached to the two       |
-- | "Sub Plans". There will be two "user defined" resource consumer groups and |
-- | one "Oracle defined" resource consumer group (OTHER_GROUPS) defined for    |
-- | each "Sub Plan".                                                           |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP(CONSUMER_GROUP => 'ONLINE_GROUP_SUB_PLAN_1', COMMENT => 'Online Group - Sub Plan 1');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP(CONSUMER_GROUP => 'BATCH_GROUP_SUB_PLAN_1',  COMMENT => 'Batch Group - Sub Plan 1');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP(CONSUMER_GROUP => 'ONLINE_GROUP_SUB_PLAN_2', COMMENT => 'Online Group - Sub Plan 2');
DBMS_RESOURCE_MANAGER.CREATE_CONSUMER_GROUP(CONSUMER_GROUP => 'BATCH_GROUP_SUB_PLAN_2',  COMMENT => 'Batch Group - Sub Plan 2');


-- +----------------------------------------------------------------------------+
-- | We first define the directives that will control CPU resources between the |
-- | "Top Plan" and its two "Sub Plans". The first sub plan (SUB_PLAN1) will    |
-- | receive 30% of the CPU at level 1 while the second sub plan (SUB_PLAN2)    |
-- | will receive 70% of the CPU at level 1.                                    |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN =>'TOP_PLAN'
                                            , GROUP_OR_SUBPLAN =>'SUB_PLAN1'
                                            , COMMENT=> 'All sub plan 1 user sessions at level 1'
                                            , CPU_P1 => 30);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN =>'TOP_PLAN'
                                            , GROUP_OR_SUBPLAN =>'SUB_PLAN2'
                                            , COMMENT=> 'All sub plan 2 user sessions at level 1'
                                            , CPU_P1 => 70);


-- +----------------------------------------------------------------------------+
-- | Finally, we define the key directives for each of the sub plans and        |
-- | resources available for user sessions.                                     |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN1'
                                            , GROUP_OR_SUBPLAN => 'ONLINE_GROUP_SUB_PLAN_1'
                                            , COMMENT => 'Online sub plan 1 users sessions at level 1'
                                            , CPU_P1 => 80
                                            , CPU_P2=> 0);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN1'
                                            , GROUP_OR_SUBPLAN => 'BATCH_GROUP_SUB_PLAN_1'
                                            , COMMENT => 'Batch sub plan 1 users sessions at level 1'
                                            , CPU_P1 => 20
                                            , CPU_P2 => 0);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN1'
                                            , GROUP_OR_SUBPLAN => 'OTHER_GROUPS'
                                            , COMMENT => 'All other users sessions at level 2'
                                            , CPU_P1 => 0
                                            , CPU_P2 => 100);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN2'
                                            , GROUP_OR_SUBPLAN => 'ONLINE_GROUP_SUB_PLAN_2'
                                            , COMMENT => 'Online sub plan 2 users sessions at level 1'
                                            , CPU_P1 => 60
                                            , CPU_P2 => 0);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN2'
                                            , GROUP_OR_SUBPLAN => 'BATCH_GROUP_SUB_PLAN_2'
                                            , COMMENT => 'Batch sub plan 2 users sessions at level 1'
                                            , CPU_P1 => 40
                                            , CPU_P2 => 0);

DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE(  PLAN => 'SUB_PLAN2'
                                            , GROUP_OR_SUBPLAN => 'OTHER_GROUPS'
                                            , COMMENT => 'All other users sessions at level 2'
                                            , CPU_P1 => 0
                                            , CPU_P2 => 100);


-- +----------------------------------------------------------------------------+
-- | The preceding call to VALIDATE_PENDING_AREA is optional because the        |
-- | validation is implicitly performed in SUBMIT_PENDING_AREA.                 |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();


-- +----------------------------------------------------------------------------+
-- | Submit the pending area to Oracle!                                         |
-- +----------------------------------------------------------------------------+
DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();

END;
/


ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = top_plan;

