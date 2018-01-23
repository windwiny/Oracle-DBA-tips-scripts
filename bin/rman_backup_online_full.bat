@echo off
REM +--------------------------------------------------------------------------+
REM |                          Jeffrey M. Hunter                               |
REM |                      jhunter@idevelopment.info                           |
REM |                         www.idevelopment.info                            |
REM |--------------------------------------------------------------------------|
REM |    Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
REM |--------------------------------------------------------------------------|
REM | FILE         : rman_backup_online_full.bat                               |
REM | CLASS        : WINDOWS Shell Scripts                                     |
REM | PURPOSE      : Used to perform a physical backup of an Oracle database   |
REM |                using RMAN. This script uses the database control file as |
REM |                the RMAN repository. A command script will be dynamically |
REM |                written to a temporary directory and run through RMAN.    |
REM |                                                                          |
REM | DEPENDENCIES : BLAT.EXE           Command line utility to send the       |
REM |                                   resulting log file to administrators.  |
REM |                FORFILES.EXE       Used to remove obsolete files.         |
REM |                                                                          |
REM | PARAMETERS   : DBA_USERNAME       Database username RMAN will use to log |
REM |                                   in to the database. This user must     |
REM |                                   have the SYSDBA role.                  |
REM |                DBA_PASSWORD       Database password RMAN will use to log |
REM |                                   in to the database.                    |
REM |                TNS_ALIAS          TNS connect string to the target       |
REM |                                   database.                              |
REM | EXAMPLE RUN  :                                                           |
REM |                                                                          |
REM |     rman_backup_online_full.bat backup_admin backup_admin_pwd orcl       |
REM |                                                                          |
REM | NOTE         : As with any code, ensure to test this script in a         |
REM |                development environment before attempting to run it in    |
REM |                production.                                               |
REM +--------------------------------------------------------------------------+

REM +--------------------------------------------------------------------------+
REM | ORGANIZATION VARIABLES                                                   |
REM +--------------------------------------------------------------------------+

SET PRODUCTION_MACHINE_NAME=iDevelopment.info
SET COMPANY_DOMAIN_NAME=idevelopment.info

REM +--------------------------------------------------------------------------+
REM | SCRIPT NAME VARIABLES                                                    |
REM +--------------------------------------------------------------------------+

SET SCRIPTNAME=rman_backup_online_full.bat
SET FILENAME=rman_backup_online_full
SET SCRIPT_VERSION=9.0

REM +--------------------------------------------------------------------------+
REM | EMAIL VARIABLES                                                          |
REM +--------------------------------------------------------------------------+

SET SMTP_SERVER=localhost
SET SMTP_PORT=25
SET SMTP_EMAIL_TO=jhunter@idevelopment.info
SET SMTP_EMAIL_FROM=dba@idevelopment.info

REM +--------------------------------------------------------------------------+
REM | SET START DATE AND TIME ENVIRONMENT VARIABLES                            |
REM +--------------------------------------------------------------------------+

set START_DATE=%DATE%
set START_TIME=%TIME%

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
REM | PARAMETER VARIABLES                                                      |
REM +--------------------------------------------------------------------------+

SET DBA_USERNAME=%1%
SET DBA_PASSWORD=%2%
SET TNS_ALIAS=%3%

REM +--------------------------------------------------------------------------+
REM | ORACLE ENVIRONMENT VARIABLES                                             |
REM +--------------------------------------------------------------------------+

SET ORACLE_SID=%TNS_ALIAS%
SET ORACLE_BASE=C:\oracle
SET ORACLE_HOME=%ORACLE_BASE%\product\11.2.0\dbhome_1
SET ORACLE_HOME_UNC=C$\oracle\product\11.2.0\dbhome_1
SET ORACLE_ADMIN_DIR=%ORACLE_BASE%\admin

REM +--------------------------------------------------------------------------+
REM | CUSTOM DIRECTORIES                                                       |
REM +--------------------------------------------------------------------------+

SET CUSTOM_ORACLE_DIR=%ORACLE_BASE%\dba_scripts
SET ORA_BIN_DIR=%CUSTOM_ORACLE_DIR%\bin
SET ORA_LIB_DIR=%CUSTOM_ORACLE_DIR%\lib
SET ORA_LOG_DIR=%CUSTOM_ORACLE_DIR%\log
SET ORA_OUT_DIR=%CUSTOM_ORACLE_DIR%\out
SET ORA_SQL_DIR=%CUSTOM_ORACLE_DIR%\sql
SET ORA_TMP_DIR=%CUSTOM_ORACLE_DIR%\temp

REM +--------------------------------------------------------------------------+
REM | SCRIPT ENVIRONMENT VARIABLES                                             |
REM +--------------------------------------------------------------------------+

SET FOUND_SCRIPT_EXCEPTIONS=FALSE
SET HOSTNAME=%COMPUTERNAME%

SET LOGFILE=%ORA_LOG_DIR%\%FILENAME%_%ORACLE_SID%_%FILEDATE%_%FILETIME%.log
SET LOGFILE_COPY=%ORA_LOG_DIR%\%FILENAME%_%ORACLE_SID%.log

SET RMAN_CMDFILE=%ORA_TMP_DIR%\%FILENAME%_%ORACLE_SID%.rcv
SET RMAN_LOGFILE=%ORA_LOG_DIR%\%FILENAME%_%ORACLE_SID%.rman

SET HIDE_PASSWORD_STRING=xxxxxxxxxxxxx

SET RMAN_ARCHIVE_LOG_RETENTION_DAYS=2

SET NUM_LOG_DAYS_TO_KEEP=60


REM +==========================================================================+
REM |                                                                          |
REM |                 S C R I P T   S T A R T S   H E R E                      |
REM |                                                                          |
REM +==========================================================================+

echo.
echo -----------------------------------------------------------------------------------
echo START SCRIPT
echo -----------------------------------------------------------------------------------
echo Log File          : %LOGFILE%
echo End Date          : %START_DATE%
echo End Time          : %START_TIME%
echo -----------------------------------------------------------------------------------
echo.

echo.                                                                                      >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo START SCRIPT                                                                          >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo Log File          : %LOGFILE%     >> "%LOGFILE%"
echo End Date          : %START_DATE%  >> "%LOGFILE%"
echo End Time          : %START_TIME%  >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo.                                                                                      >> "%LOGFILE%"

echo.                                                                 >> "%LOGFILE%"
echo %FILENAME% - Version %SCRIPT_VERSION%                            >> "%LOGFILE%"
echo Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.  >> "%LOGFILE%"
echo.                                                                 >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | Write header information to the log file.                                |
REM +--------------------------------------------------------------------------+

echo.                                                                                      >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo                              COMMON SCRIPT VARIABLES                                  >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo Script Name                        : %SCRIPTNAME%                                     >> "%LOGFILE%"
echo Script Version                     : %SCRIPT_VERSION%                                 >> "%LOGFILE%"
echo Begin Date                         : %START_DATE%                                     >> "%LOGFILE%"
echo Begin Time                         : %START_TIME%                                     >> "%LOGFILE%"
echo Host Name                          : %HOSTNAME%                                       >> "%LOGFILE%"
echo Log File Name                      : %LOGFILE%        >> "%LOGFILE%"
echo Log File Name (Copy)               : %LOGFILE_COPY%   >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo                              CUSTOM SCRIPT VARIABLES                                  >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo DBA_USERNAME      (P1)             : %DBA_USERNAME%                                   >> "%LOGFILE%"
echo DBA_PASSWORD      (P2)             : %HIDE_PASSWORD_STRING%                           >> "%LOGFILE%"
echo TNS_ALIAS         (P3)             : %TNS_ALIAS%                                      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Remove all temporary files.                                   >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

del /q /f %RMAN_CMDFILE%
del /q /f %RMAN_LOGFILE%

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Write RMAN command script.                                    >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

echo run {                                                                     > %RMAN_CMDFILE%
echo     allocate channel c1 type disk;                                       >> %RMAN_CMDFILE%
echo         report schema;                                                   >> %RMAN_CMDFILE%
echo     release channel c1;                                                  >> %RMAN_CMDFILE%
echo }                                                                        >> %RMAN_CMDFILE%

echo     allocate channel for maintenance device type disk;                   >> %RMAN_CMDFILE%
echo         crosscheck backup of database;                                   >> %RMAN_CMDFILE%
echo         crosscheck backup of archivelog all;                             >> %RMAN_CMDFILE%
echo         crosscheck backup of controlfile;                                >> %RMAN_CMDFILE%
echo         crosscheck backup of spfile;                                     >> %RMAN_CMDFILE%
echo         crosscheck archivelog all;                                       >> %RMAN_CMDFILE%
echo         delete noprompt force expired backup;                            >> %RMAN_CMDFILE%
echo         delete noprompt force expired archivelog all;                    >> %RMAN_CMDFILE%
echo         delete noprompt force expired copy;                              >> %RMAN_CMDFILE%
echo         delete noprompt force obsolete;                                  >> %RMAN_CMDFILE%
echo     release channel;                                                     >> %RMAN_CMDFILE%

REM echo     allocate channel for maintenance device type disk;               >> %RMAN_CMDFILE%
REM echo         delete noprompt force backup;                                >> %RMAN_CMDFILE%
REM echo         delete noprompt force copy;                                  >> %RMAN_CMDFILE%
REM echo     release channel;                                                 >> %RMAN_CMDFILE%

echo run {                                                                    >> %RMAN_CMDFILE%
echo     allocate channel c1 type disk maxpiecesize=2g;                       >> %RMAN_CMDFILE%
echo         backup as backupset database;                                    >> %RMAN_CMDFILE%
echo         sql 'alter system switch logfile';                               >> %RMAN_CMDFILE%
echo         backup as backupset archivelog all not backed up delete input;   >> %RMAN_CMDFILE%
REM echo     backup as backupset archivelog all not backed up;                >> %RMAN_CMDFILE%
REM echo     delete noprompt force archivelog all completed before 'sysdate-%RMAN_ARCHIVE_LOG_RETENTION_DAYS%';  >> %RMAN_CMDFILE%
echo         backup current controlfile;                                      >> %RMAN_CMDFILE%
echo         backup spfile;                                                   >> %RMAN_CMDFILE%
echo     release channel c1;                                                  >> %RMAN_CMDFILE%
echo }                                                                        >> %RMAN_CMDFILE%
    
REM echo run {                                                                >> %RMAN_CMDFILE%
REM echo     allocate channel c1 type disk;                                   >> %RMAN_CMDFILE%
REM echo         delete noprompt force obsolete;                              >> %RMAN_CMDFILE%
REM echo     release channel c1;                                              >> %RMAN_CMDFILE%
REM echo }                                                                    >> %RMAN_CMDFILE%
    
echo run {                                                                    >> %RMAN_CMDFILE%
echo     report need backup;                                                  >> %RMAN_CMDFILE%
echo     report unrecoverable;                                                >> %RMAN_CMDFILE%
echo }                                                                        >> %RMAN_CMDFILE%

echo exit;                                                                    >> %RMAN_CMDFILE%

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Perform RMAN Backup.                                          >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

rman target %DB_USERNAME%/%DB_PASSWORD%@%TNS_ALIAS% nocatalog cmdfile=%RMAN_CMDFILE% msglog %RMAN_LOGFILE% 

type %RMAN_LOGFILE% >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Remove all temporary files.                                   >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

del /q /f %RMAN_CMDFILE%
del /q /f %RMAN_LOGFILE%

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"



REM +==========================================================================+
REM |                                                                          |
REM |                   S C R I P T   E N D S   H E R E                        |
REM |                                                                          |
REM +==========================================================================+

echo.                                                                   >> "%LOGFILE%"
echo ------------------------------------------------------------------ >> "%LOGFILE%"
echo Remove obsolete log files older than %NUM_LOG_DAYS_TO_KEEP% days.  >> "%LOGFILE%"
echo ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                   >> "%LOGFILE%"

echo List of log files in %ORA_LOG_DIR% older than %NUM_LOG_DAYS_TO_KEEP% days... >> "%LOGFILE%"
forfiles /P %ORA_LOG_DIR% /S /D -%NUM_LOG_DAYS_TO_KEEP% /M %FILENAME%_%ORACLE_SID%*.log /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"

echo Deleting log files in %ORA_LOG_DIR% older than %NUM_LOG_DAYS_TO_KEEP% days... >> "%LOGFILE%"
forfiles /P %ORA_LOG_DIR% /S /D -%NUM_LOG_DAYS_TO_KEEP% /M %FILENAME%_%ORACLE_SID%*.log /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.
echo -----------------------------------------------------------------------------------
echo END SCRIPT
echo -----------------------------------------------------------------------------------
echo Log File          : %LOGFILE%
echo End Date          : %DATE%
echo End Time          : %TIME%
echo -----------------------------------------------------------------------------------
echo.

echo.                                                                                      >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo END SCRIPT                                                                            >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo Log File          : %LOGFILE%  >> "%LOGFILE%"
echo End Date          : %DATE%     >> "%LOGFILE%"
echo End Time          : %TIME%     >> "%LOGFILE%"
echo -----------------------------------------------------------------------------------   >> "%LOGFILE%"
echo.                                                                                      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Making copy of log file:                                      >> "%LOGFILE%"
echo    [%LOGFILE%]                                                >> "%LOGFILE%"
echo to                                                            >> "%LOGFILE%"
echo    [%LOGFILE_COPY%]                                           >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

copy /Y /V %LOGFILE% %LOGFILE_COPY% >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Scan the logfile for exceptions.                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

findstr /i "ORA-" "%LOGFILE%" | findstr /v "ORA-27056"
if errorlevel 1 (SET FOUND_SCRIPT_EXCEPTIONS=FALSE) else (SET FOUND_SCRIPT_EXCEPTIONS=TRUE)

echo.                                                  >> "%LOGFILE%"
echo FOUND_SCRIPT_EXCEPTIONS=%FOUND_SCRIPT_EXCEPTIONS% >> "%LOGFILE%"
echo.                                                  >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Send email.                                                   >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

REM --
REM -- Determine if you want to send email for successful completions.
REM --
REM if /i %FOUND_SCRIPT_EXCEPTIONS% equ FALSE (goto DONE_SEND_EMAIL)

:DO_SEND_EMAIL

echo.                                                                   >> "%LOGFILE%"
echo ------------------------------------------------------------------ >> "%LOGFILE%"
echo LABEL: [  DO_SEND_EMAIL  ]                                         >> "%LOGFILE%"
echo ------------------------------------------------------------------ >> "%LOGFILE%"
echo.                                                                   >> "%LOGFILE%"

if /i %FOUND_SCRIPT_EXCEPTIONS% equ TRUE (SET EMAIL_STATUS=[%HOSTNAME%] - FAILED: %SCRIPTNAME%) else (SET EMAIL_STATUS=[%HOSTNAME%] - SUCCESSFUL: %SCRIPTNAME%)

blat "%LOGFILE%" -subject "%EMAIL_STATUS%" -to %SMTP_EMAIL_TO% -server %SMTP_SERVER% -f %SMTP_EMAIL_FROM%

:DONE_SEND_EMAIL

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


REM +--------------------------------------------------------------------------+
REM | End this script.                                                         |
REM +--------------------------------------------------------------------------+

goto END


REM +--------------------------------------------------------------------------+
REM | ERROR LABELS.                                                            |
REM +--------------------------------------------------------------------------+

:PARAMETER_ERROR

echo.
echo Invalid parameters.
echo.
echo Usage:  %SCRIPTNAME%  DBA_USERNAME  DBA_PASSWORD  TNS_ALIAS
echo.
echo Please enter the following parameters:
echo.
echo           DBA_USERNAME   = Oracle DBA Username - (Requires SYSDBA Role)
echo           DBA_PASSWORD   = Oracle DBA Password
echo           TNS_ALIAS      = Connect String to connect to the database (ex. ORCL)
goto END


REM +--------------------------------------------------------------------------+
REM | END OF SCRIPT.                                                           |
REM +--------------------------------------------------------------------------+

:END
@echo on
