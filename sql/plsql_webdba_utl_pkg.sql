-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : plsql_webdba_utl_pkg.sql                                        |
-- | CLASS    : PL/SQL                                                          |
-- | PURPOSE  : Example PL/SQL package that shows how to use dynamic SQL before |
-- |            Oracle8i.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CREATE OR REPLACE PACKAGE webdba_util AS

  PROCEDURE drop_user(username_in IN VARCHAR2);
  PROCEDURE create_user(username_in             IN VARCHAR2, 
                        default_tablespace_in   IN VARCHAR2,
                        temporary_tablespace_in IN VARCHAR2,
                        password_in             IN VARCHAR2);
  PROCEDURE change_user_password(username_in IN VARCHAR2,
                                password_in IN VARCHAR2);
  PROCEDURE grant_user(username_in IN VARCHAR2,
                       privilege_in IN VARCHAR2);
  PROCEDURE revoke_user(username_in IN VARCHAR2,
                       privilege_in IN VARCHAR2);
  
END webdba_util;
/
show errors

CREATE OR REPLACE PACKAGE BODY webdba_util AS

  PROCEDURE drop_user(username_in IN VARCHAR2) IS
    v_Cursor           NUMBER;
    v_DropUserString   VARCHAR2(500);
    v_Results          INTEGER;
  BEGIN

    v_Cursor  := DBMS_SQL.open_cursor;
    v_DropUserString := 'DROP USER ' || username_in || ' CASCADE';

    DBMS_SQL.PARSE(v_Cursor, v_DropUserString, DBMS_SQL.V7);
    v_Results := DBMS_SQL.EXECUTE(v_Cursor);

    DBMS_SQL.close_cursor(v_Cursor);

  END drop_user;

  PROCEDURE create_user(username_in             IN VARCHAR2,
                        default_tablespace_in   IN VARCHAR2,
                        temporary_tablespace_in IN VARCHAR2,
                        password_in             IN VARCHAR2) IS
    v_Cursor           NUMBER;
    v_DropUserString   VARCHAR2(1500);
    v_Results          INTEGER;
  BEGIN

    v_Cursor  := DBMS_SQL.open_cursor;
    v_DropUserString := 'CREATE USER ' || username_in || ' DEFAULT TABLESPACE ' || default_tablespace_in ||
' TEMPORARY TABLESPACE ' || temporary_tablespace_in || ' IDENTIFIED BY ' || password_in;

    DBMS_SQL.PARSE(v_Cursor, v_DropUserString, DBMS_SQL.V7);
    v_Results := DBMS_SQL.EXECUTE(v_Cursor);

    DBMS_SQL.close_cursor(v_Cursor);

  END create_user;


  PROCEDURE change_user_password(username_in IN VARCHAR2,
                                 password_in IN VARCHAR2) IS
    v_Cursor           NUMBER;
    v_AlterUserString   VARCHAR2(500);
    v_Results          INTEGER;
  BEGIN

    v_Cursor  := DBMS_SQL.open_cursor;
    v_AlterUserString := 'ALTER USER ' || username_in || ' IDENTIFIED BY ' || password_in;

    DBMS_SQL.PARSE(v_Cursor, v_AlterUserString, DBMS_SQL.V7);
    v_Results := DBMS_SQL.EXECUTE(v_Cursor);

    DBMS_SQL.close_cursor(v_Cursor);

  END change_user_password;

  PROCEDURE grant_user(username_in IN VARCHAR2,
                       privilege_in IN VARCHAR2) IS
    v_Cursor           NUMBER;
    v_AlterUserString   VARCHAR2(500);
    v_Results          INTEGER;
  BEGIN

    v_Cursor  := DBMS_SQL.open_cursor;
    v_AlterUserString := 'GRANT ' || privilege_in || ' TO ' || username_in;

    DBMS_SQL.PARSE(v_Cursor, v_AlterUserString, DBMS_SQL.V7);
    v_Results := DBMS_SQL.EXECUTE(v_Cursor);

    DBMS_SQL.close_cursor(v_Cursor);

  END grant_user;

  PROCEDURE revoke_user(username_in IN VARCHAR2,
                       privilege_in IN VARCHAR2) IS
    v_Cursor           NUMBER;
    v_AlterUserString   VARCHAR2(500);
    v_Results          INTEGER;
  BEGIN

    v_Cursor  := DBMS_SQL.open_cursor;
    v_AlterUserString := 'REVOKE ' || privilege_in || ' FROM ' || username_in;

    DBMS_SQL.PARSE(v_Cursor, v_AlterUserString, DBMS_SQL.V7);
    v_Results := DBMS_SQL.EXECUTE(v_Cursor);

    DBMS_SQL.close_cursor(v_Cursor);

  END revoke_user;


END webdba_util;
/

SHOW ERRORS

