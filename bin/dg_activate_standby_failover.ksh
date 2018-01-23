#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : dg_activate_standby_failover.ksh                              |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : This script is part of a larger disaster recovery plan and    |
# |              executes the tasks responsible to FAILOVER a physical standby |
# |              database to make it the primary database in a Data Guard      |
# |              configuration. A failover implies that the primary database   |
# |              is unavailable and that there is no possibility of restoring  |
# |              it to a service within a reasonable amount of time. Depending |
# |              on the protection mode, the possibility of data loss exists.  |
# |                                                                            |
# |              This script can be used on a single instance (non-RAC)        |
# |              physical standby database regardless of its "protection mode" |
# |              - maximum performance, maximum availability, or maximum       |
# |              protection.                                                   |
# |                                                                            |
# |              Prompts are provided throughout this script to walk the DBA   |
# |              through the role transition process and providing him/her     |
# |              with a clear understanding of the consequences involved when  |
# |              performing a failover operation.                              |
# |                                                                            |
# |              Anyone executing this script should have a clear              |
# |              understanding of the outcome after performing a failover      |
# |              operation.                                                    |
# |                                                                            |
# |              IMPORTANT: Verify that this script is being run from the node |
# |                         hosting the physical standby database. DO NOT      |
# |                         attempt to run this script from the primary node.  |
# |                                                                            |
# | PARAMETERS : None.                                                         |
# |                                                                            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# | GLOBAL VARIABLES                                                           |
# +----------------------------------------------------------------------------+

export DFLT_ORACLE_SID=orclgs
export DFLT_ORACLE_HOME=/u01/app/oracle/product/10.2.0/db_1
export DFLT_USING_STDBY_LOGS=Y
export RUN_USERID=oracle

export VERSION="3.8"
export SCRIPT_NAME_FULL=$0
export SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
export SCRIPT_NAME_NOEXT=${SCRIPT_NAME%%\.ksh}
export DATE=`date +%Y``date +%m``date +%d`
export TIME=`date +%H%M`
export DAY=`date +%a`
export CURRENT_YEAR=`${DATE_BIN} +"%Y"`;
export THIS_HOST=`hostname`
export DATE_LOG=`date +%Y%m%d_%H%M`
export LOG_FILE=${SCRIPT_NAME_NOEXT}_${DATE_LOG}.log


# +----------------------------------------------------------------------------+
# | GLOBAL FUNCTIONS                                                           |
# +----------------------------------------------------------------------------+

function wl {

    echo "${1}" >> ${LOG_FILE}
    echo "${1}"

}

function verifyOracleUser {

    RUID=`id | awk -F\( '{print $2}'|awk -F\) '{print $1}'`
    if [[ ${RUID} != "$RUN_USERID" ]];then
        wl "You must be logged in as $RUN_USERID to run this script."
        wl "Exiting script."
        wl " "
        exit 1
    fi

}

function startScript {

    DATE_START=`date "+%m/%d/%Y %H:%M"`
    echo "START: ${DATE_START}" > ${LOG_FILE}

}

function endScript {

    DATE_END=`date "+%m/%d/%Y %H:%M"`
    echo "END: ${DATE_END}" >> ${LOG_FILE}

}

showSignonBanner() {

    wl " "
    wl "${SCRIPT_NAME} - Version ${VERSION}"
    wl "Copyright (c) 1998-${CURRENT_YEAR} Jeffrey M. Hunter. All rights reserved."
    wl " "

}

function usage {

    wl " "
    wl "Usage: ${SCRIPT_NAME_NOEXT}.ksh \"TARGET_STANDBY_ORACLE_SID\""
    wl " "

}


function errorExit {

    wl " "
    wl "!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    wl "!!!!!! CRITICAL ERROR !!!!!!"
    wl "!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    wl "Exiting script."
    wl " "
    exit 2
}


# +----------------------------------------------------------------------------+
# | GATHER ALL SCRIPT VARIABLES FROM USER FOR THE TARGET STANDBY DATABASE      |
# +----------------------------------------------------------------------------+

startScript

showSignonBanner

verifyOracleUser


wl " "
wl "------------------------------------------------------------------------------"
wl "This script will transition the role of the physical standby database running "
wl "on this node to the primary role. This script MUST be run from the node       "
wl "hosting the physical standby database. Continue - (y/[n])?"
wl "------------------------------------------------------------------------------"
wl " "

read userResponse

if [[ ${userResponse} == "" || ${userResponse} == "N" || ${userResponse} == "n" ]]; then
    wl "Exiting script as per user request."
    wl "Good-bye!"
    wl " "
    exit
fi


wl " "
wl "----------------------------------------------------------"
wl "Gathering script variables for the target standby database"
wl "----------------------------------------------------------"
wl " "


wl " "
wl "Please enter ORACLE_SID [ $DFLT_ORACLE_SID ]:"

read userResponse

if [[ ${userResponse} == ""  ]]; then
    ORACLE_SID=$DFLT_ORACLE_SID
else
    ORACLE_SID=${userResponse}
fi

TARGET_STANDBY_ORACLE_SID=${ORACLE_SID}


wl " "
wl "Please enter ORACLE_HOME [ $DFLT_ORACLE_HOME ]:"

read userResponse

if [[ ${userResponse} == ""  ]]; then
    ORACLE_HOME=$DFLT_ORACLE_HOME
else
    ORACLE_HOME=${userResponse}
fi


wl " "
wl "Is the target standby database using Standby Redo Logs (y/n)? [ $DFLT_USING_STDBY_LOGS ]:"

read userResponse

if [[ ${userResponse} == ""  ]]; then
    DFLT_USING_STDBY_LOGS=`echo "$DFLT_USING_STDBY_LOGS" | tr '[a-z]' '[A-Z]'`
    USING_STDBY_LOGS=$DFLT_USING_STDBY_LOGS
else
    userResponse=`echo "${userResponse}" | tr '[a-z]' '[A-Z]'`
    if [[ ${userResponse} == "Y"  || ${userResponse} == "N" ]]; then
      USING_STDBY_LOGS=${userResponse}
    else
      wl "Invalid response. Please answer either Y or N."
      wl "Good-bye!"
      wl " "
      exit
    fi
fi



wl "-----------------------------------------------------------------"
wl " "
wl "You have specified the following settings"
wl " "
wl "Target Standby Database ORACLE_SID  ................ $ORACLE_SID"
wl "Standby Database ORACLE_HOME ....................... $ORACLE_HOME"
wl "Using Standby Redo Logs? ........................... $USING_STDBY_LOGS"
wl " "
wl "-----------------------------------------------------------------"

wl " "
wl "Do you wish to Continue? - (y/[n])"
wl " "

read userResponse

if [[ ${userResponse} == "" || ${userResponse} == "N" || ${userResponse} == "n" ]]; then
    wl "Exiting script as per user request."
    wl "Good-bye!"
    wl " "
    exit
fi

export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:$LD_LIBRARY_PATH



wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK FOR VALID PASSWORD FILE FOR TARGET STANDBY INSTANCE                  |"
wl "+----------------------------------------------------------------------------+"

COMMAND="ls -l $ORACLE_HOME/dbs/orapw${TARGET_STANDBY_ORACLE_SID}"
wl ${COMMAND}

RESULTS=`ls -l $ORACLE_HOME/dbs/orapw${TARGET_STANDBY_ORACLE_SID}`
wl "RESULTS :  $RESULTS"

if [[ $RESULTS == "" ]]; then
    wl " "
    wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) DOES NOT HAVE a valid password file on host (${THIS_HOST})!"
    errorExit
else
    wl " "
    wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) HAS a valid password file on host (${THIS_HOST})!"
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK FOR VALID PFILE / SPFILE FOR TARGET STANDBY INSTANCE                 |"
wl "+----------------------------------------------------------------------------+"

COMMAND="ls -l $ORACLE_HOME/dbs/init${TARGET_STANDBY_ORACLE_SID}.ora"
wl ${COMMAND}

RESULTS=`ls -l $ORACLE_HOME/dbs/init${TARGET_STANDBY_ORACLE_SID}.ora`
wl "RESULTS :  $RESULTS"

if [[ $RESULTS == "" ]]; then
    wl " "
    wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) DOES NOT HAVE a valid pfile / spfile on host (${THIS_HOST})!"
    errorExit
else
    wl " "
    wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) HAS a valid pfile / spfile on host (${THIS_HOST})!"
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK THAT THE TARGET STANDBY INSTANCE IS UP                               |"
wl "+----------------------------------------------------------------------------+"

COMMAND="ps -ef | grep smon | grep ${TARGET_STANDBY_ORACLE_SID} | grep -v 'grep'"
wl ${COMMAND}
ps -ef | grep smon | grep ${TARGET_STANDBY_ORACLE_SID} | grep -v 'grep'

if (( $? == 0 )); then
  wl " "
  wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) IS running on host (${THIS_HOST})!"
else
  wl " "
  wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) IS NOT running on host ${THIS_HOST}."
  wl "TRACE> The target standby instance (${TARGET_STANDBY_ORACLE_SID}) must be up to continue."
  errorExit
fi



wl " "
wl " "
wl "+-----------------------+"
wl "|  !!!   WARNING   !!!  |"
wl "|------------------------------------------------------------------------+"
wl "| This script is responsible for transitioning the role of a physical    |"
wl "| standby database running on this node to the primary role.             |"
wl "|                                                                        |"
wl "| This script is part of a larger disaster recovery plan and executes    |"
wl "| the tasks responsible to FAILOVER a physical standby database to make  |"
wl "| it the primary database in a Data Guard configuration. A failover      |"
wl "| implies that the primary database is unavailable and that there is no  |"
wl "| possibility of restoring it to a service within a reasonable amount of |"
wl "| time. Depending on the protection mode, the possibility of data loss   |"
wl "| exists.                                                                |"
wl "|                                                                        |"
wl "| This script can be used on a physical standby database regardless of   |"
wl "| its "protection mode" - maximum performance, maximum availability, or  |"
wl "| maximum protection. Prompts are provided throughout this script to     |"
wl "| walk the DBA through the role transition process to provide him/her    |"
wl "| with a clear understanding of the consequences involved when           |"
wl "| performing a failover operation.                                       |"
wl "|                                                                        |"
wl "| Anyone executing this script should have a clear understanding of the  |"
wl "| outcome after performing a failover operation.                         |"
wl "|                                                                        |"
wl "| Please note that prior to the actual failover commands that transition |"
wl "| the standby into a primary, you MUST first perform several actions     |"
wl "| that will ensure that the DBA has as much data as possible from the    |"
wl "| primary database. Keep in mind the following actions that should be    |"
wl "| performed to prepare the target physical standby database to assume    |"
wl "| the role of the primary database using this failover operation.        |"
wl "|                                                                        |"
wl "|    1.) First, every attempt should be made to get all unapplied (if    |"
wl "|        any), data off of the primary host and onto the standby host.   |"
wl "|        This would include any archive logs that did not get            |"
wl "|        transferred from the primary database to the target standby     |"
wl "|        database.                                                       |"
wl "|                                                                        |"
wl "|    2.) The definition for any temporary tablespace will be included in |"
wl "|        the data dictionary at the target standby database. The         |"
wl "|        tempfiles associated with the temporary tablespace in Oracle9i, |"
wl "|        however, are not brought over and therefore will not exist      |"
wl "|        after the failover operation is completed. With the release of  |"
wl "|        Oracle10g, this is no longer the case - the tempfiles ARE       |"
wl "|        automatically created as part of the failover process. It is    |"
wl "|        imperative that Oracle9i users manually create all tempfiles    |"
wl "|        that are associated with the temporary tablespace definition    |"
wl "|        after the failover process.                                     |"
wl "|                                                                        |"
wl "|    3.) Remove and DELAY setting for recovery of redo from the primary. |"
wl "|                                                                        |"
wl "|    4.) Change the protection mode of the standby database to maximum   |"
wl "|        performance before attempting the failover operation.           |"
wl "|                                                                        |"
wl "|        NOTE: This script WILL automatically perform the step of        |"
wl "|        modifying the protection mode of the target standby database    |"
wl "|        to maximum performance before attempting the failover           |"
wl "|        operation.                                                      |"
wl "|                                                                        |"
wl "+------------------------------------------------------------------------+"

wl " "
wl "Would you like to continue with the failover operation and transition "
wl "the role of this physical standby database to the primary role - (y/[n])?"
wl " "

read userResponse

if [[ ${userResponse} == "" || ${userResponse} == "N" || ${userResponse} == "n" ]]; then
    wl "Exiting script as per user request."
    wl "Good-bye!"
    wl " "
    exit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| LOOK FOR AND RESOLVE ANY GAPS                                              |"
wl "| -------------------------------------------------------------------------- |"
wl "| You should resolve any gaps that may exist on the standby.                 |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE
  connect / as sysdba
  prompt LOOKING FOR ANY ARCHIVE REDO GAPS...
  select thread#, low_sequence#, high_sequence# from v\$archive_gap;
EOF


wl " "
wl " "
wl "+-----------------------+"
wl "|  !!!   WARNING   !!!  |"
wl "|------------------------------------------------------------------------+"
wl "| Please review the results from the above query. If a record was        |"
wl "| returned from the query against the V\$ARCHIVE_GAP view, this           |"
wl "| indicates a gap in the archived redo logs and may require manual       |"
wl "| intervention by the DBA to prevent data loss. Performing a failover    |"
wl "| operation when gaps exists in the archived redo logs will result in    |"
wl "| data loss. All data contained in the missing archived redo logs will   |"
wl "| not be applied during the recovery process of the failover operation!  |"
wl "|                                                                        |"
wl "| The DBA should make every attempt to recover as much data as possible  |"
wl "| before committing to a failover operation! If the DBA has already made |"
wl "| every attempt to recover any missing archive redo logs that would need |"
wl "| to be registered with the standby database, then this script can       |"
wl "| be continued recognizing that the recovery process involved in the     |"
wl "| failover operation will only apply data up to the last registered redo |"
wl "| log file.                                                              |"
wl "|                                                                        |"
wl "| If gaps exist, the DBA should exit this script and attempt to resolve  |"
wl "| the gaps by copying any missing archivelogs to the standby host. The   |"
wl "| DBA should also verify that no other archive redo logs exist that have |"
wl "| a higher sequence number than the last one registered at the standby   |"
wl "| chosen for failover.                                                   |"
wl "|                                                                        |"
wl "| Any archivelogs that have been copied to resolve a gap need to be      |"
wl "| registered in the standby controlfile. Register the archivelogs with   |"
wl "| the target standby database by running the following command example:  |"
wl "|                                                                        |"
wl "|   ALTER DATABASE REGISTER PHYSICAL LOGFILE "
wl "|   '+FLASH_RECOVERY_AREA/orcl/archivelog/2007_07_31/thread_1_seq_1256.332.629388977'; "
wl "|                                                                        |"
wl "| Note that the V\$ARCHIVE_GAP view only returns the next gap in the redo |"
wl "| logs that would currently block a recovery process (or managed         |"
wl "| recovery process) from continuing. After resolving the identified gap, |"
wl "| the DBA should query the V$ARCHIVE_GAP view again on the physical      |"
wl "| standby database to determine the next (if any) gap sequence. This     |"
wl "| process should be repeated until there are no more gaps.               |"
wl "+------------------------------------------------------------------------+"

wl " "
wl "Would you like to continue with the failover operation and transition "
wl "the role of this physical standby database to the primary role - (y/[n])?"
wl " "

read userResponse

if [[ ${userResponse} == "" || ${userResponse} == "N" || ${userResponse} == "n" ]]; then
    wl "Exiting script as per user request."
    wl "Good-bye!"
    wl " "
    exit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| PREPARE FOR FAILOVER OPERATION                                             |"
wl "| -------------------------------------------------------------------------- |"
wl "| Since this is a failover operation and incomplete recovery will be         |"
wl "| performed on the target standby database, it is assumed that all other     |"
wl "| nodes in the Data Guard configuration (all other standby databases and     |"
wl "| the original primary database) will have to be rebuilt (Unless the         |"
wl "| databases are Oracle10g and configured to use Flashback Database). Under   |"
wl "| this assumption we should DEFER any log transport services that would      |"
wl "| attempt to send redo data from this database (when it becomes the primary) |"
wl "| to any other node in the Data Guard configuration.                         |"
wl "|                                                                            |"
wl "| The protection mode for the target standby database cannot be configured   |"
wl "| for maximum availability or maximum protection when it is involved in a    |"
wl "| failover operation. This script will force the target standby database to  |"
wl "| the protection mode maximum performance.                                   |"
wl "|                                                                            |"
wl "| The last step in the preparation process is to put the target standby      |"
wl "| database in managed recovery mode.                                         |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE

  CONNECT / AS SYSDBA

  ALTER SYSTEM SET job_queue_processes      = 0      SCOPE=both;
  ALTER SYSTEM SET log_archive_dest_state_2 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_3 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_4 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_5 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_6 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_7 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_8 = defer  SCOPE=both;
  -- ALTER SYSTEM SET log_archive_dest_state_9 = defer  SCOPE=both;

  ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
  SHUTDOWN IMMEDIATE

  STARTUP NOMOUNT
  ALTER DATABASE MOUNT STANDBY DATABASE;
  ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE;

  ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

EOF



wl " "
wl "+------------------------------------------------------------------------------+"
wl "| PERFORM TERMINAL RECOVERY                                                    |"
wl "| ---------------------------------------------------------------------------- |"
wl "| At this point, we need to perform terminal recovery on the target standby    |"
wl "| database by issuing managed recovery with the FINISH keyword.                |"
wl "|                                                                              |"
wl "| If the target standby database does contain standby redo logs, the following |"
wl "| SQL statement will be run:                                                   |"
wl "|                                                                              |"
wl "| ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;                      |"
wl "|                                                                              |"
wl "| If the target standby database does not contain standby redo logs, the       |"
wl "| following SQL statement will be run:                                         |"
wl "|                                                                              |"
wl "| ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH SKIP STANDBY LOGFILE; |"
wl "+------------------------------------------------------------------------------+"

if [[ $USING_STDBY_LOGS == "Y" ]]; then
    SQL_COMMAND="ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;"
else
    SQL_COMMAND="ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH SKIP STANDBY LOGFILE;"
fi

wl " "
wl "TRACE> SQL_COMMAND: $SQL_COMMAND"
wl " "

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
  CONNECT / AS SYSDBA
  WHENEVER SQLERROR EXIT FAILURE
  $SQL_COMMAND
EOF

if (( $? == 0 )); then
    wl " "
    wl "TRACE> Successfully performed terminal recovery on (${TARGET_STANDBY_ORACLE_SID}) running on host (${THIS_HOST})!"

    SQL_COMMAND="ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;"
else
    wl " "
    wl "TRACE> !!!!!!!!!!!!!!!!!!!!!!!"
    wl "TRACE> !!!!!!!! ERROR !!!!!!!!"
    wl "TRACE> !!!!!!!!!!!!!!!!!!!!!!!"
    wl "TRACE> Terminal recovery failed on (${TARGET_STANDBY_ORACLE_SID}) running on host (${THIS_HOST})."
    wl "TRACE> Will attempt to perform a manual activation to transition the role from standby to primary."

    SQL_COMMAND="ALTER DATABASE ACTIVATE STANDBY DATABASE;"
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CONVERT TARGET STANDBY DATABASE TO PRIMARY                                 |"
wl "| -------------------------------------------------------------------------- |"
wl "| Once the terminal recovery command completes, transition the target        |"
wl "| standby database to the primary role.                                      |"
wl "+----------------------------------------------------------------------------+"

wl " "
wl "TRACE> SQL_COMMAND: $SQL_COMMAND"
wl " "


$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
  CONNECT / AS SYSDBA
  WHENEVER SQLERROR EXIT FAILURE
  $SQL_COMMAND
EOF

if (( $? == 0 )); then
    wl " "
    wl "TRACE> Successfully converted target standby database (${TARGET_STANDBY_ORACLE_SID}) to the primary role running on host (${THIS_HOST})!"
else
    wl " "
    wl "TRACE> FAILED to convert the target standby database (${TARGET_STANDBY_ORACLE_SID}) to the primary role  running on host (${THIS_HOST})!"
    wl "TRACE> Will attempt to perform a manual activation to transition the role from standby to primary."

    SQL_COMMAND="ALTER DATABASE ACTIVATE STANDBY DATABASE;"

    wl " "
    wl "TRACE> SQL_COMMAND: $SQL_COMMAND"
    wl " "

    $ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
      connect / as sysdba
      $SQL_COMMAND
EOF


fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| RESTART DATABASE                                                           |"
wl "| -------------------------------------------------------------------------- |"
wl "| Finally, restart the new primary database.                                 |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE

  CONNECT / AS SYSDBA

  SHUTDOWN IMMEDIATE;

  STARTUP;

  ALTER SYSTEM SET job_queue_processes=1 SCOPE=both;

  -- Oracle9i Users Only
  -- ALTER TABLESPACE TEMP ADD TEMPFILE SIZE 512M REUSE
  -- AUTOEXTEND ON NEXT 100M MAXSIZE unlimited;

EOF


wl " "
wl "+------------------------------------------------------------------------------+"
wl "| ENDING SCRIPT.                                                               |"
wl "+------------------------------------------------------------------------------+"

endScript
