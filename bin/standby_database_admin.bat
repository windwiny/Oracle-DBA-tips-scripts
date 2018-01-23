@echo off
REM +--------------------------------------------------------------------------+
REM |                          Jeffrey M. Hunter                               |
REM |                      jhunter@idevelopment.info                           |
REM |                         www.idevelopment.info                            |
REM |--------------------------------------------------------------------------|
REM |    Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
REM |--------------------------------------------------------------------------|
REM | DATABASE     : Oracle                                                    |
REM | FILE         : standby_database_admin.bat                                |
REM | CLASS        : Disaster Recovery                                         |
REM | PURPOSE      : Batch file used to administer an Oracle standby database  |
REM |                on the Microsoft Windows platform.                        |
REM |                                                                          |
REM |                The primary function of this script is to maintain an     |
REM |                Oracle standby database that has not been configured      |
REM |                using Oracle Data Guard.                                  |
REM |                                                                          |
REM |                Using the "REFRESH" option to this script, any new        |
REM |                archive redo log files since the last refresh from the    |
REM |                primary database, will be remotely copied to the standby  |
REM |                database server and then applied to the Oracle standby    |
REM |                database. The Oracle standby database being maintained    |
REM |                must be in either the MOUNT state or the OPEN READ ONLY   |
REM |                state. If the standby database is in the OPEN READ ONLY   |
REM |                state, it will be taken down and brought into the MOUNT   |
REM |                state. Once all new archived redo log files have been     |
REM |                applied, if the standby database was in the OPEN READ ONLY|
REM |                state, it will be returned to the OPEN READ ONLY state.   |
REM |                If the standby database was in the MOUNT state before the |
REM |                refresh, it will remain in the MOUNT state after the      |
REM |                refresh.                                                  |
REM |                                                                          |
REM |                The "BUILD" option to this script will build a new Oracle |
REM |                standby database from the primary databse. If the same    |
REM |                standby database name exists on the standby database      |
REM |                server, it will be removed.                               |
REM |                                                                          |
REM |                The "ACTIVATE" option to this script will transition the  |
REM |                the role of the physical standby database running on this |
REM |                node to the primary role. This is part of a larger        |
REM |                disaster recovery plan and executes the tasks responsible |
REM |                to FAILOVER a physical standby database to make it the    |
REM |                primary database. A failover implies that the primary     |
REM |                database is unavailable and that there is no possibility  |
REM |                of restoring it to a service within a reasonable amount   |
REM |                of time. The possibility of data loss exists. Anyone      |
REM |                executing this script should have a clear understanding   |
REM |                of the outcome after performing a failover operation.     |
REM |                Every attempt should be made to get all unapplied (if     |
REM |                any), data off of the primary host and onto the standby   |
REM |                host. This would include any archive logs that did not    |
REM |                get transferred from the primary database to the target   |
REM |                standby database.                                         |
REM |                                                                          |
REM | *IMPORTANT*  : This script "MUST" be run from the standby database       |
REM |                machine.                                                  |
REM |                                                                          |
REM | DEPENDENCIES : ROBOCOPY.EXE             - Used to copy files from the    |
REM |                                           primary database machine.      |
REM |                FORFILES.EXE             - Used to remove obsolete files. |
REM |                                                                          |
REM | PARAMETERS   : STANDBY_ADMIN_OPTION     - Valid values are "BUILD",      |
REM |                                           "REFRESH", or "ACTIVATE".      |
REM |                STANDBY_DB               - Oracle SID for the standby     |
REM |                                           database.                      |
REM |                STANDBY_DB_TNS_CONNECT   - TNS connect string to the      |
REM |                                           standby database.              |
REM |                STANDBY_SYS_PASSWD       - SYS password for the           |
REM |                                           standby database.              |
REM |                STANDBY_MACHINE_NAME     - Name of the standby database   |
REM |                                           machine.                       |
REM |                PRIMARY_DB               - Oracle SID and TNS connect     |
REM |                                           string for the primary         |
REM |                                           database. Only required if     |
REM |                                           STANDBY_ADMIN_OPTION equals    |
REM |                                           "REFRESH" or "BUILD".          |
REM |                PRIMARY_SYS_PASSWD       - SYS password for the primary   |
REM |                                           database. Only required if     |
REM |                                           STANDBY_ADMIN_OPTION equals    |
REM |                                           "REFRESH" or "BUILD".          |
REM |                PRIMARY_MACHINE_NAME     - Name of the primary database   |
REM |                                           machine. Only required if      |
REM |                                           STANDBY_ADMIN_OPTION equals    |
REM |                                           "REFRESH" or "BUILD".          |
REM |                                                                          |
REM | EXAMPLE USAGE: standby_database_admin.bat BUILD PROD PROD_STBY sysprod win-db2 PROD sysprod win-db1
REM |                standby_database_admin.bat REFRESH PROD PROD_STBY sysprod win-db2 PROD sysprod win-db1
REM |                standby_database_admin.bat ACTIVATE PROD PROD_STBY sysprod win-db2
REM |                                                                          |
REM | NOTE         : As with any code, ensure to test this script in a         |
REM |                development environment before attempting to run it in    |
REM |                production.                                               |
REM |                                                                          |
REM +--------------------------------------------------------------------------+

REM +--------------------------------------------------------------------------+
REM | DEBUG SCRIPT                                                             |
REM +--------------------------------------------------------------------------+

REM SET DEBUG_SCRIPT=TRUE
SET DEBUG_SCRIPT=FALSE

REM +--------------------------------------------------------------------------+
REM | ORGANIZATION VARIABLES                                                   |
REM +--------------------------------------------------------------------------+

SET PRODUCTION_MACHINE_NAME=win-db1
SET COMPANY_DOMAIN_NAME=idevelopment.info

REM -- ----------------------------------------------
REM -- If SQL*Net is configured to use a domain name,
REM -- then make certain to include the domain name
REM -- preceeded with a period. If SQL*Net is not
REM -- configured with a domain name, use:
REM -- SET SQLNET_COMPANY_DOMAIN_NAME=
REM -- ----------------------------------------------
SET SQLNET_COMPANY_DOMAIN_NAME=.IDEVELOPMENT.INFO

SET SCRIPT_VERSION=1.4

SET SCRIPTNAME=standby_database_admin.bat
SET FILENAME=standby_database_admin

SET AL_RETENTION_TIME_DAYS=7
SET AL_WAIT_SLEEP_TIME_SECONDS=30

REM +--------------------------------------------------------------------------+
REM | EMAIL VARIABLES                                                          |
REM +--------------------------------------------------------------------------+

set SMTP_SERVER=localhost
set SMTP_PORT=25
set SMTP_EMAIL_TO=jhunter@idevelopment.info
set SMTP_EMAIL_FROM=dba@idevelopment.info

REM +--------------------------------------------------------------------------+
REM | SHOW BANNER                                                              |
REM +--------------------------------------------------------------------------+

echo.
echo %FILENAME% - Version %SCRIPT_VERSION%
echo Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.
echo.

REM +--------------------------------------------------------------------------+
REM | VALIDATE COMMAND-LINE PARAMETERS                                         |
REM +--------------------------------------------------------------------------+

if (%1)==() goto PARAMETER_ERROR
if (%2)==() goto PARAMETER_ERROR
if (%3)==() goto PARAMETER_ERROR
if (%4)==() goto PARAMETER_ERROR
if (%5)==() goto PARAMETER_ERROR

if /i %1% equ ACTIVATE (goto SKIP_PRIMARY_PARAMETERS)

if (%6)==() goto PARAMETER_ERROR
if (%7)==() goto PARAMETER_ERROR
if (%8)==() goto PARAMETER_ERROR

:SKIP_PRIMARY_PARAMETERS

REM +--------------------------------------------------------------------------+
REM | SET DATE AND TIME ENVIRONMENT VARIABLES                                  |
REM +--------------------------------------------------------------------------+

SETLOCAL

FOR /f "tokens=2-4 skip=1 delims=(-)" %%G IN ('echo.^|date') DO (
    FOR /f "tokens=2 delims= " %%A IN ('date /t') DO (
        SET v_first=%%G
        SET v_second=%%H
        SET v_third=%%I
        SET v_all=%%A
    )
)

SET %v_first%=%v_all:~0,2%
SET %v_second%=%v_all:~3,2%
SET %v_third%=%v_all:~6,4%

ENDLOCAL & SET v_year=%yy%& SET v_month=%mm%& SET v_day=%dd%

SET FILEDATE=%v_year%-%v_month%-%v_day%

SETLOCAL
FOR /f "tokens=*" %%G IN ('time/t') DO set v_time=%%G
    SET v_time=%v_time:~0,2%-%v_time:~3,2%_%v_time:~6,2%
ENDLOCAL & SET v_time=%v_time%
   
SET v

SET FILETIME=%v_time%


REM +--------------------------------------------------------------------------+
REM | SET ALL GLOBAL ENVIRONMENT VARIABLES                                     |
REM +--------------------------------------------------------------------------+

SET STANDBY_ADMIN_OPTION=%1%
SET STANDBY_DB=%2%
SET STANDBY_DB_TNS_CONNECT=%3%
SET STANDBY_SYS_PASSWD=%4%
SET STANDBY_MACHINE_NAME=%5%
SET PRIMARY_DB=%6%
SET PRIMARY_SYS_PASSWD=%7%
SET PRIMARY_MACHINE_NAME=%8%

if /i %STANDBY_MACHINE_NAME% equ %PRIMARY_MACHINE_NAME% (set LOCAL_PRIMARY_MACHINE=TRUE) else (set LOCAL_PRIMARY_MACHINE=FALSE)
if /i %STANDBY_DB% equ %PRIMARY_DB% (set SAME_STANDBY_PRIMARY_DATABASE_NAME=TRUE) else (set SAME_STANDBY_PRIMARY_DATABASE_NAME=FALSE)

SET FOUND_SCRIPT_EXCEPTIONS=FALSE

SET ORACLE_SID=%STANDBY_DB%
SET ORACLE_BASE=C:\oracle
SET ORACLE_HOME=%ORACLE_BASE%\product\10.2.0\db_1
SET ORACLE_HOME_UNC=C$\oracle\product\10.2.0\db_1

SET ORA_BIN_DIR=C:\Oracle\dba_scripts\bin
SET ORA_TMP_DIR=C:\Oracle\dba_scripts\temp
SET ORA_LOG_DIR=C:\Oracle\dba_scripts\log

REM --------------------------------------------------
REM  NOTE THAT %STANDBY_DB% WILL BE APPENDED TO THE 
REM  FOLLOWING VARIABLES.
REM --------------------------------------------------
SET ORA_DB_FILES_DIR=D:\oracle\oradata
SET ORA_CONTROL_FILE_DIR=F:\oracle\flash_recovery_area
SET ORA_REDO_LOG_FILE_DIR=F:\oracle\flash_recovery_area
SET ORA_FRA_DIR=F:\oracle\flash_recovery_area
SET ORA_FRA_UNC=F$\oracle\flash_recovery_area
SET ORA_ADMIN_DIR=C:\oracle\admin

SET TNS_NAMES_FILE=%ORACLE_HOME%\network\admin\tnsnames.ora

SET TEMPRMAN_CMDFILE=%ORA_TMP_DIR%\%FILENAME%_%STANDBY_DB%_%FILEDATE%_%FILETIME%.rman
SET TEMPSQLFILE=%ORA_TMP_DIR%\%FILENAME%_%STANDBY_DB%_%FILEDATE%_%FILETIME%.sql
SET TEMPLOGFILE=%ORA_TMP_DIR%\%FILENAME%_%STANDBY_DB%_%FILEDATE%_%FILETIME%_2.log

SET LOGFILE=%ORA_LOG_DIR%\%FILENAME%_%STANDBY_ADMIN_OPTION%_%STANDBY_DB%_%FILEDATE%_%FILETIME%.log
SET LOGFILE_COPY=%ORA_LOG_DIR%\%FILENAME%_%STANDBY_ADMIN_OPTION%_%STANDBY_DB%.log

SET STANDBY_DB_BATCH_SCRIPT=%ORA_BIN_DIR%\%STANDBY_DB%.bat

SET NUM_LOG_DAYS_TO_KEEP=7


REM +==========================================================================+
REM |                                                                          |
REM |                 S C R I P T   S T A R T S   H E R E                      |
REM |                                                                          |
REM +==========================================================================+

echo.                > "%LOGFILE%"
echo Start script.  >> "%LOGFILE%"
echo.               >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | WRITE HEADER INFORMATION TO CONSOLE AND LOG FILE.                        |
REM +--------------------------------------------------------------------------+

echo ===============================================================================
echo                            GLOBAL VARIABLES
echo ===============================================================================
echo Log File Name                         : %LOGFILE%
echo Script Name                           : %SCRIPTNAME%
echo Begin Date                            : %DATE%
echo Begin Time                            : %TIME%
echo Debug Script?                         : %DEBUG_SCRIPT%
echo Local Primary Machine?                : %LOCAL_PRIMARY_MACHINE%
echo Same Standby / Primary Database Name  : %SAME_STANDBY_PRIMARY_DATABASE_NAME%
echo Production Machine Name               : %PRODUCTION_MACHINE_NAME%
echo Company Domain                        : %COMPANY_DOMAIN_NAME%
echo SQL*Net Company Domain                : %SQLNET_COMPANY_DOMAIN_NAME%
echo ORACLE_BASE                           : %ORACLE_BASE%
echo ORACLE_HOME                           : %ORACLE_HOME%
echo ORACLE_HOME_UNC                       : %ORACLE_HOME_UNC%
echo Oracle DB Files Directory             : %ORA_DB_FILES_DIR%
echo Oracle Control File Directory         : %ORA_CONTROL_FILE_DIR%
echo Oracle Redo Log File Directory        : %ORA_REDO_LOG_FILE_DIR%
echo Oracle Flash Recovery Area Directory  : %ORA_FRA_DIR%
echo Oracle Flash Recovery Area UNC        : %ORA_FRA_UNC%
echo Oracle ADMIN Directory                : %ORA_ADMIN_DIR%
echo Oracle TNSNAMES File                  : %TNS_NAMES_FILE%
echo Database Environment Batch Script     : %STANDBY_DB_BATCH_SCRIPT%
echo Production Machine Name               : %PRODUCTION_MACHINE_NAME%
echo Number of Days to Keep Log Files      : %NUM_LOG_DAYS_TO_KEEP%
echo Wait Time (sec) for Arch Log to Write : %AL_WAIT_SLEEP_TIME_SECONDS%
echo Machine Name                          : %COMPUTERNAME%
echo.
echo ===============================================================================
echo                              EMAIL VARIABLES
echo ===============================================================================
echo SMTP Server                           : %SMTP_SERVER%
echo SMTP Port                             : %SMTP_PORT%
echo SMTP Mail To                          : %SMTP_EMAIL_TO%
echo SMTP Email From                       : %SMTP_EMAIL_FROM%
echo.
echo ===============================================================================
echo                            SCRIPT ARGUMENTS
echo ===============================================================================
echo Standby Admin Option             (P1) : %STANDBY_ADMIN_OPTION%
echo Standby Database                 (P2) : %STANDBY_DB%
echo Standby Database TNS Connect     (P3) : %STANDBY_DB_TNS_CONNECT%
echo Standby SYS Password             (P4) : xxxxxxxxxxxxxxxxx
echo Standby Machine Name             (P5) : %STANDBY_MACHINE_NAME%
echo Primary Database                 (P6) : %PRIMARY_DB%
echo Primary SYS Password             (P7) : xxxxxxxxxxxxxxxxx
echo Primary Machine Name             (P8) : %PRIMARY_MACHINE_NAME%
echo ===============================================================================


echo ===============================================================================  >> "%LOGFILE%"
echo                            GLOBAL VARIABLES                                      >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"
echo Log File Name                         : %LOGFILE%                                >> "%LOGFILE%"
echo Script Name                           : %SCRIPTNAME%                             >> "%LOGFILE%"
echo Begin Date                            : %DATE%                                   >> "%LOGFILE%"
echo Begin Time                            : %TIME%                                   >> "%LOGFILE%"
echo Debug Script?                         : %DEBUG_SCRIPT%                           >> "%LOGFILE%"
echo Local Primary Machine?                : %LOCAL_PRIMARY_MACHINE%                  >> "%LOGFILE%"
echo Same Standby / Primary Database Name  : %SAME_STANDBY_PRIMARY_DATABASE_NAME%     >> "%LOGFILE%"
echo Production Machine Name               : %PRODUCTION_MACHINE_NAME%                >> "%LOGFILE%"
echo Company Domain                        : %COMPANY_DOMAIN_NAME%                    >> "%LOGFILE%"
echo SQL*Net Company Domain                : %SQLNET_COMPANY_DOMAIN_NAME%             >> "%LOGFILE%"
echo ORACLE_BASE                           : %ORACLE_BASE%                            >> "%LOGFILE%"
echo ORACLE_HOME                           : %ORACLE_HOME%                            >> "%LOGFILE%"
echo ORACLE_HOME_UNC                       : %ORACLE_HOME_UNC%                        >> "%LOGFILE%"
echo Oracle DB Files Directory             : %ORA_DB_FILES_DIR%                       >> "%LOGFILE%"
echo Oracle Control File Directory         : %ORA_CONTROL_FILE_DIR%                   >> "%LOGFILE%"
echo Oracle Redo Log File Directory        : %ORA_REDO_LOG_FILE_DIR%                  >> "%LOGFILE%"
echo Oracle Flash Recovery Area Directory  : %ORA_FRA_DIR%                            >> "%LOGFILE%"
echo Oracle Flash Recovery Area UNC        : %ORA_FRA_UNC%                            >> "%LOGFILE%"
echo Oracle ADMIN Directory                : %ORA_ADMIN_DIR%                          >> "%LOGFILE%"
echo Oracle TNSNAMES File                  : %TNS_NAMES_FILE%                         >> "%LOGFILE%"
echo Database Environment Batch Script     : %STANDBY_DB_BATCH_SCRIPT%                >> "%LOGFILE%"
echo Production Machine Name               : %PRODUCTION_MACHINE_NAME%                >> "%LOGFILE%"
echo Number of Days to Keep Log Files      : %NUM_LOG_DAYS_TO_KEEP%                   >> "%LOGFILE%"
echo Wait Time (sec) for Arch Log to Write : %AL_WAIT_SLEEP_TIME_SECONDS%             >> "%LOGFILE%"
echo Machine Name                          : %COMPUTERNAME%                           >> "%LOGFILE%"
echo.                                                                                 >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"
echo                              EMAIL VARIABLES                                     >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"
echo SMTP Server                           : %SMTP_SERVER%                            >> "%LOGFILE%"
echo SMTP Port                             : %SMTP_PORT%                              >> "%LOGFILE%"
echo SMTP Mail To                          : %SMTP_EMAIL_TO%                          >> "%LOGFILE%"
echo SMTP Email From                       : %SMTP_EMAIL_FROM%                        >> "%LOGFILE%"
echo.                                                                                 >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"
echo                            SCRIPT ARGUMENTS                                      >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"
echo Standby Admin Option             (P1) : %STANDBY_ADMIN_OPTION%                   >> "%LOGFILE%"
echo Standby Database                 (P2) : %STANDBY_DB%                             >> "%LOGFILE%"
echo Standby Database TNS Connect     (P3) : %STANDBY_DB_TNS_CONNECT%                 >> "%LOGFILE%"
echo Standby SYS Password             (P4) : xxxxxxxxxxxxxxxxx                        >> "%LOGFILE%"
echo Standby Machine Name             (P5) : %STANDBY_MACHINE_NAME%                   >> "%LOGFILE%"
echo Primary Database                 (P6) : %PRIMARY_DB%                             >> "%LOGFILE%"
echo Primary SYS Password             (P7) : xxxxxxxxxxxxxxxxx                        >> "%LOGFILE%"
echo Primary Machine Name             (P8) : %PRIMARY_MACHINE_NAME%                   >> "%LOGFILE%"
echo ===============================================================================  >> "%LOGFILE%"




REM +--------------------------------------------------------------------------+
REM | VERIFY SCRIPT IS NOT BEING RUN FROM THE PRODUCTION MACHINE               |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Verify script is not being run from the production machine.   >> "%LOGFILE%"
echo TRACE^> PRODUCTION_MACHINE_NAME  : %PRODUCTION_MACHINE_NAME%          >> "%LOGFILE%"
echo TRACE^> COMPUTERNAME             : %COMPUTERNAME%                     >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %PRODUCTION_MACHINE_NAME% equ %COMPUTERNAME% (goto VERIFY_NOT_PRODUCTION_MACHINE_ERROR) else (goto VERIFY_NOT_PRODUCTION_MACHINE_CONTINUE)

:VERIFY_NOT_PRODUCTION_MACHINE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002008: Script being run from the production machine (%PRODUCTION_MACHINE_NAME%). >> "%LOGFILE%"
echo TRACE^> CAJ-002009: This script cannot be run from the production machine. >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:VERIFY_NOT_PRODUCTION_MACHINE_CONTINUE

echo.
echo Script not running on the production machine - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | VERIFY STANDBY MACHINE IS NOT THE PRODUCTION MACHINE                     |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Verify standby machine is not the production machine.         >> "%LOGFILE%"
echo TRACE^> PRODUCTION_MACHINE_NAME  : %PRODUCTION_MACHINE_NAME%          >> "%LOGFILE%"
echo TRACE^> STANDBY_MACHINE_NAME     : %STANDBY_MACHINE_NAME%             >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %PRODUCTION_MACHINE_NAME% equ %STANDBY_MACHINE_NAME% (goto VERIFY_STANDBY_MACHINE_ERROR) else (goto VERIFY_STANDBY_MACHINE_CONTINUE)

:VERIFY_STANDBY_MACHINE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002003: Standby machine (%STANDBY_MACHINE_NAME%) is the same as production (%PRODUCTION_MACHINE_NAME%). >> "%LOGFILE%"
echo TRACE^> CAJ-002004: The standby machine cannot be set to production. >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:VERIFY_STANDBY_MACHINE_CONTINUE

echo Standby machine is not set to production - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | VERIFY STANDBY ADMIN OPTION PARAMETER                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Verify standby admin option parameter ("REFRESH" or "BUILD"). >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %STANDBY_ADMIN_OPTION% equ REFRESH (goto STANDBY_ADMIN_OPTION_REFRESH)
if /i %STANDBY_ADMIN_OPTION% equ BUILD (goto STANDBY_ADMIN_OPTION_BUILD)
if /i %STANDBY_ADMIN_OPTION% equ ACTIVATE (goto STANDBY_ADMIN_OPTION_ACTIVATE)

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002008: Standby Admin Option must be either BUILD, REFRESH, or ACTIVATE. >> "%LOGFILE%"
echo TRACE^> CAJ-002009: Standby Admin Option passed in was (%STANDBY_ADMIN_OPTION%). >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT





REM ============================================================================
REM ----------------------------------------------------------------------------
REM                         R  E  F  R  E  S  H
REM ----------------------------------------------------------------------------
REM ============================================================================

:STANDBY_ADMIN_OPTION_REFRESH

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> LABEL: [  STANDBY_ADMIN_OPTION_REFRESH  ]                          >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK PRIMARY MACHINE                                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Checking for primary machine (%PRIMARY_MACHINE_NAME%).        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

ping -n 3 %PRIMARY_MACHINE_NAME% >> "%LOGFILE%"

if errorlevel 1 (goto PING_PRIMARY_REFRESH_ERROR) else (goto PING_PRIMARY_REFRESH_CONTINUE)

:PING_PRIMARY_REFRESH_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002002: Failed to ping (%PRIMARY_MACHINE_NAME%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:PING_PRIMARY_REFRESH_CONTINUE

echo Ping primary machine - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK PRIMARY DATABASE                                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Checking for primary database (%PRIMARY_DB%).                 >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

%ORACLE_HOME%\bin\tnsping %PRIMARY_DB% >> "%LOGFILE%"

if errorlevel 1 (goto TNS_PRIMARY_REFRESH_ERROR) else (goto TNS_PRIMARY_REFRESH_CONTINUE)

:TNS_PRIMARY_REFRESH_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002001: Failed to TNSPING Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:TNS_PRIMARY_REFRESH_CONTINUE

echo TNSPING primary database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Check log in to primary database (%PRIMARY_DB%).              >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

echo set head off                                 > %TEMPSQLFILE%
echo SPOOL %TEMPLOGFILE%                         >> %TEMPSQLFILE%
echo SELECT 'CURRENT USER='^|^| user FROM dual;  >> %TEMPSQLFILE%
echo spool off                                   >> %TEMPSQLFILE%
echo exit;                                       >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto DB_LOG_IN_CHECK_PRIMARY_BUILD_CONTINUE) ELSE (goto DB_LOG_IN_CHECK_PRIMARY_BUILD_ERROR)

:DB_LOG_IN_CHECK_PRIMARY_BUILD_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002010: Failed to Log In to Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:DB_LOG_IN_CHECK_PRIMARY_BUILD_CONTINUE

echo Log in to primary database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | PERFORM LOG SWITCH ON PRIMARY DATABASE                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Perform log switch on primary database (%PRIMARY_DB%).        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_REFRESH_CONTINUE)

echo SPOOL %TEMPLOGFILE%            > %TEMPSQLFILE%
echo ALTER SYSTEM SWITCH LOGFILE;  >> %TEMPSQLFILE%
echo spool off                     >> %TEMPSQLFILE%
echo exit;                         >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_REFRESH_CONTINUE) ELSE (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_REFRESH_ERROR)

:PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_REFRESH_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002015: Failed to perform a log switch on the Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_REFRESH_CONTINUE

echo Perform log switch on primary database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | WAIT FOR ORACLE TO FINISH WRITING NEW ARCHIVED LOG FILE ON PRIMARY       |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Take a nap.                                                   >> "%LOGFILE%"
echo TRACE^> Wait for Oracle to finish writing new archived log file       >> "%LOGFILE%"
echo TRACE^> on primary.                                                   >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

@CHOICE /D N /T %AL_WAIT_SLEEP_TIME_SECONDS% > NUL

echo Sleep for %AL_WAIT_SLEEP_TIME_SECONDS% seconds - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | COPY ARCHIVED REDO LOG FILES FROM PRIMARY                                |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Copy archived redo log files from primary.                    >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_REFRESH_COPY_AL_FILES_FROM_PRIMARY_MACHINE)

robocopy.exe \\%PRIMARY_MACHINE_NAME%\%ORA_FRA_UNC%\%PRIMARY_DB%\ARCHIVELOG\ %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG\ /E /MIR /LOG:%TEMPLOGFILE%

REM type "%TEMPLOGFILE%" >> "%LOGFILE%"

del /q /f "%TEMPLOGFILE%"

:DONE_REFRESH_COPY_AL_FILES_FROM_PRIMARY_MACHINE

echo Copy new archived logs from the primary database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK STANDBY DATABASE                                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Checking for standby database (%STANDBY_DB_TNS_CONNECT%).     >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

%ORACLE_HOME%\bin\tnsping %STANDBY_DB_TNS_CONNECT% >> "%LOGFILE%"

if errorlevel 1 (goto TNS_STANDBY_ERROR) else (goto TNS_STANDBY_CONTINUE)

:TNS_STANDBY_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002001: Failed to TNSPING Standby Database (%STANDBY_DB_TNS_CONNECT%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:TNS_STANDBY_CONTINUE

echo TNSPING standby database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | APPLY NEW ARCHIVED REDO LOGS TO STANDBY DATABASE                         |
REM +--------------------------------------------------------------------------+

echo.                                                                                     >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------                >> "%LOGFILE%"
echo TRACE^> Apply new archived redo logs to standby database (%STANDBY_DB_TNS_CONNECT%). >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------                >> "%LOGFILE%"
echo.                                                                                     >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto PERFORM_REFRESH_APPLY_AL_STANDBY_DATABASE_CONTINUE)

echo SPOOL %TEMPLOGFILE%                      > %TEMPSQLFILE%
echo SHUTDOWN IMMEDIATE;                     >> %TEMPSQLFILE%
echo STARTUP NOMOUNT;                        >> %TEMPSQLFILE%
echo ALTER DATABASE MOUNT STANDBY DATABASE;  >> %TEMPSQLFILE%
echo SET AUTORECOVERY ON;                    >> %TEMPSQLFILE%
echo RECOVER STANDBY DATABASE UNTIL CANCEL;  >> %TEMPSQLFILE%
echo ALTER DATABASE OPEN READ ONLY;          >> %TEMPSQLFILE%
echo spool off                               >> %TEMPSQLFILE%
echo exit;                                   >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%STANDBY_SYS_PASSWD%@%STANDBY_DB_TNS_CONNECT% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2- OSD-" "%TEMPLOGFILE%" | findstr /v "ORA-01109 ORA-00279 ORA-00289 ORA-00280 ORA-00278 ORA-00308 ORA-27041 OSD-04002"

if errorlevel 1 (goto PERFORM_REFRESH_APPLY_AL_STANDBY_DATABASE_CONTINUE) ELSE (goto PERFORM_REFRESH_APPLY_AL_STANDBY_DATABASE_ERROR)

:PERFORM_REFRESH_APPLY_AL_STANDBY_DATABASE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002015: Failed to apply new archived redo logs to the standby database (%STANDBY_DB_TNS_CONNECT%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:PERFORM_REFRESH_APPLY_AL_STANDBY_DATABASE_CONTINUE

echo Apply new archived redo logs to the standby database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | PURGE OBSOLETE ARCHIVED REDO LOGS FROM THE STANDBY DATABASE              |
REM +--------------------------------------------------------------------------+

if /i %DEBUG_SCRIPT% equ TRUE (goto PERFORM_REFRESH_PURGE_OBSOLETE_AL_STANDBY_DATABASE_CONTINUE)

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Remove obsolete archived redo logs from the standby database  >> "%LOGFILE%"
echo TRACE^> older than %AL_RETENTION_TIME_DAYS% days.                     >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

REM --------
REM   NOTE
REM ------------------------------------------------------------------------
REM No need to manually remove obsolete archived redo logs from the standby
REM database server. The primary database is maintaining the physical backup
REM sets and archived redo log retention using RMAN. The ROBOCOPY utility,  
REM used in this section, mirrors the Flash Recovery Area from the primary
REM database server using the /mir (mirror) option which takes care of
REM removing any obsolete archived redo log files from the standby database
REM server.
REM ------------------------------------------------------------------------

REM 
REM echo List of log files in %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG older than %AL_RETENTION_TIME_DAYS% days... >> "%LOGFILE%"
REM forfiles /P %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG /S /D -%AL_RETENTION_TIME_DAYS% /M O1_MF_*.ARC /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"
REM 
REM echo Deleting log files in %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG older than %AL_RETENTION_TIME_DAYS% days... >> "%LOGFILE%"
REM forfiles /P %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG /S /D -%AL_RETENTION_TIME_DAYS% /M O1_MF_*.ARC /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"
REM 

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> Remove obsolete log files from the standby database control file.  >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"

echo CROSSCHECK ARCHIVELOG ALL;                      > %TEMPRMAN_CMDFILE%
echo DELETE FORCE NOPROMPT EXPIRED ARCHIVELOG ALL;  >> %TEMPRMAN_CMDFILE%
echo EXIT;                                          >> %TEMPRMAN_CMDFILE%

%ORACLE_HOME%\bin\rman TARGET SYS/%STANDBY_SYS_PASSWD%@%STANDBY_DB_TNS_CONNECT% nocatalog cmdfile=%TEMPRMAN_CMDFILE% msglog %TEMPLOGFILE% 

type "%TEMPLOGFILE%" >> "%LOGFILE%"

findstr /i "ORA-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto PERFORM_REFRESH_PURGE_OBSOLETE_AL_STANDBY_DATABASE_CONTINUE) ELSE (goto PERFORM_REFRESH_PURGE_OBSOLETE_AL_STANDBY_DATABASE_ERROR)

:PERFORM_REFRESH_PURGE_OBSOLETE_AL_STANDBY_DATABASE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002021: Failed to purge obsolete archived redo logs from the standby database.   >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"
goto END_OF_FILE_REPORT

:PERFORM_REFRESH_PURGE_OBSOLETE_AL_STANDBY_DATABASE_CONTINUE

echo Purge obsolete archived redo logs from the standby database - [OK]

del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Done with standby database refresh option.                    >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

goto STANDBY_ADMIN_OPTION_CONTINUE





REM ============================================================================
REM ----------------------------------------------------------------------------
REM                          A C T I V A T E
REM ----------------------------------------------------------------------------
REM ============================================================================

:STANDBY_ADMIN_OPTION_ACTIVATE

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> LABEL: [  STANDBY_ADMIN_OPTION_ACTIVATE  ]                         >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | ACKNOWLEDGE STANDBY DATABASE ACTIVATE OPERATION                          |
REM +--------------------------------------------------------------------------+

echo.
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!   WARNING   !!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo ! You are about to transition the role of the physical standby !
echo ! database running on this node (%STANDBY_DB%) to the primary role.    !
echo !                                                              !
echo ! This is part of a larger disaster recovery plan and executes !
echo ! the tasks responsible to FAILOVER a physical standby         !
echo ! database to make it the primary database. A failover implies !
echo ! that the primary database is unavailable and that there is   !
echo ! no possibility of restoring it to a service within a         !
echo ! reasonable amount of time. The possibility of data loss      !
echo ! exists.                                                      !
echo !                                                              !
echo ! Anyone executing this script should have a clear             !
echo ! understanding of the outcome after performing a failover     !
echo ! operation.                                                   !
echo !                                                              !
echo ! Every attempt should be made to get all unapplied (if any),  !
echo ! data off of the primary host and onto the standby host. This !
echo ! would include any archive logs that did not get transferred  !
echo ! from the primary database to the target standby database.    !
echo !                                                              !
echo ! This script MUST be run from the standby database machine    !
echo ! (%STANDBY_MACHINE_NAME%).                                                    !
echo !                                                              !
echo ! Hit [ENTER] to continue or CTRL-C to exit ...                !
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.

pause

echo.
echo Please note that this process may take several minutes to complete...
echo.


REM +--------------------------------------------------------------------------+
REM | ACTIVATE THE STANDBY DATABASE                                            |
REM +--------------------------------------------------------------------------+

echo.                                                                       >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------  >> "%LOGFILE%"
echo TRACE^> Activate the standby database (%STANDBY_DB_TNS_CONNECT%).      >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------  >> "%LOGFILE%"
echo.                                                                       >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto PERFORM_ACTIVATE_STANDBY_DATABASE_CONTINUE)

echo SPOOL %TEMPLOGFILE%                         > %TEMPSQLFILE%
echo SHUTDOWN IMMEDIATE;                        >> %TEMPSQLFILE%
echo STARTUP NOMOUNT;                           >> %TEMPSQLFILE%
echo ALTER DATABASE MOUNT STANDBY DATABASE;     >> %TEMPSQLFILE%
echo ALTER DATABASE ACTIVATE STANDBY DATABASE;  >> %TEMPSQLFILE%
echo SHUTDOWN IMMEDIATE;                        >> %TEMPSQLFILE%
echo STARTUP;                                   >> %TEMPSQLFILE%
echo spool off                                  >> %TEMPSQLFILE%
echo exit;                                      >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%STANDBY_SYS_PASSWD%@%STANDBY_DB_TNS_CONNECT% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2- OSD-" "%TEMPLOGFILE%" | findstr /v "ORA-01109"

if errorlevel 1 (goto PERFORM_ACTIVATE_STANDBY_DATABASE_CONTINUE) ELSE (goto PERFORM_ACTIVATE_STANDBY_DATABASE_ERROR)

:PERFORM_ACTIVATE_STANDBY_DATABASE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002020: Failed to activate the standby database (%STANDBY_DB_TNS_CONNECT%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:PERFORM_ACTIVATE_STANDBY_DATABASE_CONTINUE

echo Activate the standby database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Done with standby database activate option.                   >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

goto STANDBY_ADMIN_OPTION_CONTINUE





REM ============================================================================
REM ----------------------------------------------------------------------------
REM                             B  U  I  L  D
REM ----------------------------------------------------------------------------
REM ============================================================================

:STANDBY_ADMIN_OPTION_BUILD

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> LABEL: [  STANDBY_ADMIN_OPTION_BUILD  ]                            >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK PRIMARY MACHINE                                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Checking for primary machine (%PRIMARY_MACHINE_NAME%).        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

ping -n 3 %PRIMARY_MACHINE_NAME% >> "%LOGFILE%"

if errorlevel 1 (goto PING_PRIMARY_BUILD_ERROR) else (goto PING_PRIMARY_BUILD_CONTINUE)

:PING_PRIMARY_BUILD_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002002: Failed to ping (%PRIMARY_MACHINE_NAME%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:PING_PRIMARY_BUILD_CONTINUE

echo Ping primary machine - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK PRIMARY DATABASE                                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Checking for primary database (%PRIMARY_DB%).                 >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

%ORACLE_HOME%\bin\tnsping %PRIMARY_DB% >> "%LOGFILE%"

if errorlevel 1 (goto TNS_PRIMARY_BUILD_ERROR) else (goto TNS_PRIMARY_BUILD_CONTINUE)

:TNS_PRIMARY_BUILD_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002001: Failed to TNSPING Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:TNS_PRIMARY_BUILD_CONTINUE

echo TNSPING primary database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Check log in to primary database (%PRIMARY_DB%).              >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

echo set head off                                 > %TEMPSQLFILE%
echo SPOOL %TEMPLOGFILE%                         >> %TEMPSQLFILE%
echo SELECT 'CURRENT USER='^|^| user FROM dual;  >> %TEMPSQLFILE%
echo spool off                                   >> %TEMPSQLFILE%
echo exit;                                       >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto DB_LOG_IN_CHECK_PRIMARY_BUILD_CONTINUE) ELSE (goto DB_LOG_IN_CHECK_PRIMARY_BUILD_ERROR)

:DB_LOG_IN_CHECK_PRIMARY_BUILD_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002010: Failed to Log In to Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:DB_LOG_IN_CHECK_PRIMARY_BUILD_CONTINUE

echo Log in to primary database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | ACKNOWLEDGE STANDBY DATABASE BUILD OPERATION                             |
REM +--------------------------------------------------------------------------+

echo.
echo.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!   WARNING   !!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo ! You are about to remove the existing standby database        !
echo ! (%STANDBY_DB%) and replace it with a new standby database            !
echo ! created from the primary database (%PRIMARY_DB%).                    !
echo !                                                              !
echo ! The primary database MUST be open and reachable from the     !
echo ! standby database machine. In addition, there must be a       !
echo ! recent RMAN backup of the primary database available in the  !
echo ! Flash Recovery Area (FRA).                                   !
echo !                                                              !
echo ! This script MUST be run from the standby database machine    !
echo ! (%STANDBY_MACHINE_NAME%).                                                    !
echo !                                                              !
echo ! Hit [ENTER] to continue or CTRL-C to exit ...                !
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.

pause

echo.
echo Please note that this process may take several hours to complete...
echo.


REM +--------------------------------------------------------------------------+
REM | PERFORM LOG SWITCH ON PRIMARY DATABASE                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Perform log switch on primary database (%PRIMARY_DB%).        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_BUILD_CONTINUE)

echo SPOOL %TEMPLOGFILE%            > %TEMPSQLFILE%
echo ALTER SYSTEM SWITCH LOGFILE;  >> %TEMPSQLFILE%
echo spool off                     >> %TEMPSQLFILE%
echo exit;                         >> %TEMPSQLFILE%

%ORACLE_HOME%\bin\sqlplus -S -L "SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AS SYSDBA" @%TEMPSQLFILE%

type %TEMPLOGFILE% >> "%LOGFILE%"

findstr /i "ORA- SP2-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_BUILD_CONTINUE) ELSE (goto PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_BUILD_ERROR)

:PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_BUILD_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002015: Failed to perform a log switch on the Primary Database (%PRIMARY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:PERFORM_LOG_SWITCH_ON_PRIMARY_DATABASE_BUILD_CONTINUE

echo Perform log switch on primary database - [OK]

del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | DROP STANDBY DATABASE                                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Dropping standby database (%STANDBY_DB%).                     >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_DROP_STANDBY_DATABASE)

call %ORACLE_HOME%\bin\dbca -silent -deleteDatabase -sourceDB %STANDBY_DB% -sysDBAUserName SYS -sysDBAPassword %STANDBY_DB% >> "%LOGFILE%"

rmdir /S /Q %ORA_DB_FILES_DIR%\%STANDBY_DB%
rmdir /S /Q %ORA_CONTROL_FILE_DIR%\%STANDBY_DB%
rmdir /S /Q %ORA_REDO_LOG_FILE_DIR%\%STANDBY_DB%
rmdir /S /Q %ORA_FRA_DIR%\%STANDBY_DB%
rmdir /S /Q %ORA_ADMIN_DIR%\%STANDBY_DB%

if /i %LOCAL_PRIMARY_MACHINE% equ TRUE (goto SKIP_PRE_REMOVE_PRIMARY_FRA) else (goto PERFORM_PRE_REMOVE_PRIMARY_FRA)

:PERFORM_PRE_REMOVE_PRIMARY_FRA

rmdir /S /Q %ORA_FRA_DIR%\%PRIMARY_DB%

goto DONE_DROP_STANDBY_DATABASE

:SKIP_PRE_REMOVE_PRIMARY_FRA

echo.                                                   >> "%LOGFILE%"
echo TRACE^> This is a local build.                     >> "%LOGFILE%"
echo TRACE^> No need to remove the initial primary FRA. >> "%LOGFILE%"
echo.                                                   >> "%LOGFILE%"

:DONE_DROP_STANDBY_DATABASE

echo Drop standby database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY TNSNAMES ENTRY                                            |
REM +--------------------------------------------------------------------------+

echo.                                                                             >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------        >> "%LOGFILE%"
echo TRACE^> Create standby database TNSNAMES entry (%STANDBY_DB_TNS_CONNECT%).   >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------        >> "%LOGFILE%"
echo.                                                                             >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_CREATE_STANDBY_TNSNAMES_ENTRY)

echo. >> %TNS_NAMES_FILE%
echo %STANDBY_DB_TNS_CONNECT%%SQLNET_COMPANY_DOMAIN_NAME% = >> %TNS_NAMES_FILE%
echo  (DESCRIPTION = >> %TNS_NAMES_FILE%
echo    (ADDRESS = (PROTOCOL = TCP)(HOST = %STANDBY_MACHINE_NAME%.%COMPANY_DOMAIN_NAME%)(PORT = 1521)) >> %TNS_NAMES_FILE%
echo    (CONNECT_DATA = >> %TNS_NAMES_FILE%
echo      (SERVER = DEDICATED) >> %TNS_NAMES_FILE%
echo      (SERVICE_NAME = %STANDBY_DB%) >> %TNS_NAMES_FILE%
echo    ) >> %TNS_NAMES_FILE%
echo  ) >> %TNS_NAMES_FILE%
echo. >> %TNS_NAMES_FILE%

echo. >> %TNS_NAMES_FILE%
echo %PRIMARY_DB%%SQLNET_COMPANY_DOMAIN_NAME% = >> %TNS_NAMES_FILE%
echo  (DESCRIPTION = >> %TNS_NAMES_FILE%
echo    (ADDRESS = (PROTOCOL = TCP)(HOST = %PRIMARY_MACHINE_NAME%.%COMPANY_DOMAIN_NAME%)(PORT = 1521)) >> %TNS_NAMES_FILE%
echo    (CONNECT_DATA = >> %TNS_NAMES_FILE%
echo      (SERVER = DEDICATED) >> %TNS_NAMES_FILE%
echo      (SERVICE_NAME = %PRIMARY_DB%) >> %TNS_NAMES_FILE%
echo    ) >> %TNS_NAMES_FILE%
echo  ) >> %TNS_NAMES_FILE%
echo. >> %TNS_NAMES_FILE%

:DONE_CREATE_STANDBY_TNSNAMES_ENTRY

echo Create standby database TNSNAMES entry - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | CHECK STANDBY TNSNAMES ENTRY                                             |
REM +--------------------------------------------------------------------------+

echo.                                                                                   >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------              >> "%LOGFILE%"
echo TRACE^> Checking for standby database TNSNAMES entry (%STANDBY_DB_TNS_CONNECT%).   >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------              >> "%LOGFILE%"
echo.                                                                                   >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto TNS_STANDBY_CONTINUE)

%ORACLE_HOME%\bin\tnsping %STANDBY_DB_TNS_CONNECT% >> "%LOGFILE%"

if errorlevel 1 (goto TNS_STANDBY_ERROR) else (goto TNS_STANDBY_CONTINUE)

:TNS_STANDBY_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!     >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors.   >> "%LOGFILE%"
echo TRACE^> CAJ-002001: Failed to TNSPING (%STANDBY_DB_TNS_CONNECT%)     >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:TNS_STANDBY_CONTINUE

echo Check standby database TNSNAMES entry - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | COPY STANDBY PASSWORD FILE FROM PRIMARY                                  |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Copy standby password file from primary (%STANDBY_DB%).       >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto ORAPWD_STANDBY_CONTINUE)

robocopy.exe \\%PRIMARY_MACHINE_NAME%\%ORACLE_HOME_UNC%\database\ %ORACLE_HOME%\database\ PWD%PRIMARY_DB%.ora /LOG:%TEMPLOGFILE%

type "%TEMPLOGFILE%" >> "%LOGFILE%"

del /q /f "%TEMPLOGFILE%"

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Rename standby password (%STANDBY_DB%).                       >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

move %ORACLE_HOME%\database\PWD%PRIMARY_DB%.ora %ORACLE_HOME%\database\PWD%STANDBY_DB%.ora

:ORAPWD_STANDBY_CONTINUE

dir %ORACLE_HOME%\database\PWD%STANDBY_DB%.ora >> "%LOGFILE%"

echo Create standby database password file - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY DATABASE CONTROLFILE FROM PRIMARY                         |
REM +--------------------------------------------------------------------------+

echo.                                                                         >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------    >> "%LOGFILE%"
echo TRACE^> Create standby database controlfile from primary (%PRIMARY_DB%). >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------    >> "%LOGFILE%"
echo.                                                                         >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto CREATE_STANDBY_DATABASE_CONTROLFILE_CONTINUE)

echo RUN {                                                 > %TEMPRMAN_CMDFILE%
echo     BACKUP CURRENT CONTROLFILE FOR STANDBY;          >> %TEMPRMAN_CMDFILE%
echo }                                                    >> %TEMPRMAN_CMDFILE%
echo EXIT;                                                >> %TEMPRMAN_CMDFILE%

%ORACLE_HOME%\bin\rman TARGET SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% nocatalog cmdfile=%TEMPRMAN_CMDFILE% msglog %TEMPLOGFILE% 

type "%TEMPLOGFILE%" >> "%LOGFILE%"

findstr /i "ORA-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto CREATE_STANDBY_DATABASE_CONTROLFILE_CONTINUE) ELSE (goto CREATE_STANDBY_DATABASE_CONTROLFILE_ERROR)

:CREATE_STANDBY_DATABASE_CONTROLFILE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002019: Failed to create standby database controlfile from primary.      >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"
goto END_OF_FILE_REPORT

:CREATE_STANDBY_DATABASE_CONTROLFILE_CONTINUE

echo Create standby database controlfile from primary - [OK]

del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | COPY FLASH RECOVERY AREA FILES FROM PRIMARY MACHINE                      |
REM +--------------------------------------------------------------------------+

echo.                                                                            >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------       >> "%LOGFILE%"
echo TRACE^> Copy Flash Recovery Area files from primary machine (%PRIMARY_DB%). >> "%LOGFILE%"
echo TRACE^> (If necessary)                                                      >> "%LOGFILE%"
echo TRACE^> -------------------------------------------------------------       >> "%LOGFILE%"
echo.                                                                            >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_COPY_FILES_FROM_PRIMARY_MACHINE)

if /i %LOCAL_PRIMARY_MACHINE% equ TRUE (goto DO_NOT_COPY_FILES_FROM_PRIMARY)

robocopy.exe /E \\%PRIMARY_MACHINE_NAME%\%ORA_FRA_UNC%\%PRIMARY_DB% %ORA_FRA_DIR%\%PRIMARY_DB%\ /LOG:%TEMPLOGFILE%

REM type "%TEMPLOGFILE%" >> "%LOGFILE%"

del /q /f "%TEMPLOGFILE%"

goto DONE_COPY_FILES_FROM_PRIMARY_MACHINE

:DO_NOT_COPY_FILES_FROM_PRIMARY

echo.                                                   >> "%LOGFILE%"
echo TRACE^> This is a local build.                     >> "%LOGFILE%"
echo TRACE^> No need to copy Flash Recovery Area files. >> "%LOGFILE%"
echo.                                                   >> "%LOGFILE%"

:DONE_COPY_FILES_FROM_PRIMARY_MACHINE

echo Copy flash recovery area files from primary machine - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY DIRECTORIES                                               |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Create standby directories (%STANDBY_DB%).                    >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_CREATE_STANDBY_DIRECTORIES)

mkdir %ORA_ADMIN_DIR%\%STANDBY_DB% >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\adump >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\bdump >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\cdump >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\dpdump >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\pfile >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\scripts >> "%LOGFILE%"
mkdir %ORA_ADMIN_DIR%\%STANDBY_DB%\udump >> "%LOGFILE%"

mkdir %ORACLE_BASE%\product\10.2.0\admin\%STANDBY_DB% >> "%LOGFILE%"
mkdir %ORACLE_BASE%\product\10.2.0\admin\%STANDBY_DB%\dpdump >> "%LOGFILE%"

mkdir %ORA_DB_FILES_DIR%\%STANDBY_DB% >> "%LOGFILE%"
mkdir %ORA_DB_FILES_DIR%\%STANDBY_DB%\DATAFILE >> "%LOGFILE%"

mkdir %ORA_REDO_LOG_FILE_DIR%\%STANDBY_DB% >> "%LOGFILE%"
mkdir %ORA_CONTROL_FILE_DIR%\%STANDBY_DB%\CONTROLFILE >> "%LOGFILE%"
mkdir %ORA_REDO_LOG_FILE_DIR%\%STANDBY_DB%\ONLINELOG >> "%LOGFILE%"

mkdir %ORA_FRA_DIR%\%STANDBY_DB% >> "%LOGFILE%"
mkdir %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG >> "%LOGFILE%"
mkdir %ORA_FRA_DIR%\%STANDBY_DB%\BACKUPSET >> "%LOGFILE%"
mkdir %ORA_FRA_DIR%\%STANDBY_DB%\ONLINELOG >> "%LOGFILE%"

:DONE_CREATE_STANDBY_DIRECTORIES

echo Create standby database directories - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY SERVICE (%STANDBY_DB%)                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Create standby service (%STANDBY_DB%).                        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto ORADIM_STANDBY_CONTINUE)

call %ORACLE_HOME%\bin\oradim -NEW -SID %STANDBY_DB% -STARTMODE auto -SRVCSTART system >> "%LOGFILE%"

if errorlevel 1 (goto ORADIM_STANDBY_ERROR) else (goto ORADIM_STANDBY_CONTINUE)

:ORADIM_STANDBY_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002007: Failed to create the standby instance (%STANDBY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
goto END_OF_FILE_REPORT

:ORADIM_STANDBY_CONTINUE

echo Create standby database service - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY PFILE                                                     |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Create STANDBY PFILE (%STANDBY_DB%).                          >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_CREATE_STANDBY_PFILE)

echo  SET PAGESIZE  9000                                                                                > "%TEMPSQLFILE%"
echo  SET LINESIZE  300                                                                                >> "%TEMPSQLFILE%"
echo  SET HEAD      off                                                                                >> "%TEMPSQLFILE%"
echo  SET TERM      off                                                                                >> "%TEMPSQLFILE%"
echo  SET FEEDBACK  off                                                                                >> "%TEMPSQLFILE%"
echo  SET TRIMSPOOL on                                                                                 >> "%TEMPSQLFILE%"
echo  spool %ORACLE_HOME%\database\init%STANDBY_DB%.ora                                                >> "%TEMPSQLFILE%"
echo  SELECT                                                                                           >> "%TEMPSQLFILE%"
echo    RPAD(name,45) ^|^| ' = '                                                                       >> "%TEMPSQLFILE%"
echo    ^|^| REPLACE(UPPER(value), UPPER('%PRIMARY_DB%'), UPPER('%STANDBY_DB%'))                       >> "%TEMPSQLFILE%"
echo  FROM v$parameter                                                                                 >> "%TEMPSQLFILE%"
echo  WHERE isdefault = 'FALSE'                                                                        >> "%TEMPSQLFILE%"
echo    AND value IS NOT NULL                                                                          >> "%TEMPSQLFILE%"
echo    AND name in (    'aq_tm_processes', 'archive_lag_target', 'audit_file_dest'                    >> "%TEMPSQLFILE%"
echo                   , 'background_dump_dest', 'compatible', 'core_dump_dest', 'db_block_size'       >> "%TEMPSQLFILE%"
echo                   , 'db_create_file_dest', 'db_file_multiblock_read_count', 'db_name'             >> "%TEMPSQLFILE%"
echo                   , 'db_recovery_file_dest', 'db_recovery_file_dest_size', 'job_queue_processes'  >> "%TEMPSQLFILE%"
echo                   , 'nls_length_semantics', 'open_cursors', 'pga_aggregate_target', 'processes'   >> "%TEMPSQLFILE%"
echo                   , 'remote_dependencies_mode', 'remote_login_passwordfile'                       >> "%TEMPSQLFILE%"
echo                   , 'smtp_out_server', 'undo_management', 'undo_retention'                        >> "%TEMPSQLFILE%"
echo                   , 'sga_target', 'sga_max_size'                                                  >> "%TEMPSQLFILE%"
echo                   , 'undo_tablespace', 'user_dump_dest')                                          >> "%TEMPSQLFILE%"
echo  ORDER BY name;                                                                                   >> "%TEMPSQLFILE%"
echo  SELECT                                                                                           >> "%TEMPSQLFILE%"
echo    RPAD(name,45) ^|^| ' = '                                                                       >> "%TEMPSQLFILE%"
echo    ^|^| '''' ^|^| REPLACE(UPPER(value), UPPER('%PRIMARY_DB%'),  UPPER('%STANDBY_DB%')) ^|^| ''''  >> "%TEMPSQLFILE%"
echo  FROM v$parameter                                                                                 >> "%TEMPSQLFILE%"
echo  WHERE isdefault = 'FALSE'                                                                        >> "%TEMPSQLFILE%"
echo    AND value IS NOT NULL                                                                          >> "%TEMPSQLFILE%"
echo    AND name in ('dispatchers')                                                                    >> "%TEMPSQLFILE%"
echo  ORDER BY name;                                                                                   >> "%TEMPSQLFILE%"
echo  spool off                                                                                        >> "%TEMPSQLFILE%"
echo  exit;                                                                                            >> "%TEMPSQLFILE%"

%ORACLE_HOME%\bin\sqlplus -L SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AS SYSDBA @"%TEMPSQLFILE%"

echo control_files  = '%ORA_CONTROL_FILE_DIR%\%STANDBY_DB%\CONTROLFILE\CONTROL01.CTL', '%ORA_CONTROL_FILE_DIR%\%STANDBY_DB%\CONTROLFILE\CONTROL02.CTL', '%ORA_CONTROL_FILE_DIR%\%STANDBY_DB%\CONTROLFILE\CONTROL03.CTL'  >> "%ORACLE_HOME%\database\init%STANDBY_DB%.ora"

type "%ORACLE_HOME%\database\init%STANDBY_DB%.ora" >> "%LOGFILE%"

del /q "%TEMPSQLFILE%"

:DONE_CREATE_STANDBY_PFILE

echo Create standby database PFILE - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CREATE STANDBY SPFILE                                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Create standby SPFILE (%STANDBY_DB%).                         >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto CREATE_STANDBY_SPFILE_CONTINUE)

SET ORACLE_SID=%STANDBY_DB%

echo  spool %TEMPLOGFILE%             > "%TEMPSQLFILE%"
echo  STARTUP NOMOUNT;               >> "%TEMPSQLFILE%"
echo  CREATE SPFILE FROM PFILE;      >> "%TEMPSQLFILE%"
echo  SHUTDOWN IMMEDIATE             >> "%TEMPSQLFILE%"
echo  STARTUP NOMOUNT;               >> "%TEMPSQLFILE%"
echo  spool off                      >> "%TEMPSQLFILE%"
echo  exit;                          >> "%TEMPSQLFILE%"

%ORACLE_HOME%\bin\sqlplus -L SYS/%STANDBY_SYS_PASSWD% AS SYSDBA @"%TEMPSQLFILE%"

type "%TEMPLOGFILE%" >> "%LOGFILE%"

findstr /i "ORA- SP2-" "%TEMPLOGFILE%" | findstr /v "ORA-01507" >> "%LOGFILE%"
if errorlevel 1 (goto CREATE_STANDBY_SPFILE_CONTINUE) ELSE (goto CREATE_STANDBY_SPFILE_ERROR)

:CREATE_STANDBY_SPFILE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002018: Failed to create standby SPFILE (%STANDBY_DB%) >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q /f "%TEMPSQLFILE%"
del /q /f "%TEMPLOGFILE%"
goto END_OF_FILE_REPORT

:CREATE_STANDBY_SPFILE_CONTINUE

del /q "%TEMPSQLFILE%"
del /q "%TEMPLOGFILE%"
del /q "%ORACLE_HOME%\database\init%STANDBY_DB%.ora"

echo Create standby database SPFILE - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | COPY ARCHIVE LOGS FOR STANDBY DATABASE                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Copy archive logs for STANDBY database (%PRIMARY_DB%).        >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_COPY_ARCHIVE_LOGS_FOR_STANDBY_DATABASE)

if /i %LOCAL_PRIMARY_MACHINE% equ TRUE (goto PERFORM_LOCAL_ARCHIVE_LOG_COPY) else (goto PERFORM_REMOTE_ARCHIVE_LOG_COPY)

:PERFORM_REMOTE_ARCHIVE_LOG_COPY

robocopy.exe /E %ORA_FRA_DIR%\%PRIMARY_DB%\ARCHIVELOG\ %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG\ /LOG:%TEMPLOGFILE%

REM type "%TEMPLOGFILE%" >> "%LOGFILE%"

del /q "%TEMPLOGFILE%"

goto DONE_COPY_ARCHIVE_LOGS_FOR_STANDBY_DATABASE

:PERFORM_LOCAL_ARCHIVE_LOG_COPY

xcopy /S /E /Y %ORA_FRA_DIR%\%PRIMARY_DB%\ARCHIVELOG\*.* %ORA_FRA_DIR%\%STANDBY_DB%\ARCHIVELOG\ >> "%LOGFILE%"

:DONE_COPY_ARCHIVE_LOGS_FOR_STANDBY_DATABASE

echo Copy archived logs to standby database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | DUPLICATE THE DATABASE                                                   |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Duplicate the database for standby.                           >> "%LOGFILE%"
echo TRACE^> -----------------------                                       >> "%LOGFILE%"
echo TRACE^> Login to target (primary) and (standby) auxiliary database    >> "%LOGFILE%"
echo TRACE^> using RMAN. All of this should be performed from the          >> "%LOGFILE%"
echo TRACE^> auxiliary database server. In order to perform this section,  >> "%LOGFILE%"
echo TRACE^> you will need the last log sequence number, which we recorded >> "%LOGFILE%"
echo TRACE^> earlier in this script.                                       >> "%LOGFILE%"
echo TRACE^> Notice that the parameter NOFILENAMECHECK must be used when   >> "%LOGFILE%"
echo TRACE^> you are duplicating a database to a different host with the   >> "%LOGFILE%"
echo TRACE^> same file system (directory structure).                       >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DUPLICATE_THE_DATABASE_CONTINUE)

SET ORACLE_SID=%STANDBY_DB%

echo RUN {                                                 > %TEMPRMAN_CMDFILE%
echo     DUPLICATE TARGET DATABASE FOR STANDBY;           >> %TEMPRMAN_CMDFILE%
echo }                                                    >> %TEMPRMAN_CMDFILE%
echo EXIT;                                                >> %TEMPRMAN_CMDFILE%

%ORACLE_HOME%\bin\rman TARGET SYS/%PRIMARY_SYS_PASSWD%@%PRIMARY_DB% AUXILIARY SYS/%STANDBY_SYS_PASSWD% nocatalog cmdfile=%TEMPRMAN_CMDFILE% msglog %TEMPLOGFILE% 

type "%TEMPLOGFILE%" >> "%LOGFILE%"

findstr /i "ORA-" "%TEMPLOGFILE%" >> "%LOGFILE%"

if errorlevel 1 (goto DUPLICATE_THE_DATABASE_CONTINUE) ELSE (goto DUPLICATE_THE_DATABASE_ERROR)

:DUPLICATE_THE_DATABASE_ERROR

echo.        >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!  Script Error  !!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001001: !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   >> "%LOGFILE%"
echo TRACE^> CAJ-001002: Please review the log file for errors. >> "%LOGFILE%"
echo TRACE^> CAJ-002014: Failed to duplicate the database.      >> "%LOGFILE%"
echo TRACE^> >> "%LOGFILE%"
echo.        >> "%LOGFILE%"
del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"
goto END_OF_FILE_REPORT

:DUPLICATE_THE_DATABASE_CONTINUE

echo Duplicate the database - [OK]

del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | REMOVE OBSOLETE RMAN BACKUPS                                             |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Remove obsolete rman backups.                                 >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_REMOVE_COPIED_PRIMARY_BACKUPS)

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Remove copied standby backups (%STANDBY_DB%).                 >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

rmdir /S /Q %ORA_FRA_DIR%\%STANDBY_DB%\BACKUPSET
rmdir /S /Q %ORA_FRA_DIR%\%STANDBY_DB%\ONLINELOG
rmdir /S /Q %ORA_FRA_DIR%\%STANDBY_DB%\AUTOBACKUP

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Remove copied primary backups (%PRIMARY_DB%).                 >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %LOCAL_PRIMARY_MACHINE% equ TRUE (goto SKIP_REMOVE_COPIED_PRIMARY_BACKUPS)

if /i %SAME_STANDBY_PRIMARY_DATABASE_NAME% equ TRUE (goto SKIP_REMOVE_COPIED_PRIMARY_BACKUPS)

rmdir /S /Q %ORA_FRA_DIR%\%PRIMARY_DB%

goto DONE_REMOVE_COPIED_PRIMARY_BACKUPS

:SKIP_REMOVE_COPIED_PRIMARY_BACKUPS

echo.                                                   >> "%LOGFILE%"
echo TRACE^> This is a local build.                     >> "%LOGFILE%"
echo TRACE^> No need to remove copied primary backups.  >> "%LOGFILE%"
echo.                                                   >> "%LOGFILE%"

:DONE_REMOVE_COPIED_PRIMARY_BACKUPS

echo Remove obsolete RMAN backup files - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | CLEAN STANDBY RECOVERY CATALOG                                           |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Clean standby recovery catalog (%STANDBY_DB%).                >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_CLEAN_STANDBY_RECOVERY_CATALOG)

SET ORACLE_SID=%STANDBY_DB%

echo CROSSCHECK BACKUP OF DATABASE;                          > %TEMPRMAN_CMDFILE%
echo CROSSCHECK BACKUP OF CONTROLFILE;                      >> %TEMPRMAN_CMDFILE%
echo CROSSCHECK ARCHIVELOG ALL;                             >> %TEMPRMAN_CMDFILE%
echo DELETE FORCE NOPROMPT EXPIRED BACKUP OF DATABASE;      >> %TEMPRMAN_CMDFILE%
echo DELETE FORCE NOPROMPT EXPIRED BACKUP OF CONTROLFILE;   >> %TEMPRMAN_CMDFILE%
echo DELETE FORCE NOPROMPT EXPIRED ARCHIVELOG ALL;          >> %TEMPRMAN_CMDFILE%
echo EXIT;                                                  >> %TEMPRMAN_CMDFILE%

%ORACLE_HOME%\bin\rman TARGET SYS/%STANDBY_SYS_PASSWD% nocatalog cmdfile=%TEMPRMAN_CMDFILE% msglog %TEMPLOGFILE% 

type "%TEMPLOGFILE%" >> "%LOGFILE%"

del /q "%TEMPLOGFILE%"
del /q "%TEMPRMAN_CMDFILE%"

:DONE_CLEAN_STANDBY_RECOVERY_CATALOG

echo Clean standby database recovery catalog - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | WRITE OUT DB ENV BATCH SCRIPT FOR STANDBY DATABASE                       |
REM +--------------------------------------------------------------------------+

echo.                                                                                 >> "%LOGFILE%"
echo TRACE^> ----------------------------------------------------------------------   >> "%LOGFILE%"
echo TRACE^> Write out db env batch script for standby database.                      >> "%LOGFILE%"
echo TRACE^> ----------------------------------------------------------------------   >> "%LOGFILE%"
echo.                                                                                 >> "%LOGFILE%"

:WRITE_OUT_DB_ENV_BATCH_SCRIPT_FOR_STANDBY_DB

echo @echo off> %STANDBY_DB_BATCH_SCRIPT%
echo.>> %STANDBY_DB_BATCH_SCRIPT%
echo SET ORACLE_SID=%STANDBY_DB%>> %STANDBY_DB_BATCH_SCRIPT%
echo.>> %STANDBY_DB_BATCH_SCRIPT%
echo SET ORACLE_BASE=%ORACLE_BASE%>> %STANDBY_DB_BATCH_SCRIPT%
echo SET ORACLE_HOME=%ORACLE_HOME%>> %STANDBY_DB_BATCH_SCRIPT%
echo.>> %STANDBY_DB_BATCH_SCRIPT%
echo echo.>> %STANDBY_DB_BATCH_SCRIPT%
echo echo DB Environment = %%ORACLE_SID%% >> %STANDBY_DB_BATCH_SCRIPT%

echo Write out db env batch script for standby database - [OK]

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


goto STANDBY_ADMIN_OPTION_CONTINUE




REM ============================================================================
REM ----------------------------------------------------------------------------
REM      S T A N D B Y    A D M I N    O P T I O N    C O N T I N U E
REM ----------------------------------------------------------------------------
REM ============================================================================

:STANDBY_ADMIN_OPTION_CONTINUE

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> LABEL: [  STANDBY_ADMIN_OPTION_CONTINUE  ]                         >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | REMOVE OBSOLETE LOG FILES                                                |
REM +--------------------------------------------------------------------------+

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> Remove obsolete log files older than %NUM_LOG_DAYS_TO_KEEP% days.  >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"

echo List of log files in %ORA_LOG_DIR% older than %NUM_LOG_DAYS_TO_KEEP% days... >> "%LOGFILE%"
forfiles /P %ORA_LOG_DIR% /S /D -%NUM_LOG_DAYS_TO_KEEP% /M %FILENAME%_%STANDBY_ADMIN_OPTION%_%STANDBY_DB%*.LOG /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"

echo Deleting log files in %ORA_LOG_DIR% older than %NUM_LOG_DAYS_TO_KEEP% days... >> "%LOGFILE%"
forfiles /P %ORA_LOG_DIR% /S /D -%NUM_LOG_DAYS_TO_KEEP% /M %FILENAME%_%STANDBY_ADMIN_OPTION%_%STANDBY_DB%*.LOG /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | ACKNOWLEDGE SUCCESSFUL COMPLETION OF SCRIPT                              |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Acknowledge successful completion of script.                  >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

echo.                    >> "%LOGFILE%"
echo TRACE^> ----------- >> "%LOGFILE%"
echo TRACE^> Successful. >> "%LOGFILE%"
echo TRACE^> ----------- >> "%LOGFILE%"
echo.                    >> "%LOGFILE%"



REM +--------------------------------------------------------------------------+
REM | LABEL DECLARATION SECTION.                                               |
REM +--------------------------------------------------------------------------+

:END_OF_FILE_REPORT

echo.
echo ...........................................................................
echo END OF FILE REPORT
echo Log File          : %LOGFILE%
echo End Date          : %DATE%
echo End Time          : %TIME%
echo ...........................................................................
echo.

echo. >> "%LOGFILE%"
echo ........................................................................... >> "%LOGFILE%"
echo END OF FILE REPORT            >> "%LOGFILE%"
echo Log File          : %LOGFILE% >> "%LOGFILE%"
echo End Date          : %DATE%    >> "%LOGFILE%"
echo End Time          : %TIME%    >> "%LOGFILE%"
echo ........................................................................... >> "%LOGFILE%"
echo. >> "%LOGFILE%"


:MAKE_COPY_OF_LOG_FILE

REM +--------------------------------------------------------------------------+
REM | MAKE COPY OF LOG FILE                                                    |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Making copy of log file:                                      >> "%LOGFILE%"
echo TRACE^>    [%LOGFILE%]                                                >> "%LOGFILE%"
echo TRACE^> to                                                            >> "%LOGFILE%"
echo TRACE^>    [%LOGFILE_COPY%]                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

copy /Y /V %LOGFILE% %LOGFILE_COPY% >> "%LOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


:SCAN_THE_LOGFILE_FOR_EXCEPTIONS

REM +--------------------------------------------------------------------------+
REM | SCAN THE LOGFILE FOR EXCEPTIONS                                          |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Scan the logfile for exceptions.                              >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

REM findstr /i "CAJ- ORA-" "%LOGFILE%" | findstr /v "ORA-01918"
findstr /i "CAJ- SP2-" "%LOGFILE%"
if errorlevel 1 (set FOUND_SCRIPT_EXCEPTIONS=FALSE) else (set FOUND_SCRIPT_EXCEPTIONS=TRUE)

echo.                                                          >> "%LOGFILE%"
echo TRACE^> FOUND_SCRIPT_EXCEPTIONS=%FOUND_SCRIPT_EXCEPTIONS% >> "%LOGFILE%"
echo.                                                          >> "%LOGFILE%"

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


:SEND_EMAIL

REM +--------------------------------------------------------------------------+
REM | SEND EMAIL.                                                              |
REM +--------------------------------------------------------------------------+

echo.                                                                      >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo TRACE^> Send email.                                                   >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

if /i %DEBUG_SCRIPT% equ TRUE (goto DONE_SEND_EMAIL)

if /i %STANDBY_ADMIN_OPTION% equ BUILD (goto DO_SEND_EMAIL)

if /i %STANDBY_ADMIN_OPTION% equ ACTIVATE (goto DO_SEND_EMAIL)

if /i %FOUND_SCRIPT_EXCEPTIONS% equ TRUE (goto DO_SEND_EMAIL) else (goto DONE_SEND_EMAIL)

:DO_SEND_EMAIL

echo.                                                                           >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo TRACE^> LABEL: [  DO_SEND_EMAIL  ]                                         >> "%LOGFILE%"
echo TRACE^> ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                           >> "%LOGFILE%"

if /i %FOUND_SCRIPT_EXCEPTIONS% equ TRUE (set EMAIL_STATUS=[%COMPUTERNAME%] - FAILED: %SCRIPTNAME%) else (set EMAIL_STATUS=[%COMPUTERNAME%] - SUCCESSFUL: %SCRIPTNAME%)

blat "%LOGFILE%" -subject "%EMAIL_STATUS%" -to %SMTP_EMAIL_TO% -server %SMTP_SERVER% -f %SMTP_EMAIL_FROM%

:DONE_SEND_EMAIL

echo.              >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo TRACE^> Done. >> "%LOGFILE%"
echo TRACE^> ----- >> "%LOGFILE%"
echo.              >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | END THIS SCRIPT.                                                         |
REM +--------------------------------------------------------------------------+

goto END


:PARAMETER_ERROR

echo.
echo Invalid parameters.
echo Please enter the following parameters:
echo.
echo      STANDBY_ADMIN_OPTION      - Valid values are "BUILD", "REFRESH", or "ACTIVATE".
echo      STANDBY_DB                - Oracle SID for the standby database.
echo      STANDBY_DB_TNS_CONNECT    - TNS connect string to the standby database.
echo      STANDBY_SYS_PASSWD        - SYS password for the standby database.
echo      STANDBY_MACHINE_NAME      - Name of the standby database machine.
echo.
echo The following parameters are only required when STANDBY_ADMIN_OPTION equals "BUILD" or "REFRESH".
echo.
echo      PRIMARY_DB                - Oracle SID and TNS connect string for the primary database.
echo      PRIMARY_SYS_PASSWD        - SYS password for the primary database.
echo      PRIMARY_MACHINE_NAME      - Name of the primary database machine.
echo.
echo Example usage:
echo.
echo      standby_database_admin.bat BUILD PROD PROD_STBY sysprod win-db2 PROD sysprod win-db1
echo      standby_database_admin.bat REFRESH PROD PROD_STBY sysprod win-db2 PROD sysprod win-db1
echo      standby_database_admin.bat ACTIVATE PROD PROD_STBY sysprod win-db2


REM +==========================================================================+
REM |                    ***   END OF SCRIPT   ***                             |
REM +==========================================================================+

:END
@echo on
