#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : rman_backup_online_full.ksh                                   |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : This script is responsible for performing an on-line (hot)    |
# |              physical Oracle database backup using RMAN. This script was   |
# |              designed and tested with Oracle Database 10g. Although this   |
# |              script may work with versions higher than Oracle Database     |
# |              10g, it may not take advantage of newly introduced features.  |
# |                                                                            |
# | PARAMETERS :                                                               |
# |              TARGET_DB_NAME         TNS connect string to the target       |
# |                                     database.                              |
# |              TARGET_SID             Database SID found in the oratab file  |
# |                                     for the target database.               |
# |              TARGET_DBA_USERNAME    Database username used to log in to    |
# |                                     the target database. This user must    |
# |                                     have the SYSDBA role.                  |
# |              TARGET_DBA_PASSWORD    Database password used to log in to    |
# |                                     the target database.                   |
# |              BACKUP_PROFILE         An integer value that maps to which    |
# |                                     "RMAN Backup Profile" to run. An RMAN  |
# |                                     Backup Profile is simply a KSH         |
# |                                     function that executes the RMAN        |
# |                                     commands needed to perform a backup.   |
# |                                     The name of the KSH function will use  |
# |                                     the convention performRMANBackup[n]    |
# |                                     where n is the integer value of this   |
# |                                     command-line parameter. This script    |
# |                                     comes with several pre-written RMAN    |
# |                                     Backup Profiles that can be accessed   |
# |                                     through this integer value and         |
# |                                     provides an extensible framework by    |
# |                                     allowing the DBA to add and/or modify  |
# |                                     backup profiles.                       |
# |              RMAN_RECOVERY_CATALOG  If an RMAN recovery catalog will be    |
# |                                     used, this parameter should contain    |
# |                                     the string "catalog". If an RMAN       |
# |                                     recovery catalog will not be used,     |
# |                                     this parameter should contain the      |
# |                                     string "nocatalog" and not worry       |
# |                                     about passing the CATALOG_DB_NAME,     |
# |                                     CATALOG_DBA_USERNAME, and              |
# |                                     CATALOG_DBA_PASSWORD arguments         |
# |                                     (below).                               |
# |              CATALOG_DB_NAME        TNS connect string to the RMAN recover |
# |                                     catalog (if applicable). This          |
# |                                     parameter is only required if the      |
# |                                     parameter RMAN_RECOVERY_CATALOG        |
# |                                     is set to "catalog" (above).           |
# |              CATALOG_DBA_USERNAME   Database username used to log in to    |
# |                                     the RMAN recovery catalog database.    |
# |                                     Typically, this user is the owner of   |
# |                                     the RMAN recovery catalog and should   |
# |                                     therefore be a member of the           |
# |                                     RECOVERY_CATALOG_OWNER role. This      |
# |                                     parameter is only required if the      |
# |                                     parameter RMAN_RECOVERY_CATALOG        |
# |                                     is set to "catalog" (above).           |
# |              CATALOG_DBA_PASSWORD   Database password used to log in to    |
# |                                     the RMAN recovery catalog database.    |
# |                                     This parameter is only required if the |
# |                                     parameter RMAN_RECOVERY_CATALOG        |
# |                                     is set to "catalog" (above).           |
# |                                                                            |
# | EXAMPLE RUN:                                                               |
# |              /* Full DB backup as BACKUPSET to disk, AL backup all not backed up, delete AL > [n] days, no RMAN recovery catalog*/
# |              rman_backup_online_full.ksh  racdb1 racdb1 backup_admin backup_admin_pwd 2 nocatalog > rman_backup_online_full_racdb1_backup_admin_RACNODE1.job 2>&1
# |                                                                            |
# |              /* Full DB backup as BACKUPSET to tape, AL backup all not backed up, delete AL > [n] days, use RMAN recovery catalog */
# |              rman_backup_online_full.ksh  racdb1 racdb1 backup_admin backup_admin_pwd 3 catalog catdb.idevelopment.info rman rman_pwd > rman_backup_online_full_racdb1_backup_admin_RACNODE1.job 2>&1
# |                                                                            |
# |              /* Inc. Standby DB backup as BACKUPSET to disk, AL backup all not backed up, delete AL > [n] days, use RMAN recovery catalog */
# |              rman_backup_online_full.ksh  testdb3_stby.idevelopment.info testdb3 backup_admin backup_admin_pwd 5 catalog catdb.idevelopment.info rman rman_pwd > rman_backup_online_full_testdb3_backup_admin_LINUX4.job 2>&1
# |                                                                            |
# | NOTES      : This script assumes the target instance exists on the server  |
# |              running this script. The RMAN recovery catalog (if            |
# |              applicable) can and should be on a remote database server.    |
# |                                                                            |
# |              -----------------------------                                 |
# |              RMAN BINARY                                                   |
# |              -----------------------------                                 |
# |              This script will use the RMAN executable found in the         |
# |              $ORACLE_HOME/bin for the database version of the target       |
# |              database.                                                     |
# |                                                                            |
# |              -----------------------------                                 |
# |              RMAN CONFIGURATION PARAMETERS                                 |
# |              -----------------------------                                 |
# |              This script assumes the DBA has already set any RMAN          |
# |              configuration parameters. With the introduction of the "Flash |
# |              Recovery Area" in Oracle Database 10g, most database          |
# |              configurations do not set any RMAN configuration parameters.  |
# |              There still exists, however, many persistent configuration    |
# |              parameters that can be used to customize the RMAN. For        |
# |              example:                                                      |
# |                                                                            |
# |                  CONFIGURE RETENTION POLICY TO REDUNDANCY 2;               |
# |                  CONFIGURE DEFAULT DEVICE TYPE TO DISK;                    |
# |                  CONFIGURE CONTROLFILE AUTOBACKUP ON;                      |
# |                  CONFIGURE CHANNEL DEVICE TYPE DISK MAXPIECESIZE 2048M;    |
# |                                                                            |
# |              -----------------------------                                 |
# |              RMAN RECOVERY CATALOG                                         |
# |              -----------------------------                                 |
# |              This script provides the ability to connect to a recovery     |
# |              catalog while performing an RMAN backup. Use of a recovery    |
# |              catalog is optional although highly recommended. Regardless   |
# |              of whether or not a recovery catalog is being used, the RMAN  |
# |              will "always" write backup metadata to the control file of    |
# |              the target database. The following is an example of how to    |
# |              create an RMAN recovery catalog in a new database named       |
# |              CATDB. Note that the owner of an RMAN recovery catalog cannot |
# |              be the SYS user and the database hosting the recovery catalog |
# |              (CATDB in this example) should be a different database from   |
# |              the target database you will be backing up, created on a      |
# |              different host and on different disks than the target         |
# |              database.                                                     |
# |                                                                            |
# |              1.) Create a database for the recovery catalog named CATDB    |
# |              2.) Create a tablespace for the recovery catalog              |
# |                                                                            |
# |                  CREATE TABLESPACE rman_catalog DATAFILE SIZE 500m         |
# |                      AUTOEXTEND on NEXT 100m MAXSIZE 8g                    |
# |                      EXTENT MANAGEMENT local UNIFORM SIZE 1m               |
# |                      SEGMENT SPACE MANAGEMENT auto;                        |
# |                                                                            |
# |              3.) Create database user to hold recovery catalog objects     |
# |                                                                            |
# |                  CREATE USER rman IDENTIFIED BY rman_pwd                   |
# |                      DEFAULT TABLESPACE rman_catalog                       |
# |                      TEMPORARY TABLESPACE temp                             |
# |                      QUOTA UNLIMITED ON rman_catalog;                      |
# |                                                                            |
# |              4.) Grant the RECOVERY_CATALOG_OWNER role to the new schema   |
# |                  owner. This role provides the user with privileges to     |
# |                  create, maintain, and query the recovery catalog.         |
# |                                                                            |
# |                  GRANT recovery_catalog_owner TO rman;                     |
# |                                                                            |
# |              5.) After creating the catalog owner, create the recovery     |
# |                  catalog by using the CREATE CATALOG command within the    |
# |                  RMAN interface. This command will create the catalog in   |
# |                  the default tablespace of the catalog owner or you can    |
# |                  explicitly set the tablespace name to be used by using    |
# |                  the "TABLESPACE" option as shown below.                   |
# |                                                                            |
# |                  % rman catalog rman/rman_pwd@catdb                        |
# |                                                                            |
# |                  RMAN> create catalog tablespace rman_catalog;             |
# |                                                                            |
# |                  Just as you can create the recovery catalog schema, you   |
# |                  can also drop it using the "drop catalog" command. Of     |
# |                  course, all data contained in the schema will be lost so  |
# |                  take a backup before dropping the catalog:                |
# |                                                                            |
# |                  RMAN> drop catalog;                                       |
# |                                                                            |
# |              6.) Before using RMAN with a recovery catalog, register the   |
# |                  target database(s) in the recovery catalog. RMAN will     |
# |                  obtain all information it needs to register the target    |
# |                  database from the target database itself. As long as each |
# |                  target database has a distinct DBID, you can register     |
# |                  more than one target database in the same recovery        |
# |                  catalog. Each database registered in a given catalog must |
# |                  have a unique database identifier (DBID), but not         |
# |                  necessarily a unique database name. The following example |
# |                  registers a target database named TESTDB3 to the newly    |
# |                  created recovery catalog within the database named CATDB. |
# |                  The target database must be either mounted or opened in   |
# |                  order to register it.                                     |
# |                                                                            |
# |                  % rman target backup_admin/backup_admin_pwd catalog rman/rman_pwd@catdb
# |                                                                            |
# |                  RMAN> register database;                                  |
# |                                                                            |
# |              As easy as it is to register a target database in the         |
# |              recovery catalog, it is just as easy to unregister a          |
# |              database.                                                     |
# |                                                                            |
# |              To unregister an existing database, simply connect to that    |
# |              database and to the recovery catalog and issue the following  |
# |              command:                                                      |
# |                                                                            |
# |                  RMAN> unregister database;                                |
# |                                                                            |
# |              If the database has been removed then in most cases, all you  |
# |              need to supply is the name of the database. For example, to   |
# |              remove the TESTDB3 database, issue the following command:     |
# |                                                                            |
# |                  RMAN> unregister database testdb3;                        |
# |                                                                            |
# |              A more difficult situation exists when multiple databases     |
# |              with the same name are registered in the recovery catalog. In |
# |              this case, you need to know the DBID for the database you     |
# |              want to remove from the recovery catalog. Since this method   |
# |              necessitates the need to set the DBID, the unregister command |
# |              will need to be performed within a run block:                 |
# |                                                                            |
# |              rman catalog rman/rman_pwd@catdb                              |
# |                                                                            |
# |              RMAN> run {                                                   |
# |              2> set dbid 1041881438                                        |
# |              3> unregister database testdb3;                               |
# |              4> }                                                          |
# |                                                                            |
# |              ----------------------------------------                      |
# |              TAKING BACKUPS FROM A STANDBY DATABASE                        |
# |              ----------------------------------------                      |
# |              An Oracle standby database provides organizations with high   |
# |              availability, data protection, and disaster recovery for      |
# |              enterprise databases with extraordinary ease of use. For      |
# |              organizations that have a physical standby database and want  |
# |              to reduce the workload on their primary database server,      |
# |              database and associated archivelog backups can be performed   |
# |              on the physical standby database instead of the primary. A    |
# |              physical standby database is an exact block-for-block copy of |
# |              the primary database except that the database files may be    |
# |              located in a different location with a different name.        |
# |              Database backups taken from the physical standby database can |
# |              be used to restore and recover the primary database when      |
# |              needed. Because a physical standby database has the same DBID |
# |              as the primary database and is always from the same           |
# |              incarnation, the RMAN data file backups are interchangeable   |
# |              between the standby database and primary database. In other   |
# |              words, you can run the RESTORE command to restore a backup of |
# |              a standby data file to the primary database, and you can      |
# |              restore a backup of a primary data file to the physical       |
# |              standby database. The physical standby control file and       |
# |              primary control file, however, are not interchangeable. The   |
# |              control file and SPFILE must be backed up on the primary      |
# |              database.                                                     |
# |                                                                            |
# |              NOTE: Unlike a physical standby database, a logical standby   |
# |              is not a block-for-block clone of the primary database and    |
# |              therefore cannot participate in this type of backup.          |
# |                                                                            |
# |              This script can be used to perform RMAN backups from a        |
# |              physical standby database. The physical standby database is   |
# |              considered the "target" database and uses the TARGET_DB_NAME  |
# |              script parameter just as it would for a primary database.     |
# |              This is unlike the connection requirements when using the     |
# |              duplicate operations of RMAN to create a physical standby     |
# |              database where you connect to the standby database as an      |
# |              auxiliary database. Once a physical standby database has      |
# |              been established, connect to it has the target database and   |
# |              perform all necessary backup commands.                        |
# |                                                                            |
# |              A physical standby database can be backed up in several       |
# |              different states (open read-only, managed recovery mode,      |
# |              closed, etc.) and results in the backup being considered      |
# |              either a consistent or inconsistent backup. Only a consistent |
# |              backup can be restored without performing media recovery. An  |
# |              inconsistent backup requires media recovery. See the list     |
# |              below which shows whether a backup is consistent or           |
# |              inconsistent depending on its state:                          |
# |                                                                            |
# |              Standby Database Status                    Backup Status      |
# |              ------------------------------------------ ------------------ |
# |              Shutdown cleanly and then mounted          Consistent         |
# |                  (but not placed in recovery mode)                         |
# |              Mounted after instance failure or          Inconsistent       |
# |                  SHUTDOWN ABORT                                            |
# |              Manual recovery mode                       Inconsistent       |
# |              Managed recovery mode                      Inconsistent       |
# |              Read-only mode                             Inconsistent       |
# |                                                                            |
# |              An RMAN recovery catalog is required when running backups of  |
# |              the physical standby database in the Data Guard environment   |
# |              being described in this section. Both the primary database    |
# |              and standby database should use the same recovery catalog.    |
# |              Only register the primary database in the recovery catalog -  |
# |              you should not register the standby database in the catalog.  |
# |              Even though these databases share the same DBID, RMAN is able |
# |              to differentiate the standby database from the primary.       |
# |              Storing backup metadata for the primary and standby           |
# |              databases enables the DBA to restore backups to any of the    |
# |              nodes in the Data Guard configuration.                        |
# |                                                                            |
# |              Note that it is NOT required to RESYNC the recovery catalog   |
# |              against the primary database for the reason of having RMAN    |
# |              send to the primary database controlfile the RMAN backup      |
# |              history from the recovery catalog. This is because the        |
# |              history metadata in the controlfile is only sent TO the       |
# |              recovery catalog, never the reverse (Metalink Doc ID:         |
# |              420711.1). This is not to say that RMAN never writes from the |
# |              recovery catalog to the target database controlfile. In fact, |
# |              the persistent configuration settings (see output from        |
# |              "show all") are sent from the recovery catalog database to    |
# |              the target database controlfile when RMAN sees the target     |
# |              database controlfile was restored or has been re-created. It  |
# |              should be noted that there are valid reasons to resync the    |
# |              recovery catalog from the primary database controlfile. For   |
# |              example, if you have taken an RMAN backup of the primary      |
# |              database in "nocatalog" mode and you want this backup history |
# |              to be placed in the recovery catalog. Another reason is when  |
# |              the structure of the primary database has changed. This       |
# |              requires a resync from the primary database because a full    |
# |              resync (which obtains the database structure) happens only at |
# |              the primary database. This is essential even if no backups    |
# |              are taken at the primary database.                            |
# |                                                                            |
# |              Because an RMAN backup of the standby database does not       |
# |              backup the current controlfile, you should connect to the     |
# |              primary database and the recovery catalog in RMAN to backup   |
# |              the controlfile which provides you with a fully complete RMAN |
# |              database backup.                                              |
# |                                                                            |
# |              -----------------------------                                 |
# |              RMAN FAST INCREMENTAL BACKUPS                                 |
# |              -----------------------------                                 |
# |              The RMAN has been able to perform incremental backups since   |
# |              its introduction in Oracle8. An incremental backup backups up |
# |              only those database blocks that have changed since a previous |
# |              backup. Incremental backups provide the benefits of           |
# |              (1) reduced disk space usage through smaller backup-pieces    |
# |              having to be generated and (2) somewhat faster backup         |
# |              completion times. Even though the number of blocks eventually |
# |              written to the backup-piece is less, Oracle still had to      |
# |              read all of the database blocks in a data file to determine   |
# |              if they changed or not which results in backup times not far  |
# |              different to performing a full (level 0) backup. To speed up  |
# |              the incremental backup process, Oracle introduced a new       |
# |              feature in Oracle Database 10g known as "block change         |
# |              tracking". This new feature offers the ability to track and   |
# |              eventually back up only those database blocks that have       |
# |              changed since the last full backup. When using a block change |
# |              tracking file, RMAN no longer needs to unnecessarily read     |
# |              through each data file to identify blocks that have changed   |
# |              which significantly reduces the time to perform an            |
# |              incremental backup. RMAN simply consults the block change     |
# |              tracking file to identify the changed database blocks.        |
# |                                                                            |
# |              To enable block change tracking (while using OMF):            |
# |                                                                            |
# |                  ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;              |
# |                                                                            |
# |              If the database being backed up is a standby database, the    |
# |              same command would need to be run on the standby database to  |
# |              enable block change tracking:                                 |
# |                                                                            |
# |                  ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;              |
# |                                                                            |
# |              If not using OMF:                                             |
# |                                                                            |
# |                  ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE    |
# |                  '/u03/oradata/testdb3/block_change_tracking.chg';         |
# |                                                                            |
# |              To disable block change tracking:                             |
# |                                                                            |
# |                  ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;             |
# |                                                                            |
# |              -----------------------------                                 |
# |              RMAN NOTES AND EXAMPLES                                       |
# |              -----------------------------                                 |
# |              This script allows the DBA to define, modify, and use         |
# |              "RMAN Backup Profiles" which are simply KSH functions         |
# |              included in this script that execute the RMAN commands needed |
# |              to perform a backup. This section (RMAN NOTES AND EXAMPLES)   |
# |              provide some of the more common RMAN backup methods and       |
# |              commands that can be used when defining custom RMAN Backup    |
# |              Profiles.                                                     |
# |                                                                            |
# |              ------------------------------------------------------------- |
# |              ----    DATABASE    ----------------------------------------- |
# |              ------------------------------------------------------------- |
# |                                                                            |
# |              Perform a full backup of the target database plus all archive |
# |              logs then remove any archive logs that were backed up - all   |
# |              in one step.                                                  |
# |                                                                            |
# |                  RMAN> backup database plus archivelog delete input;       |
# |                                                                            |
# |              Perform a full backup of the target database only. In this    |
# |              example, the RMAN will not backup any archive log files. This |
# |              method would rely on the RMAN persistent configuration        |
# |              parameter "RETENTION POLICY" to identify obsolete backup      |
# |              files. The following example limits the size of any           |
# |              backup piece to 2GB.                                          |
# |                                                                            |
# |                             --------------------                           |
# |                             -  FULL BACKUPSET  -                           |
# |                             --------------------                           |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk maxpiecesize=2g;        |
# |                      backup database;                                      |
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              Perform a full image copy backup of the target database. When |
# |              using the "AS COPY" option, RMAN will simply create an image  |
# |              copy of the file with the name and/or location changed. There |
# |              are no RMAN backup pieces created when performing image       |
# |              copies. Image copies can be made for data files, control      |
# |              files, and archive log files and can only be made to disk.    |
# |                                                                            |
# |                              ------------------                            |
# |                              -  IMAGE COPIES  -                            |
# |                              ------------------                            |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      backup as copy database;                              |
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |                                   ----------                               |
# |                                   -  TAPE  -                               |
# |                                   ----------                               |
# |                                                                            |
# |              Perform a full backup of the target database to tape using    |
# |              the RMAN interface "sbt_tape". This script was tested using   |
# |              Oracle Secure Backup release 10.2.0.3.0 configured as         |
# |              follows:                                                      |
# |                                                                            |
# |                 OSB USER                                                   |
# |                 -------------------------                                  |
# |                     User:               oracle_linux3                      |
# |                     Password:           ********                           |
# |                     User class:         oracle                             |
# |                     Given name:         (null)                             |
# |                     UNIX name:          oracle                             |
# |                     UNIX group:         dba                                |
# |                     NDMP server user:   no                                 |
# |                     Email address:      jhunter@idevelopment.info          |
# |                                                                            |
# |                         WINDOWS DOMAINS                                    |
# |                         ---------------                                    |
# |                         Empty.                                             |
# |                         Removed all entries - not in a Windoze domain.     |
# |                                                                            |
# |                         PREAUTHORIZED ACCESS                               |
# |                         --------------------                               |
# |                         Host:           linux3                             |
# |                         Username:       oracle                             |
# |                         Windows Domain: *                                  |
# |                         Attributes:     rman                               |
# |                                                                            |
# |                 MEDIA FAMILY                                               |
# |                 -------------------------                                  |
# |                     Name:               RMAN-TESTDB3-MF                    |
# |                     Volume Expiration:  Content managed                    |
# |                                                                            |
# |                 DATABASE STORAGE SELECTOR                                  |
# |                 -------------------------                                  |
# |                     Name:               RMAN-TESTDB3-SSEL                  |
# |                     Content:            All                                |
# |                     Database(s):        TESTDB3                            |
# |                     Database ID(s):     (null)                             |
# |                     Host:               linux3                             |
# |                     Media family:       RMAN-TESTDB3-MF                    |
# |                     Restrictions:       tape1@packmule                     |
# |                     Copy number:        *                                  |
# |                     Resource wait time: forever                            |
# |                                                                            |
# |              Example run:                                                  |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel t1 type 'sbt_tape';                  |
# |                      backup database;                                      |
# |                      release channel t1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              If you use Oracle Secure Backup database storage selectors,   |
# |              then you are not required to set any "Media Management        |
# |              Parameters" in RMAN. The following example illustrates how to |
# |              override any database storage selectors by including RMAN     |
# |              media management parameters with the ENV parameter of the     |
# |              PARMS option using the "CONFIGURE" or "ALLOCATE CHANNEL"      |
# |              commands:                                                     |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel t1 device type sbt                   |
# |                          parms 'ENV=(OB_DEVICE=tape1,OB_MEDIA_FAMILY=RMAN-DEFAULT,OB_RESOURCE_WAIT_TIME=20minutes)';
# |                      backup database;                                      |
# |                      release channel t1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              You can also include RMAN media management parameters by      |
# |              means of the RMAN "SEND" command:                             |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel t1 device type sbt;                  |
# |                      send 'OB_MEDIA_FAMILY RMAN-TESTDB3-MF';               |
# |                      backup database;                                      |
# |                      release channel t1;                                   |
# |                  }                                                         |
# |                                                                            |
# |                                 -----------------                          |
# |                                 -  COMPRESSION  -                          |
# |                                 -----------------                          |
# |                                                                            |
# |              By default, RMAN performs NULL data block compression when    |
# |              creating backup sets. With this form of compression, Oracle   |
# |              does not back up unused data blocks (data blocks that have    |
# |              never been used) and will skip data blocks that were once     |
# |              used given specific criteria. Starting with Oracle Database   |
# |              10g, RMAN now offers the capability of using true compression |
# |              of backup sets:                                               |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      backup as compressed backupset database;              |
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |                                  --------------                            |
# |                                  -  DURATION  -                            |
# |                                  --------------                            |
# |                                                                            |
# |              RMAN offers the ability to manage the overall I/O impact of   |
# |              of running a backup using the "duration" parameter of the     |
# |              backup command. Similar to an alarm clock, if a backup runs   |
# |              longer than the specified duration, RMAN will cancel the      |
# |              backup. Note that as of Oracle Database 10g, you cannot use   |
# |              the duration parameter when using the "backup database plus   |
# |              archivelog" command. Here is an example of limiting the       |
# |              backup to 45 minutes:                                         |
# |                                                                            |
# |                  RMAN> backup duration 00:45 database;                     |
# |                                                                            |
# |              The duration parameter can also assist in throttling a        |
# |              backup by attempting to (1) minimize the time that a backup   |
# |              takes to run of (2) the I/O load that the backup consumes.    |
# |              When attempting to minimize the time that a backup runs       |
# |              (which is the default), RMAN will throw the backup into high  |
# |              gear using all available resources to finish the backup as    |
# |              soon as possible. Along with minimizing the time, RMAN will   |
# |              also prioritize the data files being backed up (those backed  |
# |              up more recent will have a lower priority than those that     |
# |              have not been backed up recently). As previously mentioned,   |
# |              RMAN can also be configured to minimize the I/O load while    |
# |              performing a backup. This method instructs RMAN to spread the |
# |              backup I/O over the established duration window with the goal |
# |              of reducing the overall impact to the database during a       |
# |              backup. The following are two examples of throttling the      |
# |              backup using both methods:                                    |
# |                                                                            |
# |                  RMAN> backup duration 00:45 minimize time database;       |
# |                  RMAN> backup duration 00:45 minimize load database;       |
# |                                                                            |
# |              One final note on using the duration parameter and that has   |
# |              to do with indicating how RMAN should treat backups that fail |
# |              the "backup duration" time restriction. By using the new      |
# |              "partial" parameter, if the backup is terminated because it   |
# |              exceeded the duration parameter, RMAN will not treat it as a  |
# |              failed backup. Any remaining commands in any "run" block will |
# |              continue to run. This option is often used when subsequent    |
# |              backup commands (i.e. archived redo logs) are part of a run   |
# |              block and should all be run regardless of previous errors.    |
# |                                                                            |
# |                  RMAN> backup duration 00:45 minimize load partial database;
# |                                                                            |
# |                              -------------------------                     |
# |                              -  INCREMENTAL BACKUPS  -                     |
# |                              -------------------------                     |
# |                                                                            |
# |              Perform an incremental backup of the target database.         |
# |                                                                            |
# |                  if (( $CURRENT_DOW_NUM == $RMAN_BASELINE_DOW_NUM )); then |
# |                      RMAN_LEVEL=0; export RMAN_LEVEL                       |
# |                  else                                                      |
# |                      RMAN_LEVEL=1; export RMAN_LEVEL                       |
# |                  fi                                                        |
# |                                                                            |
# |                  ...                                                       |
# |                  RMAN> backup incremental level=${RMAN_LEVEL} database;    |
# |                  ...                                                       |
# |                                                                            |
# |                              --------------------------                    |
# |                              -  ARCHIVE CURRENT LOGS  -                    |
# |                              --------------------------                    |
# |                                                                            |
# |              After an online backup, remember to archive current redo logs |
# |              using:                                                        |
# |                                                                            |
# |                  RMAN> sql 'alter system archive log current';             |
# |                                                                            |
# |              or all archive logs:                                          |
# |                                                                            |
# |                  RMAN> sql 'alter system archive log all';                 |
# |                                                                            |
# |                                                                            |
# |              ------------------------------------------------------------- |
# |              ----    ARCHIVE LOGS    ------------------------------------- |
# |              ------------------------------------------------------------- |
# |                                                                            |
# |              If archiving to multiple locations, RMAN does not put         |
# |              multiple copies of the same log sequence number into the same |
# |              backup set. The "BACKUP ARCHIVELOG ALL" command backs up      |
# |              exactly one copy of each distinct log sequence number.        |
# |                                                                            |
# |              If the DELETE INPUT option is specified with an archive log   |
# |              backup, then RMAN only deletes the specific copy of the       |
# |              archived redo log that it backs up. If the backup fails the   |
# |              archive logs are not deleted.                                 |
# |                                                                            |
# |              The backup retention policy considers logs obsolete only if   |
# |              the logs are not needed by a "guaranteed restore point"(*)    |
# |              and the logs are not needed by Oracle Flashback Database.     |
# |              Archived redo logs are needed by Flashback Database if the    |
# |              logs were created later than                                  |
# |              SYSDATE-'DB_FLASHBACK_RETENTION_TARGET'.                      |
# |                                                                            |
# |                  (*) A guaranteed restore point is a restore point for     |
# |                      which the database is guaranteed to retain the        |
# |                      flashback logs for an Oracle Flashback Database       |
# |                      operation. Unlike a normal restore point, a           |
# |                      guaranteed restore point does not age out of the      |
# |                      control file and must be explicitly dropped.          |
# |                      Guaranteed restore points utilize space in the flash  |
# |                      recovery area, which must be defined.                 |
# |                                                                            |
# |              Back up all archived logs to tape and clear disk space of old |
# |              logs in one step.                                             |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel t1 type 'sbt_tape';                  |
# |                      backup archivelog all delete input;                   |
# |                      release channel t1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              Back up archived logs to disk and clear disk space of old     |
# |              logs in one step.                                             |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      backup archivelog delete input;                       |
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              Backup and remove archived redo logs more than 7 days old.    |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      backup archivelog until time 'sysdate - 7' delete input;
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |              Specify a range of archived redo logs by time, SCN, or log    |
# |              sequence number. The following will back up all archived logs |
# |              created more than 7 and less than 30 days ago.                |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      backup archivelog from time 'SYSDATE-30' until time 'SYSDATE-7' delete input;
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |                                                                            |
# |              ------------------------------------------------------------- |
# |              ----    RETENTION POLICIES    ------------------------------- |
# |              ------------------------------------------------------------- |
# |                                                                            |
# |              How to implement a retention policy.                          |
# |                                                                            |
# |                  run {                                                     |
# |                      allocate channel c1 type disk;                        |
# |                      crosscheck backup of database;                        |
# |                      crosscheck backup of archivelog all;                  |
# |                      crosscheck archivelog all;                            |
# |                      crosscheck backup of controlfile;                     |
# |                      crosscheck backup of spfile;                          |
# |                      delete noprompt force expired backup;                 |
# |                      delete noprompt force expired copy;                   |
# |                      delete noprompt force obsolete;                       |
# |                      release channel c1;                                   |
# |                  }                                                         |
# |                                                                            |
# |                                                                            |
# |              ------------------------------------------------------------- |
# |              ----  [  CONTROL / SPFILE BACKUP  ]  ------------------------ |
# |              ------------------------------------------------------------- |
# |                                                                            |
# |              Backup the current control file, a copy of the current        |
# |              control file, a current control file for a standby database,  |
# |              the SPFILE, and a copy of the SPFILE.                         |
# |                                                                            |
# |                  EXAMPLES:                                                 |
# |                                                                            |
# |                  RMAN> backup current controlfile;                         |
# |                  RMAN> backup as copy current controlfile;                 |
# |                  RMAN> backup current controlfile for standby;             |
# |                  RMAN> backup as copy current controlfile for standby;     |
# |                  RMAN> backup spfile;                                      |
# |                                                                            |
# |                                                                            |
# |              ------------------------------------------------------------- |
# |              ----    REPORTING    ---------------------------------------- |
# |              ------------------------------------------------------------- |
# |                                                                            |
# |              Report the structure of the database.                         |
# |                                                                            |
# |                  RMAN> report schema;                                      |
# |                                                                            |
# |              Report which files need to be backed up.                      |
# |                                                                            |
# |                  RMAN> report need backup ...;                             |
# |                                                                            |
# |              Report which backups can be deleted.                          |
# |                                                                            |
# |                  RMAN> report obsolete;                                    |
# |                                                                            |
# |              Report which files are not recoverable because of             |
# |              unrecoverable operations.                                     |
# |                                                                            |
# |                  RMAN> report unrecoverable ...;                           |
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
BACKUP_PROFILE=$5
RMAN_RECOVERY_CATALOG=$6
CATALOG_DB_NAME=$7
CATALOG_DBA_USERNAME=$8
CATALOG_DBA_PASSWORD=$9

BACKUP_RMAN_RECOVERY_CATALOG=$6
RMAN_RECOVERY_CATALOG=`echo $RMAN_RECOVERY_CATALOG | tr '[:lower:]' '[:upper:]'`

if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
    EXPECTED_NUM_SCRIPT_PARAMS=9
elif [[ $RMAN_RECOVERY_CATALOG = "NOCATALOG" ]]; then
    EXPECTED_NUM_SCRIPT_PARAMS=6
else
    RMAN_RECOVERY_CATALOG="INVALID_VALUE"
    EXPECTED_NUM_SCRIPT_PARAMS=6
fi

UNIQUE_SCRIPT_IDENTIFIER=${TARGET_SID}_${TARGET_DBA_USERNAME}

# ----------------------------
# CUSTOM SCRIPT VARIABLES
# ----------------------------
RMAN_BASELINE_DOW_NUM=6       # Day of week to perform the base (level 0)
                              # RMAN backup (if applicable).
                              #     0 = Sunday         4 = Thursday
                              #     1 = Monday         5 = Friday
                              #     2 = Tuesday        6 = Saturday
                              #     3 = Wednesday

RMAN_ARCHIVE_LOG_RETENTION_DAYS=4
RMAN_ARCHIVE_LOG_SLEEP_TIME_SECONDS=120

case ${RMAN_BASELINE_DOW_NUM} in
    0) RMAN_BASELINE_DOW_NAME="Sunday" ;;
    1) RMAN_BASELINE_DOW_NAME="Monday" ;;
    2) RMAN_BASELINE_DOW_NAME="Tuesday" ;;
    3) RMAN_BASELINE_DOW_NAME="Wednesday" ;;
    4) RMAN_BASELINE_DOW_NAME="Thursday" ;;
    5) RMAN_BASELINE_DOW_NAME="Friday" ;;
    6) RMAN_BASELINE_DOW_NAME="Saturday" ;;
    *) RMAN_BASELINE_DOW_NAME="unknown" ;;
esac

# ---------------------------------------------------
# IF THE DATABASE BEING BACKED UP IS A PHYSICAL 
# STANDBY DATABASE, DEFINE THE DATABASE LOG IN
# CREDENTIALS TO ITS PRIMARY DATABASE. ALSO PROVIDE
# THE HOST NAME FOR THE MACHINE HOSTING THE PRIMARY
# DATABASE. THIS SCRIPT WILL USE RMAN TO CREATE A
# BACKUP OF THE CURRENT CONTROLFILE AND SPFILE FROM
# THE PRIMARY DATABASE. VERIFY THE MACHINE RUNNING
# THIS SCRIPT (HOSTING THE STANDBY DATABASE), CAN
# ACCESS THE PRIMARY MACHINE USING SECURE SHELL (SSH)
# AS THE UNIX USER ACCOUNT RUNNING THIS SCRIPT
# WITHOUT BEING PROMPTED FOR A PASSWORD. FINALLY,
# DEFINE THE DIRECTORY ON THIS MACHINE THAT WILL BE
# USED TO STORE THE BACKUP OF THE PRIMARY DATABASE'S
# CURRENT CONTROLFILE AND SPFILE THAT WILL BE COPIED
# FROM THE PRIMARY MACHINE.
# 
# FOR MORE INFORMATION ABOUT PERFORMING RMAN BACKUPS
# FROM THE STANDBY DATABASE, SEE THE SECTION "TAKING
# BACKUPS FROM THE STANDBY DATABASE" IN THE
# DOCUMENTATION NOTES AT THE BEGINNING OF THIS
# SCRIPT.
# ---------------------------------------------------
case ${BACKUP_PROFILE} in
    1)  RMAN_TARGET_DB_TYPE=PRIMARY
        ;;
    2)  RMAN_TARGET_DB_TYPE=PRIMARY
        ;;
    3)  RMAN_TARGET_DB_TYPE=PRIMARY
        ;;
    4)  RMAN_TARGET_DB_TYPE=PRIMARY
        ;;
    5)  RMAN_TARGET_DB_TYPE=STANDBY
        RMAN_PRIMARY_HOST_NAME=linux3.idevelopment.info
        RMAN_PRIMARY_BACKUP_DIR=/u04/orabackup
        RMAN_PRIMARY_DB_NAME=testdb3.idevelopment.info
        RMAN_PRIMARY_DBA_USERNAME=backup_admin
        RMAN_PRIMARY_DBA_PASSWORD=backup_admin_pwd
        ;;
    *)  RMAN_TARGET_DB_TYPE="INVALID PARAMETER"
        ;;
esac

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
MKDIR_BIN=/bin/mkdir
MV_BIN=/bin/mv
PS_BIN=/bin/ps
RM_BIN=/bin/rm
SENDMAIL_BIN=/usr/lib/sendmail
SCP_BIN=/usr/bin/scp
SLEEP_BIN=/bin/sleep
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
    wl "TRACE> TARGET_DB_NAME         set to $TARGET_DB_NAME"
    wl "TRACE> TARGET_SID             set to $TARGET_SID"
    wl "TRACE> TARGET_DBA_USERNAME    set to $TARGET_DBA_USERNAME"
    wl "TRACE> TARGET_DBA_PASSWORD    set to $HIDE_PASSWORD_STRING"
    wl "TRACE> BACKUP_PROFILE         set to $BACKUP_PROFILE"
    wl "TRACE> RMAN_RECOVERY_CATALOG  set to $RMAN_RECOVERY_CATALOG"
    wl "TRACE> CATALOG_DB_NAME        set to $CATALOG_DB_NAME"
    wl "TRACE> CATALOG_DBA_USERNAME   set to $CATALOG_DBA_USERNAME"

    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        wl "TRACE> CATALOG_DBA_PASSWORD   set to $HIDE_PASSWORD_STRING"
    else
        wl "TRACE> CATALOG_DBA_PASSWORD   set to "
    fi 

}

function performScriptParameterValidation {

    typeset -r  L_VERSION=${1}
    typeset -r  L_CURRENT_YEAR=${2}

    # -------------------------------------------
    # CHECK FOR VALID RMAN RECOVERY CATALOG VALUE
    # -------------------------------------------
    if [[ $RMAN_RECOVERY_CATALOG = "INVALID_VALUE" ]]; then
        showSignonBanner $L_VERSION $L_CURRENT_YEAR "NOLOG"
        showUsage "NOLOG"
        echo " "
        echo "JMA-0003: Invalid value for script parameter RMAN_RECOVERY_CATALOG ($BACKUP_RMAN_RECOVERY_CATALOG)."
        echo "JMA-0004: RMAN_RECOVERY_CATALOG must be set to either \"catalog\" or \"nocatalog\" (without the double quotes)."
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
    $L_SHOW "    parameters:  target_db_name"
    $L_SHOW "                 target_sid"
    $L_SHOW "                 target_dba_username"
    $L_SHOW "                 target_dba_password"
    $L_SHOW "                 backup_profile"
    $L_SHOW "                 rman_recovery_catalog [ catalog | nocatalog ]"
    $L_SHOW " "
    $L_SHOW "    optional"
    $L_SHOW "    parameters:  catalog_db_name"
    $L_SHOW "                 catalog_dba_username"
    $L_SHOW "                 catalog_dba_password"
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
    showSignonBanner $L_VERSION $L_CURRENT_YEAR "LOG"

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

function reportFlashbackDatabaseStatus {

    typeset -r L_DB_NAME=${1}
    typeset -r L_DBA_USERNAME=${2}
    typeset -r L_DBA_PASSWORD=${3}
    
    $ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
        WHENEVER SQLERROR EXIT SQL.SQLCODE
        SPOOL ${SQL_OUTPUT_TEMP_FILE_NAME} REPLACE
        CONNECT ${L_DBA_USERNAME}/${L_DBA_PASSWORD}@${L_DB_NAME} as sysdba
        SET LINESIZE 145
        SET PAGESIZE 9000
        COLUMN dbid                      HEADING 'DB ID'
        COLUMN name          FORMAT A15  HEADING 'DB Name'
        COLUMN log_mode      FORMAT A18  HEADING 'Log Mode'
        COLUMN flashback_on  FORMAT A18  HEADING 'Flashback DB On?'
    
        SELECT
            dbid
          , name
          , log_mode
          , flashback_on
        FROM v\$database;
    
        COLUMN oldest_flashback_scn                               HEADING 'Oldest|Flashback SCN'
        COLUMN oldest_flashback_time    FORMAT A21                HEADING 'Oldest|Flashback Time' JUST right
        COLUMN retention_target         FORMAT 999,999            HEADING 'Retention|Target (min)'
        COLUMN flashback_size           FORMAT 9,999,999,999,999  HEADING 'Flashback|Size'
        COLUMN estimated_flashback_size FORMAT 9,999,999,999,999  HEADING 'Estimated|Flashback Size'
    
        SELECT
            oldest_flashback_scn
          , TO_CHAR(oldest_flashback_time, 'DD-MON-YYYY HH24:MI:SS') oldest_flashback_time
          , retention_target
          , flashback_size
          , estimated_flashback_size
        FROM v\$flashback_database_log;
        SPOOL OFF
EOF
        
    if (( $? == 0 )); then
        wl " "
        wl "TRACE> Successful SQL*Plus session."
        wl " "
        ${CAT_BIN} $SQL_OUTPUT_TEMP_FILE_NAME | ${TEE_BIN} -a $LOG_FILE_NAME
        wl " "
        wl "TRACE> Removing temporary SQL output file ($SQL_OUTPUT_TEMP_FILE_NAME)."
        ${RM_BIN} -f $SQL_OUTPUT_TEMP_FILE_NAME
    else 
        wl " "
        wl "TRACE> Failed to report flashback database status."
    fi

    return

}

function performRMANBackup1 {

    typeset -r L_TARGET_DB_NAME=${1}
    typeset -r L_TARGET_DBA_USERNAME=${2}
    typeset -r L_TARGET_DBA_PASSWORD=${3}
    typeset -r L_CATALOG_DB_NAME=${4}
    typeset -r L_CATALOG_DBA_USERNAME=${5}
    typeset -r L_CATALOG_DBA_PASSWORD=${6}
    typeset    L_RMAN_CONNECT_TARGET
    typeset    L_RMAN_CONNECT_CATALOG

    wl " "
    wl "TRACE> +---------------------------------+"
    wl "TRACE> | RMAN Backup Profile Description |"
    wl "TRACE> |------------------------------------------------------------------------+"
    wl "TRACE> | * Full database backup + archivelog delete input to disk as BACKUPSET. |"
    wl "TRACE> | * Primary database if using Data Guard.                                |"
    wl "TRACE> | * Compatibility: 10g / 11g                                             |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl " "


    # ---------------------------------------------
    # SET LOG IN CREDENTIALS
    # ---------------------------------------------
    L_RMAN_CONNECT_TARGET="CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${L_TARGET_DBA_PASSWORD}@${L_TARGET_DB_NAME}"
    wl "TRACE> [TARGET] CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_TARGET_DB_NAME}"
    
    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        L_RMAN_CONNECT_CATALOG="CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${L_CATALOG_DBA_PASSWORD}@${L_CATALOG_DB_NAME}"
        wl "TRACE> [CATALOG] CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_CATALOG_DB_NAME}"
    else
        L_RMAN_CONNECT_CATALOG=""
        wl "TRACE> [CATALOG] No recovery catalog credentials defined."
    fi


    # ---------------------------------------------
    # PERFORM FULL RMAN BACKUP
    # ---------------------------------------------
    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_TARGET
        $L_RMAN_CONNECT_CATALOG
        
        run {
            allocate channel c1 type disk;
                report schema;
                crosscheck backup of database;
                crosscheck backup of archivelog all;
                crosscheck backup of controlfile;
                crosscheck backup of spfile;
                crosscheck archivelog all;
                delete noprompt force expired backup;
                delete noprompt force expired archivelog all;
                delete noprompt force expired copy;
                delete noprompt force obsolete;
            release channel c1;
        }
    
        run {
            allocate channel c1 type disk maxpiecesize=2g;
                backup database plus archivelog delete input;
            release channel c1;
        }
    
        run {
            allocate channel c1 type disk;
                delete noprompt force obsolete;
            release channel c1;
        }
    
        run {
            report need backup;
            report unrecoverable;
        }
    
        exit; 
EOF

    return

}

function performRMANBackup2 {

    typeset -r L_TARGET_DB_NAME=${1}
    typeset -r L_TARGET_DBA_USERNAME=${2}
    typeset -r L_TARGET_DBA_PASSWORD=${3}
    typeset -r L_CATALOG_DB_NAME=${4}
    typeset -r L_CATALOG_DBA_USERNAME=${5}
    typeset -r L_CATALOG_DBA_PASSWORD=${6}
    typeset    L_RMAN_CONNECT_TARGET
    typeset    L_RMAN_CONNECT_CATALOG

    wl " "
    wl "TRACE> +---------------------------------+"
    wl "TRACE> | RMAN Backup Profile Description |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl "TRACE> | * Full database backup to disk as BACKUPSET.                           |"
    wl "TRACE> | * Archivelog backup all not backed up to disk using BACKUPSET.         |"
    wl "TRACE> | * Delete archivelog files older then N days.                           |"
    wl "TRACE> | * Backup current control file and SPFILE to disk.                      |"
    wl "TRACE> | * Primary database if using Data Guard.                                |"
    wl "TRACE> | * Compatibility: 10g / 11g                                             |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl " "


    # ---------------------------------------------
    # SET LOG IN CREDENTIALS
    # ---------------------------------------------
    L_RMAN_CONNECT_TARGET="CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${L_TARGET_DBA_PASSWORD}@${L_TARGET_DB_NAME}"
    wl "TRACE> [TARGET] CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_TARGET_DB_NAME}"
    
    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        L_RMAN_CONNECT_CATALOG="CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${L_CATALOG_DBA_PASSWORD}@${L_CATALOG_DB_NAME}"
        wl "TRACE> [CATALOG] CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_CATALOG_DB_NAME}"
    else
        L_RMAN_CONNECT_CATALOG=""
        wl "TRACE> [CATALOG] No recovery catalog credentials defined."
    fi


    # ---------------------------------------------
    # PERFORM FULL RMAN BACKUP
    # ---------------------------------------------
    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_TARGET
        $L_RMAN_CONNECT_CATALOG
        
        run {
            allocate channel c1 type disk;
                report schema;
                crosscheck backup of database;
                crosscheck backup of archivelog all;
                crosscheck backup of controlfile;
                crosscheck backup of spfile;
                crosscheck archivelog all;
                delete noprompt force expired backup;
                delete noprompt force expired archivelog all;
                delete noprompt force expired copy;
                delete noprompt force obsolete;
            release channel c1;
        }
    
        run {
            allocate channel c1 type disk maxpiecesize=2g;
                backup as backupset database;
                sql 'alter system switch logfile';
                backup as backupset archivelog all not backed up;
                delete noprompt force archivelog all completed before 'sysdate-${RMAN_ARCHIVE_LOG_RETENTION_DAYS}';
                backup current controlfile;
                backup spfile;
            release channel c1;
        }
    
        run {
            allocate channel c1 type disk;
                delete noprompt force obsolete;
            release channel c1;
        }
    
        run {
            report need backup;
            report unrecoverable;
        }
    
        exit; 
EOF

    return

}

function performRMANBackup3 {

    typeset -r L_TARGET_DB_NAME=${1}
    typeset -r L_TARGET_DBA_USERNAME=${2}
    typeset -r L_TARGET_DBA_PASSWORD=${3}
    typeset -r L_CATALOG_DB_NAME=${4}
    typeset -r L_CATALOG_DBA_USERNAME=${5}
    typeset -r L_CATALOG_DBA_PASSWORD=${6}
    typeset    L_RMAN_CONNECT_TARGET
    typeset    L_RMAN_CONNECT_CATALOG

    wl " "
    wl "TRACE> +---------------------------------+"
    wl "TRACE> | RMAN Backup Profile Description |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl "TRACE> | * Full database backup to tape as BACKUPSET.                           |"
    wl "TRACE> | * Archivelog backup all not backed up to tape using BACKUPSET.         |"
    wl "TRACE> | * Delete archivelog files older then N days.                           |"
    wl "TRACE> | * Backup current control file and SPFILE to tape.                      |"
    wl "TRACE> | * Primary database if using Data Guard.                                |"
    wl "TRACE> | * Compatibility: 10g / 11g                                             |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl " "


    # ---------------------------------------------
    # SET LOG IN CREDENTIALS
    # ---------------------------------------------
    L_RMAN_CONNECT_TARGET="CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${L_TARGET_DBA_PASSWORD}@${L_TARGET_DB_NAME}"
    wl "TRACE> [TARGET] CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_TARGET_DB_NAME}"
    
    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        L_RMAN_CONNECT_CATALOG="CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${L_CATALOG_DBA_PASSWORD}@${L_CATALOG_DB_NAME}"
        wl "TRACE> [CATALOG] CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_CATALOG_DB_NAME}"
    else
        L_RMAN_CONNECT_CATALOG=""
        wl "TRACE> [CATALOG] No recovery catalog credentials defined."
    fi


    # ---------------------------------------------
    # PERFORM FULL RMAN BACKUP
    # ---------------------------------------------
    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_TARGET
        $L_RMAN_CONNECT_CATALOG
        
        run {
            allocate channel t1 type 'sbt_tape';
                report schema;
                crosscheck backup of database;
                crosscheck backup of archivelog all;
                crosscheck backup of controlfile;
                crosscheck backup of spfile;
                crosscheck archivelog all;
                delete noprompt force expired backup;
                delete noprompt force expired archivelog all;
                delete noprompt force expired copy;
                delete noprompt force obsolete;
            release channel t1;
        }
    
        run {
            allocate channel t1 type 'sbt_tape';
                backup as backupset database;
                sql 'alter system switch logfile';
                backup as backupset archivelog all not backed up;
                delete noprompt force archivelog all completed before 'sysdate-${RMAN_ARCHIVE_LOG_RETENTION_DAYS}';
                backup current controlfile;
                backup spfile;
            release channel t1;
        }
    
        run {
            allocate channel t1 type 'sbt_tape';
                delete noprompt force obsolete;
            release channel t1;
        }
    
        run {
            report need backup;
            report unrecoverable;
        }
    
        exit; 
EOF

    return

}

function performRMANBackup4 {

    typeset -r L_TARGET_DB_NAME=${1}
    typeset -r L_TARGET_DBA_USERNAME=${2}
    typeset -r L_TARGET_DBA_PASSWORD=${3}
    typeset -r L_CATALOG_DB_NAME=${4}
    typeset -r L_CATALOG_DBA_USERNAME=${5}
    typeset -r L_CATALOG_DBA_PASSWORD=${6}
    typeset -i L_RMAN_INC_LEVEL
    typeset    L_RMAN_CONNECT_TARGET
    typeset    L_RMAN_CONNECT_CATALOG

    wl " "
    wl "TRACE> +---------------------------------+"
    wl "TRACE> | RMAN Backup Profile Description |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl "TRACE> | * Incremental database backup (level 0/1) to disk as BACKUPSET.        |"
    wl "TRACE> | * Archivelog backup all not backed up to disk using BACKUPSET.         |"
    wl "TRACE> | * Delete archivelog files older then N days.                           |"
    wl "TRACE> | * Backup current control file and SPFILE to disk.                      |"
    wl "TRACE> | * Primary database if using Data Guard.                                |"
    wl "TRACE> | * Compatibility: 10g / 11g                                             |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl " "


    # ---------------------------------------------
    # DETERMINE DAY OF WEEK FOR INCREMENTAL BACKUPS
    # ---------------------------------------------
    if (( $CURRENT_DOW_NUM == $RMAN_BASELINE_DOW_NUM )); then
        wl "TRACE> Performing a level 0 backup of the target database."
        wl " "
        L_RMAN_INC_LEVEL=0; export L_RMAN_INC_LEVEL
    else
        wl "TRACE> Performing a level 1 backup of the target database."
        wl " "
        L_RMAN_INC_LEVEL=1; export L_RMAN_INC_LEVEL
    fi


    # ---------------------------------------------
    # SET LOG IN CREDENTIALS
    # ---------------------------------------------
    L_RMAN_CONNECT_TARGET="CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${L_TARGET_DBA_PASSWORD}@${L_TARGET_DB_NAME}"
    wl "TRACE> [TARGET] CONNECT TARGET ${L_TARGET_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_TARGET_DB_NAME}"

    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        L_RMAN_CONNECT_CATALOG="CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${L_CATALOG_DBA_PASSWORD}@${L_CATALOG_DB_NAME}"
        wl "TRACE> [CATALOG] CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_CATALOG_DB_NAME}"
    else
        L_RMAN_CONNECT_CATALOG=""
        wl "TRACE> [CATALOG] No recovery catalog credentials defined."
    fi


    # ---------------------------------------------
    # REPORT, CROSSCHECK, AND DELETE EXPIRED
    # BACKUPS
    # ---------------------------------------------
    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_TARGET
        $L_RMAN_CONNECT_CATALOG
        
        run {
            allocate channel c1 type disk;
                report schema;
                crosscheck backup of database;
                crosscheck backup of archivelog all;
                crosscheck backup of controlfile;
                crosscheck backup of spfile;
                crosscheck archivelog all;
                delete noprompt force expired backup;
                delete noprompt force expired archivelog all;
                delete noprompt force expired copy;
                delete noprompt force obsolete;
            release channel c1;
        }

        exit;
EOF
        
    # ---------------------------------------------
    # PERFORM INCREMENTAL RMAN BACKUP OF DATABASE
    # ---------------------------------------------
    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_TARGET
        $L_RMAN_CONNECT_CATALOG
    
        run {
            allocate channel c1 type disk maxpiecesize=2g;
                backup as backupset incremental level=${L_RMAN_INC_LEVEL} database;
                sql 'alter system switch logfile';
                backup as backupset archivelog all not backed up;
                delete noprompt force archivelog all completed before 'sysdate-${RMAN_ARCHIVE_LOG_RETENTION_DAYS}';
                backup current controlfile;
                backup spfile;
            release channel c1;
        }
    
        run {
            allocate channel c1 type disk;
                delete noprompt force obsolete;
            release channel c1;
        }
    
        run {
            report need backup;
            report unrecoverable;
        }
    
        exit; 
EOF

    return

}

function performRMANBackup5 {

    typeset -r L_STANDBY_DB_NAME=${1}
    typeset -r L_STANDBY_SID=${2}
    typeset -r L_STANDBY_DBA_USERNAME=${3}
    typeset -r L_STANDBY_DBA_PASSWORD=${4}
    typeset -r L_CATALOG_DB_NAME=${5}
    typeset -r L_CATALOG_DBA_USERNAME=${6}
    typeset -r L_CATALOG_DBA_PASSWORD=${7}
    typeset -r L_RMAN_PRIMARY_DB_NAME=${8}
    typeset -r L_RMAN_PRIMARY_DBA_USERNAME=${9}
    typeset -r L_RMAN_PRIMARY_DBA_PASSWORD=${10}
    typeset -i L_RMAN_INC_LEVEL
    typeset    L_RMAN_CONNECT_STANDBY
    typeset    L_RMAN_CONNECT_CATALOG

    wl " "
    wl "TRACE> +---------------------------------+"
    wl "TRACE> | RMAN Backup Profile Description |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl "TRACE> | * Incremental database backup (level 0/1) to disk as BACKUPSET.        |"
    wl "TRACE> | * Archivelog backup all not backed up to disk using BACKUPSET.         |"
    wl "TRACE> | * Delete archivelog files older then N days.                           |"
    wl "TRACE> | * Backup current control file and SPFILE to disk.                      |"
    wl "TRACE> | * Standby database using Data Guard.                                   |"
    wl "TRACE> | * Compatibility: 10g / 11g                                             |"
    wl "TRACE> +------------------------------------------------------------------------+"
    wl " "


    # ---------------------------------------------
    # DETERMINE DAY OF WEEK FOR INCREMENTAL BACKUPS
    # ---------------------------------------------
    if (( $CURRENT_DOW_NUM == $RMAN_BASELINE_DOW_NUM )); then
        wl "TRACE> Performing a level 0 backup of the standby database."
        wl " "
        L_RMAN_INC_LEVEL=0; export L_RMAN_INC_LEVEL
    else
        wl "TRACE> Performing a level 1 backup of the standby database."
        wl " "
        L_RMAN_INC_LEVEL=1; export L_RMAN_INC_LEVEL
    fi


    # ---------------------------------------------
    # SET ALL CONNECTION STRING VARIABLES
    # ---------------------------------------------
    wl " "
    wl "TRACE> Setting all connection string variables."
    wl " "
    
    L_RMAN_CONNECT_STANDBY="CONNECT TARGET ${L_STANDBY_DBA_USERNAME}/${L_STANDBY_DBA_PASSWORD}@${L_STANDBY_DB_NAME}"
    wl "TRACE> [STANDBY] CONNECT TARGET ${L_STANDBY_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_STANDBY_DB_NAME}"
    
    if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
        L_RMAN_CONNECT_CATALOG="CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${L_CATALOG_DBA_PASSWORD}@${L_CATALOG_DB_NAME}"
        wl "TRACE> [CATALOG] CONNECT CATALOG ${L_CATALOG_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_CATALOG_DB_NAME}"
    else
        wl " "
        wl "TRACE> [CATALOG] JMA-1003: Missing credentials for the recovery catalog."
        wl "TRACE>           JMA-1004: Perform backups from the standby database requires the use of a recovery catalog."
        return
    fi

    L_RMAN_CONNECT_PRIMARY="CONNECT TARGET ${L_RMAN_PRIMARY_DBA_USERNAME}/${L_RMAN_PRIMARY_DBA_PASSWORD}@${L_RMAN_PRIMARY_DB_NAME}"
    wl "TRACE> [PRIMARY] CONNECT TARGET ${L_RMAN_PRIMARY_DBA_USERNAME}/${HIDE_PASSWORD_STRING}@${L_RMAN_PRIMARY_DB_NAME}"


    # ---------------------------------------------
    # IF THE SERVER HOSTING THE DATABASE IS LIMITED
    # ON DISK STORAGE, THE BACKUP PROCESS MAY BE
    # UNABLE TO SAVE MORE THAN ONE COPY OF THE
    # TARGET DATABASE TO DISK. UN-COMMENT THE
    # FOLLOWING BLOCK OF CODE WHICH WILL REMOVE
    # ALL PREVIOUS BACKUPS (EXCLUDING ARCHIVE REDO
    # LOGS) BEFORE PERFORMING THE FULL BACKUP.
    # FOR THE PURPOSE OF THIS BACKUP PROFILE, THE
    # TARGET DATABASE IS A STANDBY DATABASE WHICH
    # WILL RECEIVE A FULL BACKUP ONCE A WEEK AND 
    # INCREMENTAL BACKUPS ALL OTHER DAYS. THE 
    # PREVIOUS BACKUPS (FULL AND INCREMENTAL) WILL
    # BE REMOVED BEFORE PERFORMING A LEVEL 0
    # BACKUP.
    # 
    #              !!! WARNING !!!
    # IT IS IMPORTANT TO NOTE THAT UN-COMMENTING
    # THIS SECTION AND ALLOWING THE REMOVAL OF
    # ALL PREVIOUS BACKUPS BEFORE PERFORMING THE
    # CURRENT BACKUP IS NOT ONLY BAD PRACTICE BUT
    # EXTREMELY RISKY. AFTER ALL PREVIOUS BACKUPS
    # HAVE BEEN REMOVED AND UNTIL THE CURRENT
    # BACKUP COMPLETES SUCCESSFULLY, THE TARGET
    # DATABASE REMAINS IN A VULNERABLE AND
    # UN-RECOVERABLE STATE! BEFORE IMPLEMENTING
    # THIS METHOD OF REMOVING ALL PREVIOUS BACKUPS
    # ON A MISSION-CRITICAL SYSTEM JUST SO AN
    # ILL-INFORMED MANAGER CAN SAVE A FEW BUCKS BY
    # NOT PERFORMING THE TRIVIAL TASK OF PROCURING
    # AN ADEQUATE AMOUNT DISK STORAGE IN THE 21st
    # CENTURY, CONSIDER THIS - 
    #           "PURCHASE THE DAMN DISKS".
    # ---------------------------------------------
    
    # ---------------------------------------------
    # [ BEGIN ] - REMOVE PREVIOUS BACKUP
    # ---------------------------------------------
    if [[ $L_RMAN_INC_LEVEL = 0 ]]; then
        wl " "
        wl "TRACE> Level 0 backup. Removing all previous backups (excluding archive redo logs) due to lack of disk storage."
        wl "TRACE> Note that this is not only bad practice but extremely risky to the recoverability of the target database."
        wl "TRACE> First, delete backups from the standby database w/o connecting to the recovery catalog..."

        $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
            $L_RMAN_CONNECT_STANDBY
            
            delete noprompt force backup;
            
            exit;
EOF

        wl " "
        wl "TRACE> Next, delete backups from the primary database w/o connecting to the recovery catalog..."

        $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
            $L_RMAN_CONNECT_PRIMARY
            
            delete noprompt force backup;
            
            exit;
EOF

        wl " "
        wl "TRACE> PARTIAL RESYNC - Propagate metadata from the standby controlfile to the rman recovery catalog."
    
        $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
            $L_RMAN_CONNECT_STANDBY
            $L_RMAN_CONNECT_CATALOG
    
            resync catalog;
    
            exit;
EOF

        wl " "
        wl "TRACE> FULL RESYNC - Propagate metadata from the primary controlfile to the rman recovery catalog."
    
        $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
            $L_RMAN_CONNECT_PRIMARY
            $L_RMAN_CONNECT_CATALOG
    
            resync catalog;
    
            exit;
EOF

    fi
    # ---------------------------------------------
    # [ END ] - REMOVE PREVIOUS BACKUP
    # ---------------------------------------------


    # ---------------------------------------------
    # REPORT SCHEMA STRUCTURES. WHEN THE TARGET IS
    # A STANDBY DATABASE, CONNECT TO THE RECOVERY
    # CATALOG BEFORE RUNNING THE RMAN "REPORT
    # SCHEMA" COMMAND. IF NOT, YOU WILL RECEIVE AN
    # RMAN-6139 ERROR INDICATING THAT THE
    # CONTROLFILE MOUNTED BY THE TARGET INSTANCE IS
    # NOT CURRENT SO THE INFORMATION ABOUT THE
    # CURRENT LIST OF DATA FILES MAY NOT BE
    # CURRENT.
    # ---------------------------------------------
    wl " "
    wl "TRACE> Report schema structures."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY
        $L_RMAN_CONNECT_CATALOG

        report schema;

        exit;
EOF


    # ---------------------------------------------
    # REMOVE EXPIRED BACKUPS AND COPIES
    # ---------------------------------------------
    wl " "
    wl "TRACE> Remove expired backups and copies:"
    wl "TRACE>     crosscheck backup of database"
    wl "TRACE>     crosscheck backup of archivelog all"
    wl "TRACE>     crosscheck backup of controlfile"
    wl "TRACE>     crosscheck backup of spfile"
    wl "TRACE>     crosscheck archivelog all"
    wl "TRACE>     delete noprompt force expired backup"
    wl "TRACE>     delete noprompt force expired archivelog all"
    wl "TRACE>     delete noprompt force expired copy"

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY
        $L_RMAN_CONNECT_CATALOG
        
        run {
            allocate channel c1 type disk;
                crosscheck backup of database;
                crosscheck backup of archivelog all;
                crosscheck backup of controlfile;
                crosscheck backup of spfile;
                crosscheck archivelog all;
                delete noprompt force expired backup;
                delete noprompt force expired archivelog all;
                delete noprompt force expired copy;
            release channel c1;
        }

        exit;
EOF


    # ---------------------------------------------
    # PERFORM INCREMENTAL BACKUP OF THE STANDBY
    # DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Perform incremental backup (level ${L_RMAN_INC_LEVEL}) of the standby database."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY
        $L_RMAN_CONNECT_CATALOG

        run {
            allocate channel c1 type disk maxpiecesize=8g;
                backup as backupset incremental level=${L_RMAN_INC_LEVEL} database;
            release channel c1;
        }

        exit; 
EOF


    # ---------------------------------------------
    # PERFORM LOG SWITCH ON THE PRIMARY DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Perform a log switch on the primary database."

    $ORACLE_HOME/bin/sqlplus -s /nolog <<EOF
        WHENEVER SQLERROR EXIT SQL.SQLCODE
        SPOOL ${SQL_OUTPUT_TEMP_FILE_NAME} REPLACE
        CONNECT ${L_RMAN_PRIMARY_DBA_USERNAME}/${L_RMAN_PRIMARY_DBA_PASSWORD}@${L_RMAN_PRIMARY_DB_NAME} as sysdba
        alter system switch logfile;
        SPOOL OFF
EOF
        
    if (( $? == 0 )); then
        wl " "
        wl "TRACE> Successfully switched current log file on the primary database."
        wl " "
        cat $SQL_OUTPUT_TEMP_FILE_NAME | ${TEE_BIN} -a $LOG_FILE_NAME
        wl " "
        wl "TRACE> Removing temporary SQL output file ($SQL_OUTPUT_TEMP_FILE_NAME)."
        ${RM_BIN} -f $SQL_OUTPUT_TEMP_FILE_NAME
    else 
        wl " "
        wl "TRACE> Failed to switch current log file on the primary database."
    fi


    # ---------------------------------------------
    # TAKE A SHORT NAP AND ALLOW LOG FILE TO BE
    # ARCHIVED AND THEN APPLIED TO THE STANDBY
    # DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Taking a nap for ${RMAN_ARCHIVE_LOG_SLEEP_TIME_SECONDS} seconds..."

    ${SLEEP_BIN} ${RMAN_ARCHIVE_LOG_SLEEP_TIME_SECONDS}


    # ---------------------------------------------
    # DELETE OBSOLETE ARCHIVE LOGS ON THE STANDBY
    # DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Delete obsolete archive logs on the standby database."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY

        run {
            allocate channel c1 type disk;
                delete noprompt force archivelog all completed before 'sysdate-${RMAN_ARCHIVE_LOG_RETENTION_DAYS}';
            release channel c1;
        }

        exit; 
EOF


    # ---------------------------------------------
    # DELETE OBSOLETE ARCHIVE LOGS ON THE PRIMARY
    # DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Delete obsolete archive logs on the primary database."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_PRIMARY

        run {
            allocate channel c1 type disk;
                delete noprompt force archivelog all completed before 'sysdate-${RMAN_ARCHIVE_LOG_RETENTION_DAYS}';
            release channel c1;
        }

        exit;
EOF


    # ---------------------------------------------
    # BACKUP CURRENT CONTROLFILE AND SPFILE FROM
    # THE STANDBY DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Backup current controlfile and spfile from the standby database."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY
        $L_RMAN_CONNECT_CATALOG

        run {
            allocate channel c1 type disk;
                backup current controlfile;
                backup spfile;
            release channel c1;
        }

        exit; 
EOF


    # ---------------------------------------------
    # BACKUP CURRENT CONTROLFILE AND SPFILE FROM
    # THE PRIMARY DATABASE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Backup current controlfile and spfile from the primary database."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_PRIMARY
        $L_RMAN_CONNECT_CATALOG

        run {
            delete noprompt force controlfilecopy tag 'PRIMARY_CURRENT_CONTROLFILE';
        }

        run {
            allocate channel c1 type disk;
                backup as copy current controlfile tag 'PRIMARY_CURRENT_CONTROLFILE' format '${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/controlfile/primary_current_controlfile.ctl';
            release channel c1;
        }

        run {
            delete noprompt force backup tag 'PRIMARY_SPFILE';
        }

        run {
            allocate channel c1 type disk;
                backup spfile tag 'PRIMARY_SPFILE' format '${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/spfile/primary_spfile.bkp';
            release channel c1;
        }

        exit; 
EOF


    # ---------------------------------------------
    # PERFORM REMOTE COPY OF CURRENT CONTROLFILE
    # AND SPFILE FROM THE PRIMARY MACHINE TO THE
    # STANDBY MACHINE
    # ---------------------------------------------
    wl " "
    wl "TRACE> Remote copy of current controlfile and spfile from the primary machine to the standby machine."
    wl "TRACE> \"${RMAN_PRIMARY_HOST_NAME}:${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/*\" to \"${RMAN_PRIMARY_BACKUP_DIR}/\""

    ${SCP_BIN} -r ${RMAN_PRIMARY_HOST_NAME}:${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/* ${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/ | ${TEE_BIN} -a $LOG_FILE_NAME


    # ---------------------------------------------
    # PARTIAL RESYNC - PROPAGATE METADATA FROM THE
    # STANDBY CONTROLFILE TO THE RMAN RECOVERY
    # CATALOG.
    # ---------------------------------------------
    wl " "
    wl "TRACE> PARTIAL RESYNC - Propagate metadata from the standby controlfile to the rman recovery catalog."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY
        $L_RMAN_CONNECT_CATALOG

        resync catalog;

        exit;
EOF


    # ---------------------------------------------
    # FULL RESYNC - PROPAGATE METADATA FROM THE
    # PRIMARY CONTROLFILE TO THE RMAN RECOVERY
    # CATALOG.
    # ---------------------------------------------
    wl " "
    wl "TRACE> FULL RESYNC - Propagate metadata from the primary controlfile to the rman recovery catalog."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_PRIMARY
        $L_RMAN_CONNECT_CATALOG

        resync catalog;

        exit;
EOF


    # ---------------------------------------------
    # REPORT UNRECOVERABLE FILES AND FILES THAT
    # NEED BACKED UP (if any)
    # ---------------------------------------------
    wl " "
    wl "TRACE> Report unrecoverable files and files that need backed up (if any)."

    $ORACLE_HOME/bin/rman <<EOF | ${TEE_BIN} -a $LOG_FILE_NAME
        $L_RMAN_CONNECT_STANDBY

        report need backup;
        report unrecoverable;

        exit; 
EOF


    # ---------------------------------------------
    # COPY ANY REMAINING MISCELLANEOUS FILES TO
    # ORABACKUP
    # ---------------------------------------------
    MISC_ADMIN_FILES=${RMAN_PRIMARY_BACKUP_DIR}/${L_STANDBY_SID}/misc_admin_files
    wl " "
    wl "TRACE> Copy any remaining miscellaneous files to orabackup ($MISC_ADMIN_FILES)."

    ${RM_BIN} -rf $MISC_ADMIN_FILES | ${TEE_BIN} -a $LOG_FILE_NAME
    ${MKDIR_BIN} -pv $MISC_ADMIN_FILES | ${TEE_BIN} -a $LOG_FILE_NAME
    ${CP_BIN} -rv $ORACLE_HOME/network/admin/* $MISC_ADMIN_FILES/ | ${TEE_BIN} -a $LOG_FILE_NAME
    ${CP_BIN} -rv $ORACLE_HOME/dbs/* $MISC_ADMIN_FILES/ | ${TEE_BIN} -a $LOG_FILE_NAME
    ${CP_BIN} -r  $ORACLE_BASE/admin/${L_STANDBY_SID} $MISC_ADMIN_FILES/ | ${TEE_BIN} -a $LOG_FILE_NAME
    ${CP_BIN} -v /home/oracle/.bash_profile $MISC_ADMIN_FILES/bash_profile | ${TEE_BIN} -a $LOG_FILE_NAME
    ${CP_BIN} -v /home/oracle/.bashrc $MISC_ADMIN_FILES/bashrc | ${TEE_BIN} -a $LOG_FILE_NAME

    return

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
wl "TARGET_DB_NAME         (P1)          : $TARGET_DB_NAME"
wl "TARGET_SID             (P2)          : $TARGET_SID"
wl "TARGET_DBA_USERNAME    (P3)          : $TARGET_DBA_USERNAME"
wl "TARGET_DBA_PASSWORD    (P4)          : $HIDE_PASSWORD_STRING"
wl "BACKUP_PROFILE         (P5)          : $BACKUP_PROFILE"
wl "RMAN_RECOVERY_CATALOG  (P6)          : $RMAN_RECOVERY_CATALOG"
wl "CATALOG_DB_NAME        (P7)          : $CATALOG_DB_NAME"
wl "CATALOG_DBA_USERNAME   (P8)          : $CATALOG_DBA_USERNAME"
if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then
    wl "CATALOG_DBA_PASSWORD   (P9)          : $HIDE_PASSWORD_STRING"
else
    wl "CATALOG_DBA_PASSWORD   (P9)          : "
fi

wl " "
wl "==========================================================="
wl "                  CUSTOM SCRIPT VARIABLES                  "
wl "==========================================================="
wl "RMAN_BASELINE_DOW_NUM                : $RMAN_BASELINE_DOW_NUM"
wl "RMAN_BASELINE_DOW_NAME               : $RMAN_BASELINE_DOW_NAME"
wl "RMAN_ARCHIVE_LOG_RETENTION_DAYS      : $RMAN_ARCHIVE_LOG_RETENTION_DAYS"
wl "RMAN_ARCHIVE_LOG_SLEEP_TIME_SECONDS  : $RMAN_ARCHIVE_LOG_SLEEP_TIME_SECONDS"

if [[ $RMAN_TARGET_DB_TYPE = "STANDBY" ]]; then
    wl "RMAN_PRIMARY_DB_NAME                 : $RMAN_PRIMARY_DB_NAME"
    wl "RMAN_PRIMARY_DBA_USERNAME            : $RMAN_PRIMARY_DBA_USERNAME"
    wl "RMAN_PRIMARY_DBA_PASSWORD            : $HIDE_PASSWORD_STRING"
fi


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

verifyDatabaseLoginCredentials $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD "SYSDBA" $UNIQUE_SCRIPT_IDENTIFIER



# +----------------------------------------------------------------------------+
# |                                                                            |
# |                        CUSTOM SCRIPT TASKS (BEGIN)                         |
# |                                                                            |
# +----------------------------------------------------------------------------+

if [[ $RMAN_RECOVERY_CATALOG = "CATALOG" ]]; then

    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| VERIFY THE ORACLE TNS CONNECT STRING IS VALID TO THE CATALOG DATABASE.  |"
    wl "+-------------------------------------------------------------------------+"
    
    verifyTNSConnectString $CATALOG_DB_NAME $UNIQUE_SCRIPT_IDENTIFIER
    

    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| VERIFY LOG IN CREDENTIALS TO THE CATALOG DATABASE.                      |"
    wl "+-------------------------------------------------------------------------+"
    
    verifyDatabaseLoginCredentials $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD "NOSYSDBA" $UNIQUE_SCRIPT_IDENTIFIER

fi

if [[ $RMAN_TARGET_DB_TYPE = "STANDBY" ]]; then

    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| VERIFY THE ORACLE TNS CONNECT STRING IS VALID TO THE PRIMARY DATABASE.  |"
    wl "+-------------------------------------------------------------------------+"
    
    verifyTNSConnectString $RMAN_PRIMARY_DB_NAME $UNIQUE_SCRIPT_IDENTIFIER
    

    DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
    wl " "
    wl "+-------------------------------------------------------------------------+"
    wl "| ${DATE_PRINT_LOG}                                                     |"
    wl "|-------------------------------------------------------------------------|"
    wl "| VERIFY LOG IN CREDENTIALS TO THE PRIMARY DATABASE.                      |"
    wl "+-------------------------------------------------------------------------+"
    
    verifyDatabaseLoginCredentials $RMAN_PRIMARY_DB_NAME $RMAN_PRIMARY_DBA_USERNAME $RMAN_PRIMARY_DBA_PASSWORD "SYSDBA" $UNIQUE_SCRIPT_IDENTIFIER

fi


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| REPORT FLASHBACK DATABASE STATUS.                                       |"
wl "+-------------------------------------------------------------------------+"

reportFlashbackDatabaseStatus $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD


DATE_PRINT_LOG=`date "+%m/%d/%Y %H:%M:%S"`
wl " "
wl "+-------------------------------------------------------------------------+"
wl "| ${DATE_PRINT_LOG}                                                     |"
wl "|-------------------------------------------------------------------------|"
wl "| PERFORM RMAN DATABASE BACKUP PROFILE.                                   |"
wl "+-------------------------------------------------------------------------+"

wl " "
wl "TRACE> RMAN Backup Profile ${BACKUP_PROFILE}"
    
case ${BACKUP_PROFILE} in
    1)  performRMANBackup1 $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD
        ;;
    2)  performRMANBackup2 $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD
        ;;
    3)  performRMANBackup3 $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD
        ;;
    4)  performRMANBackup4 $TARGET_DB_NAME $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD
        ;;
    5)  performRMANBackup5 $TARGET_DB_NAME $TARGET_SID $TARGET_DBA_USERNAME $TARGET_DBA_PASSWORD $CATALOG_DB_NAME $CATALOG_DBA_USERNAME $CATALOG_DBA_PASSWORD $RMAN_PRIMARY_DB_NAME $RMAN_PRIMARY_DBA_USERNAME $RMAN_PRIMARY_DBA_PASSWORD
        ;;
    *)  wl " "
        wl "TRACE> JMA-1001: Invalid RMAN Backup Profile (${BACKUP_PROFILE})."
        wl "TRACE> JMA-1002: Restart this script with a valid Backup Profile value."
        ;;
esac



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

${EGREP_BIN} 'ORA-|JMA-|RMAN-' $LOG_FILE_NAME | ${EGREP_BIN} -v 'RMAN-20242|RMAN-00571|RMAN-00569|RMAN-03002'

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
