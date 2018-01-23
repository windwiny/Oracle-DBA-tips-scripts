#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : ocfs2_check_orphaned_files.ksh                                |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : Used to check for any orphaned files in an OCFS2 file system. |
# |              This script queries the "orphan_dir" name space using the     |
# |              debugfs.ocfs2 command to determine the number of orphaned     |
# |              files. For example:                                           |
# |                                                                            |
# |              debugfs.ocfs2 -R "ls -l //orphan_dir:<OCFS2_SLOT_NUM>" <DISK_DEVICE_NAME>
# |                                                                            |
# |              This script should be scheduled to run on a nightly basis     |
# |              through CRON as the root user account.                        |
# |                                                                            |
# | OCFS2 VER. : ocfs2-tools-1.4.2-1.el5                                       |
# |              ocfs2-2.6.18-128.el5-1.4.2-1.el5                              |
# |              ocfs2console-1.4.2-1.el5                                      |
# |                                                                            |
# | PARAMETERS : DISK_DEVICE_NAME                   Name of the disk device.   |
# |                                                 For example:               |
# |                                                 /dev/iscsi/thingdbcrsvol1/part1
# |              OCFS2_SLOT_NUM                     Four digit OCFS2 slot      |
# |                                                 number that specifies      |
# |                                                 which node to check using  |
# |                                                 debugfs.ocfs2. For example,|
# |                                                 node 1 will be slot number |
# |                                                 0000, node 2 will be slot  |
# |                                                 number 0001, node 3 will   |
# |                                                 be slot number 0002, node  |
# |                                                 n will be slot number      |
# |                                                 LPAD(n-1, 4, '0'), and so  |
# |                                                 on.                        |
# |              OCFS2_ORPHAN_FILE_COUNT_THRESHOLD  Maximum number of orphaned |
# |                                                 files that can exist in the|
# |                                                 provided OCFS2 file system |
# |                                                 before this script issues  |
# |                                                 a warning.                 |
# |                                                                            |
# | EXAMPLE RUN:                                                               |
# |              Node 1                                                        |
# |              ocfs2_check_orphaned_files.ksh /dev/iscsi/thingdbocfs2vol1/part1 0000 5 > ocfs2_check_orphaned_files_thingdbocfs2vol1_part1_0000_THING1.job 2>&1
# |                                                                            |
# |              Node 2                                                        |
# |              ocfs2_check_orphaned_files.ksh /dev/iscsi/thingdbocfs2vol1/part1 0001 5 > ocfs2_check_orphaned_files_thingdbocfs2vol1_part1_0001_THING2.job 2>&1
# |                                                                            |
# |              Node 3                                                        |
# |              ocfs2_check_orphaned_files.ksh /dev/iscsi/thingdbocfs2vol1/part1 0002 5 > ocfs2_check_orphaned_files_thingdbocfs2vol1_part1_0002_RACNODE3.job 2>&1
# |                                                                            |
# |              Node 4                                                        |
# |              ocfs2_check_orphaned_files.ksh /dev/iscsi/thingdbocfs2vol1/part1 0003 5 > ocfs2_check_orphaned_files_thingdbocfs2vol1_part1_0003_RACNODE4.job 2>&1
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
DISK_DEVICE_NAME=$1
OCFS2_SLOT_NUM=$2
OCFS2_ORPHAN_FILE_COUNT_THRESHOLD=$3

EXPECTED_NUM_SCRIPT_PARAMS=3

# 
# If disk device name ends in /part[1-9],
# use the /deviceName/part[1-9] to
# determine the value for
# UNIQUE_SCRIPT_IDENTIFIER,
# else simply use the last portion
# of the device name.
#
DISK_DEVICE_NAME_UNIQUE=${1##*/}
if [[ $DISK_DEVICE_NAME_UNIQUE =~ ^(part[1-9])$ ]]; then
    UNIQUE_SCRIPT_IDENTIFIER=`echo $DISK_DEVICE_NAME | awk -F'/' {'print $(NF-1)'}`_`echo $DISK_DEVICE_NAME | awk -F'/' {'print $NF'}`_${OCFS2_SLOT_NUM}
else
    UNIQUE_SCRIPT_IDENTIFIER=${DISK_DEVICE_NAME_UNIQUE}_${OCFS2_SLOT_NUM}
fi

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
OCFS2_DEBUGFS_BIN=/sbin/debugfs.ocfs2

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
    wl "TRACE> DISK_DEVICE_NAME                   set to $DISK_DEVICE_NAME"
    wl "TRACE> OCFS2_SLOT_NUM                     set to $OCFS2_SLOT_NUM"
    wl "TRACE> OCFS2_ORPHAN_FILE_COUNT_THRESHOLD  set to $OCFS2_ORPHAN_FILE_COUNT_THRESHOLD"

}

function performScriptParameterValidation {

    typeset -r  L_VERSION=${1}
    typeset -r  L_CURRENT_YEAR=${2}
    typeset     L_OCFS2_SLOT_NUM_EXPECTED_LEN
    typeset     L_OCFS2_SLOT_NUM_LEN

    L_OCFS2_SLOT_NUM_EXPECTED_LEN=4
    L_OCFS2_SLOT_NUM_LEN=${#OCFS2_SLOT_NUM}

    # --------------------------------------------
    # VERIFY COMMAND-LINE OCFS2 SLOT NUMBER LENGTH
    # --------------------------------------------
    if (( $L_OCFS2_SLOT_NUM_LEN != $L_OCFS2_SLOT_NUM_EXPECTED_LEN )); then
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        echo " "
        echo "JMA-0003: Invalid OCFS2 slot number length (${L_OCFS2_SLOT_NUM_LEN})."
        echo "JMA-0004: The OCFS2 slot number length must be (${L_OCFS2_SLOT_NUM_EXPECTED_LEN})."
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
    $L_SHOW "    parameters:  disk_device_name"
    $L_SHOW "                 ocfs2_slot_number"
    $L_SHOW "                 ocfs2_orphan_file_count_threshold"
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
wl "DISK_DEVICE_NAME                  (P1) : $DISK_DEVICE_NAME"
wl "OCFS2_SLOT_NUM                    (P2) : $OCFS2_SLOT_NUM"
wl "OCFS2_ORPHAN_FILE_COUNT_THRESHOLD (P3) : $OCFS2_ORPHAN_FILE_COUNT_THRESHOLD"

wl " "
wl "==========================================================="
wl "                  CUSTOM SCRIPT VARIABLES                  "
wl "==========================================================="
wl "OCFS2_DEBUGFS_BIN                    : $OCFS2_DEBUGFS_BIN"



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
wl "| VERIFY DISK DEVICE NAME IS A VALID BLOCK SPECIAL FILE.                  |"
wl "+-------------------------------------------------------------------------+"

if [[ -b ${DISK_DEVICE_NAME} ]]; then
    wl " "
    wl "TRACE> The disk device ${DISK_DEVICE_NAME} is a valid block special file."
else
    wl " "
    wl "TRACE> The disk device ${DISK_DEVICE_NAME} is NOT a valid block special file."
    wl "TRACE> The disk device name must be a valid block special file."
    exitFailed "FAILED" "${UNIQUE_SCRIPT_IDENTIFIER}"
fi


DATE_PRINT_LOG=`${DATE_BIN} "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| CHECK FOR ORPHANED FILES ON OCFS2 FILE SYSTEM.                          |"
wl "+-------------------------------------------------------------------------+"

wl " "
wl "Count the number of orphaned files..."
OCFS2_ORPHAN_FILE_COUNT_TEMP=`${OCFS2_DEBUGFS_BIN} -R "ls -l //orphan_dir:${OCFS2_SLOT_NUM}" ${DISK_DEVICE_NAME} | ${WC_BIN} -l`
let OCFS2_ORPHAN_FILE_COUNT=${OCFS2_ORPHAN_FILE_COUNT_TEMP}-2
wl "TRACE> Found ${OCFS2_ORPHAN_FILE_COUNT} orphaned files."

if (( ${OCFS2_ORPHAN_FILE_COUNT} > ${OCFS2_ORPHAN_FILE_COUNT_THRESHOLD} )); then
    wl " "
    wl "TRACE> JMA-1001: Found (${OCFS2_ORPHAN_FILE_COUNT}) orphaned files beyond the defined threshold of ($OCFS2_ORPHAN_FILE_COUNT_THRESHOLD)."
else
    wl " "
    wl "TRACE> No orphaned files found beyond the defined threshold of ($OCFS2_ORPHAN_FILE_COUNT_THRESHOLD)."
fi

wl " "
wl "TRACE> To list orphaned files, use:"
wl "TRACE> ${OCFS2_DEBUGFS_BIN} -R \"ls -l //orphan_dir:${OCFS2_SLOT_NUM}\" ${DISK_DEVICE_NAME}"



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

${EGREP_BIN} 'ORA-|JMA-' $LOG_FILE_NAME | ${EGREP_BIN} -v 'JMA-19999'


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
wl "| REMOVING OBSOLETE SCRIPT LOG FILES (greater than $LOG_FILE_ARCHIVE_OBSOLETE_DAYS days old)           |"
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

    ${EGREP_BIN} 'JMA-1001' $LOG_FILE_NAME

    if (( $? == 0 ))
    then 
        exitWarning "WARNING" $UNIQUE_SCRIPT_IDENTIFIER
    else 
        exitFailed "FAILED" $UNIQUE_SCRIPT_IDENTIFIER
    fi

else
    exitSuccess "SUCCESSFUL" $UNIQUE_SCRIPT_IDENTIFIER
fi
