-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_random_number.sql                                           |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : A quick way to produce random numbers using SQL.                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SELECT
  TRUNC( 
    (TO_NUMBER(SUBSTR(TO_CHAR(TO_NUMBER(TO_CHAR(SYSDATE,'sssss'))/86399),-7,7))/10000000)*32767
  ) random 
FROM dual;
