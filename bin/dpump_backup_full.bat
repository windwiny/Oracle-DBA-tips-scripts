@echo off
REM +--------------------------------------------------------------------------+
REM |                          Jeffrey M. Hunter                               |
REM |                      jhunter@idevelopment.info                           |
REM |                         www.idevelopment.info                            |
REM |--------------------------------------------------------------------------|
REM |    Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
REM |--------------------------------------------------------------------------|
REM | FILE         : dpump_backup_full.bat                                     |
REM | CLASS        : WINDOWS Shell Scripts                                     |
REM | PURPOSE      : Used to perform a logical backup of an Oracle database    |
REM |                using the Data Pump utility. Note that Data Pump was      |
REM |                first introduced in Oracle 10g which means this script    |
REM |                will only work with Oracle Database 10g or higher. By     |
REM |                default, this script performs a full and consistent       |
REM |                backup of the database using a dynamically created        |
REM |                parameter file that gets written to a temporary directory |
REM |                and run through Oracle Data Pump using the "parfile"      |
REM |                parameter.                                                |
REM |                                                                          |
REM | DEPENDENCIES : BLAT.EXE           Command line utility to send the       |
REM |                                   resulting log file to administrators.  |
REM |                FORFILES.EXE       Used to remove obsolete files.         |
REM |                                                                          |
REM |                --------------------------------------------              |
REM |                NEW DATA PUMP UTILITY IN ORACLE DATABASE 10g              |
REM |                --------------------------------------------              |
REM |                Oracle Database 10g users (and higher) should consider    |
REM |                using the new Data Pump utility in place of the original  |
REM |                Oracle import/export. The original export utility was     |
REM |                deprecated in Oracle Database 10g Release 2, and is no    |
REM |                longer supported for general use as of Oracle Database    |
REM |                11g. Going forward, Data Pump export (expdp) will be the  |
REM |                sole supported means of exporting data from the database. |
REM |                The original import utility (imp) still ships with Oracle |
REM |                Database 10g and Oracle Database 11g in order to support  |
REM |                import of legacy dump files. The original import utility  |
REM |                will be supported forever and will provide the means to   |
REM |                import dump files from earlier releases (release 5.0 and  |
REM |                later) that were created with the original export (exp).  |
REM |                Please note that the original export dump files and the   |
REM |                new Data Pump dump files are "not" compatible. You cannot |
REM |                read an original Oracle export dump file with Data Pump   |
REM |                and vice versa. Neither client can read dump files        |
REM |                created by the other.                                     |
REM |                                                                          |
REM |                --------------------------------------------              |
REM |                KNOWN ISSUES                                              |
REM |                --------------------------------------------              |
REM |                1.) Oracle Database 10g users (version 10.1.0.0 to        |
REM |                    10.2.0.4) may experience the following error when     |
REM |                    attempting to export XML Schemas or XML Schema-based  |
REM |                    columns:                                              |
REM |                                                                          |
REM |                    ORA-39139: Data Pump does not support XMLSchema objects
REM |                                                                          |
REM |                    As documented in Oracle Note: 443373.1, Data Pump     |
REM |                    does not support exporting XML Schemas or XML         |
REM |                    Schema-based columns. The only workaround documented  |
REM |                    for this issue is to use the original export and      |
REM |                    import utilities for the XML objects.                 |
REM |                                                                          |
REM |                2.) Export fails with the following "insufficient         |
REM |                    privileges" errors:                                   |
REM |                                                                          |
REM |                    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/STATISTICS/TABLE_STATISTICS
REM |                    ORA-39127: unexpected error from call to local_str := <...>
REM |                    ORA-01031: insufficient privileges
REM |                    ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 257
REM |                    ORA-06512: at line 1
REM |                    ORA-06512: at "SYS.DBMS_METADATA", line 4770
REM |                    ORA-39127: unexpected error from call to local_str := <...>
REM |                    ORA-01031: insufficient privileges
REM |                    ORA-06512: at "SYS.DBMS_EXPORT_EXTENSION", line 257
REM |                    ORA-06512: at line 1
REM |                    ORA-06512: at "SYS.DBMS_METADATA", line 4770
REM |                    Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/DOMAIN_INDEX/INDEX
REM |                                                                          |
REM |                    This occurs because the user account performing the   |
REM |                    export lacks the "SELECT ANY TABLE" privilege. Grant  |
REM |                    the "SELECT ANY TABLE" privilege to the user          |
REM |                    performing the export.                                |
REM |                                                                          |
REM |                3.) When using Oracle Label Security policies, the user   |
REM |                    should have EXEMPT ACCESS POLICY in order to export   |
REM |                    all rows in the table, or else no rows are exported.  |
REM |                                                                          |
REM |                    The Data Pump / Export utility functions in the       |
REM |                    standard way under Oracle Label Security. There are,  |
REM |                    however, a few differences resulting from the         |
REM |                    enforcement of Oracle Label Security policies.        |
REM |                                                                          |
REM |                      a.) For any tables protected by an Oracle Label     |
REM |                          Security policy, only rows with labels          |
REM |                          authorized for read access will be exported.    |
REM |                          Unauthorized rows will not be included in the   |
REM |                          export file. Consequently, to export all the    |
REM |                          data in protected tables, you must have a       |
REM |                          privilege (such as FULL or READ) that gives you |
REM |                          complete access.                                |
REM |                                                                          |
REM |                      b.) SQL statements to reapply policies are exported |
REM |                          along with tables and schemas that are exported.|
REM |                          These statements are carried out during import  |
REM |                          to reapply policies with the same enforcement   |
REM |                          options as in the original database.            |
REM |                                                                          |
REM |                      c.) The HIDE property is not exported. When         |
REM |                          protected tables are exported, the label        |
REM |                          columns in those tables are also exported (as   |
REM |                          numeric values). However, if a label column is  |
REM |                          hidden, then it is exported as a normal,        |
REM |                          unhidden column.                                |
REM |                                                                          |
REM |                     d.) The LBACSYS schema cannot be exported due to the |
REM |                         use of opaque types in Oracle Label Security. An |
REM |                         export of the entire database (parameter FULL=Y) |
REM |                         with Oracle Label Security installed can be done,|
REM |                         except that the LBACSYS schema would not be      |
REM |                         exported.                                        |
REM |                                                                          |
REM | PARAMETERS   : DBA_USERNAME       Database username Data Pump will use   |
REM |                                   to log in to the database. This user   |
REM |                                   must be a DBA, or must have the        |
REM |                                   EXP_FULL_DATABASE or IMP_FULL_DATABASE |
REM |                                   roles in order to attach and control   |
REM |                                   Data Pump jobs of other users. The     |
REM |                                   user running Data Pump must have       |
REM |                                   sufficient tablespace quota to create  |
REM |                                   the master table. A common username    |
REM |                                   for performing Oracle backups is       |
REM |                                   BACKUP_ADMIN.                          |
REM |                                                                          |
REM |                DBA_PASSWORD       Database password Data Pump will use   |
REM |                                   to log in to the database.             |
REM |                                                                          |
REM |                TNS_ALIAS          TNS connect string to the target       |
REM |                                   database.                              |
REM |                                                                          |
REM |                DPUMP_DUMP_DIR     Oracle "Directory Name" used by Data   |
REM |                                   Pump to write the dump file(s) to on   |
REM |                                   the database server. Note that this    |
REM |                                   parameter should not be set to the     |
REM |                                   "absolute file path" on the database   |
REM |                                   server but however an Oracle Directory |
REM |                                   Name. Directory names are actual named |
REM |                                   objects in Oracle that Data Pump uses  |
REM |                                   to map to a specific operating system  |
REM |                                   directory. For example:                |
REM |                                                                          |
REM |                                     CREATE OR REPLACE DIRECTORY dpump_dump_dir AS 'C:\oracle\oradpump\orcl';
REM |                                                                          |
REM |                                   Creating an Oracle directory object    |
REM |                                   requires that the user have the DBA    |
REM |                                   role or have the CREATE ANY DIRECTORY  |
REM |                                   system privilege. Also verify that the |
REM |                                   Oracle user performing the logical     |
REM |                                   backup (DBA_USERNAME) has write        |
REM |                                   privileges to the directory object:    |
REM |                                                                          |
REM |                                     GRANT read, write ON DIRECTORY dpump_dump_dir TO BACKUP_ADMIN;
REM |                                                                          |
REM |                DPUMP_LOG_DIR      Oracle "Directory Name" used by Data   |
REM |                                   Pump to write the log file to on the   |
REM |                                   database server. As with the           |
REM |                                   DPUMP_DUMP_DIR parameter (above), this |
REM |                                   parameter should not be set to the     |
REM |                                   "absolute file path" on the database   |
REM |                                   server but however an Oracle Directory |
REM |                                   Name. For example:                     |
REM |                                                                          |
REM |                                     CREATE OR REPLACE DIRECTORY dpump_log_dir AS 'C:\Oracle\dba_scripts\log';
REM |                                                                          |
REM |                                   Verify that the Oracle user performing |
REM |                                   the logical backup (DBA_USERNAME) has  |
REM |                                   write privileges to the directory      |
REM |                                   object:                                |
REM |                                                                          |
REM |                                     GRANT read, write ON DIRECTORY dpump_log_dir TO BACKUP_ADMIN;
REM |                                                                          |
REM |                NUM_DAYS_TO_KEEP   Number of days worth of Data Pump dump |
REM |                                   files to retain on the file system.    |
REM |                                                                          |
REM | EXAMPLE RUN  :                                                           |
REM |                                                                          |
REM |     dpump_backup_full.bat backup_admin backup_admin_pwd orcl dpump_dump_dir dpump_log_dir 2
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

SET SCRIPTNAME=dpump_backup_full.bat
SET FILENAME=dpump_backup_full
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
if (%4)==() goto PARAMETER_ERROR
if (%5)==() goto PARAMETER_ERROR
if (%6)==() goto PARAMETER_ERROR

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
SET DPUMP_DUMP_DIR=%4%
SET DPUMP_LOG_DIR=%5%
SET NUM_DAYS_TO_KEEP=%6%

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

SET TEMP_SQLFILE=%ORA_TMP_DIR%\%FILENAME%_%ORACLE_SID%.sql
SET TEMP_BATFILE=%ORA_TMP_DIR%\%FILENAME%_%ORACLE_SID%.bat

SET HIDE_PASSWORD_STRING=xxxxxxxxxxxxx

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


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Verify "DUMP" directory object: %DPUMP_DUMP_DIR%.             >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

echo set pagesize 0 feedback off verify off heading off trimspool on echo off > %TEMP_SQLFILE%
echo SPOOL %TEMP_BATFILE%  >> %TEMP_SQLFILE%
echo SELECT 'SET DPUMP_DUMP_DIR_PATH='^|^| directory_path FROM dba_directories >> %TEMP_SQLFILE%
echo WHERE UPPER(directory_name) = UPPER('%DPUMP_DUMP_DIR%'); >> %TEMP_SQLFILE%
echo spool off  >> %TEMP_SQLFILE%
echo exit; >> %TEMP_SQLFILE%

%ORACLE_HOME%\bin\sqlplus -S "%DBA_USERNAME%/%DBA_PASSWORD%@%TNS_ALIAS% as sysdba" @%TEMP_SQLFILE%

findstr /i "SET DPUMP_DUMP_DIR_PATH" "%TEMP_BATFILE%" >> "%LOGFILE%"
IF errorlevel 1 (SET FOUND="NO") ELSE (SET FOUND="YES")

IF %FOUND%=="YES" (
    call %TEMP_BATFILE%
) ELSE (
    goto ERROR_DPUMP_DUMP_DIR
)

echo. >> "%LOGFILE%"
echo Oracle Directory "%DPUMP_DUMP_DIR%" maps to "%DPUMP_DUMP_DIR_PATH%" >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Verify "LOG" directory object: %DPUMP_LOG_DIR%.               >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

echo set pagesize 0 feedback off verify off heading off trimspool on echo off > %TEMP_SQLFILE%
echo SPOOL %TEMP_BATFILE%  >> %TEMP_SQLFILE%
echo SELECT 'SET DPUMP_LOG_DIR_PATH='^|^| directory_path FROM dba_directories >> %TEMP_SQLFILE%
echo WHERE UPPER(directory_name) = UPPER('%DPUMP_LOG_DIR%'); >> %TEMP_SQLFILE%
echo spool off  >> %TEMP_SQLFILE%
echo exit; >> %TEMP_SQLFILE%

%ORACLE_HOME%\bin\sqlplus -S "%DBA_USERNAME%/%DBA_PASSWORD%@%TNS_ALIAS% as sysdba" @%TEMP_SQLFILE%

findstr /i "SET DPUMP_LOG_DIR_PATH" "%TEMP_BATFILE%" >> "%LOGFILE%"
IF errorlevel 1 (SET FOUND="NO") ELSE (SET FOUND="YES")

IF %FOUND%=="YES" (
    call %TEMP_BATFILE%
) ELSE (
    goto ERROR_DPUMP_LOG_DIR
)

echo. >> "%LOGFILE%"
echo Oracle Directory "%DPUMP_LOG_DIR%" maps to "%DPUMP_LOG_DIR_PATH%" >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Set DPUMP_FLASHBACK_TIME.                                     >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

echo set pagesize 0 feedback off verify off heading off trimspool on echo off > %TEMP_SQLFILE%
echo SPOOL %TEMP_BATFILE%  >> %TEMP_SQLFILE%
echo SELECT 'SET DPUMP_FLASHBACK_TIME='^|^| TO_CHAR(sysdate,'DD-MON-YYYY HH24:MM:SS') FROM dual; >> %TEMP_SQLFILE%
echo SELECT 'SET DPUMP_FLASHBACK_SCN='^|^| DBMS_FLASHBACK.GET_SYSTEM_CHANGE_NUMBER FROM dual; >> %TEMP_SQLFILE%
echo spool off  >> %TEMP_SQLFILE%
echo exit; >> %TEMP_SQLFILE%

%ORACLE_HOME%\bin\sqlplus -S "%DBA_USERNAME%/%DBA_PASSWORD%@%TNS_ALIAS% as sysdba" @%TEMP_SQLFILE%

call %TEMP_BATFILE%

echo. >> "%LOGFILE%"
echo Oracle Data Pump Flashback Time is "%DPUMP_FLASHBACK_TIME%" >> "%LOGFILE%"
echo Oracle Data Pump Flashback SCN is "%DPUMP_FLASHBACK_SCN%" >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Set further environment variables.                            >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

SET DPUMP_DATE_LOG=%FILEDATE%_%FILETIME%
SET DPUMP_DUMP_FILE_NAME=%DPUMP_DUMP_DIR%:%FILENAME%_%ORACLE_SID%_%DPUMP_DATE_LOG%.dmp
SET DPUMP_LOG_FILE_NAME=%DPUMP_LOG_DIR%:%FILENAME%_%ORACLE_SID%_%DPUMP_DATE_LOG%_DPUMPLOG.log
SET DPUMP_LOG_FILE_LOCATION=%DPUMP_LOG_DIR_PATH%\%FILENAME%_%ORACLE_SID%_%DPUMP_DATE_LOG%_DPUMPLOG.log
SET DPUMP_PARFILE_FILE_NAME=%ORA_TMP_DIR%\%FILENAME%_%ORACLE_SID%_%DPUMP_DATE_LOG%.parfile

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


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
echo DPUMP_DUMP_DIR    (P4)             : %DPUMP_DUMP_DIR%                                 >> "%LOGFILE%"
echo DPUMP_LOG_DIR     (P5)             : %DPUMP_LOG_DIR%                                  >> "%LOGFILE%"
echo NUM_DAYS_TO_KEEP  (P6)             : %NUM_DAYS_TO_KEEP%                               >> "%LOGFILE%"
echo DPUMP_DUMP_FILE_NAME               : %DPUMP_DUMP_FILE_NAME%                           >> "%LOGFILE%"
echo DPUMP_DUMP_DIR_PATH                : %DPUMP_DUMP_DIR_PATH%                            >> "%LOGFILE%"
echo DPUMP_LOG_FILE_NAME                : %DPUMP_LOG_FILE_NAME%                            >> "%LOGFILE%"
echo DPUMP_LOG_DIR_PATH                 : %DPUMP_LOG_DIR_PATH%                             >> "%LOGFILE%"
echo DPUMP_LOG_FILE_LOCATION            : %DPUMP_LOG_FILE_LOCATION%                        >> "%LOGFILE%"
echo DPUMP_PARFILE_FILE_NAME            : %DPUMP_PARFILE_FILE_NAME%                        >> "%LOGFILE%"
echo DPUMP_FLASHBACK_TIME               : %DPUMP_FLASHBACK_TIME% - (Consistent Export)     >> "%LOGFILE%"
echo DPUMP_FLASHBACK_SCN                : %DPUMP_FLASHBACK_SCN% - (Consistent Export)      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Write Data Pump export parameter file.                        >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

echo USERID=%DBA_USERNAME%/%DBA_PASSWORD%@%TNS_ALIAS% > %DPUMP_PARFILE_FILE_NAME%
echo DUMPFILE=%DPUMP_DUMP_FILE_NAME% >> %DPUMP_PARFILE_FILE_NAME%
echo LOGFILE=%DPUMP_LOG_FILE_NAME% >> %DPUMP_PARFILE_FILE_NAME%
echo CONTENT=all >> %DPUMP_PARFILE_FILE_NAME%
echo EXCLUDE=TABLE:"IN ('SCHEDULER$_JOB_ARG')" >> %DPUMP_PARFILE_FILE_NAME%
REM echo FLASHBACK_TIME="TO_TIMESTAMP('%DPUMP_FLASHBACK_TIME%', 'DD-MON-YYYY HH24:MI:SS')" >> %DPUMP_PARFILE_FILE_NAME%
echo FLASHBACK_SCN=%DPUMP_FLASHBACK_SCN% >> %DPUMP_PARFILE_FILE_NAME%
echo FULL=y >> %DPUMP_PARFILE_FILE_NAME%

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Perform Data Pump export.                                     >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

%ORACLE_HOME%\bin\expdp parfile=%DPUMP_PARFILE_FILE_NAME% >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Display Data Pump export log file.                            >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

type %DPUMP_LOG_FILE_LOCATION%  >> "%LOGFILE%"


echo.                                                              >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo Remove all temporary files.                                   >> "%LOGFILE%"
echo ------------------------------------------------------------- >> "%LOGFILE%"
echo.                                                              >> "%LOGFILE%"

del /q /f %DPUMP_LOG_FILE_LOCATION%   >> "%LOGFILE%"
del /q /f %DPUMP_PARFILE_FILE_NAME%   >> "%LOGFILE%"
del /q /f %TEMP_SQLFILE%              >> "%LOGFILE%"
del /q /f %TEMP_BATFILE%              >> "%LOGFILE%"

echo.      >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo Done. >> "%LOGFILE%"
echo ----- >> "%LOGFILE%"
echo.      >> "%LOGFILE%"


echo.                                                                      >> "%LOGFILE%"
echo -------------------------------------------------------------         >> "%LOGFILE%"
echo Enforce Data Pump export retention policy.                            >> "%LOGFILE%"
echo   - Scan log file for exceptions.                                     >> "%LOGFILE%"
echo   - Ignore 'ORA 39139: Data Pump does not support XMLSchema objects'  >> "%LOGFILE%"
echo   - Apply retention policy for obsolete export (dump) files.          >> "%LOGFILE%"
echo -------------------------------------------------------------         >> "%LOGFILE%"
echo.                                                                      >> "%LOGFILE%"

findstr /i "ORA-" "%LOGFILE%" | findstr /v "ORA-39050: ORA-39139: Data Pump does not support XMLSchema objects"  >> "%LOGFILE%"
if errorlevel 1 (SET FOUND_SCRIPT_EXCEPTIONS=FALSE) else (SET FOUND_SCRIPT_EXCEPTIONS=TRUE)

echo.                                                  >> "%LOGFILE%"
echo FOUND_SCRIPT_EXCEPTIONS=%FOUND_SCRIPT_EXCEPTIONS% >> "%LOGFILE%"
echo.                                                  >> "%LOGFILE%"

if /i %FOUND_SCRIPT_EXCEPTIONS% equ TRUE (

    echo.                                                 >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo Detected known exceptions in the export log      >> "%LOGFILE%"
    echo file. Retention policy will NOT be enforced.     >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo.                                                 >> "%LOGFILE%"

) else (

    echo.                                                 >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo Did not detect any known exceptions in the       >> "%LOGFILE%"
    echo export log file. Applying retention policy.      >> "%LOGFILE%"
    echo -----------------------------------------------  >> "%LOGFILE%"
    echo.                                                 >> "%LOGFILE%"

    echo.                                                               >> "%LOGFILE%"
    echo -----------------------------------------------                >> "%LOGFILE%"
    echo Removing obsolete data pump dump files:                        >> "%LOGFILE%"
    echo   %DPUMP_DUMP_DIR_PATH%\%FILENAME%_%ORACLE_SID%_*.dmp          >> "%LOGFILE%"
    echo -----------------------------------------------                >> "%LOGFILE%"
    echo.                                                               >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo List of dump files in %DPUMP_DUMP_DIR_PATH% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %DPUMP_DUMP_DIR_PATH% /S /D -%NUM_DAYS_TO_KEEP% /M %FILENAME%_%ORACLE_SID%_*.dmp /C "CMD /C Echo @FILE will be deleted!" >> "%LOGFILE%"

    echo. >> "%LOGFILE%"
    echo Deleting dump files in %DPUMP_DUMP_DIR_PATH% older than %NUM_DAYS_TO_KEEP% days... >> "%LOGFILE%"
    forfiles /P %DPUMP_DUMP_DIR_PATH% /S /D -%NUM_DAYS_TO_KEEP% /M %FILENAME%_%ORACLE_SID%_*.dmp /C "CMD /C del /Q /F @FILE" >> "%LOGFILE%"
)



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

findstr /i "ORA-" "%LOGFILE%" | findstr /v "ORA-39050: ORA-39139: ORA-39181:"  >> "%LOGFILE%"
if errorlevel 1 (SET FOUND_SCRIPT_EXCEPTIONS=FALSE) else (SET FOUND_SCRIPT_EXCEPTIONS=TRUE)

echo.                                                  >> "%LOGFILE%"
echo FOUND_SCRIPT_EXCEPTIONS=%FOUND_SCRIPT_EXCEPTIONS% >> "%LOGFILE%"
echo.                                                  >> "%LOGFILE%"


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
echo Usage:  %SCRIPTNAME%  DBA_USERNAME  DBA_PASSWORD  TNS_ALIAS   DPUMP_DUMP_DIR   DPUMP_LOG_DIR   NUM_DAYS_TO_KEEP
echo.
echo Please enter the following parameters:
echo.
echo           DBA_USERNAME     = Oracle DBA Username
echo           DBA_PASSWORD     = Oracle DBA Password
echo           TNS_ALIAS        = Connect String to connect to the database (ex. ORCL)
echo           DPUMP_DUMP_DIR   = Oracle "Directory Name" used by Data Pump to 
echo                              write the dump file(s) to on the database server.
echo           DPUMP_LOG_DIR    = Oracle "Directory Name" used by Data Pump to 
echo                              write the log file to on the database server.
echo           NUM_DAYS_TO_KEEP = Number of days worth of Oracle Data Pump exports 
echo                              to retain on the file system
goto END


:ERROR_DPUMP_DUMP_DIR
echo.                                                                                     >> "%LOGFILE%"
echo CRITICAL ERROR: Could not find %DPUMP_DUMP_DIR% (DPUMP_DUMP_DIR) in DBA_DIRECTORIES  >> "%LOGFILE%"
echo.                                                                                     >> "%LOGFILE%"
echo USAGE:                                                                               >> "%LOGFILE%"
echo %SCRIPT_NAME_FULL%  "DBA_USERNAME"  "DBA_PASSWORD"  "TNS_ALIAS"  "DPUMP_DUMP_DIR"  "DPUMP_LOG_DIR"  "NUM_DAYS_TO_KEEP" >> "%LOGFILE%"
SET END_DATE=%DATE%
SET END_TIME=%TIME%
echo.                                                                                     >> "%LOGFILE%"
echo ======================================================                               >> "%LOGFILE%"
echo   - FINISH TIME : %END_DATE% %END_TIME%                                              >> "%LOGFILE%"
echo ======================================================                               >> "%LOGFILE%"
SET EMAIL_STATUS=[%HOSTNAME%] - FAILED: %SCRIPT_NAME_FULL%
blat "%LOGFILE%" -subject "%EMAIL_STATUS%" -to %SMTP_EMAIL_TO% -server %SMTP_SERVER% -f %SMTP_EMAIL_FROM%
goto END


:ERROR_DPUMP_LOG_DIR
echo.                                                                                     >> "%LOGFILE%"
echo CRITICAL ERROR: Could not find %DPUMP_LOG_DIR% (DPUMP_LOG_DIR) in DBA_DIRECTORIES    >> "%LOGFILE%"
echo.                                                                                     >> "%LOGFILE%"
echo USAGE:                                                                               >> "%LOGFILE%"
echo %SCRIPT_NAME_FULL%  "DBA_USERNAME"  "DBA_PASSWORD"  "TNS_ALIAS"  "DPUMP_DUMP_DIR"  "DPUMP_LOG_DIR"  "NUM_DAYS_TO_KEEP" >> "%LOGFILE%"
SET END_DATE=%DATE%
SET END_TIME=%TIME%
echo. >> "%LOGFILE%"
echo ======================================================                               >> "%LOGFILE%"
echo   - FINISH TIME : %END_DATE% %END_TIME%                                              >> "%LOGFILE%"
echo ======================================================                               >> "%LOGFILE%"
SET EMAIL_STATUS=[%HOSTNAME%] - FAILED: %SCRIPT_NAME_FULL%
blat "%LOGFILE%" -subject "%EMAIL_STATUS%" -to %SMTP_EMAIL_TO% -server %SMTP_SERVER% -f %SMTP_EMAIL_FROM%
goto END


REM +--------------------------------------------------------------------------+
REM | END OF SCRIPT.                                                           |
REM +--------------------------------------------------------------------------+

:END
@echo on
