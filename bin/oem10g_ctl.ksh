#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE : Oracle                                                          |
# | FILE     : oem10g_ctl.ksh                                                  |
# | CLASS    : UNIX Shell Scripts                                              |
# | PURPOSE  : Used to control all components of Oracle Enterprise Manager     |
# |            (OEM). This script can be used for both Database Control and    |
# |            Grid Control and is controlled by one of the parameters to this |
# |            script. Use this script to start and stop OEM10g components as  |
# |            well as checking status.                                        |
# |                                                                            |
# | USAGE    : oem10g_ctl  "start|stop|status"  "grid|dbconsole|agent"         |
# |                                                                            |
# | OEM COMPS: This section looks into the different OEM Grid Control          |
# |            components.                                                     |
# |                                                                            |
# |            - ORACLE MANAGEMENT SERVICE                                     |
# |              Use the "emctl start oms" command to start/stop the Oracle    |
# |              Application Server components required to run the Management  |
# |              Service J2EE application. Specifically, this command starts   |
# |              OPMN, the Oracle HTTP Server, and the OC4J_EM instance where  |
# |              the Management Service is deployed. Note that the emctl start |
# |              "oms" command option does not start Oracle Application Server |
# |              Web Cache.                                                    |
# |                                                                            |
# |            - ORACLE APPLICATION SERVER COMPONENTS                          |
# |              Components such as the Oracle HTTP Server the OracleAS Web    |
# |              Cache.                                                        |
# |                                                                            |
# |            - APPLICATION SERVER CONTROL CONSOLE (optional)                 |
# |              Optional component used to manage the Oracle Application      |
# |              Server instance that is used to deploy the Management         |
# |              Service. This usually starts on "http://<host_name>:1810/"    |
# |              for Oracle10g R1 and "http://<host_name>:4889/" for           |
# |              Oracle10g R2.
# |                                                                            |
# | NOTE     : As with any code, ensure to test this script in a development   |
# |            environment before attempting to run it in production.          |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# |                                                                            |
# |                       DEFINE ALL GLOBAL VARIABLES                          |
# |                                                                            |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
VERSION="5.2"
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%%\.ksh}

# ----------------------------
# DATE VARIABLES
# ----------------------------
START_DATE=`date`
DATE_LOG=`date +%Y-%m-%d-%H:%M`
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
LOG_FILE_NAME=${CUSTOM_ORACLE_LOG_DIR}/${SCRIPT_NAME_NOEXT}.log

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
ORACLE_ADMIN_DIR=${ORACLE_BASE}/admin
ORACLE_HOME=${ORACLE_BASE}/product/oms10g;
AGENT_HOME=${ORACLE_BASE}/product/agent10g;
ORACLE_SID=emrep;

export ORACLE_BASE ORACLE_ADMIN_DIR ORACLE_HOME AGENT_HOME ORACLE_SID

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
SLEEP="sleep 2"
OEM_GRID_CONTROL_WEB_SITE_10gR1="http://`hostname`:7777/em"
OEM_GRID_CONTROL_WEB_SITE_10gR2="http://`hostname`:4889/em"
OEM_GRID_CONTROL_AS_WEB_SITE_10gR1="http://`hostname`:1810/"
OEM_GRID_CONTROL_AS_WEB_SITE_10gR2="http://`hostname`:4889/"
OEM_DATABASE_CONTROL_WEB_SITE_10gR1="http://`hostname`:5500/em"
OEM_DATABASE_CONTROL_WEB_SITE_10gR2="http://`hostname`:1158/em"


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

    rm -f ${LOG_FILE_NAME}

}

showUsage() {

    wl "USAGE:"
    wl "oem10g_ctl.ksh \"start|stop|status\" \"grid|dbconsole|agent\" "
    wl " "
}

showSignonBanner() {

    wl " "
    wl "$SCRIPT_NAME - Version $VERSION"
    wl "Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved."
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

if [[ $# -eq 2 ]]; then
    export OEM_ACTION=$1
    export OEM_TYPE=$2
else
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

if [[ $OEM_TYPE != "grid" ]] && [[ $OEM_TYPE != "dbconsole" ]] && [[ $OEM_TYPE != "agent" ]] ; then
    wl "ERROR: OEM type must be either \"grid\", \"dbconsole\" or \"agent\"."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

if [[ $OEM_ACTION != "start" ]] && [[ $OEM_ACTION != "stop" ]] && [[ $OEM_ACTION != "status" ]]; then
    wl "ERROR: Action type must be either \"start\", \"stop\", or \"status\"."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

if [[ $ORACLE_HOME = "" ]]; then
    wl "ERROR: \$ORACLE_HOME environmnet variable must be set to the"
    wl "       OEM Management Server / Management Repository home."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

if [[ $AGENT_HOME = "" ]] && [[ $OEM_TYPE = "grid" ]]; then
    wl "ERROR: \$AGENT_HOME environment variable must be set to the"
    wl "      Management Agent home."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

if [[ $AGENT_HOME = "" ]] && [[ $OEM_TYPE = "agent" ]]; then
    wl "ERROR: \$AGENT_HOME environment variable must be set to the"
    wl "      Management Agent home."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi


if [[ $ORACLE_SID = "" ]]; then
    wl "ERROR: \$ORACLE_SID environment variable must be set to the"
    wl "      Management Repository database."
    wl " "
    showUsage
    rm -f ${LOG_FILE_NAME}
    exit 2
fi

getOSName

if [[ $UNIX_TYPE = "linux" ]]; then
    ORATAB_FILE="/etc/oratab"
elif [[ $UNIX_TYPE = "solaris" ]];then
    ORATAB_FILE="/var/opt/oracle/oratab"
else
    ORATAB_FILE="/etc/oratab"
fi

wl "==================================================================================="
wl "                             COMMON SCRIPT VARIABLES"
wl "==================================================================================="
wl "SCRIPT                                : $SCRIPT_NAME"
wl "VERSION                               : $VERSION"
wl "START TIME                            : $START_DATE"
wl "HOST NAME                             : $HOSTNAME"
wl "O/S PLATFORM                          : $UNIX_TYPE"
wl "ORATAB_FILE                           : $ORATAB_FILE"
wl "LOG_FILE_NAME                         : $LOG_FILE_NAME"
wl "==================================================================================="
wl "                             CUSTOM SCRIPT VARIABLES"
wl "==================================================================================="
wl "OEM_TYPE          (P1)                : $OEM_TYPE"
wl "OEM_ACTION        (P2)                : $OEM_ACTION"
wl "ORACLE_HOME                           : $ORACLE_HOME"
wl "AGENT_HOME                            : $AGENT_HOME"
wl "ORACLE_SID                            : $ORACLE_SID"
wl "OEM_GRID_CONTROL_WEB_SITE_10gR1       : $OEM_GRID_CONTROL_WEB_SITE_10gR1"
wl "OEM_GRID_CONTROL_WEB_SITE_10gR2       : $OEM_GRID_CONTROL_WEB_SITE_10gR2"
wl "OEM_GRID_CONTROL_AS_WEB_SITE_10gR1    : $OEM_GRID_CONTROL_AS_WEB_SITE_10gR1"
wl "OEM_GRID_CONTROL_AS_WEB_SITE_10gR2    : $OEM_GRID_CONTROL_AS_WEB_SITE_10gR2"
wl "OEM_DATABASE_CONTROL_WEB_SITE_10gR1   : $OEM_DATABASE_CONTROL_WEB_SITE_10gR1"
wl "OEM_DATABASE_CONTROL_WEB_SITE_10gR2   : $OEM_DATABASE_CONTROL_WEB_SITE_10gR2"
wl "==================================================================================="
wl " "


if [[ $OEM_TYPE = "grid" ]]; then

    # +--------------------------------------------------------------------------------+
    # |                          <<<<<< START >>>>>>                                   |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "start" ]]; then

        wl " "
        wl "+--------------+"
        wl "| GRID CONTROL |"
        wl "|---------------------------------------------------------------------+"
        wl "| Starting OEM Components                                             |"
        wl "+---------------------------------------------------------------------+"
        wl " "

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND="$ORACLE_HOME/bin/lsnrctl start"
        wl "+--------------+"
        wl "| STARTING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| TNS Listener                                                           |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        wl " "
        wl "+--------------+"
        wl "| STARTING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Repository (database)                                |"
        wl "+------------------------------------------------------------------------+"
        $ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a ${LOG_FILE_NAME}
            connect / as sysdba
            startup
            exit
EOF

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"
        $SLEEP

        wl " "
        COMMAND="$ORACLE_HOME/opmn/bin/opmnctl startall"
        wl "+--------------+"
        wl "| STARTING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Components                                   |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        wl " "
        COMMAND="$ORACLE_HOME/opmn/bin/opmnctl status"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Components                                   |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        wl " "
        COMMAND="$AGENT_HOME/bin/emctl start agent"
        wl "+--------------+"
        wl "| STARTING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP


        wl " "
        wl "DONE!"
        wl " "
        wl "--> OEM Grid Control 10gR1 is started on ${OEM_GRID_CONTROL_WEB_SITE_10gR1}"
        wl "--> OEM Grid Control 10gR2 is started on ${OEM_GRID_CONTROL_WEB_SITE_10gR2}"
        wl " "
        wl "--> OEM Application Server Control 10gR1 is started on ${OEM_GRID_CONTROL_AS_WEB_SITE_10gR1}"
        wl "--> OEM Application Server Control 10gR2 is started on ${OEM_GRID_CONTROL_AS_WEB_SITE_10gR2}"
        wl " "

    fi



    # +--------------------------------------------------------------------------------+
    # |                             <<<<<< STOP >>>>>>                                 |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "stop" ]]; then

        wl " "
        wl "+--------------+"
        wl "| GRID CONTROL |"
        wl "|------------------------------------------------------------------------+"
        wl "| Stopping OEM Components                                                |"
        wl "+------------------------------------------------------------------------+"
        wl " "

        wl " "
        COMMAND="$AGENT_HOME/bin/emctl stop agent"
        wl "+--------------+"
        wl "| STOPPING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        wl " "
        COMMAND="$ORACLE_HOME/opmn/bin/opmnctl stopall"
        wl "+--------------+"
        wl "| STOPPING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Components                                   |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        wl " "
        COMMAND="$ORACLE_HOME/opmn/bin/opmnctl status"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Components                                   |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl " "
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND="$ORACLE_HOME/bin/lsnrctl stop"
        wl "+--------------+"
        wl "| STOPPING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| TNS Listener                                                           |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        wl " "
        wl "+--------------+"
        wl "| STOPPING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Repository (database)                                |"
        wl "+------------------------------------------------------------------------+"
        $ORACLE_HOME/bin/sqlplus /nolog <<EOF | tee -a ${LOG_FILE_NAME}
            connect / as sysdba
            shutdown immediate
            exit
EOF

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"

        wl " "
        wl "DONE!"
        wl " "
        wl "--> OEM Grid Control 10gR1 is stopped on ${OEM_GRID_CONTROL_WEB_SITE_10gR1}"
        wl "--> OEM Grid Control 10gR2 is stopped on ${OEM_GRID_CONTROL_WEB_SITE_10gR2}"
        wl " "
        wl "--> OEM Application Server Control 10gR1 is stopped on ${OEM_GRID_CONTROL_AS_WEB_SITE_10gR1}"
        wl "--> OEM Application Server Control 10gR2 is stopped on ${OEM_GRID_CONTROL_AS_WEB_SITE_10gR2}"
        wl " "

    fi

    # +--------------------------------------------------------------------------------+
    # |                                <<<<<< STATUS >>>>>>                            |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "status" ]]; then
        wl " "
        wl "+--------------+"
        wl "| GRID CONTROL |"
        wl "|------------------------------------------------------------------------+"
        wl "| OEM Component Status                                                   |"
        wl "+------------------------------------------------------------------------+"
        wl " "

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND1="$ORACLE_HOME/bin/lsnrctl status"
        COMMAND2="$ORACLE_HOME/bin/tnsping $ORACLE_SID"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| TNS Listener                                                           |"
        wl "| COMMAND1: $COMMAND1"
        wl "| COMMAND1: $COMMAND2"
        wl "+------------------------------------------------------------------------+"
        STATUS=`ps -fu oracle | grep -v grep | grep lsnr`
        if [[ $? = 0 ]]; then
            wl "[TNS Listener is ONLINE!]"
            $COMMAND1 | tee -a ${LOG_FILE_NAME}
            $COMMAND2 | tee -a ${LOG_FILE_NAME}
        else
            wl "[TNS Listener is OFFLINE]"
        fi


        wl " "
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Repository (database)                                |"
        wl "+------------------------------------------------------------------------+"
        STATUS=`ps -fu oracle | grep -v grep | grep $ORACLE_SID | grep ora_`
        if [[ $? = 0 ]]; then
            wl "[Database $ORACLE_SID is ONLINE!]"
            $ORACLE_HOME/bin/sqlplus -s /nolog <<EOF | tee -a ${LOG_FILE_NAME}
                set head off
                set verify off
                connect / as sysdba
                select '[Successful database login as ' || user || ']'
                from dual;
                exit
EOF
        else
            wl "[Database $ORACLE_SID is OFFLINE]"
        fi

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"

        wl " "
        COMMAND="$ORACLE_HOME/bin/emctl status oms"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Server                                               |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        wl " "
        COMMAND="$ORACLE_HOME/opmn/bin/opmnctl status"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Components                                   |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        wl " "
        COMMAND="$AGENT_HOME/bin/emctl status agent"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        wl " "
        COMMAND="$ORACLE_HOME/bin/emctl status iasconsole"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Application Server Control Console - (optional)                 |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        wl " "
        wl "DONE!"
        wl " "

    fi

fi



if [[ $OEM_TYPE = "dbconsole" ]]; then


    # +--------------------------------------------------------------------------------+
    # |                             <<<<<< START >>>>>>                                |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "start" ]]; then
        wl " "
        wl "+--------------+"
        wl "| DB CONSOLE   |"
        wl "|------------------------------------------------------------------------+"
        wl "| Starting OEM Components                                                |"
        wl "+------------------------------------------------------------------------+"
        wl " "

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND="$ORACLE_HOME/bin/emctl start dbconsole"
        wl "+--------------+"
        wl "| START        |"
        wl "|------------------------------------------------------------------------+"
        wl "| Database Console                                                       |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"

        wl " "
        wl "DONE!"
        wl " "
        wl "--> OEM Database Control 10gR1 is started on ${OEM_DATABASE_CONTROL_WEB_SITE_10gR1}"
        wl "--> OEM Database Control 10gR2 is started on ${OEM_DATABASE_CONTROL_WEB_SITE_10gR1}"
        wl " "

    fi



    # +--------------------------------------------------------------------------------+
    # |                             <<<<<< STOP >>>>>>                                 |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "stop" ]]; then
        wl " "
        wl "+--------------+"
        wl "| DB CONSOLE   |"
        wl "|------------------------------------------------------------------------+"
        wl "| Stopping OEM Components                                                |"
        wl "+------------------------------------------------------------------------+"
        wl " "

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND="$ORACLE_HOME/bin/emctl stop dbconsole"
        wl "+--------------+"
        wl "| STOP         |"
        wl "|------------------------------------------------------------------------+"
        wl "| Database Console                                                       |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"

        wl " "
        wl "DONE!"
        wl " "
        wl "--> OEM Database Control 10gR1 is stopped on ${OEM_DATABASE_CONTROL_WEB_SITE_10gR1}"
        wl "--> OEM Database Control 10gR2 is stopped on ${OEM_DATABASE_CONTROL_WEB_SITE_10gR2}"
        wl " "

    fi



    # +--------------------------------------------------------------------------------+
    # |                                <<<<<< STATUS >>>>>>                            |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "status" ]]; then
        wl " "
        wl "+--------------+"
        wl "| DB CONSOLE   |"
        wl "|------------------------------------------------------------------------+"
        wl "| OEM Component Status                                                   |"
        wl "+------------------------------------------------------------------------+"
        wl " "

        for DB_ENTRY in `cat ${ORATAB_FILE} | grep -v '^\#' | grep -v '^\*' | cut -d":" -f1,2`
        do
            TEMP_ORACLE_SID=`echo $DB_ENTRY | cut -d":" -f1`
            if [[ $TEMP_ORACLE_SID = $ORACLE_SID ]]; then
                OLD_ORACLE_HOME=$ORACLE_HOME
                wl "[Set old ORACLE_HOME to: $OLD_ORACLE_HOME]"
                ORACLE_HOME=`echo $DB_ENTRY | cut -d":" -f2`
                switchOracleEnv $ORACLE_HOME
                wl "[Set new ORACLE_HOME to: $ORACLE_HOME]"
            fi
        done

        wl " "
        COMMAND="$ORACLE_HOME/bin/emctl status dbconsole"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Database Console                                                       |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}

        ORACLE_HOME=$OLD_ORACLE_HOME
        wl " "
        wl "[Set ORACLE_HOME back to: $ORACLE_HOME]"

    fi

fi


if [[ $OEM_TYPE = "agent" ]]; then


    # +--------------------------------------------------------------------------------+
    # |                             <<<<<< START >>>>>>                                |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "start" ]]; then
        wl " "
        COMMAND="$AGENT_HOME/bin/emctl start agent"
        wl "+--------------+"
        wl "| STARTING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
    fi



    # +--------------------------------------------------------------------------------+
    # |                             <<<<<< STOP >>>>>>                                 |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "stop" ]]; then
        wl " "
        COMMAND="$AGENT_HOME/bin/emctl stop agent"
        wl "+--------------+"
        wl "| STOPPING     |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
        $SLEEP
    fi



    # +--------------------------------------------------------------------------------+
    # |                                <<<<<< STATUS >>>>>>                            |
    # +--------------------------------------------------------------------------------+
    if [[ $OEM_ACTION = "status" ]]; then
        wl " "
        COMMAND="$AGENT_HOME/bin/emctl status agent"
        wl "+--------------+"
        wl "| STATUS       |"
        wl "|------------------------------------------------------------------------+"
        wl "| Oracle Management Agent                                                |"
        wl "| COMMAND: $COMMAND"
        wl "+------------------------------------------------------------------------+"
        $COMMAND | tee -a ${LOG_FILE_NAME}
    fi

fi



END_DATE=`date`
wl " "
wl "======================================================"
wl "END TIME: $END_DATE"
wl "                   EXITING SCRIPT"
wl "======================================================"

exit
