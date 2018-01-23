#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : crs_components_backup_10g.ksh                                 |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : This script is responsible for backing up the two critical    |
# |              Oracle Clusterware components - the OCR File and the Voting   |
# |              Disk.                                                         |
# |                                                                            |
# |              This script should be scheduled to run on a nightly basis     |
# |              through CRON as the root user account.                        |
# |                                                                            |
# | ORACLE VER.: Oracle RAC 10g Release 1                                      |
# |              Oracle RAC 10g Release 2                                      |
# |                                                                            |
# | PARAMETERS :                                                               |
# |               CRS_CLUSTER_NAME    Name of the cluster. (i.e. crs)          |
# |               BACKUP_VOTING_DISK  To backup the voting disk(s), set this   |
# |                                   parameter to a value of VOTEDISK. To     |
# |                                   skip the backup of all voting disk(s),   |
# |                                   set this parameter to NOVOTEDISK.        |
# |               BACKUP_OCR_FILE     To backup the OCR file(s), set this      |
# |                                   parameter to a value of OCRFILE. To      |
# |                                   skip the backup of all OCR file(s), set  |
# |                                   this parameter to NOOCRFILE.             |
# |                                                                            |
# | EXAMPLE RUN:                                                               |
# |              Node 1                                                        |
# |              crs_components_backup_10g.ksh crs VOTEDISK OCRFILE > crs_components_backup_10g_crs_THING1.job 2>&1
# |                                                                            |
# |              Node 2                                                        |
# |              crs_components_backup_10g.ksh crs NOVOTEDISK OCRFILE > crs_components_backup_10g_crs_THING2.job 2>&1
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
CRS_CLUSTER_NAME=$1
BACKUP_VOTING_DISK=`echo $2 | tr '[:lower:]' '[:upper:]'`
BACKUP_OCR_FILE=`echo $3 | tr '[:lower:]' '[:upper:]'`

EXPECTED_NUM_SCRIPT_PARAMS=3

UNIQUE_SCRIPT_IDENTIFIER=$CRS_CLUSTER_NAME

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
ORA_CRS_HOME=/u01/app/crs
DD_BLOCK_SIZE=4k

# ----------------------------
# SET VOTING DISK VARIABLES
# ----------------------------
VOTING_DISK[1]=/u02/oradata/thingdb/CSSFile
# VOTING_DISK[2]=/u02/oradata/thingdb/CSSFile_mirror1
# VOTING_DISK[3]=/u02/oradata/thingdb/CSSFile_mirror2

VOTING_DISK_BACKUP_BASE_DIR=/u03/crs_backup/votebackup

VOTING_DISK_BACKUP_FILE_PREFIX=VotingDiskBackup

VOTING_DISK_RETENTION_DAYS=3

VOTING_DISK_OWNER=oracle
VOTING_DISK_GROUP=oinstall
VOTING_DISK_PERMISSIONS=644

# ----------------------------
# SET OCR VARIABLES
# ----------------------------
OCR_FILE[1]=/u02/oradata/thingdb/OCRFile
# OCR_FILE[2]=/u02/oradata/thingdb/OCRFile_mirror

OCR_FILE_BACKUP_BASE_DIR=/u03/crs_backup/ocrbackup

OCR_FILE_BACKUP_FILE_PREFIX=OCRFileBackup

OCR_FILE_RETENTION_DAYS=3

OCR_FILE_OWNER=root
OCR_FILE_GROUP=oinstall
OCR_FILE_PERMISSIONS=640

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
MAIL_RECIPIENT_LIST_EXIT_SUCCESS="jhunter@idevelopment.info"
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
CHMOD_BIN=/bin/chmod
CHOWN_BIN=/bin/chown
CP_BIN=/bin/cp
CPIO_BIN=/bin/cpio
DATE_BIN=/bin/date
DD_BIN=/bin/dd
EGREP_BIN=/bin/egrep
FIND_BIN=/usr/bin/find
GREP_BIN=/bin/grep
GZIP_BIN=/bin/gzip
HOSTNAME_BIN=/bin/hostname
ID_BIN=/usr/bin/id
LS_BIN=/bin/ls
MKDIR_BIN=/bin/mkdir
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
    wl "TRACE> CRS_CLUSTER_NAME     set to $CRS_CLUSTER_NAME"
    wl "TRACE> BACKUP_VOTING_DISK   set to $BACKUP_VOTING_DISK"
    wl "TRACE> BACKUP_OCR_FILE      set to $BACKUP_OCR_FILE"

}

function performScriptParameterValidation {

    typeset -r  L_VERSION=${1}
    typeset -r  L_CURRENT_YEAR=${2}
    typeset     L_TEMP_VALUE

    # --------------------------------------------
    # VERIFY BACKUP VOTING DISK VALUE
    # --------------------------------------------
    if [[ $BACKUP_VOTING_DISK = "VOTEDISK" || $BACKUP_VOTING_DISK = "NOVOTEDISK" ]]; then
        L_TEMP_VALUE="Correct Value"
    else
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        echo " "
        echo "JMA-0003: Invalid BACKUP_VOTING_DISK value (${BACKUP_VOTING_DISK})."
        echo "JMA-0004: BACKUP_VOTING_DISK must be set to VOTEDISK or NOVOTEDISK."
        echo " "
        exit $HOST_RVAL_SUCCESS
    fi


    # --------------------------------------------
    # VERIFY BACKUP OCR FILE VALUE
    # --------------------------------------------
    if [[ $BACKUP_OCR_FILE = "OCRFILE" || $BACKUP_OCR_FILE = "NOOCRFILE" ]]; then
        L_TEMP_VALUE="Correct Value"
    else
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        echo " "
        echo "JMA-0005: Invalid BACKUP_OCR_FILE value (${BACKUP_OCR_FILE})."
        echo "JMA-0006: BACKUP_OCR_FILE must be set to OCRFILE or NOOCRFILE."
        echo " "
        exit $HOST_RVAL_SUCCESS
    fi

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
    $L_SHOW "    parameters:  crs_cluster_name"
    $L_SHOW "                 backup_voting_disk = VOTEDISK | NOVOTEDISK"
    $L_SHOW "                 backup_ocr_file = OCRFILE | NOOCRFILE"
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

function performVotingDiskBackup {

    wl " "
    wl "TRACE> Listing current voting disks..."
    $ORA_CRS_HOME/bin/crsctl query css votedisk | ${TEE_BIN} -a $LOG_FILE_NAME
    
    VOTING_DISK_BACKUP_DIR=${VOTING_DISK_BACKUP_BASE_DIR}/${HOSTNAME_SHORT_UPPER}
    
    wl " "
    wl "TRACE> Making directory ${VOTING_DISK_BACKUP_DIR}"
    ${MKDIR_BIN} -p ${VOTING_DISK_BACKUP_DIR}
    ${CHOWN_BIN} ${VOTING_DISK_OWNER}:${VOTING_DISK_GROUP} ${VOTING_DISK_BACKUP_DIR}
    
    wl " "
    wl "TRACE> Starting voting disk backup process..."
    for i in "${!VOTING_DISK[@]}"; do
    
        VOTING_DISK_FULL=${VOTING_DISK[$i]}
        VOTING_DISK_FILENAME=${VOTING_DISK_FULL##*/}
        wl " "
        wl "TRACE> Working on voting disk [$i]: ${VOTING_DISK_FULL}"
    
        VOTING_DISK_FULLNAME_BACKUP="${VOTING_DISK_BACKUP_DIR}/${VOTING_DISK_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_${VOTING_DISK_FILENAME}_${START_DATE_LOG}.dmp"
        wl "TRACE> Creating voting disk backup: ${VOTING_DISK_FULLNAME_BACKUP}"
    
        ${DD_BIN} if=${VOTING_DISK_FULL} of=${VOTING_DISK_FULLNAME_BACKUP} bs=${DD_BLOCK_SIZE} | ${TEE_BIN} -a $LOG_FILE_NAME
    
        if (( $? == 0 )); then 
            wl " "
            wl "TRACE> No exceptions were found."
        else 
            wl " "
            wl "TRACE> JMA-1001: Error creating voting disk backup."
            continue
        fi
    
        ${CHOWN_BIN} ${VOTING_DISK_OWNER}:${VOTING_DISK_GROUP} ${VOTING_DISK_FULLNAME_BACKUP}
        ${CHMOD_BIN} ${VOTING_DISK_PERMISSIONS} ${VOTING_DISK_FULLNAME_BACKUP}
    
        wl " "
        wl "+-------------------------------------------------------------------------+"
        wl "| LIST VOTING DISK RESTORE COMMAND                                        |"
        wl "+-------------------------------------------------------------------------+"
        wl " "
        wl "dd if=${VOTING_DISK_FULLNAME_BACKUP} of=${VOTING_DISK_FULL} bs=${DD_BLOCK_SIZE}"
    
    done
    

    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| REMOVING OBSOLETE VOTING DISK BACKUPS (greater than $VOTING_DISK_RETENTION_DAYS days old)         |"
    wl "|   (${VOTING_DISK_BACKUP_DIR}/${VOTING_DISK_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp)"
    wl "+-------------------------------------------------------------------------+"
    
    ${FIND_BIN} ${VOTING_DISK_BACKUP_DIR}/ -name "${VOTING_DISK_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp" -mtime +${VOTING_DISK_RETENTION_DAYS} -exec ls -l {} \; | ${TEE_BIN} -a $LOG_FILE_NAME
    ${FIND_BIN} ${VOTING_DISK_BACKUP_DIR}/ -name "${VOTING_DISK_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp" -mtime +${VOTING_DISK_RETENTION_DAYS} -exec rm -rf {} \; | ${TEE_BIN} -a $LOG_FILE_NAME

}

function performOCRFileBackup {

    wl " "
    wl "TRACE> Listing current OCR files..."
    $ORA_CRS_HOME/bin/ocrcheck | ${TEE_BIN} -a $LOG_FILE_NAME
    
    wl " "
    wl "TRACE> Listing current OCR file physical backups..."
    $ORA_CRS_HOME/bin/ocrconfig -showbackup | ${TEE_BIN} -a $LOG_FILE_NAME
    
    OCR_FILE_BACKUP_EXPORT_DIR=${OCR_FILE_BACKUP_BASE_DIR}/${HOSTNAME_SHORT_UPPER}/exports
    OCR_FILE_BACKUP_AUTO_DIR=${OCR_FILE_BACKUP_BASE_DIR}/${HOSTNAME_SHORT_UPPER}/cdata 
    
    wl " "
    wl "TRACE> Making directory ${OCR_FILE_BACKUP_EXPORT_DIR}"
    ${MKDIR_BIN} -p ${OCR_FILE_BACKUP_EXPORT_DIR}
    ${CHOWN_BIN} ${OCR_FILE_OWNER}:${OCR_FILE_GROUP} ${OCR_FILE_BACKUP_EXPORT_DIR}
    
    wl " "
    wl "TRACE> Making directory ${OCR_FILE_BACKUP_AUTO_DIR}"
    ${MKDIR_BIN} -p ${OCR_FILE_BACKUP_AUTO_DIR}
    ${CHOWN_BIN} ${OCR_FILE_OWNER}:${OCR_FILE_GROUP} ${OCR_FILE_BACKUP_AUTO_DIR}
    
    wl " "
    wl "TRACE> Copy all OCR file physical backups (cdata)..."
    ${CP_BIN} -R -p -v $ORA_CRS_HOME/cdata/* ${OCR_FILE_BACKUP_AUTO_DIR}/ | ${TEE_BIN} -a $LOG_FILE_NAME
    
    wl " "
    wl "TRACE> Export the contents of the OCR using the logical backup method..."
    
    OCR_FILE_FULLNAME_BACKUP="${OCR_FILE_BACKUP_EXPORT_DIR}/${OCR_FILE_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_${START_DATE_LOG}.dmp"
    
    wl " "
    wl "TRACE> Creating logical backup: ${OCR_FILE_FULLNAME_BACKUP}"
    
    $ORA_CRS_HOME/bin/ocrconfig -export $OCR_FILE_FULLNAME_BACKUP
    
    if (( $? == 0 )); then 
        wl " "
        wl "TRACE> No exceptions were found."
        ${CHOWN_BIN} ${OCR_FILE_OWNER}:${OCR_FILE_GROUP} ${OCR_FILE_FULLNAME_BACKUP}
        ${CHMOD_BIN} ${OCR_FILE_PERMISSIONS} ${OCR_FILE_FULLNAME_BACKUP}
    else 
        wl " "
        wl "TRACE> JMA-1002: Error creating OCR logical backup."
    fi
    
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| LIST OCR RESTORE COMMANDS                                               |"
    wl "+-------------------------------------------------------------------------+"
    
    wl " "
    wl "1.) Restore the OCR from most recent physical backup"
    wl " "
    wl "    $ORA_CRS_HOME/bin/ocrconfig -restore ${OCR_FILE_BACKUP_AUTO_DIR}/crs/backup00.ocr"
    
    wl " "
    wl "2.) Restore the OCR from day old physical backup"
    wl " "
    wl "    $ORA_CRS_HOME/bin/ocrconfig -restore ${OCR_FILE_BACKUP_AUTO_DIR}/crs/day.ocr"
    
    wl " "
    wl "3.) Restore the OCR from week old physical backup"
    wl " "
    wl "    $ORA_CRS_HOME/bin/ocrconfig -restore ${OCR_FILE_BACKUP_AUTO_DIR}/crs/week.ocr"
    
    wl " "
    wl "4.) Restore the OCR from logical backup of OCR taken using the export option"
    wl " "
    wl "    $ORA_CRS_HOME/bin/ocrconfig -import ${OCR_FILE_FULLNAME_BACKUP}"
    
    
    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| REMOVING OBSOLETE OCR LOGICAL BACKUPS (greater than $OCR_FILE_RETENTION_DAYS days old)         |"
    wl "|   (${OCR_FILE_BACKUP_EXPORT_DIR}/${OCR_FILE_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp)"
    wl "+-------------------------------------------------------------------------+"
    
    ${FIND_BIN} ${OCR_FILE_BACKUP_EXPORT_DIR}/ -name "${OCR_FILE_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp" -mtime +${OCR_FILE_RETENTION_DAYS} -exec ls -l {} \; | ${TEE_BIN} -a $LOG_FILE_NAME
    ${FIND_BIN} ${OCR_FILE_BACKUP_EXPORT_DIR}/ -name "${OCR_FILE_BACKUP_FILE_PREFIX}_${UNIQUE_SCRIPT_IDENTIFIER}_*.dmp" -mtime +${OCR_FILE_RETENTION_DAYS} -exec rm -rf {} \; | ${TEE_BIN} -a $LOG_FILE_NAME

}



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

verifyOSUserLogin "root" "TRUE" $UNIQUE_SCRIPT_IDENTIFIER


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
wl "CRS_CLUSTER_NAME       (P1)          : $CRS_CLUSTER_NAME"
wl "BACKUP_VOTING_DISK     (P2)          : $BACKUP_VOTING_DISK"
wl "BACKUP_OCR_FILE        (P3)          : $BACKUP_OCR_FILE"

wl " "
wl "==========================================================="
wl "                  CUSTOM SCRIPT VARIABLES                  "
wl "==========================================================="
wl "ORA_CRS_HOME                         : $ORA_CRS_HOME"
wl "DD_BLOCK_SIZE                        : $DD_BLOCK_SIZE"
for i in "${!VOTING_DISK[@]}"; do
    wl "VOTING_DISK[$i]                       : ${VOTING_DISK[$i]}"
done
wl "VOTING_DISK_BACKUP_BASE_DIR          : $VOTING_DISK_BACKUP_BASE_DIR"
wl "VOTING_DISK_BACKUP_FILE_PREFIX       : $VOTING_DISK_BACKUP_FILE_PREFIX"
wl "VOTING_DISK_RETENTION_DAYS           : $VOTING_DISK_RETENTION_DAYS"
wl "VOTING_DISK_OWNER                    : $VOTING_DISK_OWNER"
wl "VOTING_DISK_GROUP                    : $VOTING_DISK_GROUP"
wl "VOTING_DISK_PERMISSIONS              : $VOTING_DISK_PERMISSIONS"
for i in "${!OCR_FILE[@]}"; do
    wl "OCR_FILE[$i]                          : ${OCR_FILE[$i]}"
done
wl "OCR_FILE_BACKUP_BASE_DIR             : $OCR_FILE_BACKUP_BASE_DIR"
wl "OCR_FILE_BACKUP_FILE_PREFIX          : $OCR_FILE_BACKUP_FILE_PREFIX"
wl "OCR_FILE_RETENTION_DAYS              : $OCR_FILE_RETENTION_DAYS"
wl "OCR_FILE_OWNER                       : $OCR_FILE_OWNER"
wl "OCR_FILE_GROUP                       : $OCR_FILE_GROUP"
wl "OCR_FILE_PERMISSIONS                 : $OCR_FILE_PERMISSIONS"



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                        CUSTOM SCRIPT TASKS (BEGIN)                         |
# |                                                                            |
# +----------------------------------------------------------------------------+

DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| BACKUP VOTING DISK(s).                                                  |"
wl "+-------------------------------------------------------------------------+"

if [[ ${BACKUP_VOTING_DISK} = "VOTEDISK" ]]; then
    wl " "
    wl "TRACE> Performing voting disk backups."
    performVotingDiskBackup
else
    wl " "
    wl "TRACE> Voting disk backup will NOT be performed as per user request."
fi


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| BACKUP OCR FILE(s).                                                     |"
wl "+-------------------------------------------------------------------------+"

if [[ ${BACKUP_OCR_FILE} = "OCRFILE" ]]; then
    wl " "
    wl "TRACE> Performing OCR file backups."
    performOCRFileBackup
else
    wl " "
    wl "TRACE> OCR file backup will NOT be performed as per user request."
fi


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

${EGREP_BIN} 'ORA-|CRS-|JMA-' $LOG_FILE_NAME | ${EGREP_BIN} -v 'JMA-19999'

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
