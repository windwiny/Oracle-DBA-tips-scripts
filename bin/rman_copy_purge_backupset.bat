@echo off
REM +--------------------------------------------------------------------------+
REM |                          Jeffrey M. Hunter                               |
REM |                      jhunter@idevelopment.info                           |
REM |                         www.idevelopment.info                            |
REM |--------------------------------------------------------------------------|
REM |    Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
REM |--------------------------------------------------------------------------|
REM | FILE       : rman_copy_purge_backupset.bat                               |
REM | CLASS      : WINDOWS Shell Scripts                                       |
REM | PURPOSE    : Used to copy a set or RMAN backupsets from one directory    |
REM |              location (the source) to another directory location (the    |
REM |              destination). After the copy is performed, the destination  |
REM |              directory will be purged by the amount of days passed in    |
REM |              as a parameter to this script.                              |
REM |                                                                          |
REM | PARAMETERS : SOURCE_DIR     Source directory that contains the RMAN      |
REM |                             backup sets.                                 |
REM |              DEST_DIR       Destination directory that will be used to   |
REM |                             store archived RMAN backup sets.             |
REM |              DAYS_OLD       Number of days worth of backup sets to keep  |
REM |                             in the destination directory.                |
REM | USAGE      :                                                             |
REM |                                                                          |
REM | rman_copy_purge_backupset.bat "SOURCE_DIR"  "DEST_DIR"  "DAYS_OLD"       |
REM |                                                                          |
REM | NOTE       : As with any code, ensure to test this script in a           |
REM |              development environment before attempting to run it in      |
REM |              production.                                                 |
REM +--------------------------------------------------------------------------+

REM +--------------------------------------------------------------------------+
REM | VALIDATE COMMAND-LINE PARAMETERS                                         |
REM +--------------------------------------------------------------------------+

if (%1)==() goto USAGE
if (%2)==() goto USAGE
if (%3)==() goto USAGE


REM +--------------------------------------------------------------------------+
REM | DECLARE ALL GLOBAL VARIABLES.                                            |
REM +--------------------------------------------------------------------------+

set FILENAME=rman_copy_purge_backupset
set SOURCE_DIR=%1%
set DEST_DIR=%2%
set DAYS_OLD=%3%


REM +--------------------------------------------------------------------------+
REM | PERFORM BACKUP OF RMAN BACKUP SETS.                                      |
REM +--------------------------------------------------------------------------+

echo Copying %SOURCE_DIR% to %DEST_DIR%...
copy /Y %SOURCE_DIR% %DEST_DIR%


REM +--------------------------------------------------------------------------+
REM | PURGE OLD FILES.                                                         |
REM +--------------------------------------------------------------------------+

echo List of RMAN backup files in %DEST_DIR% older than %DAYS_OLD% days...
forfiles -p%DEST_DIR% -s -d-%DAYS_OLD% -mBACKUP_* -c"CMD /C Echo @FILE will be deleted!"

echo Deleting RMAN backup files in %DEST_DIR% older than %DAYS_OLD% days...
forfiles -p%DEST_DIR% -s -d-%DAYS_OLD% -mBACKUP_* -c"CMD /C del /Q /F @FILE"

echo ...
echo END OF FILE REPORT
echo Filename      : %FILENAME%
echo Source Dir    : %SOURCE_DIR%
echo Dest Dir      : %DEST_DIR%
echo Purge Days    : %DAYS_OLD%
echo Hostname      : %COMPUTERNAME%
echo Date          : %DATE%
echo Time          : %TIME%


REM +--------------------------------------------------------------------------+
REM | END THIS SCRIPT.                                                         |
REM +--------------------------------------------------------------------------+

goto END



REM +==========================================================================+
REM |                    ***   END OF SCRIPT   ***                             |
REM +==========================================================================+

REM +--------------------------------------------------------------------------+
REM | LABEL DECLARATION SECTION.                                               |
REM +--------------------------------------------------------------------------+

:USAGE
echo Usage:  rman_copy_purge_backupset.bat  SOURCE_DIR  DEST_DIR  DAYS_OLD
echo           SOURCE_DIR  = Source directory that contains the RMAN
echo                         backup sets.
echo           DEST_DIR    = Destination directory that will be used to
echo                         store archived RMAN backup sets.
echo           DAYS_OLD    = Number of days worth of backup sets to keep
echo                         in the destination directory.
goto END

:END
@echo on
