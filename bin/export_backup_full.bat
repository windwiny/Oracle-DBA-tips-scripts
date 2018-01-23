@echo off
REM +--------------------------------------------------------------------------+
REM |                          Jeffrey M. Hunter                               |
REM |                      jhunter@idevelopment.info                           |
REM |                         www.idevelopment.info                            |
REM |--------------------------------------------------------------------------|
REM |    Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
REM |--------------------------------------------------------------------------|
REM | FILE       : export_backup_full.bat                                      |
REM | CLASS      : WINDOWS Shell Scripts                                       |
REM | PURPOSE    : Used to perform a logical backup of an Oracle database      |
REM |              using the traditional export utility. By default, this      |
REM |              script performs a full and consistent backup of the         |
REM |              database using a dynamically created parameter file that    |
REM |              gets written to a temporary directory and run through       |
REM |              Oracle export using the "parfile" parameter.                |
REM |                                                                          |
REM |              -------------                                               |
REM |              IMPORTANT !!!                                               |
REM |              -------------                                               |
REM |              Please note that this script makes use of the command       |
REM |              utility "forfiles.exe" to list and remove obsolete Oracle   |
REM |              export dump files and log files. Some Microsoft operating   |
REM |              system environments do not include this utility by default  |
REM |              (i.e. Windows XP). A copy of "forfiles.exe" can be          |
REM |              downloaded from:                                            |
REM |                                                                          |
REM |         http://www.idevelopment.info/data/Supporting_Tools/forfiles.exe  |
REM |                                                                          |
REM |              ------------------                                          |
REM |              EMAIL CAPABILITIES                                          |
REM |              ------------------                                          |
REM |              This script makes use of the BLAT command line utility to   |
REM |              send the resulting log file to administrators. For more     |
REM |              information on configuring BLAT to send email from scripts  |
REM |              in Windows, see the following article:                      |
REM |                                                                          |
REM |         http://www.idevelopment.info/data/Oracle/DBA_tips/Microsoft_Windows/WINDOWS_5.shtml
REM |                                                                          |
REM |              --------------------------------------------                |
REM |              NEW DATA PUMP UTILITY IN ORACLE DATABASE 10g                |
REM |              --------------------------------------------                |
REM |              Oracle Database 10g users (and higher) should consider      |
REM |              using the new Data Pump utility in place of the original    |
REM |              Oracle import/export. The original export utility was       |
REM |              deprecated in Oracle Database 10g Release 2, and is no      |
REM |              longer supported for general use as of Oracle Database 11g. |
REM |              Going forward, Data Pump export (expdp) will be the sole    |
REM |              supported means of exporting data from the database. The    |
REM |              original import utility (imp) still ships with Oracle       |
REM |              Database 10g and Oracle Database 11g in order to support    |
REM |              import of legacy dump files. The original import utility    |
REM |              will be supported forever and will provide the means to     |
REM |              import dump files from earlier releases (release 5.0 and    |
REM |              later) that were created with the original export (exp).    |
REM |              Please note that the original export dump files and the new |
REM |              Data Pump dump files are "not" compatible. You cannot read  |
REM |              an original Oracle export dump file with Data Pump and vice |
REM |              versa. Neither client can read dump files created by the    |
REM |              other.                                                      |
REM |                                                                          |
REM |              ----------------------------                                |
REM |              LABEL SECURITY AND VPD USERS                                |
REM |              ----------------------------                                |
REM |              When exporting data from an Oracle database that contains   |
REM |              tables protected by Fine-Grained Access Control (FGAC)      |
REM |              policies, it is possible to receive EXP-00079 and/or        |
REM |              EXP-00080 warnings.                                         |
REM |                                                                          |
REM |              Note that Fine-Grained Access Control (FGAC) is a synonym   |
REM |              for Row-Level Security (RLS) and should not be confused     |
REM |              with FGA which stands for Fine-Grained Auditing!            |
REM |                                                                          |
REM |              This warning is thrown by Oracle export when FGAC is        |
REM |              enabled on a SELECT statement and indicates that Oracle     |
REM |              export may not export the entire table because FGAC access  |
REM |              may rewrite the query. There are two methods used to        |
REM |              resolve this issue and ensure Oracle export is able to      |
REM |              access and backup all data:                                 |
REM |                                                                          |
REM |                  (1) Use the Direct Path clause of Oracle Export or      |
REM |                  (2) Use a database login that has access to all rows    |
REM |                      regardless of existing FGAC policies.               |
REM |                                                                          |
REM |              It is highly recommended that the latter option be used     |
REM |              especially when exporting tables that contain objects and   |
REM |              LOBs. Rows in tables that contain objects and LOBs will be  |
REM |              exported using the Conventional Path method, even if Direct |
REM |              Path was specified. If this table has FGAC policies         |
REM |              enabled, the export will then fail with EXP-00008,          |
REM |              ORA-00604, and ORA-28112 errors. The recommended method is  |
REM |              to run Oracle export while connected as a user who has      |
REM |              access to all rows regardless of existing FGAC policies.    |
REM |              Only the user SYS (all versions) or any user who has the    |
REM |              EXEMPT ACCESS POLICY privilege (Oracle9i and higher), can   |
REM |              select all rows. The recommended convention is to export    |
REM |              using the database user BACKUP_ADMIN which has been granted |
REM |              the EXEMPT ACCESS POLICY privilege:                         |
REM |                                                                          |
REM |              SQL> GRANT exempt access policy TO backup_admin;            |
REM |                                                                          |
REM |              Note that this section does not apply to the                |
REM |              Oracle Database 10g Data Pump Export utility (expdp). An    |
REM |              export with the new Oracle Database 10g Data Pump Export    |
REM |              utility will not give any warning message.                  |
REM |                                                                          |
REM |              ----------------------------                                |
REM |              ORACLE 11g USERS                                            |
REM |              ----------------------------                                |
REM |              Running the export utility (exp) in Oracle Database 11g or  |
REM |              after applying CPUOCT2007 (Patch 12) on top of Oracle       |
REM |              Database 10g (10.2.0.3), the following errors will occur    |
REM |              during a full database export such as:                      |
REM |                                                                          |
REM |                  . about to export SYSTEM's tables via Direct Path ...   |
REM |                  . . exporting table                    DEF$_AQCALL      |
REM |                  EXP-00008: ORACLE error 6550 encountered                |
REM |                  ORA-06550: line 1, column 19:                           |
REM |                  PLS-00201: identifier 'SYS.DBMS_DEFER_IMPORT_INTERNAL' must be declared
REM |                  ORA-06550: line 1, column 7:                            |
REM |                  PL/SQL: Statement ignored                               |
REM |                  ORA-06512: at "SYS.DBMS_SQL", line 1501                 |
REM |                  ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 97      |
REM |                  ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 126     |
REM |                  ORA-06512: at line 1                                    |
REM |                                                                          |
REM |                  ORA-06512: at "SYS.DBMS_SYS_SQL", line 1204             |
REM |                  ORA-06512: at "SYS.DBMS_SQL", line 323                  |
REM |                  ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 97      |
REM |                  ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 126     |
REM |                  ORA-06512: at line 1                                    |
REM |                                                                          |
REM |              This problem can occur on any platform.                     |
REM |                                                                          |
REM |              This is an Oracle bug documented in Metalink note:          |
REM |                                                                          |
REM |              464672.1 "ORA-06512 SYS.DBMS_EXPORT_EXTENSION And PLS-00201 |
REM |                       SYS.DBMS_DEFER_IMPORT_INTERNAL in 11g Export Or    |
REM |                       After OCTCPU2007"                                  |
REM |                                                                          |
REM |              The recommended workaround to this bug is to grant the      |
REM |              missing privileges to the user performing the backup. For   |
REM |              example:                                                    |
REM |                                                                          |
REM |              SQL> GRANT EXECUTE ON SYS.DBMS_DEFER_IMPORT_INTERNAL TO backup_admin;
REM |              SQL> GRANT EXECUTE ON SYS.DBMS_EXPORT_EXTENSION TO backup_admin;
REM |                                                                          |
REM |              ------------------                                          |
REM |              ORACLE EXPORT TIPS                                          |
REM |              ------------------                                          |
REM |              (1) Some organizations find it necessary to also perform    |
REM |                  a daily export with rows=n. These export dumps can be   |
REM |                  vaulted long-term if it ever becomes necessary to       |
REM |                  extract DDL definitions or PL/SQL procedure/packages    |
REM |                  from the past. In addition to Oracle import, other      |
REM |                  utilities exist that can read and parse empty           |
REM |                  (rows=n) export dump files like DDL Wizard.             |
REM |                                                                          |
REM | PARAMETERS : DBA_USERNAME       Database username EXP will use to login  |
REM |                                 to the database. This user must have     |
REM |                                 the DBA role.                            |
REM |              DBA_PASSWORD       Database password EXP will use to login  |
REM |                                 to the database.                         |
REM |              TNS_ALIAS          TNS connect string to the target         |
REM |                                 database.                                |
REM |              NUM_DAYS_TO_KEEP   Number of days worth of Oracle exports   |
REM |                                 to retain on the file system.            |
REM | USAGE      :                                                             |
REM |                                                                          |
REM |   export_backup_full.bat "DBA_USERNAME" "DBA_PASSWORD" "TNS_ALIAS" "NUM_DAYS_TO_KEEP"
REM |                                                                          |
REM | NOTE       : As with any code, ensure to test this script in a           |
REM |              development environment before attempting to run it in      |
REM |              production.                                                 |
REM +--------------------------------------------------------------------------+

REM +--------------------------------------------------------------------------+
REM | SCRIPT NAME VARIABLES                                                    |
REM +--------------------------------------------------------------------------+

set SCRIPT_NAME_NOEXT=export_backup_full
set SCRIPT_NAME_FULL=%SCRIPT_NAME_NOEXT%.bat
set SCRIPT_VERSION=3.9

REM +--------------------------------------------------------------------------+
REM | SET / VALIDATE ENVIRONMENT VARIABLES                                     |
REM +--------------------------------------------------------------------------+

set ORA_EXP_DIR=C:\Oracle\oraexp\orcl

if (%ORA_EXP_DIR%)==() goto ENV_VARIABLES

REM +--------------------------------------------------------------------------+
REM | EMAIL VARIABLES                                                          |
REM +--------------------------------------------------------------------------+

set SMTP_SERVER=localhost
set SMTP_PORT=25
set SMTP_EMAIL_TO=jhunter@idevelopment.info
set SMTP_EMAIL_FROM=dba@idevelopment.info

REM +--------------------------------------------------------------------------+
REM | SET START DATE AND TIME ENVIRONMENT VARIABLES                            |
REM +--------------------------------------------------------------------------+

set START_DATE=%DATE%
set START_TIME=%TIME%

REM +--------------------------------------------------------------------------+
REM | SHOW SIGNON BANNER                                                       |
REM +--------------------------------------------------------------------------+

echo.
echo %SCRIPT_NAME_FULL% - Version %SCRIPT_VERSION%
echo Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.
echo.

REM +--------------------------------------------------------------------------+
REM | VALIDATE COMMAND-LINE PARAMETERS                                         |
REM +--------------------------------------------------------------------------+

if (%1)==() goto USAGE
if (%2)==() goto USAGE
if (%3)==() goto USAGE
if (%4)==() goto USAGE

REM +--------------------------------------------------------------------------+
REM | SET DATE AND TIME ENVIRONMENT VARIABLES FOR FILES                        |
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

SET FILEDATE=%v_year%%v_month%%v_day%

SETLOCAL
FOR /f "tokens=*" %%G IN ('time /t') DO set v_time=%%G
    SET v_time=%v_time:~0,2%%v_time:~3,2%%v_time:~6,2%
ENDLOCAL & SET v_time=%v_time%
   
SET v

SET FILETIME=%v_time%

REM +--------------------------------------------------------------------------+
REM | ORACLE ENVIRONMENT VARIABLES                                             |
REM +--------------------------------------------------------------------------+

set ORACLE_BASE=C:\oracle
set ORACLE_HOME=%ORACLE_BASE%\product\11.2.0\dbhome_1
set ORACLE_ADMIN_DIR=%ORACLE_BASE%\admin

REM +--------------------------------------------------------------------------+
REM | CUSTOM DIRECTORIES                                                       |
REM +--------------------------------------------------------------------------+

set CUSTOM_ORACLE_DIR=%ORACLE_BASE%\dba_scripts
set CUSTOM_ORACLE_BIN_DIR=%CUSTOM_ORACLE_DIR%\bin
set CUSTOM_ORACLE_LIB_DIR=%CUSTOM_ORACLE_DIR%\lib
set CUSTOM_ORACLE_LOG_DIR=%CUSTOM_ORACLE_DIR%\log
set CUSTOM_ORACLE_OUT_DIR=%CUSTOM_ORACLE_DIR%\out
set CUSTOM_ORACLE_SQL_DIR=%CUSTOM_ORACLE_DIR%\sql
set CUSTOM_ORACLE_TEMP_DIR=%CUSTOM_ORACLE_DIR%\temp

REM +--------------------------------------------------------------------------+
REM | DECLARE GLOBAL VARIABLES                                                 |
REM +--------------------------------------------------------------------------+

set DBA_USERNAME=%1%
set DBA_PASSWORD=%2%
set TNS_ALIAS=%3%
set NUM_DAYS_TO_KEEP=%4%

set ERRORS="NO"

SET LOGDIR=%CUSTOM_ORACLE_LOG_DIR%
SET LOGFILE=%LOGDIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_%FILEDATE%_%FILETIME%.log
SET LOGFILE_COPY=%LOGDIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%.log

set EXP_PARAMETER_FILE_NAME=%CUSTOM_ORACLE_TEMP_DIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%.parfile
set EXP_DUMP_FILE_NAME=%ORA_EXP_DIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_%FILEDATE%_%FILETIME%.dmp
set EXP_DUMP_LOG_FILE_NAME=%CUSTOM_ORACLE_TEMP_DIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_EXPLOG.log

set ORACLE_SID=%TNS_ALIAS%

REM +--------------------------------------------------------------------------+
REM | HOSTNAME VARIABLES                                                       |
REM +--------------------------------------------------------------------------+

set HOSTNAME=%COMPUTERNAME%

REM +--------------------------------------------------------------------------+
REM | WRITE HEADER INFORMATION TO CONSOLE AND LOG FILE.                        |
REM +--------------------------------------------------------------------------+

echo ======================================================
echo   - START TIME : %START_DATE% %START_TIME%
echo ======================================================

echo.
echo ===================================================================================
echo                              COMMON SCRIPT VARIABLES
echo ===================================================================================
echo Script Name                        : %SCRIPT_NAME_FULL%
echo Script Version                     : %SCRIPT_VERSION%
echo Begin Date                         : %START_DATE%
echo Begin Time                         : %START_TIME%
echo Host Name                          : %HOSTNAME%
echo Log File Name                      : %LOGFILE%
echo Log File Name (Copy)               : %LOGFILE_COPY%
echo ===================================================================================
echo                              CUSTOM SCRIPT VARIABLES
echo ===================================================================================
echo DBA_USERNAME      (P1)             : %DBA_USERNAME%
echo DBA_PASSWORD      (P2)             : xxxxxxxxxxxxx
echo TNS_ALIAS         (P3)             : %TNS_ALIAS%
echo NUM_DAYS_TO_KEEP  (P4)             : %NUM_DAYS_TO_KEEP%
echo Oracle Export Parameter File Name  : %EXP_PARAMETER_FILE_NAME%
echo Oracle Export Dump File Name       : %EXP_DUMP_FILE_NAME%
echo Oracle Export Dump Log File Name   : %EXP_DUMP_LOG_FILE_NAME%
echo.

echo ====================================================== > "%LOGFILE%"
echo   - START TIME : %START_DATE% %START_TIME% >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo =================================================================================== >> "%LOGFILE%"
echo                              COMMON SCRIPT VARIABLES >> "%LOGFILE%"
echo =================================================================================== >> "%LOGFILE%"
echo Script Name                        : %SCRIPT_NAME_FULL% >> "%LOGFILE%"
echo Script Version                     : %SCRIPT_VERSION% >> "%LOGFILE%"
echo Begin Date                         : %START_DATE% >> "%LOGFILE%"
echo Begin Time                         : %START_TIME% >> "%LOGFILE%"
echo Host Name                          : %HOSTNAME% >> "%LOGFILE%"
echo Log File Name                      : %LOGFILE% >> "%LOGFILE%"
echo Log File Name (Copy)               : %LOGFILE_COPY% >> "%LOGFILE%"
echo =================================================================================== >> "%LOGFILE%"
echo                              CUSTOM SCRIPT VARIABLES >> "%LOGFILE%"
echo =================================================================================== >> "%LOGFILE%"
echo DBA_USERNAME      (P1)             : %DBA_USERNAME% >> "%LOGFILE%"
echo DBA_PASSWORD      (P2)             : xxxxxxxxxxxxx >> "%LOGFILE%"
echo TNS_ALIAS         (P3)             : %TNS_ALIAS% >> "%LOGFILE%"
echo NUM_DAYS_TO_KEEP  (P4)             : %NUM_DAYS_TO_KEEP% >> "%LOGFILE%"
echo Oracle Export Parameter File Name  : %EXP_PARAMETER_FILE_NAME% >> "%LOGFILE%"
echo Oracle Export Dump File Name       : %EXP_DUMP_FILE_NAME% >> "%LOGFILE%"
echo Oracle Export Dump Log File Name   : %EXP_DUMP_LOG_FILE_NAME% >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ==============================================================  >> "%LOGFILE%"
echo   - REMOVE TEMPORARY EXPORT LOG AND PARAMETER FILE. >> "%LOGFILE%"
echo ==============================================================  >> "%LOGFILE%"

del /q %EXP_PARAMETER_FILE_NAME% >> "%LOGFILE%"
del /q %EXP_DUMP_LOG_FILE_NAME% >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"
echo   - WRITE EXPORT PARAMETER FILE. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"

echo userid=%DBA_USERNAME%/%DBA_PASSWORD%@%TNS_ALIAS% > %EXP_PARAMETER_FILE_NAME%
echo buffer=50000000 >> %EXP_PARAMETER_FILE_NAME%
echo file=%EXP_DUMP_FILE_NAME% >> %EXP_PARAMETER_FILE_NAME%
echo compress=n >> %EXP_PARAMETER_FILE_NAME%
echo grants=y >> %EXP_PARAMETER_FILE_NAME%
echo indexes=y >> %EXP_PARAMETER_FILE_NAME%
echo direct=no >> %EXP_PARAMETER_FILE_NAME%
echo log=%EXP_DUMP_LOG_FILE_NAME% >> %EXP_PARAMETER_FILE_NAME%
echo rows=y >> %EXP_PARAMETER_FILE_NAME%
echo consistent=y >> %EXP_PARAMETER_FILE_NAME%
echo full=y >> %EXP_PARAMETER_FILE_NAME%
REM owner=(SCOTT) >> %EXP_PARAMETER_FILE_NAME%
REM echo tables=(EMP, DEPT) >> %EXP_PARAMETER_FILE_NAME%
echo triggers=y >> %EXP_PARAMETER_FILE_NAME%
echo statistics=none >> %EXP_PARAMETER_FILE_NAME%
echo constraints=y >> %EXP_PARAMETER_FILE_NAME%

echo. >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"
echo   - PERFORM EXPORT. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"

%ORACLE_HOME%\bin\exp parfile=%EXP_PARAMETER_FILE_NAME%

echo. >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"
echo   - DISPLAY EXPORT LOG FILE. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"

type %EXP_DUMP_LOG_FILE_NAME%  >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"
echo   - SCAN LOG FILE FOR ERRORS >> "%LOGFILE%"
echo     IGNORE 'EXP-00079: Data in table "[TABLE_NAME]" is protected. >> "%LOGFILE%"
echo   - APPLY RETENTION POLICY FOR OBSOLETE EXPORT (DUMP) FILES. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"

findstr /i "ORA- EXP-" "%LOGFILE%" | findstr /v "EXP-00079"  >> "%LOGFILE%"
IF errorlevel 1 (set ERRORS="NO") ELSE (set ERRORS="YES")


IF %ERRORS%=="YES" (
    echo. >> "%LOGFILE%"
    echo SETTING ERRORS TO %ERRORS% >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo Detected known exceptions in the export log >> "%LOGFILE%"
    echo file. Retention policy will NOT be enforced. >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
) ELSE (
    echo. >> "%LOGFILE%"
    echo SETTING ERRORS TO %ERRORS% >> "%LOGFILE%"
    echo. >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo Did not detect any known exceptions in the >> "%LOGFILE%"
    echo export log file. Applying retention policy. >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo ============================================================== >> "%LOGFILE%"
    echo   - REMOVE OBSOLETE LOG FILES. >> "%LOGFILE%"
    echo       %LOGDIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.log >> "%LOGFILE%"
    echo ============================================================== >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo List of log files in %LOGDIR% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %LOGDIR% /S /D -%NUM_DAYS_TO_KEEP% /M %SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.log /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo Deleting log files in %LOGDIR% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %LOGDIR% /S /D -%NUM_DAYS_TO_KEEP% /M %SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.log /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo ============================================================== >> "%LOGFILE%"
    echo   - REMOVE OBSOLETE EXPORT DUMP FILES. >> "%LOGFILE%"
    echo       %ORA_EXP_DIR%\%SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.dmp >> "%LOGFILE%"
    echo ============================================================== >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo List of dump files in %ORA_EXP_DIR% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %ORA_EXP_DIR% /S /D -%NUM_DAYS_TO_KEEP% /M %SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.dmp /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo Deleting dump files in %ORA_EXP_DIR% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %ORA_EXP_DIR% /S /D -%NUM_DAYS_TO_KEEP% /M %SCRIPT_NAME_NOEXT%_%TNS_ALIAS%_*.dmp /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"
)


echo. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"
echo   - REMOVE ANY TEMPORARY FILES. >> "%LOGFILE%"
echo ============================================================== >> "%LOGFILE%"

del /q %EXP_PARAMETER_FILE_NAME% >> "%LOGFILE%"
del /q %EXP_DUMP_LOG_FILE_NAME% >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | SET END DATE AND TIME ENVIRONMENT VARIABLES                              |
REM +--------------------------------------------------------------------------+

set END_DATE=%DATE%
set END_TIME=%TIME%

echo.
echo ======================================================
echo   - FINISH TIME : %END_DATE% %END_TIME%
echo ======================================================


echo. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
echo   - FINISH TIME : %END_DATE% %END_TIME% >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"


echo. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
echo   - SEND EMAIL TO ADMINISTRATORS >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

IF %ERRORS%=="YES" (
    set EMAIL_STATUS=[%HOSTNAME%] - FAILED: %SCRIPT_NAME_FULL%
) ELSE (
    set EMAIL_STATUS=[%HOSTNAME%] - SUCCESSFUL: %SCRIPT_NAME_FULL%
)

blat "%LOGFILE%" -subject "%EMAIL_STATUS%" -to %SMTP_EMAIL_TO% -server %SMTP_SERVER% -f %SMTP_EMAIL_FROM%


echo. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
echo   - EXITING SCRIPT >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

echo Making copy of log file [%LOGFILE%] to [%LOGFILE_COPY%] >> "%LOGFILE%"
copy /Y /V %LOGFILE% %LOGFILE_COPY% >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | END THIS SCRIPT                                                          |
REM +--------------------------------------------------------------------------+

goto END


REM +==========================================================================+
REM |                    ***   END OF SCRIPT   ***                             |
REM +==========================================================================+

REM +--------------------------------------------------------------------------+
REM | LABEL DECLARATION SECTION                                                |
REM +--------------------------------------------------------------------------+

:USAGE
echo Usage:    %SCRIPT_NAME_FULL%  "DBA_USERNAME"  "DBA_PASSWORD"  "TNS_ALIAS"  "NUM_DAYS_TO_KEEP"
echo.
echo           DBA_USERNAME     = Oracle DBA Username - (Requires DBA Role)
echo           DBA_PASSWORD     = Oracle DBA Password
echo           TNS_ALIAS        = Connect String to connect to the database (ex. ORCL)
echo           NUM_DAYS_TO_KEEP = Number of days worth of Oracle exports to retain on the file system
goto END

:ENV_VARIABLES
echo ERROR:  You must set the following environment variables before
echo         running this script or manually set them within the script:
echo.
echo           ORA_EXP_DIR    = Directory used for export dump files
goto END

:END
@echo on
