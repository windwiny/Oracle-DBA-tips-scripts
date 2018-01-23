-- +-------------------------------------------------------------------------------------------------+
-- |                                       Jeffrey M. Hunter                                         |
-- |                                    jhunter@idevelopment.info                                    |
-- |                                      www.idevelopment.info                                      |
-- |-------------------------------------------------------------------------------------------------|
-- |              Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.                    |
-- |-------------------------------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                                               |
-- | FILE     : sp_statspack_custom_pkg_9i.sql                                                       |
-- | CLASS    : Statspack                                                                            |
-- | PURPOSE  : Custom package to be used in managing Statspack. This version has been modified to   |
-- |            work with Oracle9i.                                                                  |
-- |                                                                                                 |
-- | EXAMPLES:                                                                                       |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Perform a Statspack Snapshot.                                                                   |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.snap;                                                                          |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a snapshot job to run once every 15 minutes starting at the next 15 minute interval.   |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.snap_schedule(                                                                 |
-- |     TRUNC(sysdate,'HH24')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,'MI'))/15)+1)*15)/(24*60)           |
-- |   , 'TRUNC(sysdate,''HH24'')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,''MI''))/15)+1)*15)/(24*60)');   |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a snapshot job to run once every 5 minutes starting at the next 5 minute interval.     |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.snap_schedule_5;                                                               |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a snapshot job to run once every 15 minutes starting at the next 15 minute interval.   |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.snap_schedule_15;                                                              |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a snapshot job to run once every 30 minutes starting at the next 30 minute interval.   |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.snap_schedule_30;                                                              |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Purge all snapshots older than 30 days.                                                         |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.purge(30);                                                                     |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a purge job to run once a day and purge snapshots older than 30 days. The job will     |
-- | start at the begining of the next hour.                                                         |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.purge_schedule(30, trunc(sysdate+1/24,'HH'), 'SYSDATE+1');                     |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a purge job to run once a day at midnight to purge snapshots older than 30 days. The   |
-- | job will start at the next midnight and continue to run daily at midnight.                      |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.purge_schedule(30, trunc(sysdate+1), 'SYSDATE+1');                             |
-- |                                                                                                 |
-- | ----------------------------------------------------------------------------------------------- |
-- | Schedule a purge job to run once every day at midnight, removing snapshot records older than 30 |
-- | days. The job will start at the next midnight and continue to run daily at midnight.            |
-- | ----------------------------------------------------------------------------------------------- |
-- | statspack_custom.purge_schedule_midnight(30);                                                   |
-- |                                                                                                 |
-- | NOTE    : As with any code, ensure to test this script in a development environment before      |
-- |           attempting to run it in production.                                                   |
-- +-------------------------------------------------------------------------------------------------+

set feedback     on
set timing       on
set verify       on
set serveroutput on

spool sp_statspack_custom_9i.lst


prompt 
prompt 
prompt COMPILING statspack_custom (specification)...
prompt ============================================
prompt


set termout off


-- +----------------------------------------------------------------------------+
-- | ************************************************************************** |
-- | *                   ***   PACKAGE SPECIFICATION   ***                    * |
-- | *                                                                        * |
-- | *                            statspack_custom                            * |
-- | ************************************************************************** |
-- +----------------------------------------------------------------------------+

CREATE OR REPLACE PACKAGE statspack_custom
IS

    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap                                          |
    -- |                                                           |
    -- |             Wrapper procedure (wraps the original snap()  |
    -- |             procedure in the STATSPACK package) used to   |
    -- |             perform a Statspack snapshot.                 |
    -- +-----------------------------------------------------------+
    PROCEDURE snap;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule                                 |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call.                      |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule(   in_start_date      IN DATE
                             , in_interval        IN VARCHAR2
    );



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_5                               |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 5 minutes and   |
    -- |             starts at the next 5 minute interval.         |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_5;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_15                              |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 15 minutes and  |
    -- |             starts at the next 15 minute interval.        |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_15;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_30                              |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 30 minutes and  |
    -- |             starts at the next 30 minute interval.        |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_30;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge                                         |
    -- |                                                           |
    -- |             Used to purge old records from the Statspack  |
    -- |             repository.                                   |
    -- +-----------------------------------------------------------+
    PROCEDURE purge(in_days_older_than IN INTEGER);



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge_schedule                                |
    -- |                                                           |
    -- |             Utility procedure used to schedule the        |
    -- |             "purge()" procedure - removing a given number |
    -- |             of obsolete records by the provided number of |
    -- |             days parameter.                               |
    -- +-----------------------------------------------------------+
    PROCEDURE purge_schedule(  in_days_older_than IN INTEGER
                             , in_start_date      IN DATE
                             , in_interval        IN VARCHAR2
    );



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge_schedule_midnight                       |
    -- |                                                           |
    -- |             Utility procedure used to schedule the        |
    -- |             "purge()" procedure to run every day at       |
    -- |             midnight - removing a given number of         |
    -- |             obsolete records by the provided number of    |
    -- |             days parameter.                               |
    -- +-----------------------------------------------------------+
    PROCEDURE purge_schedule_midnight(in_days_older_than IN INTEGER);



END statspack_custom;
/

set termout on
show errors



-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



prompt 
prompt 
prompt COMPILING statspack_custom (body)...
prompt ============================================
prompt

set termout off

-- +----------------------------------------------------------------------------+
-- | ************************************************************************** |
-- | *                         ***   PACKAGE BODY   ***                       * |
-- | *                                                                        * |
-- | *                              statspack_custom                          * |
-- | ************************************************************************** |
-- +----------------------------------------------------------------------------+

CREATE OR REPLACE PACKAGE BODY statspack_custom
IS


    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap                                          |
    -- |                                                           |
    -- |             Wrapper procedure (wraps the original snap()  |
    -- |             procedure in the STATSPACK package) used to   |
    -- |             perform a Statspack snapshot.                 |
    -- +-----------------------------------------------------------+
    PROCEDURE snap
    IS
    BEGIN
        statspack.snap;
        commit;
    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule                                 |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call.                      |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule(   in_start_date      IN DATE
                             , in_interval        IN VARCHAR2)
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);
        v_JobNumber              NUMBER;
        v_InstanceNumber         NUMBER;

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.snap_schedule';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');


        -- -------------------------------------------------------------------------
        -- Get instance number
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Get instance number';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        SELECT instance_number INTO v_InstanceNumber FROM v$instance;


        -- -------------------------------------------------------------------------
        -- Submit job
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit job';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DBMS_JOB.SUBMIT(   job       => v_JobNumber
                         , what      => 'statspack_custom.snap;'
                         , next_date => in_start_date
                         , interval  => in_interval
                         , no_parse  => TRUE
                         , instance  => v_InstanceNumber);

        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_5                               |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 5 minutes and   |
    -- |             starts at the next 5 minute interval.         |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_5
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.snap_schedule_5';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');


        -- -------------------------------------------------------------------------
        -- Submit job to run every 5 minutes
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit job every 5 minutes';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        statspack_custom.snap_schedule(
              TRUNC(sysdate,'HH24')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,'MI'))/5)+1)*5)/(24*60)
            , 'TRUNC(sysdate,''HH24'')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,''MI''))/5)+1)*5)/(24*60)');


        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_15                              |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 15 minutes and  |
    -- |             starts at the next 15 minute interval.        |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_15
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.snap_schedule_15';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');


        -- -------------------------------------------------------------------------
        -- Submit job to run every 15 minutes
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit job every 15 minutes';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        statspack_custom.snap_schedule(
              TRUNC(sysdate,'HH24')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,'MI'))/15)+1)*15)/(24*60)
            , 'TRUNC(sysdate,''HH24'')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,''MI''))/15)+1)*15)/(24*60)');


        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - snap_schedule_30                              |
    -- |                                                           |
    -- |             Utility procedure used to schedule a          |
    -- |             "snap()" procedure call every 30 minutes and  |
    -- |             starts at the next 30 minute interval.        |
    -- +-----------------------------------------------------------+
    PROCEDURE snap_schedule_30
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.snap_schedule_30';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');


        -- -------------------------------------------------------------------------
        -- Submit job to run every 30 minutes
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit job every 30 minutes';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        statspack_custom.snap_schedule(
              TRUNC(sysdate,'HH24')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,'MI'))/30)+1)*30)/(24*60)
            , 'TRUNC(sysdate,''HH24'')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,''MI''))/30)+1)*30)/(24*60)');


        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge                                         |
    -- |                                                           |
    -- |             Used to purge old records from the Statspack  |
    -- |             repository.                                   |
    -- +-----------------------------------------------------------+
    PROCEDURE purge(in_days_older_than IN INTEGER)
    IS

        e_NoRecordsFound         EXCEPTION;
        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);

        v_DbId                   sys.v_$database.dbid%TYPE;
        v_DbName                 sys.v_$database.name%TYPE;
        v_InstanceNumber         sys.v_$instance.instance_number%TYPE;
        v_InstanceName           sys.v_$instance.instance_name%TYPE;

        v_LowSnapId              NUMBER;
        v_HiSnapId               NUMBER;

        v_BeginTime              DATE;
        v_EndTime                DATE;

        v_tempRowCount           NUMBER;

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.purge';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');

        -- -------------------------------------------------------------------------
        -- Get database and instance currently connected to. This will be used later
        -- in the report along with other metadata to lookup snapshots.
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Gather instance / DB information';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        SELECT
            d.dbid
          , d.name
          , i.instance_number
          , i.instance_name
        INTO
            v_DbId
          , v_DbName
          , v_InstanceNumber
          , v_InstanceName
        FROM
            v$database d
          , v$instance i;

        DBMS_OUTPUT.PUT_LINE('v_DbId                                      : ' || v_DbId);
        DBMS_OUTPUT.PUT_LINE('v_DbName                                    : ' || v_DbName);
        DBMS_OUTPUT.PUT_LINE('v_InstanceNumber                            : ' || v_InstanceNumber);
        DBMS_OUTPUT.PUT_LINE('v_InstanceName                              : ' || v_InstanceName);


        -- -------------------------------------------------------------------------
        -- Obtain the MIN and MAX Snapshot IDs to be removed from the range of IDs
        -- order than "days_to_purge days".
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Gather MIN/MAX Snapshot IDs';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        SELECT
              NVL(MIN(snap_id),0)
            , NVL(MAX(snap_id),0)
        INTO
              v_LowSnapId
            , v_HiSnapId
        FROM    stats$snapshot
        WHERE   snap_time < (sysdate - in_days_older_than);

        DBMS_OUTPUT.PUT_LINE('v_LowSnapId                                 : ' || v_LowSnapId);
        DBMS_OUTPUT.PUT_LINE('v_HiSnapId                                  : ' || v_HiSnapId);


        -- -------------------------------------------------------------------------
        -- Check if any Statspack Records exist for the given number of days old.
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Checking HiSnapId > 0';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        IF (v_HiSnapId = 0) THEN
            v_ActionContext := 'No snapshots older than ' || in_days_older_than || ' days in STATS$SNAPSHOT';
            DBMS_OUTPUT.PUT_LINE('No snapshots found older than ' || in_days_older_than || ' days in STATS$SNAPSHOT');
            RAISE e_NoRecordsFound;
        END IF;


        -- -------------------------------------------------------------------------
        -- Get begin and end snapshot times - these are used to delete undostat.
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Get Begin / End SS Times';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        SELECT  b.snap_time
        INTO    v_BeginTime
        FROM    stats$snapshot b
        WHERE   b.snap_id         = v_LowSnapId
          AND   b.dbid            = v_DbId
          AND   b.instance_number = v_InstanceNumber;

        SELECT  e.snap_time
        INTO    v_EndTime
        FROM    stats$snapshot e
        WHERE   e.snap_id         = v_HiSnapId
          AND   e.dbid            = v_DbId
          AND   e.instance_number = v_InstanceNumber;

        DBMS_OUTPUT.PUT_LINE('v_BeginTime                                 : ' || TO_CHAR(v_BeginTime, 'MM/DD/YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('v_EndTime                                   : ' || TO_CHAR(v_EndTime, 'MM/DD/YYYY HH24:MI:SS'));


        -- -------------------------------------------------------------------------
        -- Deleting obsolete Statspack records.
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Deleting obsolete SP records';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DELETE FROM  stats$snapshot
            WHERE    instance_number = v_InstanceNumber
              AND    dbid            = v_DbId
              AND    snap_id between v_LowSnapId and v_HiSnapId;

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$snapshot DELETE %ROWCOUNT             : ' || v_tempRowCount);

        -- -------------------------------------------------------------------------
        -- Delete any dangling SQLtext. The following statement deletes any dangling
        -- SQL statements which are no longer referred to by ANY snapshots. By
        -- default, Oracle comments this statement out as it can be very resource
        -- intensive.
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Delete dangling SQLtext';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        EXECUTE IMMEDIATE 'ALTER SESSION SET hash_area_size=1048576';

        DELETE --+ index_ffs(st) 
        FROM  stats$sqltext st
        WHERE
            (   hash_value
              , text_subset
            )
            NOT IN
            (  select --+ hash_aj full(ss) no_expand 
                   hash_value
                 , text_subset
               from stats$sql_summary ss
               where ( (
                         snap_id     < v_LowSnapId
                         or
                         snap_id     > v_HiSnapId
                       )
                       and dbid            = v_DbId
                       and instance_number = v_InstanceNumber
                     )
                     or
                     (
                       dbid            != v_DbId
                       or
                       instance_number != v_InstanceNumber
                     )
            );

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$sqltext DELETE %ROWCOUNT              : ' || v_tempRowCount);


        -- -------------------------------------------------------------------------
        -- (OPTIONAL) - STATS$SEG_STAT_OBJ delete statement
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Delete STATS$SEG_STAT_OBJ';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DELETE --+ index_ffs(sso)
        FROM  stats$seg_stat_obj sso
        WHERE (   dbid
                , dataobj#
                , obj#
              )
              NOT IN
              (
                select --+ hash_aj full(ss) no_expand
                    dbid
                  , dataobj#
                  , obj#
                from
                    stats$seg_stat ss
                where ( ( snap_id     < v_LowSnapId
                          or
                          snap_id     > v_HiSnapId
                         )
                         and dbid            = v_DbId
                         and instance_number = v_InstanceNumber
                      )
                      or
                      ( dbid            != v_DbId
                        or
                        instance_number != v_InstanceNumber
                      )
              );

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$seg_stat_obj DELETE %ROWCOUNT         : ' || v_tempRowCount);


        -- -------------------------------------------------------------------------
        -- Delete from stats$undostat - Undostat rows that cover the snap times
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Delete from stats$undostat';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DELETE  from stats$undostat
         WHERE  dbid            = v_DbId
           AND  instance_number = v_InstanceNumber
           AND  end_time        < v_EndTime;

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$undostat DELETE %ROWCOUNT             : ' || v_tempRowCount);


        -- -------------------------------------------------------------------------
        -- Delete from stats$database_instance.
        -- Dangling database instance rows for that startup time
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Delete from stats$database_instance';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DELETE from stats$database_instance di
         WHERE instance_number = v_InstanceNumber
           AND dbid            = v_DbId
           AND NOT EXISTS (select 1
                           from   stats$snapshot s
                           where  s.dbid            = di.dbid
                             and  s.instance_number = di.instance_number
                             and  s.startup_time    = di.startup_time);

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$database_instance DELETE %ROWCOUNT    : ' || v_tempRowCount);


        -- -------------------------------------------------------------------------
        -- Delete from stats$statspack_parameter
        -- Dangling statspack parameter rows for the database / instance
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Delete from stats$statspack_parameter';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DELETE from stats$statspack_parameter sp
         WHERE instance_number = v_InstanceNumber
           AND dbid            = v_DbId
           AND NOT EXISTS (select 1
                           from   stats$snapshot s
                           where  s.dbid            = sp.dbid
                             and  s.instance_number = sp.instance_number);

        v_tempRowCount := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('stats$statspack_parameter DELETE %ROWCOUNT  : ' || v_tempRowCount);


        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;


    EXCEPTION

        WHEN e_NoRecordsFound THEN
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'WARNING: ' || v_ActionContext);

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge_schedule                                |
    -- |                                                           |
    -- |             Utility procedure used to schedule the        |
    -- |             "purge()" procedure - removing a given number |
    -- |             of obsolete records by the provided number of |
    -- |             days parameter.                               |
    -- +-----------------------------------------------------------+
    PROCEDURE purge_schedule(  in_days_older_than IN INTEGER
                             , in_start_date      IN DATE
                             , in_interval        IN VARCHAR2)
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);
        v_JobNumber              NUMBER;
        v_InstanceNumber         NUMBER;

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.purge_schedule';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');


        -- -------------------------------------------------------------------------
        -- Get instance number
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Get instance number';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        SELECT instance_number INTO v_InstanceNumber FROM v$instance;


        -- -------------------------------------------------------------------------
        -- Submit job
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit job';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        DBMS_JOB.SUBMIT(   job       => v_JobNumber
                         , what      => 'statspack_custom.purge(' || in_days_older_than || ');'
                         , next_date => in_start_date
                         , interval  => in_interval
                         , no_parse  => TRUE
                         , instance  => v_InstanceNumber);

        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;



    -- +-----------------------------------------------------------+
    -- | PROCEDURE - purge_schedule_midnight                       |
    -- |                                                           |
    -- |             Utility procedure used to schedule the        |
    -- |             "purge()" procedure to run every day at       |
    -- |             midnight - removing a given number of         |
    -- |             obsolete records by the provided number of    |
    -- |             days parameter.                               |
    -- +-----------------------------------------------------------+
    PROCEDURE purge_schedule_midnight(in_days_older_than IN INTEGER)
    IS

        v_ModuleName             VARCHAR2(48);
        v_ActionContext          VARCHAR2(100);
        v_ErrorMessage           VARCHAR2(1000);

    BEGIN

        DBMS_OUTPUT.ENABLE(1000000);

        -- -------------------------------------------------------------------------
        -- Register and initialize program module plus set the Client Info
        -- -------------------------------------------------------------------------
        v_ModuleName     := 'statspack_custom.purge_schedule_midnight';
        v_ActionContext  := 'Begin';

        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => v_ModuleName
                                          , action_name => v_ActionContext);

        DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => 'PERFSTAT');

        -- -------------------------------------------------------------------------
        -- Submit midnight job
        -- -------------------------------------------------------------------------
        v_ActionContext := 'Submit midnight job';
        DBMS_APPLICATION_INFO.SET_ACTION(action_name => v_ActionContext);

        statspack_custom.purge_schedule(in_days_older_than, trunc(sysdate+1), 'SYSDATE+1');

        -- -------------------------------------------------------------------------
        -- Successful end to module.
        -- -------------------------------------------------------------------------
        DBMS_APPLICATION_INFO.SET_MODULE(   module_name => null
                                          , action_name => null);

        COMMIT;

    EXCEPTION

        WHEN others THEN
            v_ErrorMessage := sqlerrm;
            DBMS_APPLICATION_INFO.SET_MODULE(v_ModuleName, 'ERROR: ' || v_ActionContext);
            RAISE_APPLICATION_ERROR(-20000, v_ActionContext || chr(10) || v_ErrorMessage);

    END;


END statspack_custom;
/

SET TERMOUT ON
SHOW ERRORS

PROMPT 

SPOOL OFf
