-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_transport_tablespace.sql                                |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example script that demonstrates how to use the transportable   |
-- |            tablespace feature.                                             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

connect "/ as sysdba"

set serveroutput on

Prompt =====================================================
Prompt THE FOLLOWING EXAMPLE WILL TRANSPORT THE TABLESPACES
Prompt "users" and "users2" FROM DATABASE "CUSTDB" TO "DWDB"
Prompt =====================================================
Prompt
Prompt

Prompt ==========================================
Prompt VERIFY TABLESPACE(s) ARE SELF-CONTAINED...
Prompt ==========================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

exec DBMS_TTS.TRANSPORT_SET_CHECK('users, users2', TRUE);

SELECT * FROM TRANSPORT_SET_VIOLATIONS;


Prompt ==========================================
Prompt GENERATE A TRANSPORTABLE TABLESPACE SET...
Prompt ==========================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

ALTER TABLESPACE users READ ONLY;
ALTER TABLESPACE users2 READ ONLY;

!exp userid=\"sys/change_on_install@custdb_jeffreyh3\" transport_tablespace=y tablespaces=users,users2 triggers=y constraints=y grants=y file=users.dmp

!cp /u10/app/oradata/CUSTDB/users01.dbf /u10/app/oradata/DWDB/users01.dbf
!cp /u10/app/oradata/CUSTDB/users2_02.dbf /u10/app/oradata/DWDB/users2_02.dbf

ALTER TABLESPACE users READ WRITE;
ALTER TABLESPACE users2 READ WRITE;


Prompt ===============================
Prompt LOGGING INTO TARGET DATABASE...
Prompt ===============================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

connect sys/change_on_install@dwdb_jeffreyh3 as sysdba


Prompt ============================
Prompt IMPORT THE TABLESPACE SET...
Prompt ============================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

!imp userid=\"sys/change_on_install@dwdb_jeffreyh3 as sysdba\" transport_tablespace=y datafiles='/u10/app/oradata/DWDB/users01.dbf, /u10/app/oradata/DWDB/users2_02.dbf' file=users.dmp


Prompt =================================================
Prompt FINAL CLEANUP. ALTER TABLESPACES TO READ/WRITE...
Prompt =================================================
Prompt
accept a1 Prompt "Hit <ENTER> to continue";

ALTER TABLESPACE users READ WRITE;
ALTER TABLESPACE users2 READ WRITE;
