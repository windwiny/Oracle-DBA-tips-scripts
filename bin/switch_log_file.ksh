#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : switch_log_file.ksh                                           |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : Log in to the Oracle database and switch the current online   |
# |              redo log group.                                               |
# |                                                                            |
# |              This script is commonly used to perform a manual online redo  |
# |              log switch from a primary database that is not part of an     |
# |              Oracle Data Guard configuration. For example, when using      |
# |              Oracle Standard Edition, the Data Guard feature is not        |
# |              available. All standby database management must be performed  |
# |              manually when using Oracle Standard Edition (log transport    |
# |              and log apply).                                               |
# |                                                                            |
# |              When using Oracle Data Guard (Enterprise Edition) in maximum  |
# |              performance mode, the standby database only gets updated by   |
# |              archived redo logs sent from the primary database. Many DBAs  |
# |              resort to scripts likes this to manually switch the online    |
# |              redo log group on the primary database at predetermined       |
# |              times to ensure the standby database does not fall too far    |
# |              behind the state of the primary. Starting with Oracle 9i,     |
# |              this type manual scripting (for example, this script) is      |
# |              unnecessary when using Oracle Data Guard. Instead, the DBA    |
# |              should set the instance parameter ARCHIVE_LAG_TARGET on the   |
# |              primary database in order to maintain a minimum lag target.   |
# |              ARCHIVE_LAG_TARGET limits the amount of data that can be lost |
# |              and effectively increases the availability of the standby     |
# |              database by automatically forcing a log switch after the      |
# |              specified amount of time elapses. A 0 value disables the      |
# |              time-based thread advance feature; otherwise, the value       |
# |              represents the number of seconds. Values larger than 7200     |
# |              seconds are not of much use in maintaining a reasonable lag   |
# |              in the standby database. The typical, or recommended value is |
# |              1800 (30 minutes). Extremely low values can result in         |
# |              frequent log switches, which could degrade performance; such  |
# |              values can also make the archiver process too busy to archive |
# |              the continuously generated logs.                              |
# |                                                                            |
# | PARAMETERS :                                                               |
# |              TARGET_DB_NAME         TNS connect string to the target       |
# |                                     database.                              |
# |              TARGET_SID             Database SID found in the oratab file  |
# |                                     for the target database.               |
# |              TARGET_DBA_USERNAME    Database username used to log in to    |
# |                                     the target database. This user must    |
# |                                     have the DBA role.                     |
# |              TARGET_DBA_PASSWORD    Database password used to log in to    |
# |                                     the target database.                   |
# | EXAMPLE RUN:                                                               |
# |              switch_log_file.ksh racdb1 racdb1 backup_admin backup_admin_pwd > switch_log_file_racdb1_backup_admin_RACNODE1.job 2>&1
# |                                                                            |
# | CRON USAGE : This script can be run interactively from a command line      |
# |              interface or scheduled within CRON. Regardless of the method  |
# |              used to run this script, a log file will automatically be     |
# |              created of the form "<script_name>_<varn>.log" where <varn>   |
# |              can be any user defined variable used to identify the         |
# |              instance of the run. When scheduling this script to be run    |
# |              from CRON, ensure the crontab entry does NOT redirect its     |
# |              output to the name of the log file automatically created from |
# |              within this script. When defining the crontab entry used to   |
# |              run this script, the typical convention is to redirect its    |
# |              output to a log file with an extension of .job as illustrated |
# |              in the following example:                                     |
# |                                                                            |
# |              [time] [script_name.ksh] > [script_name.job] 2>&1             |
# |                                                                            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# |                                                                            |
# |                    DEFINE ALL CUSTOM GLOBAL VARIABLES                      |
# |                                                                            |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT VERSION
# ----------------------------
VERSION="9.0"

# ----------------------------
# ORGANIZATION INFORMATION
# ----------------------------
# Note: No commas!
# ----------------------------
ORGANIZATION_NAME="iDevelopment.info"

# ----------------------------
# SCRIPT PARAMETER VARIABLES
# ----------------------------
TARGET_DB_NAME=$1
TARGET_SID=$2
TARGET_DBA_USERNAME=$3
TARGET_DBA_PASSWORD=$4

EXPECTED_NUM_SCRIPT_PARAMS=4

UNIQUE_SCRIPT_IDENTIFIER=${TARGET_SID}_${TARGET_DBA_USERNAME}

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
unset ORACLE_PATH
unset SQLPATH

# ----------------------------
# ORACLE ENVIRONMENT VARIABLES
# ----------------------------
ORACLE_BASE=/u01/app/oracle
ORACLE_ADMIN_DIR=${ORACLE_BASE}/admin
ORACLE_DIAG_DIR=${ORACLE_BASE}/diag

# ----------------------------
# CUSTOM DIRECTORIES
# ----------------------------
CUSTOM_ORACLE_DIR=${ORACLE_BASE}/dba_scripts
CUSTOM_ORACLE_BIN_DIR=${CUSTOM_ORACLE_DIR}/bin
CUSTOM_ORACLE_LIB_DIR=${CUSTOM_ORACLE_DIR}/lib
CUSTOM_ORACLE_LOG_DIR=${CUSTOM_ORACLE_DIR}/log
CUSTOM_ORACLE_OUT_DIR=${CUSTOM_ORACLE_DIR}/out
CUSTOM_ORACLE_SQL_DIR=${CUSTOM_ORACLE_DIR}/sql
CUSTOM_ORACLE_TEMP_DIR=${CUSTOM_ORACLE_DIR}/temp

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%.?*}

# ----------------------------
# HOSTNAME VARIABLES
# ----------------------------
HOSTNAME=`hostname`
HOSTNAME_UPPER=`echo $HOSTNAME | tr '[:lower:]' '[:upper:]'`
HOSTNAME_SHORT=${HOSTNAME%%.*}
HOSTNAME_SHORT_UPPER=`echo $HOSTNAME_SHORT | tr '[:lower:]' '[:upper:]'`

# ----------------------------
# EMAIL PREFERENCES
# ----------------------------
# LIST ALL ADMINISTRATIVE
# EMAIL ADDRESSES WHO WILL BE
# RESPONSIBLE FOR MONITORING
# AND RECEIVING EMAIL FROM
# THIS SCRIPT.
# ----------------------------
# THREE EMAIL RECIPIENT LISTS
# EXIST:
#   1) WHEN THIS SCRIPT CALLS
#      exitSuccess()
#   2) WHEN THIS SCRIPT CALLS
#      exitWarning()
#   3) WHEN THIS SCRIPT CALLS
#      exitFailed()
# ----------------------------
# MULTIPLE EMAIL ADDRESSES
# SHOULD ALL BE LISTED IN
# DOUBLE-QUOTES SEPARATED BY A
# SINGLE SPACE.
# ----------------------------
MAIL_RECIPIENT_LIST_EXIT_SUCCESS=""
MAIL_RECIPIENT_LIST_EXIT_WARNING="jhunter@idevelopment.info dba@idevelopment.info"
MAIL_RECIPIENT_LIST_EXIT_FAILED="jhunter@idevelopment.info support@idevelopment.info dba@idevelopment.info"
MAIL_FROM="${ORGANIZATION_NAME} Database Support <dba@idevelopment.info>"
MAIL_REPLYTO="${ORGANIZATION_NAME} Database Support <dba@idevelopment.info>"
MAIL_TO_NAME="${ORGANIZATION_NAME} Database Support"
MAIL_TEMP_FILE_NAME=${CUSTOM_ORACLE_TEMP_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}.mhr

# ----------------------------
# BINARY FILE LOCATIONS
# ----------------------------
AWK_BIN=/bin/awk
CAT_BIN=/bin/cat
CP_BIN=/bin/cp
CPIO_BIN=/bin/cpio
DATE_BIN=/bin/date
EGREP_BIN=/bin/egrep
FIND_BIN=/usr/bin/find
GREP_BIN=/bin/grep
GZIP_BIN=/bin/gzip
HOSTNAME_BIN=/bin/hostname
ID_BIN=/usr/bin/id
LS_BIN=/bin/ls
MV_BIN=/bin/mv
PS_BIN=/bin/ps
RM_BIN=/bin/rm
SENDMAIL_BIN=/usr/lib/sendmail
TEE_BIN=/usr/bin/tee
TOUCH_BIN=/bin/touch
UNAME_BIN=/bin/uname
WC_BIN=/usr/bin/wc
ZIP_BIN=/usr/bin/zip



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                   DEFINE ALL INTERNAL GLOBAL VARIABLES                     |
# |                                                                            |
# +----------------------------------------------------------------------------+

# ----------------------------
# DATE VARIABLES
# ----------------------------
START_DATE=`${DATE_BIN}`
START_DATE_LOG=`${DATE_BIN} +"%Y%m%d_%H%M%S"`
START_DATE_PRINT=`${DATE_BIN} +"%m/%d/%Y %r %Z"`
CURRENT_YEAR=`${DATE_BIN} +"%Y"`;
CURRENT_DOW_NUM=`${DATE_BIN} +"%w"`;      # - day of week (0..6); 0 is Sunday
case ${CURRENT_DOW_NUM} in
    0) CURRENT_DOW_NAME="Sunday" ;;
    1) CURRENT_DOW_NAME="Monday" ;;
    2) CURRENT_DOW_NAME="Tuesday" ;;
    3) CURRENT_DOW_NAME="Wednesday" ;;
    4) CURRENT_DOW_NAME="Thursday" ;;
    5) CURRENT_DOW_NAME="Friday" ;;
    6) CURRENT_DOW_NAME="Saturday" ;;
    *) CURRENT_DOW_NAME="unknown" ;;
esac

# ----------------------------
# SHELL PROPERTIES
# ----------------------------
SPROP_SHELL_FLAGS=$-
SPROP_PROCESS_ID=$$
SPROP_NUM_SCRIPT_PARAMS=$#
if tty -s; then
    SPROP_SHELL_ACCESS="INTERACTIVE"
else
    SPROP_SHELL_ACCESS="NON-INTERACTIVE"
fi

# ----------------------------
# MISCELLANEOUS VARIABLES
# ----------------------------
HOST_RVAL_SUCCESS=0
HOST_RVAL_WARNING=2
HOST_RVAL_FAILED=2
HIDE_PASSWORD_STRING="xxxxxxxxxxxxx"

# ----------------------------
# LOG AND TEMP FILE VARIABLES
# ----------------------------
LOG_FILE_ARCHIVE_OBSOLETE_DAYS=45
LOG_FILE_NAME=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}_${START_DATE_LOG}.log
LOG_FILE_NAME_NODATE=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}.log
CHECK_SCRIPT_RUNNING_FLAG_FILE=${CUSTOM_ORACLE_TEMP_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}.running
SQL_OUTPUT_TEMP_FILE_NAME=${CUSTOM_ORACLE_TEMP_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}.lst



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                   DEFINE ALL INTERNAL GLOBAL FUNCTIONS                     |
# |                                                                            |
# +----------------------------------------------------------------------------+

function printScriptParameterVariables {

    wl " "
    wl "================================================================"
    wl "             PRINT SCRIPT PARAMETER VARIABLES                   "
    wl "================================================================"

    wl " "
    wl "TRACE> TARGET_DB_NAME       set to $TARGET_DB_NAME"
    wl "TRACE> TARGET_SID           set to $TARGET_SID"
    wl "TRACE> TARGET_DBA_USERNAME  set to $TARGET_DBA_USERNAME"
    wl "TRACE> TARGET_DBA_PASSWORD  set to $HIDE_PASSWORD_STRING"

}

function performScriptParameterValidation {

    typeset -r  L_VERSION=${1}
    typeset -r  L_CURRENT_YEAR=${2}

    return

}

function showUsage {

    typeset -r L_WRITE_TO_LOG=${1}
    typeset    L_SHOW

    if [[ $L_WRITE_TO_LOG = "NOLOG" || -z $L_WRITE_TO_LOG ]]; then
        L_SHOW="echo"
    else
        L_SHOW="wl"
    fi

    $L_SHOW " "
    $L_SHOW "Usage: ${SCRIPT_NAME} parameters [optional parameters]"
    $L_SHOW " "
    $L_SHOW "    parameters:  target_db_name"
    $L_SHOW "                 target_sid"
    $L_SHOW "                 target_dba_username"
    $L_SHOW "                 target_dba_password"
    $L_SHOW " "
    $L_SHOW "    optional"
    $L_SHOW "    parameters:  none"
    $L_SHOW " "

    return

}

function showSignonBanner {

    typeset -r L_VERSION=${1}
    typeset -r L_CURRENT_YEAR=${2}
    typeset -r L_WRITE_TO_LOG=${3}
    typeset    L_SHOW
    
    if [[ $L_WRITE_TO_LOG = "NOLOG" || -z $L_WRITE_TO_LOG ]]; then
        L_SHOW="echo"
    else
        L_SHOW="wl"
    fi

    $L_SHOW " "
    $L_SHOW "${SCRIPT_NAME} - Version ${L_VERSION}"
    $L_SHOW "Copyright (c) 1998-${L_CURRENT_YEAR} Jeffrey M. Hunter. All rights reserved."
    $L_SHOW " "
    
    return

}

function wl {

    typeset -r L_STRING=${1}
    
    echo "${L_STRING}" >> ${LOG_FILE_NAME}
    echo "${L_STRING}"

    return

}

function startLogging {

    wl "+=========================================================================+"
    wl "|                                                                         |"
    wl "|                               START TIME                                |"
    wl "|                                                                         |"
    wl "|                      $START_DATE                       |"
    wl "|                                                                         |"
    wl "+=========================================================================+"

    return

}

function stopLogging {

    END_DATE=`${DATE_BIN}`
    wl " "
    wl "+=========================================================================+"
    wl "|                                                                         |"
    wl "|                               FINISH TIME                               |"
    wl "|                                                                         |"
    wl "|                       $END_DATE                      |"
    wl "|                                                                         |"
    wl "+=========================================================================+"

    return

}

function initializeScript {

    typeset -ru L_FIRST_PARAMETER=${1}
    typeset -r  L_VERSION=${2}
    typeset -r  L_CURRENT_YEAR=${3}

    # ----------------------------------------
    # CHECK IF USER ASKED FOR HELP
    # ----------------------------------------
    if [[ $L_FIRST_PARAMETER = "-H" || $L_FIRST_PARAMETER = "-HELP" || $L_FIRST_PARAMETER = "--HELP" || -z $L_FIRST_PARAMETER ]]; then
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        exit $HOST_RVAL_SUCCESS
    fi

    # ----------------------------------------
    # VERIFY CORRECT NUMBER OF PARAMETERS
    # ----------------------------------------
    if (( $SPROP_NUM_SCRIPT_PARAMS != $EXPECTED_NUM_SCRIPT_PARAMS )); then
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        echo " "
        echo "JMA-0001: Number of script parameters passed to this script = $SPROP_NUM_SCRIPT_PARAMS."
        echo "JMA-0002: Number of expected script parameters to this script = $EXPECTED_NUM_SCRIPT_PARAMS."
        echo " "
        exit $HOST_RVAL_SUCCESS
    fi

    # --------------------------------------------------
    # PERFORM SCRIPT PARAMETER VALIDATION (if necessary)
    # --------------------------------------------------
    performScriptParameterValidation $L_VERSION $L_CURRENT_YEAR

    # ----------------------------------------
    # CLEAN LOG FILE AND ENVIRONMENT VARIABLES
    # ----------------------------------------
    ${RM_BIN} -f ${LOG_FILE_NAME}
    NEW_ORACLE_HOME="NO_ORACLE_HOME_FOUND"
    ERRORS="NO"
    unset TWO_TASK

    # ----------------------------------------
    # INITIALIZE LOG FILE
    # ----------------------------------------
    startLogging

    # ----------------------------------------
    # DISPLAY SIGN ON BANNER
    # ----------------------------------------
    showSignonBanner $VERSION $CURRENT_YEAR "LOG"

    # ----------------------------------------
    # PRINT SCRIPT PARAMETER VARIABLES 
    # ----------------------------------------
    printScriptParameterVariables

    return

}

function getOSName {

    echo `${UNAME_BIN} -s`

    return

}

function getOSType {

    typeset -r L_OS_NAME=${1}
    typeset    L_OS_TYPE_RVAL

    case ${L_OS_NAME} in
        *BSD)
            L_OS_TYPE_RVAL="bsd" ;;
        SunOS)
            case `${UNAME_BIN} -r` in
                5.*) L_OS_TYPE_RVAL="solaris" ;;
                  *) L_OS_TYPE_RVAL="sunos" ;;
            esac
            ;;
        Linux)
            L_OS_TYPE_RVAL="linux" ;;
        HP-UX)
            L_OS_TYPE_RVAL="hpux" ;;
        AIX)
            L_OS_TYPE_RVAL="aix" ;;
        *) L_OS_TYPE_RVAL="unknown" ;;
    esac
    
    echo ${L_OS_TYPE_RVAL}
    
    return
    
}

function getOratabFile {

    typeset -r L_OS_TYPE=${1}
    typeset    L_OS_ORATAB_FILE
    
    if [[ $L_OS_TYPE = "linux" ]]; then
        L_OS_ORATAB_FILE="/etc/oratab"
    elif [[ $L_OS_TYPE = "solaris" ]];then
        L_OS_ORATAB_FILE="/var/opt/oracle/oratab"
    else
        L_OS_ORATAB_FILE="/etc/oratab"
    fi
    
    echo ${L_OS_ORATAB_FILE}
    
    return

}

function getOracleHome {

    typeset -r L_SID_NAME=${1}
    typeset -r L_ORATAB_FILE=${2}
    typeset    L_NEW_ORACLE_HOME
    typeset    L_DB_ENTRY
    typeset    L_FOUND_ENTRY

    L_FOUND_ENTRY="NO"

    for L_DB_ENTRY in `cat ${L_ORATAB_FILE} | ${GREP_BIN} -v '^\#' | ${GREP_BIN} -v '^\*' | cut -d":" -f1,2`
    do
        ORACLE_SID=`echo $L_DB_ENTRY | cut -d":" -f1`
        if [[ $ORACLE_SID = $L_SID_NAME ]]; then
            L_NEW_ORACLE_HOME=`echo $L_DB_ENTRY | cut -d":" -f2`
            L_FOUND_ENTRY="YES"
            break
        fi
    done

    if [[ $L_FOUND_ENTRY = "YES" ]]; then
        echo ${L_NEW_ORACLE_HOME}
    else
        echo "NO_ORACLE_HOME_FOUND"
    fi

    return

}

function switchOracleEnv {

    # +---------------------------------------------------------+
    # | Sets the following global environment variables:        |
    # | ------------------------------------------------        |
    # |     ORACLE_HOME                                         |
    # |     PATH                                                |
    # |     LD_LIBRARY_PATH                                     |
    # |     ORACLE_DOC                                          |
    # |     ORACLE_PATH                                         |
    # |     TNS_ADMIN                                           |
    # |     NLS_DATE_FORMAT                                     |
    # |     ORA_NLS10                                           |
    # +---------------------------------------------------------+

    typeset -r L_ORATAB_DB_ENTRY_HOME=${1}
    typeset    L_OLDHOME
    
    if [ ${ORACLE_HOME=0} = 0 ]; then
        L_OLDHOME=$PATH
    else
        L_OLDHOME=$ORACLE_HOME
    fi

    # +--------------------------------------------------------+
    # | Now that we backed up the old $ORACLE_HOME, lets set   |
    # | the environment with the new $ORACLE_HOME.             |
    # +--------------------------------------------------------+
    ORACLE_HOME=$L_ORATAB_DB_ENTRY_HOME
    export ORACLE_HOME
    wl "TRACE> New ORACLE_HOME      = ${ORACLE_HOME}"

    case "$PATH" in
        *$L_OLDHOME/bin*)  PATH=`echo $PATH | sed "s;$L_OLDHOME/bin;$L_ORATAB_DB_ENTRY_HOME/bin;g"` ;;
        *$L_ORATAB_DB_ENTRY_HOME/bin*)  ;;
        *:)              PATH=${PATH}$L_ORATAB_DB_ENTRY_HOME/bin: ;;
        "")              PATH=$L_ORATAB_DB_ENTRY_HOME/bin ;;
        *)               PATH=$PATH:$L_ORATAB_DB_ENTRY_HOME/bin ;;
    esac
    export PATH 
    wl "TRACE> New PATH             = ${PATH}"

    case "$LD_LIBRARY_PATH" in
        *$L_OLDHOME/lib*)    LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed "s;$L_OLDHOME/lib;$L_ORATAB_DB_ENTRY_HOME/lib;g"` ;;
        *$L_ORATAB_DB_ENTRY_HOME/lib*) ;;
        *:)                LD_LIBRARY_PATH=${LD_LIBRARY_PATH}$L_ORATAB_DB_ENTRY_HOME/lib: ;;
        "")                LD_LIBRARY_PATH=$L_ORATAB_DB_ENTRY_HOME/lib ;;
        *)                 LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$L_ORATAB_DB_ENTRY_HOME/lib ;;
    esac
    export LD_LIBRARY_PATH
    wl "TRACE> New LD_LIBRARY_PATH  = ${LD_LIBRARY_PATH}"

    ORACLE_DOC=$L_ORATAB_DB_ENTRY_HOME/doc
    export ORACLE_DOC 
    wl "TRACE> New ORACLE_DOC       = ${ORACLE_DOC}"

    ORACLE_PATH=$L_ORATAB_DB_ENTRY_HOME/rdbms/admin:$L_ORATAB_DB_ENTRY_HOME/sqlplus/admin
    export ORACLE_PATH
    wl "TRACE> New ORACLE_PATH      = ${ORACLE_PATH}"
    
    TNS_ADMIN=$L_ORATAB_DB_ENTRY_HOME/network/admin
    export TNS_ADMIN
    wl "TRACE> New TNS_ADMIN        = ${TNS_ADMIN}"

    NLS_DATE_FORMAT="DD-MON-YYYY HH24:MI:SS"
    export NLS_DATE_FORMAT
    wl "TRACE> New NLS_DATE_FORMAT  = ${NLS_DATE_FORMAT}"

    # (Oracle RDBMS 10g)
    ORA_NLS10=$L_ORATAB_DB_ENTRY_HOME/nls/data
    export ORA_NLS10
    wl "TRACE> New ORA_NLS10        = ${ORA_NLS10}"

    # (Oracle 8, 8i and 9i)
    # ORA_NLS33=$L_ORATAB_DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS33

    # (Oracle 7.3.x)
    # ORA_NLS32=$L_ORATAB_DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS32

    # (Oracle 7.2.x)
    # ORA_NLS=$L_ORATAB_DB_ENTRY_HOME/ocommon/nls/admin/data
    # export ORA_NLS

    return

}

function backupCurrentLogFile {
    
    ${CP_BIN} -vf ${LOG_FILE_NAME} ${LOG_FILE_NAME_NODATE}
    
    wl " "
    wl "TRACE> Copied ${LOG_FILE_NAME} to ${LOG_FILE_NAME_NODATE}"

    return

}

function removeScriptRunFlagFile {
    
    ${RM_BIN} -vf ${CHECK_SCRIPT_RUNNING_FLAG_FILE}

    wl " "
    wl "TRACE> Removed script run flag file (${CHECK_SCRIPT_RUNNING_FLAG_FILE})"

    return

}

function sendEmail {

    # -------------------------------
    # POSSIBLE L_SEVERITY VALUES ARE:
    #     SUCCESSFUL
    #     RUNNING
    #     WARNING
    #     FAILED
    # -------------------------------
    typeset -r L_SEVERITY=${1}
    typeset -r L_EMAIL_ADDRESS_LIST=${2}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${3}
    typeset    L_IMPORTANCE
    typeset    L_X_PRIORITY
    typeset    L_X_MSMAIL_PRIORITY
    typeset    L_EMAIL_ADDRESS

    case ${L_SEVERITY} in
        SUCCESSFUL)
            L_IMPORTANCE="Normal"
            L_X_PRIORITY="3"
            L_X_MSMAIL_PRIORITY="Normal"
            ;;
        RUNNING)
            L_IMPORTANCE="High"
            L_X_PRIORITY="1"
            L_X_MSMAIL_PRIORITY="High"
            ;;
        WARNING)
            L_IMPORTANCE="High"
            L_X_PRIORITY="1"
            L_X_MSMAIL_PRIORITY="High"
            ;;
        FAILED)
            L_IMPORTANCE="High"
            L_X_PRIORITY="1"
            L_X_MSMAIL_PRIORITY="High"
            ;;
        *)
            L_IMPORTANCE="High"
            L_X_PRIORITY="1"
            L_X_MSMAIL_PRIORITY="High"
        ;;
    esac

    wl " "
    wl "TRACE> Emailing the following recipients:"
    wl " "
    for L_EMAIL_ADDRESS in $L_EMAIL_ADDRESS_LIST; do
        wl "       $L_EMAIL_ADDRESS"
    done
    wl " "

    for L_EMAIL_ADDRESS in $L_EMAIL_ADDRESS_LIST; do
        {
            echo "Importance: ${L_IMPORTANCE}"
            echo "X-Priority: ${L_X_PRIORITY}"
            echo "X-MSMail-Priority: ${L_X_MSMAIL_PRIORITY}"
            echo "Subject: [${HOSTNAME_SHORT_UPPER}] - ${L_SEVERITY}: ${SCRIPT_NAME} (${L_UNIQUE_SCRIPT_IDENTIFIER})"
            echo "To: ${MAIL_TO_NAME} <${L_EMAIL_ADDRESS}>"
            echo "From: ${MAIL_FROM}"
            echo "Reply-To: ${MAIL_REPLYTO}"
            echo ""
            cat ${LOG_FILE_NAME}
        } > ${MAIL_TEMP_FILE_NAME}
        
        ${SENDMAIL_BIN} -v $L_EMAIL_ADDRESS < ${MAIL_TEMP_FILE_NAME} | ${TEE_BIN} -a $LOG_FILE_NAME

        wl "TRACE> Sent email to $L_EMAIL_ADDRESS"

        ${RM_BIN} -f $MAIL_TEMP_FILE_NAME | ${TEE_BIN} -a $LOG_FILE_NAME
    done

    return

}

function exitSuccess {

    typeset L_SEVERITY=${1}
    typeset L_UNIQUE_SCRIPT_IDENTIFIER=${2}

    wl " "
    wl "TRACE> +----------------------------------------------+"
    wl "TRACE> |                  SUCCESSFUL                  |"
    wl "TRACE> +----------------------------------------------+"
    wl " "
    wl "TRACE> Exiting script (${HOST_RVAL_SUCCESS})."
    wl " "

    removeScriptRunFlagFile
    stopLogging

    backupCurrentLogFile

    sendEmail ${L_SEVERITY} "${MAIL_RECIPIENT_LIST_EXIT_SUCCESS}" ${L_UNIQUE_SCRIPT_IDENTIFIER}

    exit ${HOST_RVAL_SUCCESS}

}

function exitWarning {

    typeset L_SEVERITY=${1}
    typeset L_UNIQUE_SCRIPT_IDENTIFIER=${2}

    wl " "
    wl "TRACE> +----------------------------------------------+"
    wl "TRACE> |       !!!!!!!!    WARNING    !!!!!!!!        |"
    wl "TRACE> +----------------------------------------------+"
    wl " "
    wl "TRACE> Exiting script (${HOST_RVAL_WARNING})."
    wl " "

    removeScriptRunFlagFile
    stopLogging

    backupCurrentLogFile

    sendEmail "${L_SEVERITY}" "${MAIL_RECIPIENT_LIST_EXIT_WARNING}" ${L_UNIQUE_SCRIPT_IDENTIFIER}

    exit ${HOST_RVAL_WARNING}

}

function exitFailed {

    typeset L_SEVERITY=${1}
    typeset L_UNIQUE_SCRIPT_IDENTIFIER=${2}

    wl " "
    wl "TRACE> +----------------------------------------------+"
    wl "TRACE> |    !!!!!!!!    CRITICAL ERROR    !!!!!!!!    |"
    wl "TRACE> +----------------------------------------------+"
    wl " "
    wl "TRACE> Exiting script (${HOST_RVAL_FAILED})."
    wl " "

    if [[ $L_SEVERITY = "RUNNING" ]]; then
      wl " "
      wl "TRACE> Script was found to be already running."
      wl "TRACE> Do not remove the script run flag file."
    else
      removeScriptRunFlagFile
    fi

    # showUsage "LOG"
    stopLogging

    backupCurrentLogFile

    sendEmail ${L_SEVERITY} "${MAIL_RECIPIENT_LIST_EXIT_FAILED}" ${L_UNIQUE_SCRIPT_IDENTIFIER}

    exit ${HOST_RVAL_FAILED}

}

function checkScriptAlreadyRunning {

    typeset -r L_SCRIPT_NAME=${1}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${2}
    typeset    L_COMMAND

    wl " "
    wl "TRACE> Check that this script (${L_SCRIPT_NAME}) is not already running on this host."

    wl " "
    wl "TRACE> Looking for script run flag file (${CHECK_SCRIPT_RUNNING_FLAG_FILE})."

    if [ -f $CHECK_SCRIPT_RUNNING_FLAG_FILE ]; then
        wl " "
        wl "TRACE> WARNING: Found ${L_SCRIPT_NAME} already running on this host. Exiting script."
        exitFailed "RUNNING" ${L_UNIQUE_SCRIPT_IDENTIFIER}
    else
        wl " "
        wl "TRACE> Did not find this script (${L_SCRIPT_NAME}) already running on this host. Setting run flag and continuing script..."
        touch $CHECK_SCRIPT_RUNNING_FLAG_FILE
    fi
    wl " "

    return

}

function verifyOSUserLogin {
    
    typeset -r L_CHECK_USER_NAME=${1}
    typeset -r L_REQUIRED=${2}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${3}
    typeset    L_UID

    # L_UID=`/usr/bin/id|awk -F\( '{print $2}'|awk -F\) '{print $1}'`
    L_UID=`${ID_BIN}|${AWK_BIN} -F\( '{print $2}'|${AWK_BIN} -F\) '{print $1}'`

    wl ""
    wl "TRACE> OS user logged in (${L_UID})."

    if [[ ${L_REQUIRED} == "TRUE" ]]; then

        if [[ ${L_UID} != "${L_CHECK_USER_NAME}" ]]; then
            wl " "
            wl "TRACE> You must be logged in as the (${L_CHECK_USER_NAME}) OS user to run this script."
            wl "TRACE> Log in to the machine as (${L_CHECK_USER_NAME}) and restart execution of this script."
            exitFailed "FAILED" ${L_UNIQUE_SCRIPT_IDENTIFIER}
        else
            wl " "
            wl "TRACE> Successfully logged in as (${L_CHECK_USER_NAME})."
        fi

    else
        wl " "
        wl "TRACE> OS user is not required to be logged in as (${L_CHECK_USER_NAME})."
    fi

    return

}

function verifyOracleSID {

    typeset -r L_SID_NAME=${1}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${2}
    typeset    L_COMMAND

    wl " "
    wl "TRACE> Check that the Oracle instance (${L_SID_NAME}) is up."

    L_COMMAND="${PS_BIN} -ef | ${GREP_BIN} \"ora_smon_$L_SID_NAME\$\" | ${GREP_BIN} -v 'grep'"
    wl "TRACE> ${L_COMMAND}"
    wl " "
    ${PS_BIN} -ef | ${GREP_BIN} "ora_smon_$L_SID_NAME$" | ${GREP_BIN} -v 'grep'

    if (( $? == 0 )); then
        wl " "
        wl "TRACE> The Oracle instance (${L_SID_NAME}) IS running on this host."
    else
        wl " "
        wl "TRACE> The Oracle instance (${L_SID_NAME}) IS NOT running on this host."
        wl "TRACE> The Oracle instance (${L_SID_NAME}) must be running on this host to continue."
        exitFailed "FAILED" ${L_UNIQUE_SCRIPT_IDENTIFIER}
    fi

    return

}

function verifyTNSConnectString {

    typeset -r L_DB_NAME=${1}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${2}

    wl " "
    wl "TRACE> Check that the Oracle TNS connect string (${L_DB_NAME}) is valid."
    wl " "

    $ORACLE_HOME/bin/tnsping ${L_DB_NAME}

    if (( $? == 0 )); then
        wl " "
        wl "TRACE> The TNS service name ($L_DB_NAME) IS valid."
    else
        wl " "
        wl "TRACE> The TNS service name ($L_DB_NAME) IS NOT valid."
        exitFailed "FAILED" ${L_UNIQUE_SCRIPT_IDENTIFIER}
    fi

    return

}

function verifyDatabaseLoginCredentials {

    typeset -r L_DB_NAME=${1}
    typeset -r L_DBA_USERNAME=${2}
    typeset -r L_DBA_PASSWORD=${3}
    typeset -r L_SYSDBA_PRIVS=${4}
    typeset -r L_UNIQUE_SCRIPT_IDENTIFIER=${5}
    typeset    L_SYSDBA_PRIVS_TXT
    typeset -i L_EXIT_STATUS

    if [[ $L_SYSDBA_PRIVS = "SYSDBA" ]]; then
        L_SYSDBA_PRIVS_TXT=" AS SYSDBA"
    else
        L_SYSDBA_PRIVS_TXT=""
    fi

    wl " "
    wl "TRACE> Test log in credentials to database (${L_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_DB_NAME}${L_SYSDBA_PRIVS_TXT})."
    wl " "
    
    $ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
      WHENEVER OSERROR EXIT 9
      WHENEVER SQLERROR EXIT SQL.SQLCODE
      SPOOL ${SQL_OUTPUT_TEMP_FILE_NAME} REPLACE
      CONNECT ${L_DBA_USERNAME}/${L_DBA_PASSWORD}@${L_DB_NAME} ${L_SYSDBA_PRIVS_TXT}
      SET HEAD OFF 
      SET LINESIZE 145
      SET PAGESIZE 9000
      COLUMN USERNAME FORMAT A10
      COLUMN PROGRAM FORMAT A45
      COLUMN MACHINE FORMAT A30
      SELECT 'SQL*TRACE> Successfully logged in to the database (${L_DB_NAME}${L_SYSDBA_PRIVS_TXT}) as the [' || lower(user) || '] user.' FROM dual;
      SPOOL OFF
EOF

    L_EXIT_STATUS=$?
    wl "TRACE> SQL*Plus exit status ($L_EXIT_STATUS)."

    ${EGREP_BIN} 'ORA-|PLS-|SP2-' ${SQL_OUTPUT_TEMP_FILE_NAME}

    if (( $? == 0 ))
    then
        wl " "
        wl "TRACE> Database credentials for (${L_DB_NAME}${L_SYSDBA_PRIVS_TXT}) ARE NOT valid."
        exitFailed "FAILED" ${L_UNIQUE_SCRIPT_IDENTIFIER}
    else
        wl " "
        wl "TRACE> Database credentials for (${L_DB_NAME}${L_SYSDBA_PRIVS_TXT}) are valid."
        wl " "
        wl "TRACE> Removing temporary SQL output file ($SQL_OUTPUT_TEMP_FILE_NAME)."
        ${RM_BIN} -f $SQL_OUTPUT_TEMP_FILE_NAME
    fi

    return

}



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                    DEFINE ALL CUSTOM GLOBAL FUNCTIONS                      |
# |                                                                            |
# +----------------------------------------------------------------------------+





# +----------------------------------------------------------------------------+
# |                                                                            |
# |                            SCRIPT STARTS HERE                              |
# |                                                                            |
# +----------------------------------------------------------------------------+

initializeScript "${1}" $VERSION $CURRENT_YEAR


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| VERIFY OS LOGIN.                                                        |"
wl "+-------------------------------------------------------------------------+"

verifyOSUserLogin "oracle" "FALSE" $UNIQUE_SCRIPT_IDENTIFIER


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| VERIFY AN INSTANCE OF THIS SCRIPT IS NOT ALREADY RUNNING.               |"
wl "+-------------------------------------------------------------------------+"

checkScriptAlreadyRunning $SCRIPT_NAME $UNIQUE_SCRIPT_IDENTIFIER


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| GET O/S NAME, O/S TYPE, AND ORATAB FILE.                                |"
wl "+-------------------------------------------------------------------------+"

OS_NAME=`getOSName`
OS_TYPE=`getOSType $OS_NAME`
ORATAB_FILE=`getOratabFile $OS_TYPE`

wl " "
wl "TRACE> O/S Name                : ${OS_NAME}"
wl "TRACE> O/S Type                : ${OS_TYPE}"
wl "TRACE> Setting oratab file to  : ${ORATAB_FILE}"


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| SEARCH FOR ORACLE_HOME AND SET GLOBAL ORACLE ENVIRONMENT VARIABLES FOR  |"
wl "| TARGET SID ($TARGET_SID)."
wl "+-------------------------------------------------------------------------+"

NEW_ORACLE_HOME=`getOracleHome ${TARGET_SID} ${ORATAB_FILE}`

wl " "
wl "TRACE> NEW_ORACLE_HOME      = ${NEW_ORACLE_HOME}"

if [[ $NEW_ORACLE_HOME = "NO_ORACLE_HOME_FOUND" ]]; then
    
    wl " "
    wl "JMA-0010: Could not find an entry in oratab for TARGET_SID (${TARGET_SID})."

    exitFailed "FAILED" $UNIQUE_SCRIPT_IDENTIFIER

else

    wl " "
    wl "TRACE> Found entry in oratab for TARGET_SID (${TARGET_SID})"
    
    switchOracleEnv $NEW_ORACLE_HOME
    
fi


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| DISPLAY ALL SCRIPT ENVIRONMENT VARIABLES.                               |"
wl "+-------------------------------------------------------------------------+"

wl " "
wl "================================================================"
wl "                 GLOBAL SCRIPT VARIABLES                        "
wl "================================================================"
wl "ORGANIZATION NAME                    : $ORGANIZATION_NAME"
wl "SCRIPT                               : $SCRIPT_NAME"
wl "VERSION                              : $VERSION"
wl "START DATE/TIME                      : $START_DATE"
wl "CURRENT_DOW_NUM                      : $CURRENT_DOW_NUM"
wl "CURRENT_DOW_NAME                     : $CURRENT_DOW_NAME"
wl "SHELL ACCESS                         : $SPROP_SHELL_ACCESS"
wl "SHELL FLAGS                          : $SPROP_SHELL_FLAGS"
wl "PROCESS ID                           : $SPROP_PROCESS_ID"
wl "# OF SCRIPT PARAMETERS               : $SPROP_NUM_SCRIPT_PARAMS"
wl "# OF EXPECTED SCRIPT PARAMETERS      : $EXPECTED_NUM_SCRIPT_PARAMS"
wl "UNIQUE_SCRIPT_IDENTIFIER             : $UNIQUE_SCRIPT_IDENTIFIER"
wl "CHECK_SCRIPT_RUNNING_FLAG_FILE       : $CHECK_SCRIPT_RUNNING_FLAG_FILE"
wl "HOST_NAME                            : $HOSTNAME"
wl "HOST_NAME (UPPER)                    : $HOSTNAME_UPPER"
wl "HOST_NAME (SHORT)                    : $HOSTNAME_SHORT"
wl "HOST_NAME (SHORT/UPPER)              : $HOSTNAME_SHORT_UPPER"
wl "ORACLE_BASE                          : $ORACLE_BASE"
wl "ORACLE_HOME                          : $ORACLE_HOME"
wl "ORACLE_ADMIN_DIR                     : $ORACLE_ADMIN_DIR"
wl "ORACLE_DIAG_DIR                      : $ORACLE_DIAG_DIR"
wl "LOG_FILE_NAME                        : $LOG_FILE_NAME"
wl "LOG_FILE_NAME_NODATE                 : $LOG_FILE_NAME_NODATE"
wl "LOG_FILE_ARCHIVE_OBSOLETE_DAYS       : $LOG_FILE_ARCHIVE_OBSOLETE_DAYS"
wl "EMAIL RECIPIENT LIST - EXIT (S)      : ... <LIST> ..."
for email_address in $MAIL_RECIPIENT_LIST_EXIT_SUCCESS; do
    wl "                                       $email_address"
done
wl "EMAIL RECIPIENT LIST - EXIT (W)      : ... <LIST> ..."
for email_address in $MAIL_RECIPIENT_LIST_EXIT_WARNING; do
    wl "                                       $email_address"
done
wl "EMAIL RECIPIENT LIST - EXIT (F)      : ... <LIST> ..."
for email_address in $MAIL_RECIPIENT_LIST_EXIT_FAILED; do
    wl "                                       $email_address"
done

wl " "
wl "==========================================================="
wl "                  COMMAND-LINE ARGUMENTS                   "
wl "==========================================================="
wl "TARGET_DB_NAME                  (P1) : $TARGET_DB_NAME"
wl "TARGET_SID                      (P2) : $TARGET_SID"
wl "TARGET_DBA_USERNAME             (P3) : $TARGET_DBA_USERNAME"
wl "TARGET_DBA_PASSWORD             (P4) : $HIDE_PASSWORD_STRING"

wl " "
wl "==========================================================="
wl "                  CUSTOM SCRIPT VARIABLES                  "
wl "==========================================================="



DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| THIS SCRIPT IS TO BE RUN FROM THE DATABASE SERVER HOSTING THE TARGET    |"
wl "| DATABASE. VERIFY ORACLE INSTANCE IS UP AND RUNNING ON THIS HOST.        |"
wl "+-------------------------------------------------------------------------+"

verifyOracleSID $TARGET_SID $UNIQUE_SCRIPT_IDENTIFIER
    

DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| VERIFY THE ORACLE TNS CONNECT STRING IS VALID TO THE TARGET DATABASE.   |"
wl "+-------------------------------------------------------------------------+"

verifyTNSConnectString $TARGET_DB_NAME $UNIQUE_SCRIPT_IDENTIFIER


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| VERIFY LOG IN CREDENTIALS TO THE TARGET DATABASE.                       |"
wl "+-------------------------------------------------------------------------+"

verifyDatabaseLoginCredentials $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD "NOSYSDBA" $UNIQUE_SCRIPT_IDENTIFIER



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                        CUSTOM SCRIPT TASKS (BEGIN)                         |
# |                                                                            |
# +----------------------------------------------------------------------------+

DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| PERFORM LOG SWITCH.                                                     |"
wl "+-------------------------------------------------------------------------+"

$ORACLE_HOME/bin/sqlplus -s "${TARGET_DBA_USERNAME}/${TARGET_DBA_PASSWORD}@${TARGET_DB_NAME}" <<EOF | tee -a $LOG_FILE_NAME
    alter system switch logfile;
    exit;
EOF



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                       CUSTOM SCRIPT TASKS ( END )                          |
# |                                                                            |
# +----------------------------------------------------------------------------+

DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| SCAN LOG FILE FOR EXCEPTIONS. IGNORE KNOWN EXCEPTIONS.                  |"
wl "+-------------------------------------------------------------------------+"

${EGREP_BIN} 'ORA-|SP2-' $LOG_FILE_NAME

if (( $? == 0 ))
then 
    wl " "
    wl "+----------------------------------------------+"
    wl "| !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!|"
    wl "|                                              |"
    wl "|   --->        ERRORS WERE FOUND       <---   |"
    wl "|                                              |"
    wl "| !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!|"
    wl "+----------------------------------------------+"
    ERRORS="YES"
else 
    wl " "
    wl "TRACE> No exceptions were found."
    ERRORS="NO"
fi


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| REMOVING OBSOLETE SCRIPT LOG FILES (greater than $LOG_FILE_ARCHIVE_OBSOLETE_DAYS days old)"
wl "|   (${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}_*.log)"
wl "+-------------------------------------------------------------------------+"

${FIND_BIN} ${CUSTOM_ORACLE_LOG_DIR}/ -name "${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}_*.log" -mtime +${LOG_FILE_ARCHIVE_OBSOLETE_DAYS} -exec ${LS_BIN} -l {} \; | ${TEE_BIN} -a $LOG_FILE_NAME
${FIND_BIN} ${CUSTOM_ORACLE_LOG_DIR}/ -name "${SCRIPT_NAME_NOEXT}_${UNIQUE_SCRIPT_IDENTIFIER}_${HOSTNAME_SHORT_UPPER}_*.log" -mtime +${LOG_FILE_ARCHIVE_OBSOLETE_DAYS} -exec ${RM_BIN} -rf {} \; | ${TEE_BIN} -a $LOG_FILE_NAME


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| ABOUT TO EXIT SCRIPT.                                                   |"
wl "+-------------------------------------------------------------------------+"
wl " "

if [[ $ERRORS = "YES" ]]; then
    exitFailed "FAILED" $UNIQUE_SCRIPT_IDENTIFIER
else
    exitSuccess "SUCCESSFUL" $UNIQUE_SCRIPT_IDENTIFIER
fi
