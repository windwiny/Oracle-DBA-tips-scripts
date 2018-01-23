+------------------------------------------------------------------------------+
|                        DBA Scripts Archive for Oracle                        |
|                                  README.txt                                  |
| ---------------------------------------------------------------------------- |
|                            Jeffrey M. Hunter                                 |
|                        jhunter@idevelopment.info                             |
|                          www.idevelopment.info                               |
| ---------------------------------------------------------------------------- |
|     Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.          |
| ---------------------------------------------------------------------------- |
| All scripts and material located at the Internet address of                  |
| http://www.idevelopment.info is the copyright of Jeffrey M. Hunter and is    |
| protected under copyright laws of the United States. These scripts may not   |
| be hosted on any other site without my express, prior, written permission.   |
| Application to host any of the material elsewhere can be made by contacting  |
| me at jhunter@idevelopment.info.                                             |
|                                                                              |
| I have made every effort and taken great care in making sure that the        |
| scripts included on my web site are technically accurate, but I disclaim any |
| and all responsibility for any loss, damage or destruction of data or any    |
| other property which may arise from relying on it. I will in no case be      |
| liable for any monetary damages arising from such loss, damage or            |
| destruction.                                                                 |
| ---------------------------------------------------------------------------- |
| This README.txt file provides notes on how to configure your operating       |
| system environment to run the DBA Scripts Archive for Oracle provided from   |
| the www.idevelopment.info website.                                           |
+------------------------------------------------------------------------------+

=============================
    INSTALLATION
=============================

Available from the www.idevelopment.info web site, the DBA Scripts Archive for
Oracle comes archived in the popular ZIP format. The same archived file can be
used for both Microsoft Windows and UNIX.

The DBA Scripts Archive for Oracle is typically installed as the Oracle
Database software owner (for example, "oracle") in the ORACLE_BASE directory,
although any directory will work. To install, simply download the archived file
to the ORACLE_BASE directory (i.e. c:\oracle) and run the appropriate command
to extract its contents:

    -----------------------
    UNIX
    -----------------------
    cd $ORACLE_BASE
    unzip dba_scripts_archive_Oracle.zip


    -----------------------
    MS WINDOWS
    -----------------------
    cd %ORACLE_BASE%
    unzip dba_scripts_archive_Oracle.zip


=============================
    CONFIGURATION
=============================

After successfully extracting the DBA Scripts Archive for Oracle to the
ORACLE_BASE directory, configure the appropriate environment variable(s) in
the operating system environment for the current UNIX shell to ensure the
Oracle SQL scripts can be run from SQL*Plus while in any directory.

    -----------------------
    UNIX
    -----------------------
    PATH=/u01/app/oracle/dba_scripts/bin:$PATH
    ORACLE_PATH=.:$ORACLE_BASE/dba_scripts/sql:$ORACLE_HOME/rdbms/admin


    -----------------------
    MS WINDOWS
    -----------------------
    PATH=c:\oracle\dba_scripts\bin;%PATH%
    SQLPATH=.;%ORACLE_BASE%\dba_scripts\sql;%ORACLE_HOME%\rdbms\admin


=============================
  RUNNING SQL SCRIPTS
=============================

DBA's rely on Oracle's data dictionary views and dynamic performance views in
order to support and better manage their databases. Although these views
provide a simple and easy mechanism to query critical information regarding
the database, it helps to have a collection of accurate and readily available
SQL scripts to query these views.

Once the DBA Scripts Archive for Oracle has been extracted and the appropriate
environment variables set, users will be able to run any of the SQL scripts
located in the ORACLE_BASE/dba_scripts/sql directory while logged into
SQL*Plus.

For example, to query tablespace information while logged into the Oracle
database as a DBA user:


    SQL> @dba_tablespaces
    
    Status   Tablespace Name   TS Type     Ext. Mgt.  Seg. Mgt.   Tablespace Size   Used (in bytes) Pct. Used
    -------- ----------------- ----------- ---------- --------- ----------------- ----------------- ---------
    ONLINE   SYSAUX            PERMANENT   LOCAL      AUTO          1,073,741,824       528,547,840        49
    ONLINE   UNDOTBS1          UNDO        LOCAL      MANUAL          524,288,000        12,058,624         2
    ONLINE   USERS             PERMANENT   LOCAL      AUTO            104,857,600         1,048,576         1
    ONLINE   SYSTEM            PERMANENT   LOCAL      MANUAL        1,073,741,824       714,866,688        67
    ONLINE   EXAMPLE           PERMANENT   LOCAL      AUTO            524,288,000        85,131,264        16
    ONLINE   TEMP              TEMPORARY   LOCAL      MANUAL          524,288,000        66,060,288        13
                                                                ----------------- ----------------- ---------
    avg                                                                                                    25
    sum                                                             3,825,205,248     1,407,713,280
    
    6 rows selected.


NOTE: The ORACLE_PATH (in UNIX) and SQLPATH (in Windows) environment variables
      do not work in Oracle Release 8.1.7.4.0 and 9.2.0.4.0. Users will have
      to either run SQL*Plus from the directory containing the Oracle SQL
      scripts or simply provide the absolute path to the SQL scripts.

      From example:

      SQL> @C:\oracle\dba_scripts\sql\dba_tablespaces


=============================
  RUNNING EXECUTABLE SCRIPTS
=============================

Executable operating system scripts are located in the
ORACLE_BASE/dba_scripts/bin directory for both UNIX and MS Windows.
These scripts can be used to assist the DBA in managing and monitoring
databases hosted on that machine.

UNIX shell scripts can be identified with either an sh or ksh extension while
command scripts for MS Windows will have ps1, cmd, vbs, js, or bat extensions.
