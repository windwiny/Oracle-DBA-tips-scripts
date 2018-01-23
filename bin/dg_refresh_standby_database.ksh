#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE : Oracle                                                          |
# | FILE     : dg_refresh_standby_database.ksh                                 |
# | CLASS    : UNIX Shell Scripts                                              |
# |                                                                            |
# | USAGE    : dg_refresh_standby_database.ksh  STANDBY_SID  STANDBY_DB_NAME  STANDBY_SYS_PASSWORD  PRIMARY_HOST_NAME  ORA_ARCHIVE_DIR  DAYS_OLD
# |                                                                            |
# | PURPOSE  : Manually refreshes an Oracle standby database by copying over   |
# |            all new archived redo log files from the primary database       |
# |            server using the UNIX utility rsync. This script should ONLY be |
# |            run from the database server hosting the Oracle standby         |
# |            database. Once the new archived redo log files are copied from  |
# |            the primary database server, they will be manually applied to   |
# |            the standby database. Finally, this script will remove any      |
# |            obsolete archived redo logs from the standby database server    |
# |            (the server this script is being run from) using a user-defined |
# |            retention policy (DAYS_OLD parameter).                          |
# |                                                                            |
# | NOTE     : This script assumes that the oracle UNIX user account on the    |
# |            node running this script (the standby database server) is       |
# |            trusted by the remote node (the primary database server)        |
# |            hosting the primary database. This means that the oracle UNIX   |
# |            account must be able to run the secure shell commands (ssh or   |
# |            scp) on the remote node without being prompted for a password   |
# |            (also known as user equivalence). The following section         |
# |            describes how to setup user equivalence for the oracle UNIX     |
# |            account where the primary database will reside on host          |
# |            "linux3.idevelopment.info" and the standby database is hosted   |
# |            on "linux4.idevelopment.info":                                  |
# |                                                                            |
# |                  STBY DB                      PRIMARY                      |
# |                  (linux4)   <--- rsync ---   (linux3)                      |
# |                                                                            |
# |            1.) You need either an RSA or a DSA key for the SSH protocol.   |
# |                RSA is used with the SSH 1.5 protocol, while DSA is the     |
# |                default for the SSH 2.0 protocol. With OpenSSH, you can use |
# |                either RSA or DSA. For the purpose of this script, we will  |
# |                configure SSH using SSH1 - (RSA).                           |
# |                                                                            |
# |            2.) All of the following commands should be executed as the     |
# |                oracle UNIX account on both nodes.                          |
# |                                                                            |
# |            3.) Create an .ssh directory in the HOME directory of the       |
# |                oracle UNIX account and then create an RSA key on both      |
# |                nodes:                                                      |
# |                                                                            |
# |                $ mkdir -p ~/.ssh                                           |
# |                $ chmod 700 ~/.ssh                                          |
# |                $ /usr/bin/ssh-keygen -t rsa                                |
# |                                                                            |
# |                  At the prompts:                                           |
# |                      Accept the default location for the key files.        |
# |                      DO NOT supply a pass phrase - hit <ENTER> twice with  |
# |                      no pass phrase. In short, hit <ENTER> three times     |
# |                      without entering anything at the prompts when         |
# |                      creating the RSA keys!                                |
# |                                                                            |
# |            4.) Create an authorized_keys file from the node that must be   |
# |                trusted (i.e. linux4) then copy the contents of the         |
# |                ~/.ssh/id_rsa.pub public key from both nodes to the         |
# |                authorized key file just created (~/.ssh/authorized_keys).  |
# |                Note that you will be prompted for the oracle UNIX user     |
# |                account password for both nodes accessed. Perform the       |
# |                following from the node "linux4":                           |
# |                                                                            |
# |                $ touch ~/.ssh/authorized_keys                              |
# |                $ ssh linux4.idevelopment.info cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# |                $ ssh linux3.idevelopment.info cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# |                                                                            |
# |            5.) At this point, we have the RSA public key from both nodes   |
# |                in the authorized key file (~/.ssh/authorized_keys) on      |
# |                linux4. We now need to copy it from linux4 to linux3 using  |
# |                the scp command:                                            |
# |                                                                            |
# |                $ scp ~/.ssh/authorized_keys linux3.idevelopment.info:.ssh/authorized_keys
# |                                                                            |
# |            6.) Change the permission of the authorized key file for both   |
# |                nodes by logging into the node and running the following:   |
# |                                                                            |
# |                $ chmod 600 ~/.ssh/authorized_keys                          |
# |                                                                            |
# |            7.) If SSH is configured correctly, you will be able to use the |
# |                ssh and scp commands from either node without being         |
# |                prompted for a password or pass phrase. Perform the         |
# |                following from both nodes. If you see any other messages or |
# |                text, apart from the host name and date, this script will   |
# |                fail. Make any changes required to ensure that only the     |
# |                host name and date is displayed when you enter these        |
# |                commands. You should ensure that any part of a login        |
# |                script(s) that generate any output, or ask any questions,   |
# |                are modified so that they act only when the shell is an     |
# |                interactive shell.                                          |
# |                                                                            |
# |                $ ssh linux4.idevelopment.info "date;hostname"              |
# |                Wed Feb  4 23:53:36 EST 2009                                |
# |                linux4                                                      |
# |                                                                            |
# |                $ ssh linux3.idevelopment.info "date;hostname"              |
# |                Wed Feb  4 23:53:25 EST 2009                                |
# |                linux3                                                      |
# |                                                                            |
# | PARAMETERS : SOURCE_SID           ORACLE_SID of the standby database.      |
# |              SOURCE_DB            TNS connect string to the standby        |
# |                                   database.                                |
# |              STANDBY_SYS_PASSWORD Database password for the SYS user on    |
# |                                   the standby database.                    |
# |              PRIMARY_HOST_NAME    Fully qualified machine name that hosts  |
# |                                   the primary database (the remote node).  |
# |              ORA_ARCHIVE_DIR      Location (full directory name) for       |
# |                                   the archived redo logs on both nodes.    |
# |              DAYS_OLD             Number of days worth of archived redo    |
# |                                   logs to keep on the standby database     |
# |                                   server (used for retention policy).      |
# |                                                                            |
# | EXAMPLE   :                                                                |
# | dg_refresh_standby_database.ksh  PRODRS  PRODRS_STBY_LINUX4  Not4USource  linux3.idevelopment.info  /u04/flash_recovery_area/PRODRS/archivelog 6
# |                                                                            |
# | NOTE     : As with any code, ensure to test this script in a development   |
# |            environment before attempting to run it in production.          |
# +----------------------------------------------------------------------------+

. /home/oracle/.bashrc

# +----------------------------------------------------------------------------+
# | ************************************************************************** |
# | *                     DEFINE ALL GLOBAL VARIABLES                        * |
# | ************************************************************************** |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
VERSION="2.4"
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%%\.ksh}

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
DBA_USERNAME=SYS

# LIST ALL EMAIL ADDRESSES SEPARATED BY A SINGLE SPACE
MAIL_USERS_EMAIL="jhunter@idevelopment.info ahunter@idevelopment.info"

MAIL_TO="Jeffrey M. Hunter <jhunter@idevelopment.info>"
MAIL_FROM="iDevelopment.info Database Support <jhunter@idevelopment.info>"
MAIL_REPLYTO="iDevelopment.info Database Support <jhunter@idevelopment.info>"

# ----------------------------
# DATE VARIABLES
# ----------------------------
START_DATE=`date`
DATE_LOG=`date +%Y-%m-%d-%H:%M:%S`
CURRENT_YEAR=`${DATE_BIN} +"%Y"`;
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
LOG_FILE_NAME=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${2}_${DATE_LOG}.log
LOG_FILE_NAME_NODATE=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${2}.log
LOG_FILE_ARCHIVE_OBSOLETE_DAYS=7

# ----------------------------
# EMAIL VARIABLES
# ----------------------------
MAIL_FILE_NAME=${CUSTOM_ORACLE_TEMP_DIR}/${SCRIPT_NAME_NOEXT}_${2}.mhr
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


# +----------------------------------------------------------------------------+
# | ************************************************************************** |
# | *                     DEFINE ALL GLOBAL FUNCTIONS                        * |
# | ************************************************************************** |
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

function usage {

  wl " "
  wl "Usage: ${SCRIPT_NAME_NOEXT}.ksh  \"STANDBY_SID\"  \"STANDBY_DB_NAME\"  \"STANDBY_SYS_PASSWORD\"  \"PRIMARY_HOST_NAME\"  \"ORA_ARCHIVE_DIR\"  \"DAYS_OLD\""
  wl " "

}

function errorExit {

  wl " "
  wl "TRACE> CRITICAL ERROR"
  wl "TRACE> Exiting script."
  wl " "
  
  cp $LOG_FILE_NAME $LOG_FILE_NAME_NODATE
      
  exit 2
}

function checkScriptAlreadyRunning {

  wl " "
  wl "TRACE> Check that this script (${SCRIPT_NAME}) is not already running on this host."
  wl " "
  COMMAND="WC=\$(ps -ef | grep ${SCRIPT_NAME} | grep -v 'grep' | wc -l)"
  wl "${COMMAND}"

  wl " "
  ps -ef | grep ${SCRIPT_NAME} | grep -v 'grep' | sed s/${STANDBY_SYS_PASSWORD}/xxxxxxx/g
  WC=$(ps -ef | grep ${SCRIPT_NAME} | grep -v 'grep' | wc -l)
  
  wl " "
  wl "TRACE> Number of instances of this script running: $WC"

  wl " "
  wl "TRACE> Check to see if this script is an interactive session."
  if tty -s; then
    # INTERACTIVE SHELL
    wl " "
    wl "TRACE> This is an INTERACTIVE session. Check number of instances of this script against > 1."
	  NUM_CHECK_INSTANCES=1
    TTY=/sbin/true
  else
    # NON-INTERACTIVE SHELL
    wl " "
    wl "TRACE> This is a NON-INTERACTIVE session (i.e. CRON). Check number of instances of this script against > 2."
	  NUM_CHECK_INSTANCES=2
    TTY=/sbin/false
  fi

  #
  # CHECK FOR INSTANCES OF THIS SCRIPT RUNNING OUT OF CRON OR INTERACTIVE
  #
  if [[ $WC -gt $NUM_CHECK_INSTANCES ]]; then
    wl " "
    wl "TRACE> WARNING: Found ${SCRIPT_NAME} already running on this host! Exiting script."
    {
        echo "Importance: High"
        echo "X-Priority: 1"
        echo "X-MSMail-Priority: High"
        echo "Subject: [$HOSTNAME_SHORT_UPPER] - WARNING: $SCRIPT_NAME (${STANDBY_DB_NAME}) ON [${DATE_LOG}]"
        echo "To: ${MAIL_TO}"
        echo "From: ${MAIL_FROM}"
        echo "Reply-To: ${MAIL_REPLYTO}"
        echo ""
        cat ${LOG_FILE_NAME}
  
    } > ${MAIL_FILE_NAME}
 
    for email_address in $MAIL_USERS_EMAIL; do
      /usr/lib/sendmail -v $email_address < ${MAIL_FILE_NAME}
    done

    rm -f $MAIL_FILE_NAME

    errorExit
  else
    wl " "
    wl "TRACE> Did not find this script (${SCRIPT_NAME}) already running on this host. Continuing script..."
  fi
  wl " "

}

switchOracleEnv() {      
    
    DB_ENTRY_HOME="$1"

    # +---------------------------------------------------------+
    # | Ensure that "OLDHOME" is non-null. The following is a   |
    # | portable way of saying, if oracle_home is not set, then |
    # | return a zero. this will then set OLDHOME to the $PATH  |
    # | variable. If ORACLE_HOME is set, then set OLDHOME to    |
    # | that of the old $ORACLE_HOME. Another way to perform    |
    # | this check is using a less portable statement:          |
    # |       if [ ${ORACLE_HOME:-0} = 0 ]; then                |
    # +---------------------------------------------------------+
    if [ ${ORACLE_HOME=0} = 0 ]; then
      OLDHOME=$PATH
    else
      OLDHOME=$ORACLE_HOME
    fi

    # +--------------------------------------------------------+
    # | Now that we backed up the old $ORACLE_HOME, lets set   |
    # | the environment with the new $ORACLE_HOME.             |
    # +--------------------------------------------------------+
    ORACLE_HOME=$DB_ENTRY_HOME
    export ORACLE_HOME
    
    # +------------------------------------------+
    # | Set $PATH                                |
    # +------------------------------------------+
    case "$PATH" in
      *$OLDHOME/bin*)  PATH=`echo $PATH | sed "s;$OLDHOME/bin;$DB_ENTRY_HOME/bin;g"` ;;
      *$DB_ENTRY_HOME/bin*)  ;;
      *:)              PATH=${PATH}$DB_ENTRY_HOME/bin: ;;
      "")              PATH=$DB_ENTRY_HOME/bin ;;
      *)               PATH=$PATH:$DB_ENTRY_HOME/bin ;;
    esac
    export PATH

    # +------------------------------------------+
    # | Set $LD_LIBRARY_PATH                     |
    # +------------------------------------------+
    case "$LD_LIBRARY_PATH" in
      *$OLDHOME/lib*)    LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed "s;$OLDHOME/lib;$DB_ENTRY_HOME/lib;g"` ;;
      *$DB_ENTRY_HOME/lib*) ;;
      *:)                LD_LIBRARY_PATH=${LD_LIBRARY_PATH}$DB_ENTRY_HOME/lib: ;;
      "")                LD_LIBRARY_PATH=$DB_ENTRY_HOME/lib ;;
      *)                 LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DB_ENTRY_HOME/lib ;;
    esac
    export LD_LIBRARY_PATH

    ORACLE_DOC=$DB_ENTRY_HOME/doc
    export ORACLE_DOC

    ORACLE_PATH=$DB_ENTRY_HOME/rdbms/admin:$DB_ENTRY_HOME/sqlplus/admin
    export ORACLE_PATH

    TNS_ADMIN=$DB_ENTRY_HOME/network/admin
    export TNS_ADMIN

    # ----------------------
    # RDBMS 10g
    # ----------------------
    ORA_NLS10=$DB_ENTRY_HOME/nls/data
    export ORA_NLS10

    # ----------------------
    # RDBMS 8, 8i and 9i
    # ----------------------
    # ORA_NLS33=$DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS33

    # ----------------------
    # RDBMS 7.3.x
    # ----------------------
    # ORA_NLS32=$DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS32

    # ----------------------
    # RDBMS 7.2.x
    # ----------------------
    # ORA_NLS=$DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS

}

getOSName() {          
      
    case `uname -s` in 
        *BSD)
            UNIX_TYPE="bsd" ;;
        SunOS)
            case `uname -r` in
                5.*) UNIX_TYPE="solaris" ;;      
                  *) UNIX_TYPE"sunos" ;;
            esac
            ;;
        Linux)
            UNIX_TYPE="linux" ;;
        HP-UX)           
            UNIX_TYPE="hpux" ;;
        AIX)
            UNIX_TYPE="aix" ;;
        *) UNIX_TYPE="unknown" ;;
    esac
    
}



# +----------------------------------------------------------------------------+
# | ************************************************************************** |
# | *                          SCRIPT STARTS HERE                            * |
# | ************************************************************************** |
# +----------------------------------------------------------------------------+

startScript

showSignonBanner

# +----------------------------------------------------------------------------+
# | VALIDATE COMMAND-LINE ARGUMENTS                                            |
# +----------------------------------------------------------------------------+

if [ "$1" ]; then
  export STANDBY_SID=$1
  unset TWO_TASK
  wl "TRACE> STANDBY_SID set to $STANDBY_SID"
  wl " "
else
  wl " "
  wl "STANDBY_SID undefined."
  usage
  exit 2
fi

if [ "$2" ]; then
  export STANDBY_DB_NAME=$2
  unset TWO_TASK
  wl "TRACE> STANDBY_DB_NAME set to $STANDBY_DB_NAME"
  wl " "
else
  wl " "
  wl "STANDBY_DB_NAME undefined."
  usage
  exit 2
fi

if [ "$3" ]; then
  export STANDBY_SYS_PASSWORD=$3
  wl "TRACE> STANDBY_SYS_PASSWORD set to xxxxxxxxxxxx"
else
  wl " "
  wl "STANDBY_SYS_PASSWORD undefined."
  usage
  exit 2
fi

if [ "$4" ]; then
  export PRIMARY_HOST_NAME=$4
  unset TWO_TASK
  wl "TRACE> PRIMARY_HOST_NAME set to $PRIMARY_HOST_NAME"
else
  wl " "
  wl "PRIMARY_HOST_NAME undefined."
  usage
  exit 2
fi

if [ "$5" ]; then
  export ORA_ARCHIVE_DIR=$5
  unset TWO_TASK
  wl "TRACE> ORA_ARCHIVE_DIR set to $ORA_ARCHIVE_DIR"
else
  wl " "
  wl "ORA_ARCHIVE_DIR undefined."
  usage
  exit 2
fi

if [ "$6" ]; then
  export DAYS_OLD=$6
  unset TWO_TASK
  wl "TRACE> DAYS_OLD set to $DAYS_OLD"
else
  wl " "
  wl "DAYS_OLD undefined."
  usage
  exit 2
fi

# +----------------------------------------------------------------------------+
# | GET O/S NAME / TYPE                                                        |
# +----------------------------------------------------------------------------+

getOSName
    
if [[ $UNIX_TYPE = "linux" ]]; then
    ORATAB_FILE="/etc/oratab"
elif [[ $UNIX_TYPE = "solaris" ]];then
    ORATAB_FILE="/var/opt/oracle/oratab"
else
    ORATAB_FILE="/etc/oratab"
fi


# +----------------------------------------------------------------------------+
# | VERIFY AN INSTANCE OF THIS SCRIPT IS NOT ALREADY RUNNING                   |
# +----------------------------------------------------------------------------+

checkScriptAlreadyRunning


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "=============================================================="
wl " ${DATE_PRINT_LOG}"
wl "--------------------------------------------------------------"
wl "  -  SEARCH FOR ORACLE_HOME AND SET GLOBAL ORACLE ENVIRONMENT"
wl "     VARIABLES FOR TARGET DB ($STANDBY_DB_NAME)."
wl "=============================================================="
wl " "

FOUND_ORACLE_HOME="NO"

for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
do

    ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
    export ORACLE_SID

    wl "--> Looking at ORACLE_SID: $ORACLE_SID ..."

    if [[ $ORACLE_SID = $STANDBY_DB_NAME ]]; then

        FOUND_ORACLE_HOME="YES"

        NEW_ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
        export NEW_ORACLE_HOME

        switchOracleEnv $NEW_ORACLE_HOME

        wl " "
        wl "--> Found ORACLE_HOME for SID (${ORACLE_SID}): ${NEW_ORACLE_HOME}"

        break

    fi

done

if [[ $FOUND_ORACLE_HOME = "NO" ]]; then
    wl " "
    wl "CRITICAL ERROR: Could not find an entry in oratab for STANDBY_DB_NAME ($STANDBY_DB_NAME)"
    wl " "
    showUsage
    exit 2
fi

echo "==================================================================================="
echo "                             COMMON SCRIPT VARIABLES"
echo "==================================================================================="
echo "SCRIPT                          : $SCRIPT_NAME"
echo "VERSION                         : $VERSION"
echo "START TIME                      : $START_DATE"
echo "HOST NAME                       : $HOSTNAME"
echo "O/S PLATFORM                    : $UNIX_TYPE"
echo "ORATAB_FILE                     : $ORATAB_FILE"
echo "LOG_FILE_NAME                   : $LOG_FILE_NAME"
echo "LOG_FILE_NAME_NODATE            : $LOG_FILE_NAME_NODATE"
echo "LOG_FILE_ARCHIVE_OBSOLETE_DAYS  : $LOG_FILE_ARCHIVE_OBSOLETE_DAYS"
echo "==================================================================================="
echo "                             CUSTOM SCRIPT VARIABLES"
echo "==================================================================================="
echo "STANDBY_SID          - (P1)      : $STANDBY_SID"
echo "STANDBY_DB_NAME      - (P2)      : $STANDBY_DB_NAME"
echo "STANDBY_SYS_PASSWORD - (P3)      : xxxxxxxxxxxx"
echo "PRIMARY_HOST_NAME    - (P4)      : $PRIMARY_HOST_NAME"
echo "ORA_ARCHIVE_DIR      - (P5)      : $ORA_ARCHIVE_DIR"
echo "DAYS_OLD             - (P6)      : $DAYS_OLD"
echo "DBA_USERNAME                     : $DBA_USERNAME"
echo "==================================================================================="
echo " "


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| USE RSYNC TO TRANSFER ARCHIVED LOGS FROM PRODUCTION                        |"
wl "+----------------------------------------------------------------------------+"

rsync --verbose --progress --stats --rsh="/usr/bin/ssh -C" --recursive --times --perms --links ${PRIMARY_HOST_NAME}:${ORA_ARCHIVE_DIR}/* ${ORA_ARCHIVE_DIR} | tee -a $LOG_FILE_NAME

# rsync --verbose --progress --stats --rsh="/usr/local/bin/bbcp -r -f -k -v -P 3 -c 6" --recursive --times --perms --links ${PRIMARY_HOST_NAME}:${ORA_ARCHIVE_DIR}/* ${ORA_ARCHIVE_DIR} | tee -a $LOG_FILE_NAME


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| MANUALLY RECOVER THE STANDBY DATABASE                                      |"
wl "+----------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a $LOG_FILE_NAME
  connect ${DBA_USERNAME}/${STANDBY_SYS_PASSWORD}@${STANDBY_DB_NAME} as sysdba
  SET AUTORECOVERY ON;
  RECOVER STANDBY DATABASE;
EOF


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| REMOVING OBSOLETE LOG FILES                                                |"
wl "+----------------------------------------------------------------------------+"

find ${CUSTOM_ORACLE_LOG_DIR}/ -name "${SCRIPT_NAME_NOEXT}*.log" -mtime +${LOG_FILE_ARCHIVE_OBSOLETE_DAYS} -exec ls -l {} \; | tee -a $LOG_FILE_NAME
find ${CUSTOM_ORACLE_LOG_DIR}/ -name "${SCRIPT_NAME_NOEXT}*.log" -mtime +${LOG_FILE_ARCHIVE_OBSOLETE_DAYS} -exec rm -rf {} \; | tee -a $LOG_FILE_NAME


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| PURGE OBSOLETE ARCHIVED LOGS                                               |"
wl "| CLEAN OUT CONTROL FILE                                                     |"
wl "+----------------------------------------------------------------------------+"

rman target ${DBA_USERNAME}/${STANDBY_SYS_PASSWORD}@${STANDBY_DB_NAME} <<EOF | tee -a $LOG_FILE_NAME
delete force noprompt archivelog until time 'sysdate - $DAYS_OLD';
crosscheck backup;
delete force noprompt expired backup;
exit;
EOF


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| SCAN LOG FILE FOR ERRORS                                                   |"
wl "| IGNORE: ORA-39139                                                          |"
wl "|     ORA-00278                                                              |"
wl "|     ORA-00279                                                              |"
wl "|     ORA-00280                                                              |"
wl "|     ORA-00289                                                              |"
wl "|     ORA-00308                                                              |"
wl "|     ORA-27037                                                              |"
wl "+----------------------------------------------------------------------------+"

egrep 'ORA-' $LOG_FILE_NAME | egrep -v 'ORA-39139|ORA-00278|ORA-00279|ORA-00280|ORA-00289|ORA-00308|ORA-27037'

if [ $? = 0 ]
then
    wl " "
    wl "TRACE> FOUND ERRORS!!!"
    ERRORS="YES"
else
    wl " "
    wl "TRACE> FOUND NO ERRORS"
    ERRORS="NO"
fi


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| BACKUP CURRENT LOG FILE                                                    |"
wl "+----------------------------------------------------------------------------+"

cp $LOG_FILE_NAME $LOG_FILE_NAME_NODATE


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+----------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                        |"
wl "|----------------------------------------------------------------------------|"
wl "| EMAIL LOG FILE TO ADMINISTRATORS                                           |"
wl "+----------------------------------------------------------------------------+"

if [[ $ERRORS = "YES" ]]; then
    {
        echo "Importance: High"
        echo "X-Priority: 1"
        echo "X-MSMail-Priority: High"
        echo "Subject: [$HOSTNAME_SHORT_UPPER] - FAILED: $SCRIPT_NAME (${STANDBY_DB_NAME}) ON [${DATE_LOG}]"
        echo "To: ${MAIL_TO}"
        echo "From: ${MAIL_FROM}"
        echo "Reply-To: ${MAIL_REPLYTO}"
        echo ""
        cat ${LOG_FILE_NAME}

    } > ${MAIL_FILE_NAME}

    for email_address in $MAIL_USERS_EMAIL; do
      /usr/lib/sendmail -v $email_address < ${MAIL_FILE_NAME}
    done
    
    rm -f $MAIL_FILE_NAME
fi

END_DATE=`date`
wl " "
wl "======================================================"
wl "FINISH TIME : $END_DATE"
wl " "
wl "              -- EXITING SCRIPT --"
wl "======================================================"
wl "END: ${END_DATE}"

exit
