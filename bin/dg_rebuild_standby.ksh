#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : dg_rebuild_standby.ksh                                        |
# | CLASS      : UNIX Shell Scripts                                            |
# |                                                                            |
# | PURPOSE    : Creates a physical standby database for the production server |
# |              "orcl" using RMAN.                                            |
# |                                                                            |
# | PARAMETERS : None.                                                         |
# |                                                                            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# |                                                                            |
# |                       DEFINE ALL GLOBAL VARIABLES                          |
# |                                                                            |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
VERSION="3.9"
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%%\.ksh}

# ----------------------------
# DATE VARIABLES
# ----------------------------
START_DATE=`date`
CURRENT_YEAR=`${DATE_BIN} +"%Y"`;
DATE_LOG=`date +%Y%m%d_%H%M`
TODAY=${DATE_LOG}

# ----------------------------
# CUSTOM DIRECTORIES
# ----------------------------
CUSTOM_ORACLE_DIR=/u01/app/oracle/dba_scripts
CUSTOM_ORACLE_BIN_DIR=${CUSTOM_ORACLE_DIR}/bin
CUSTOM_ORACLE_LIB_DIR=${CUSTOM_ORACLE_DIR}/lib
CUSTOM_ORACLE_LOG_DIR=${CUSTOM_ORACLE_DIR}/log
CUSTOM_ORACLE_OUT_DIR=${CUSTOM_ORACLE_DIR}/out
CUSTOM_ORACLE_SQL_DIR=${CUSTOM_ORACLE_DIR}/sql
CUSTOM_ORACLE_TEMP_DIR=${CUSTOM_ORACLE_DIR}/temp

# ----------------------------
# LOG FILE VARIABLES
# ----------------------------
LOG_FILE_NAME=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${DATE_LOG}.log
LOG_FILE_ARCHIVE_OBSOLETE_DAYS=7

# ----------------------------
# EMAIL VARIABLES
# ----------------------------
MAIL_FILE_NAME=${CUSTOM_ORACLE_TEMP_DIR}/${SCRIPT_NAME_NOEXT}.mhr
ERRORS="NO"

# ----------------------------
# HOSTNAME VARIABLES
# ----------------------------
HOSTNAME=`hostname`
HOSTNAME_UPPER=`hostname | tr '[:lower:]' '[:upper:]'`
HOSTNAME_SHORT=${HOSTNAME%%\.*}
HOSTNAME_SHORT_UPPER=`echo $HOSTNAME_SHORT | tr '[:lower:]' '[:upper:]'`

# ----------------------------
# ORACLE ENVIRONMENT VARIABLES
# ----------------------------
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=${ORACLE_BASE}/product/10.2.0/db_1
ORACLE_ADMIN_DIR=${ORACLE_BASE}/admin

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
TARGET_DB=orcl
AUXILIARY_DB=orclgs
DG_STAGING_DIR=/u03/dg_staging
REMOTE_SHELL_BINARY=/usr/bin/ssh
REMOTE_COPY_BINARY=/usr/bin/scp
REMOTE_COPY_SERVER=linuxgs
REMOTE_COPY_DG_STAGING_DIR=/u03/dg_staging
DBA_USERNAME=SYS
SYS_PASSWORD=dbaz0n3



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                       DEFINE ALL GLOBAL FUNCTIONS                          |
# |                                                                            |
# +----------------------------------------------------------------------------+

function wl {

  echo "${1}" >> ${LOG_FILE_NAME}
  echo "${1}"

}

function startScript {

  DATE_START=`date "+%m/%d/%Y %H:%M"`
  echo "START: ${DATE_START}" > ${LOG_FILE_NAME}

}

function endScript {

  DATE_END=`date "+%m/%d/%Y %H:%M"`
  echo "END: ${DATE_END}" >> ${LOG_FILE_NAME}

}

showSignonBanner() {

    wl " "
    wl "${SCRIPT_NAME} - Version ${VERSION}"
    wl "Copyright (c) 1998-${CURRENT_YEAR} Jeffrey M. Hunter. All rights reserved."
    wl " "

}

function errorExit {

  wl " "
  wl "TRACE> CRITICAL ERROR"
  wl "TRACE> Exiting script."
  wl " "
  exit 2
}


# +----------------------------------------------------------------------------+
# |                                                                            |
# |                            SCRIPT STARTS HERE                              |
# |                                                                            |
# +----------------------------------------------------------------------------+

startScript

showSignonBanner


wl " "
wl "------------------------------------------------------------------------------"
wl "This script will rebuild a physical standby database for the primary database "
wl "running on this node. This script MUST be run from the node hosting the       "
wl "primary production database. Continue - (y/[n])?"
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
wl "+----------------------------------------------------------------------------+"
wl "| TEST LOGIN TO TARGET DATABASE                                              |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE_NAME
  whenever sqlerror exit failure
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} as sysdba
  set head off
  set linesize 145
  select 'TRACE> Successfully logged in to the target database (${TARGET_DB}) as the ' || user || ' user!' from dual;
EOF

if (( $? == 0 )); then
  wl " "
  wl "TRACE> Target database (${TARGET_DB}) IS running!"
else 
  wl " "
  wl "TRACE> Target database (${TARGET_DB}) IS NOT running!"
  errorExit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK THAT THE STANDBY INSTANCE IS UP                                      |"
wl "+----------------------------------------------------------------------------+"

COMMAND="${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ps -ef | grep smon | grep ${AUXILIARY_DB} | grep -v 'grep'"
wl ${COMMAND}
${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ps -ef | grep smon | grep ${AUXILIARY_DB} | grep -v 'grep'

if (( $? == 0 )); then
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) IS running on host (${REMOTE_COPY_SERVER})!"
else 
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) IS NOT running on host ${REMOTE_COPY_SERVER}."
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) must be up in NOMOUNT mode to continue."
  errorExit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK THAT THE TNS SERVICE NAME FOR THE STANDBY DATABASE IS VALID          |"
wl "+----------------------------------------------------------------------------+"

tnsping ${AUXILIARY_DB}

if (( $? == 0 )); then
  wl " "
  wl "TRACE> The TNS service name for the auxiliary instance (${AUXILIARY_DB}) IS valid!"
else
  wl " "
  wl "TRACE> The TNS service name for the auxiliary instance (${AUXILIARY_DB}) IS NOT valid."
  errorExit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK FOR VALID PASSWORD FILE FOR AUXILIARY INSTANCE                       |"
wl "+----------------------------------------------------------------------------+"

COMMAND="${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ls -l $ORACLE_HOME/dbs/orapw${AUXILIARY_DB}"
wl ${COMMAND}

RESULTS=`${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ls -l $ORACLE_HOME/dbs/orapw${AUXILIARY_DB}`
wl "RESULTS :  $RESULTS"

if [[ $RESULTS == "" ]]; then
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) DOES NOT HAVE a valid password file on host (${REMOTE_COPY_SERVER})!"
  errorExit
else 
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) HAS a valid password file on host (${REMOTE_COPY_SERVER})!"
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CHECK FOR VALID SPFILE OR PFILE FOR AUXILIARY INSTANCE                     |"
wl "+----------------------------------------------------------------------------+"

COMMAND="${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ls -l $ORACLE_HOME/dbs/init${AUXILIARY_DB}.ora"
wl ${COMMAND}

RESULTS=`${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} ls -l $ORACLE_HOME/dbs/init${AUXILIARY_DB}.ora`
wl "RESULTS :  $RESULTS"

if [[ $RESULTS == "" ]]; then
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) DOES NOT HAVE a valid spfile on host (${REMOTE_COPY_SERVER})!"
  errorExit
else 
  wl " "
  wl "TRACE> The auxiliary instance (${AUXILIARY_DB}) HAS a valid spfile on host (${REMOTE_COPY_SERVER})!"
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ATTEMPT TO LOGIN TO AUXILIARY INSTANCE                                     |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${AUXILIARY_DB} as sysdba
  set linesize 135
  select username, program, machine from v\$session;
EOF



wl " "
wl " "
wl "+-----------------------+"
wl "|  !!!   WARNING   !!!  |"
wl "|------------------------------------------------------------------------+"
wl "| This script is responsible for creating a physical standby database    |"
wl "| for the primary production database running on this node. The standby  |"
wl "| will be created using an RMAN backup of the primary database that will |"
wl "| be created and transferred to the standby site.                        |"
wl "|                                                                        |"
wl "| Please note that the following prerequisites MUST be met before        |"
wl "| continuing the running of this script:                                 |"
wl "|                                                                        |"
wl "|    1.) RMAN must be configured with persistant configuration       "
wl "|        parameters for the primary database (${TARGET_DB})          "
wl "|        --> PASSED                                                  "
wl "|                                                                    "
wl "|    2.) The auxiliary instance (${TARGET_DB}) should be running     "
wl "|        in NOMOUNT mode on host ${REMOTE_COPY_SERVER}.              "
wl "|        --> PASSED                                                  "
wl "|                                                                    "
wl "|    3.) The auxiliary instance (${TARGET_DB}) should be accessible  "
wl "|        through the TNS service name (${AUXILIARY_DB}).             "
wl "|        --> PASSED                                                  "
wl "|                                                                    "
wl "|    4.) The auxiliary instance (${TARGET_DB}) has a valid password  "
wl "|        file on host ${REMOTE_COPY_SERVER}.                         "
wl "|        --> PASSED                                                  "
wl "|                                                                    "
wl "|    5.) The auxiliary instance (${TARGET_DB}) has a valid SPFILE    "
wl "|        on host ${REMOTE_COPY_SERVER}.                              "
wl "|        --> PASSED                                                  "
wl "|                                                                    "
wl "+------------------------------------------------------------------------+"

wl " "
wl "Would you like to continue to create the standby database (y/[n])?"
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
wl "| CREATE DATA GUARD STAGING DIRECTORY - (primary / standby database)         |"
wl "+----------------------------------------------------------------------------+"

mkdir -p ${DG_STAGING_DIR}

COMMAND="${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} mkdir -p ${REMOTE_COPY_DG_STAGING_DIR}"
wl ${COMMAND}

RESULTS=`${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} "mkdir -p ${REMOTE_COPY_DG_STAGING_DIR}"`
wl "RESULTS :  $RESULTS"

if (( $? == 0 )); then
  wl " "     
  wl "TRACE> Successfully created ${REMOTE_COPY_DG_STAGING_DIR} on host (${REMOTE_COPY_SERVER})!"
else     
  wl " "
  wl "TRACE> Failed to create ${REMOTE_COPY_DG_STAGING_DIR} directory on host (${REMOTE_COPY_SERVER})!"
  errorExit                                                                  
fi 


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CLEAR OUT ANY PREVIOUS DATA FROM    - (primary / standby database)         |"
wl "| THE DATA GUARD STAGING DIRECTORY                                           |"
wl "+----------------------------------------------------------------------------+"

rm -f ${DG_STAGING_DIR}/*

COMMAND="${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} rm -f ${REMOTE_COPY_DG_STAGING_DIR}/*"
wl ${COMMAND}

RESULTS=`${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} "rm -f ${REMOTE_COPY_DG_STAGING_DIR}/*"`
wl "RESULTS :  $RESULTS"

if (( $? == 0 )); then
  wl " "
  wl "TRACE> Successfully cleared files from the ${REMOTE_COPY_DG_STAGING_DIR} on host (${REMOTE_COPY_SERVER})!"
else
  wl " "
  wl "TRACE> Failed to clear files from the ${REMOTE_COPY_DG_STAGING_DIR} directory on host (${REMOTE_COPY_SERVER})!"
  errorExit
fi


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| DEFER ALL LOG TRANSPORT SERVICES - (primary database)                      |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} as sysdba
  alter system set log_archive_dest_state_2=defer scope=both;
  -- alter system set log_archive_dest_state_3=defer scope=both;
  -- alter system set log_archive_dest_state_4=defer scope=both;
  -- alter system set log_archive_dest_state_5=defer scope=both;
  -- alter system set log_archive_dest_state_6=defer scope=both;
  -- alter system set log_archive_dest_state_7=defer scope=both;
  -- alter system set log_archive_dest_state_8=defer scope=both;
  -- alter system set log_archive_dest_state_9=defer scope=both;
EOF



wl " "
wl "+----------------------------------------------------------------------------+"
wl "| BACKUP THE DATABASE TO THE DATA GUARD STAGING DIRECTORY                    |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/rman target ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} nocatalog <<EOF | tee -a $LOG_FILE_NAME
  crosscheck backup;
  delete noprompt force expired backup;
  backup device type disk format '${REMOTE_COPY_DG_STAGING_DIR}/%U' database plus archivelog;
  backup device type disk format '${REMOTE_COPY_DG_STAGING_DIR}/%U' current controlfile for standby;
  exit;
EOF


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| TAKE STANDBY DATABASE OUT OF MANAGED RECOVERY MODE                         |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${AUXILIARY_DB} as sysdba
  alter database recover managed standby database cancel;
  shutdown immediate
EOF


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CREATE SCRIPTS TO BE EXECUTED ON REMOTE SERVER                             |"
wl "+----------------------------------------------------------------------------+"

# ---------------------------
# REMOVE ASM FILES SQL SCRIPT
# ---------------------------
echo "SET LINESIZE  255
SET PAGESIZE  9999
SET VERIFY    off
SET FEEDBACK  off
SET HEAD      off

COLUMN full_alias_path    FORMAT a255       HEAD 'File Name'
COLUMN disk_group_name    noprint

SELECT
    'ALTER DISKGROUP '  ||
        disk_group_name ||
        ' DROP FILE ''' || CONCAT('+' || disk_group_name, SYS_CONNECT_BY_PATH(alias_name, '/')) || ''';' full_alias_path
FROM
    ( SELECT
          g.name               disk_group_name
        , a.parent_index       pindex
        , a.name               alias_name
        , a.reference_index    rindex
        , f.type               type
      FROM
          v\$asm_file f RIGHT OUTER JOIN v\$asm_alias     a USING (group_number, file_number)
                                   JOIN v\$asm_diskgroup g USING (group_number)
    )
WHERE type IS NOT NULL
START WITH (MOD(pindex, POWER(2, 24))) = 0
    CONNECT BY PRIOR rindex = pindex
/
exit
" > ${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files.sql


# -------------------
# NEW init.ora SCRIPT
# -------------------
echo "orclgs.__db_cache_size=1191182336
orclgs.__java_pool_size=16777216
orclgs.__large_pool_size=16777216
orclgs.__shared_pool_size=402653184
orclgs.__streams_pool_size=0
*.audit_file_dest='/u01/app/oracle/admin/orclgs/adump'
*.background_dump_dest='/u01/app/oracle/admin/orclgs/bdump'
*.cluster_database=FALSE
*.compatible='10.2.0.3.0'
*.control_files='+ORCL_DATA1/ORCLGS/CONTROLFILE/current.256.624388077','+FLASH_RECOVERY_AREA/ORCLGS/CONTROLFILE/current.256.624388077'
*.core_dump_dest='/u01/app/oracle/admin/orclgs/cdump'
*.db_block_size=8192
*.db_create_file_dest='+ORCL_DATA1'
*.db_domain='idevelopment.info'
*.db_file_multiblock_read_count=16
*.db_file_name_convert='+ORCL_DATA1/ORCL/','+ORCL_DATA1/ORCLGS/','+FLASH_RECOVERY_AREA/ORCL/','+FLASH_RECOVERY_AREA/ORCLGS/'
*.log_file_name_convert='+ORCL_DATA1/ORCL/','+ORCL_DATA1/ORCLGS/','+FLASH_RECOVERY_AREA/ORCL','+FLASH_RECOVERY_AREA/ORCLGS/'
*.db_name='orcl'
*.db_recovery_file_dest='+FLASH_RECOVERY_AREA'
*.db_recovery_file_dest_size=212599832576
*.db_unique_name='orclgs'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=ORCLGSXDB)'
*.fal_server='orcl1','orcl2','orcl3'
*.fal_client='orclgs'
*.instance_name='orclgs'
*.job_queue_processes=10
*.log_archive_config='dg_config=(orcl,orclgs)'
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST'
*.log_archive_dest_2='service=ORCL1 valid_for=(online_logfiles,primary_role) db_unique_name=orcl'
*.open_cursors=300
*.pga_aggregate_target=839909376
*.processes=850
*.remote_login_passwordfile='exclusive'
*.service_names='orclgs'
*.sga_target=1610612736
*.standby_file_management=auto
*.thread=1
*.undo_management='AUTO'
*.undo_retention=21600
orclgs.undo_tablespace='UNDOTBS1'
*.user_dump_dest='/u01/app/oracle/admin/orclgs/udump'" >  ${REMOTE_COPY_DG_STAGING_DIR}/initorclgs.ora


# --------------------------
# REMOTE EXECUTION SCRIPT
# --------------------------
echo "#!/bin/ksh
. /u01/app/oracle/.bash_profile

export ORACLE_SID=+ASM
sqlplus -s \"/ as sysdba\" @${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files.sql > ${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files_DG.sql
echo \"exit;\" >> ${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files_DG.sql
sqlplus \"/ as sysdba\" @${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files_DG.sql
sqlplus \"/ as sysdba\" @${REMOTE_COPY_DG_STAGING_DIR}/asm_drop_files.sql

rm -f ${ORACLE_ADMIN_DIR}/${AUXILIARY_DB}/*/*

cp ${REMOTE_COPY_DG_STAGING_DIR}/initorclgs.ora ${ORACLE_HOME}/dbs/initorclgs.ora

export ORACLE_SID=orclgs
sqlplus \"/ as sysdba\" <<EOF
CREATE SPFILE='+ORCL_DATA1/ORCLGS/spfileorclgs.ora' FROM PFILE='?/dbs/initorclgs.ora';
EOF

cd $ORACLE_HOME/dbs
echo "SPFILE='+ORCL_DATA1/ORCLGS/spfileorclgs.ora'" > initorclgs.ora
"  > ${REMOTE_COPY_DG_STAGING_DIR}/remote_execution_script.ksh

chmod 755 ${REMOTE_COPY_DG_STAGING_DIR}/remote_execution_script.ksh


wl "+----------------------------------------------------------------------------+"
wl "| SEND RMAN BACKUPSETS TO REMOTE SERVER                                      |"
wl "| -------------------------------------------------------------------------- |"
wl "| All files that would be required to create a standby database or simply    |"
wl "| recover the target database will be included.                              |"
wl "+----------------------------------------------------------------------------+"

wl "Copying new files to remote server..."
date
${REMOTE_COPY_BINARY} ${REMOTE_COPY_DG_STAGING_DIR}/* oracle@${REMOTE_COPY_SERVER}:${REMOTE_COPY_DG_STAGING_DIR}
date


wl "+----------------------------------------------------------------------------+"
wl "| RUN SHELL SCRIPTS ON REMOTE HOST                                           |"
wl "| -------------------------------------------------------------------------- |"
wl "|   - Remove files from ASM for previous standby database.                   |"
wl "+----------------------------------------------------------------------------+"

${REMOTE_SHELL_BINARY} ${REMOTE_COPY_SERVER} "${REMOTE_COPY_DG_STAGING_DIR}/remote_execution_script.ksh"


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| PUT STANDBY DATABASE IN NOMOUNT MODE                                       |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${AUXILIARY_DB} as sysdba
  startup nomount
EOF


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| RECOVER / CREATE STANDBY DATABASE                                          |"
wl "| -------------------------------------------------------------------------- |"
wl "| Login to target (primary) and (standby) auxiliary database using RMAN. All |"
wl "| of this should be performed from the target database server. In order to   |"
wl "| perform this section, you will need the last log sequence number, which    |"
wl "| we recorded earlier in this script.                                        |"
wl "|                                                                            |"
wl "| Notice that the parameter NOFILENAMECHECK must be used when you are        |"
wl "| duplicating a database to a different host with the same file system       |"
wl "| (directory structure).                                                     |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/rman target ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} auxiliary ${DBA_USERNAME}/${SYS_PASSWORD}@${AUXILIARY_DB} <<EOF | tee -a $LOG_FILE_NAME
  duplicate target database for standby;
  exit;
EOF


wl " "
wl "+----------------------------------------------------------------------------+"
wl "| PUT STANDBY DATABASE IN MANAGED STANDBY MODE                               |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${AUXILIARY_DB} as sysdba

  set linesize 135

  select username, program, machine from v\$session;

  recover standby database;
auto

  ALTER DATABASE DROP STANDBY LOGFILE GROUP 7;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 8;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 9;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 10;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 11;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 12;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 13;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 14;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 15;

  ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 7 SIZE 51200K, GROUP 8 SIZE 51200K, GROUP 9 SIZE 51200K;
  ALTER DATABASE ADD STANDBY LOGFILE THREAD 2 GROUP 10 SIZE 51200K, GROUP 11 SIZE 51200K, GROUP 12 SIZE 51200K;
  ALTER DATABASE ADD STANDBY LOGFILE THREAD 3 GROUP 13 SIZE 51200K, GROUP 14 SIZE 51200K, GROUP 15 SIZE 51200K;

  ALTER DATABASE FLASHBACK ON;

  alter database recover managed standby database disconnect from session;

  alter system set job_queue_processes=0 scope=both;

EOF



wl " "
wl "+----------------------------------------------------------------------------+"
wl "| CREATE STANDBY REDO LOGS - (primary database)                              |"
wl "| -------------------------------------------------------------------------- |"
wl "| Certain protection modes, such as maximum protection and maximum           |"
wl "| availability, mandate that standby redo logs be present. It is good        |"
wl "| practice to create standby redo logs on both the primary and the standby   |"
wl "| so as to make role transitions smoother.                                   |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE_NAME

  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} as sysdba

  ALTER DATABASE DROP STANDBY LOGFILE GROUP 7;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 8;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 9;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 10;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 11;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 12;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 13;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 14;
  ALTER DATABASE DROP STANDBY LOGFILE GROUP 15;

 ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 GROUP 7 SIZE 51200K, GROUP 8 SIZE 51200K, GROUP 9 SIZE 51200K;
 ALTER DATABASE ADD STANDBY LOGFILE THREAD 2 GROUP 10 SIZE 51200K, GROUP 11 SIZE 51200K, GROUP 12 SIZE 51200K;
 ALTER DATABASE ADD STANDBY LOGFILE THREAD 3 GROUP 13 SIZE 51200K, GROUP 14 SIZE 51200K, GROUP 15 SIZE 51200K;

EOF



wl " "
wl "+----------------------------------------------------------------------------+"
wl "| DO A FINAL LOG SWITCH ON PRIMARY                                           |"
wl "| -------------------------------------------------------------------------- |"
wl "| This is needed to re-establish connection to standby database in max.      |"
wl "| avail. mode.                                                               |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${SYS_PASSWORD}@${TARGET_DB} as sysdba
  set heading off
  alter system set log_archive_dest_state_2 = enable scope=both;
  alter system switch logfile;
EOF


wl " "
wl "+------------------------------------------------------------------------------+"
wl "| ENDING SCRIPT.                                                               |"
wl "+------------------------------------------------------------------------------+"

endScript
