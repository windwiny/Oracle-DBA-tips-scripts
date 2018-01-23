-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_tablespace.sql                                   |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create several      |
-- |            types of tablespaces in Oracle7 - 11g.                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


-- +-----------------------------------------------------------------+
-- | (Oracle9i and higher)                                           |
-- | ORACLE MANAGED FILES (OMF)                                      |
-- +-----------------------------------------------------------------+

CREATE TABLESPACE users
  LOGGING DATAFILE SIZE 500M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
  SEGMENT SPACE MANAGEMENT AUTO
/


-- +-----------------------------------------------------------------+
-- | (Oracle9i and higher)                                           |
-- | SEGMENT SPACE MANAGEMENT AUTO                                   |
-- +-----------------------------------------------------------------+

CREATE TABLESPACE users
  LOGGING DATAFILE '/u10/app/oradata/ORA920/users01.dbf' SIZE 500M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
  SEGMENT SPACE MANAGEMENT AUTO
/


-- +---------------------------------------------------------------------------+
-- | (Oracle8i and higher) - In version Oracle9i and higher, you               |
-- |                         create the temporary tablespace as part           |
-- |                         of the CREATE TABLESPACE statement:               |
-- |                                                                           |
-- |                           ...                                             |
-- |                           DEFAULT TEMPORARY TABLESPACE temp               |
-- |                             TEMPFILE '/u07/app/oradata/ORA920/temp01.dbf' |
-- |                             SIZE 500M REUSE                               |
-- |                             AUTOEXTEND ON NEXT 500M MAXSIZE 1500M         |
-- |                           ...                                             |
-- | TEMPORARY TABLESPACES                                                     |
-- +---------------------------------------------------------------------------+

CREATE TEMPORARY TABLESPACE temp
  TEMPFILE '/u07/app/oradata/ORA920/temp01.dbf' SIZE 500M REUSE
  AUTOEXTEND on NEXT 100M MAXSIZE unlimited
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M
/


-- +-----------------------------------------------------------------+
-- | (Oracle8i and higher)                                           |
-- | LOCALLY MANAGED TABLESPACES - with AUTOALLOCATE clause          |
-- |                                                                 |
-- | Use AUTOALLOACTE clause, if the tablespace is expected to       |
-- | contain objects of varying sizes requiring different extent     |
-- | sizes and having many extents. AUTOALLOCATE is default.         |
-- +-----------------------------------------------------------------+

CREATE TABLESPACE users
  LOGGING DATAFILE '/u10/app/oradata/ORA817/users01.dbf' SIZE 100M REUSE
  AUTOEXTEND ON NEXT 100M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
/


-- +-----------------------------------------------------------------+
-- | (Oracle8i and higher)                                           |
-- | LOCALLY MANAGED TABLESPACES - with UNIFORM SIZE clause          |
-- |                                                                 |
-- | Use UNIFORM SIZE clause if you want exact control over          |
-- | unused space, and you can predict exactly the space to be       |
-- | allocated for an object or objects and the number and size      |
-- | of extents. Default extent size is 1M, if you do not specify    | 
-- | size parameter.                                                 |
-- +-----------------------------------------------------------------+

CREATE TABLESPACE users
  LOGGING DATAFILE '/u10/app/oradata/ORA817/users01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 512K
/


-- +-----------------------------------------------------------------+
-- | (All versions of Oracle)                                        |
-- | DICTIONARY MANAGED TABLESPACE                                   |
-- +-----------------------------------------------------------------+

CREATE TABLESPACE users
  DATAFILE '/u10/app/oradata/ORA734/users01.dbf' SIZE 10M
  DEFAULT STORAGE (initial 64k next 64k maxextents 121 pctincrease 0)
/

