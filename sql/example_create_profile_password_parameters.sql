-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_profile_password_parameters.sql                  |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : The following CREATE FUNCTION and CREATE PROFILE script allow   |
-- |            the DBA to set better password controls for accounts in the     |
-- |            Oracle database. This script is based heavily on the default    |
-- |            script: utlpwdmg.sql                                            |
-- |            Note that this profile does not include parameters used to      |
-- |            limit resources.                                                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CONNECT / as sysdba

/*
 * ------------------------------------------------------------------
 * FIRST CREATE THE PL/SQL PASSWORD VERIFY FUNCTION
 * ------------------------------------------------------------------
 */

CREATE OR REPLACE FUNCTION verify_function (
    username      VARCHAR2
  , password      VARCHAR2
  , old_password  VARCHAR2
) RETURN boolean IS 

  n           BOOLEAN;
  m           INTEGER;
  differ      INTEGER;
  isdigit     BOOLEAN;
  ischar      BOOLEAN;
  ispunct     BOOLEAN;
  digitarray  VARCHAR2(20);
  punctarray  VARCHAR2(25);
  chararray   VARCHAR2(52);

BEGIN

  digitarray:= '0123456789';
  chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  punctarray:='!"#$%&()``*+,-/:;<=>?_';

  -- ---------------------------------------------
  -- CHECK IF THE PASSWORD IS SAME AS THE USERNAME
  -- ---------------------------------------------
  IF NLS_LOWER(password) = NLS_LOWER(username)
  THEN
    raise_application_error(-20001, 'Password same as or similar to user');
  END IF;

  -- ---------------------------------------------
  -- CHECK FOR THE MINIMUM LENGTH OF THE PASSWORD
  -- ---------------------------------------------
  IF length(password) < 4 THEN
    raise_application_error(-20002, 'Password length less than 4');
  END IF;

  -- ---------------------------------------------
  -- CHECK IF THE PASSWORD IS TOO SIMPLE. A 
  -- DICTIONARY OF WORDS MAY BE MAINTAINED AND A 
  -- CHECK MAY BE MADE SO AS NOT TO ALLOW THE
  -- WORDS THAT ARE TOO SIMPLE FOR THE PASSWORD.
  -- ---------------------------------------------
  IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 'password', 'oracle', 'computer', 'abcd') THEN
    raise_application_error(-20002, 'Password too simple');
  END IF;

  -- ---------------------------------------------
  -- CHECK IF THE PASSWORD CONTAINS AT LEAST ONE
  -- LETTER, ONE DIGIT AND ONE PUNCTUATION MARK.
  -- ---------------------------------------------
  -- 1. Check for the digit
  -- ---------------------------------------------
  isdigit:=FALSE;
  m := length(password);
  FOR i IN 1..10 LOOP 
    FOR j IN 1..m LOOP 
      IF substr(password,j,1) = substr(digitarray,i,1) THEN
        isdigit:=TRUE;
        GOTO findchar;
      END IF;
    END LOOP;
  END LOOP;
  IF isdigit = FALSE THEN
    raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
  END IF;

  -- ---------------------------------------------
  -- 2. Check for the character
  -- ---------------------------------------------
  <<findchar>>
  ischar:=FALSE;
  FOR i IN 1..length(chararray) LOOP 
    FOR j IN 1..m LOOP 
      IF substr(password,j,1) = substr(chararray,i,1) THEN
        ischar:=TRUE;
        GOTO findpunct;
      END IF;
    END LOOP;
  END LOOP;
  IF ischar = FALSE THEN
    raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
  END IF;

  -- ---------------------------------------------
  -- 3. Check for the punctuation
  -- ---------------------------------------------
  <<findpunct>>
  ispunct:=FALSE;
  FOR i IN 1..length(punctarray) LOOP 
    FOR j IN 1..m LOOP 
      IF substr(password,j,1) = substr(punctarray,i,1) THEN
        ispunct:=TRUE;
        GOTO endsearch;
      END IF;
    END LOOP;
  END LOOP;
  IF ispunct = FALSE THEN
    raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
  END IF;

  <<endsearch>>
  -- ---------------------------------------------
  -- CHECK IF THE PASSWORD DIFFERS FROM THE
  -- PREVIOUS PASSWORD BY AT LEAST 3 LETTERS
  -- ---------------------------------------------
  IF old_password = '' THEN
    raise_application_error(-20004, 'Old password is null');
  END IF;

  differ := length(old_password) - length(password);

  IF abs(differ) < 3 THEN
    IF length(password) < length(old_password) THEN
      m := length(password);
    ELSE
      m := length(old_password);
    END IF;

    differ := abs(differ);

    FOR i IN 1..m LOOP
      IF substr(password,i,1) != substr(old_password,i,1) THEN
        differ := differ + 1;
      END IF;
    END LOOP;
    IF differ < 3 THEN
      raise_application_error(-20004, 'Password should differ by at least 3 characters');
    END IF;
  END IF;

  -- ---------------------------------------------
  -- Everything is fine; return TRUE
  -- ---------------------------------------------
  RETURN(TRUE);

END;
/



/*
 ** +-----------------------------------------------------------------------------------+
 ** | CREATE PASSWORD PROFILE: developer_profile                                        |
 ** | --------------------------------------------------------------------------------- |
 ** |                                                                                   |
 ** | => FAILED_LOGIN_ATTEMPTS    : Represents the number of failed login attempts that |
 ** |                               can be tried before Oracle locks out an account.    |
 ** |                               Note that the user receives an error message:       |
 ** |                               "ERROR: ORA-28000": The account is locked" upon     |
 ** |                               the locking out of the account due to excessive     |
 ** |                               failed connect attempts.                            |
 ** |                                                                                   |
 ** | => PASSWORD_GRACE_TIME      : This setting is the amount of time a user has to    |
 ** |                               change his or her password once the password        |
 ** |                               expires (from "password_life_time"). This parameter |
 ** |                               is set by using by using either a number that       |
 ** |                               represents days or a number that represents a       |
 ** |                               fraction of a day.                                  |
 ** |                                                                                   |
 ** | => PASSWORD_LIFE_TIME       : This setting determines how long a user's password  |
 ** |                               is good for. Once the time has passed, the password |
 ** |                               expires and the user cannot sign onto the system.   |
 ** |                               To delay the password expiration, use the           |
 ** |                               "PASSWORD_GRACE_TIME" parameter (above).            |
 ** |                                                                                   |
 ** | => PASSWORD_LOCK_TIME       : Determines how long an account will remain locked   |
 ** |                               out if the number of failed attempts, as defined    |
 ** |                               by "FAILED_LOGIN_ATTEMPTS", is exceeded.            |
 ** |                                                                                   |
 ** | => PASSWORD_REUSE_MAX       : This setting defines the number of times a password |
 ** |                               has to be changed before it can be reused. If this  |
 ** |                               parameter is set, the parameter                     |
 ** |                               "PASSWORD_REUSE_TIME" parameter MUST be set to      |
 ** |                               UNLIMITED.                                          |
 ** |                                                                                   |
 ** | => PASSWORD_REUSE_TIME      : This setting defines the number of days before a    |
 ** |                               password can be reused.                             |
 ** |                                                                                   |
 ** | => PASSWORD_VERIFY_FUNCTION : This setting defines the user-defined PL/SQL        |
 ** |                               function that is called to control the complexity   |
 ** |                               of the password.                                    |
 ** |                                                                                   |
 ** | NOTES ON REPRESENTING TIME  :                                                     |
 ** |   To express a fraction of a day for setting, use the notation y/z. In this       |
 ** |   format, z is the total of the fractional part of the day you are representing.  |
 ** |   Therefore, if you use hours, z is 24 (24 hours in a day). If you use minutes,   |
 ** |   z is 1440. If you use seconds, z is 86400.                                      |
 ** |                                                                                   |
 ** |   The y part of the fraction is the fractional part of the z quantity you wish to |
 ** |   represent. For example, if you didn't want to immediately shut a user off when  |
 ** |   his or her password expired - but wanted to give the user six hours to change   |
 ** |   the password - you would use the setting of 1/4 (which is really 6/24, because  |
 ** |   1/4 of a day is six hours). In another example, if you wanted to use 90         |
 ** |   minutes, the proper setting would be 1/16 (90/1440 mathematically reduced).     |
 ** |                                                                                   |
 ** +-----------------------------------------------------------------------------------+
*/

CREATE PROFILE DEVELOPER_PROFILE LIMIT
PASSWORD_LIFE_TIME        60
PASSWORD_GRACE_TIME       10
PASSWORD_REUSE_TIME       1800
PASSWORD_REUSE_MAX        UNLIMITED
FAILED_LOGIN_ATTEMPTS     3
PASSWORD_LOCK_TIME        1/1440
PASSWORD_VERIFY_FUNCTION  verify_function;

