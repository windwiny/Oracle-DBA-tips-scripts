-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : plsql_random_numbers.sql                                        |
-- | CLASS    : PL/SQL                                                          |
-- | PURPOSE  : PL/SQL implementation of the linear congruential method of      |
-- |            generating random numbers. It is in the form of a PL/SQL        |
-- |            package, so it should be easy add to existing applications.     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CREATE OR REPLACE PACKAGE random IS

  -- Returns random integer between [0, r-1]
  FUNCTION rndint(r IN NUMBER) RETURN NUMBER;

  -- Returns random real between [0, 1]
  FUNCTION rndflt RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY random IS

  m         CONSTANT NUMBER:=100000000;  /* initial conditions */
  m1        CONSTANT NUMBER:=10000;      /* (for best results) */
  b         CONSTANT NUMBER:=31415821;   /*      */
  a         NUMBER;                      /* seed */
  the_date  DATE;                        /*      */
  days      NUMBER;                      /* for generating initial seed */
  secs      NUMBER;                      /*      */

  -- ------------------------
  -- Private utility FUNCTION
  -- ------------------------
  FUNCTION mult(p IN NUMBER, q IN NUMBER) RETURN NUMBER IS
    p1     NUMBER; 
    p0     NUMBER; 
    q1     NUMBER; 
    q0     NUMBER; 
  BEGIN 
    p1:=TRUNC(p/m1); 
    p0:=MOD(p,m1); 
    q1:=TRUNC(q/m1); 
    q0:=MOD(q,m1); 
    RETURN(MOD((MOD(p0*q1+p1*q0,m1)*m1+p0*q0),m)); 
  END;

  -- ---------------------------------------
  -- Returns random integer between [0, r-1]
  -- ---------------------------------------
  FUNCTION rndint (r IN NUMBER) RETURN NUMBER IS 
  BEGIN 
    -- Generate a random NUMBER, and set it to be the new seed
    a:=MOD(mult(a,b)+1,m); 

    -- Convert it to integer between [0, r-1] and return it
    RETURN(TRUNC((TRUNC(a/m1)*r)/m1));
  END;
 
  -- ----------------------------------
  -- Returns random real between [0, 1]
  -- ----------------------------------
  FUNCTION rndflt RETURN NUMBER IS
    BEGIN
      -- Generate a random NUMBER, and set it to be the new seed
      a:=MOD(mult(a,b)+1,m);
      RETURN(a/m);
    END;

BEGIN
  -- Generate initial seed "a" based on system date
  the_date:=SYSDATE;
  days:=TO_NUMBER(TO_CHAR(the_date, 'J'));
  secs:=TO_NUMBER(TO_CHAR(the_date, 'SSSSS'));
  a:=days*24*3600+secs;
END;
/

