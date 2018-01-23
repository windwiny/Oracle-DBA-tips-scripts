-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_object_cache.sql                                            |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Summary of objects in the shared pool cache.                    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Summary of Objects in the Shared Pool Cache                 |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     OFF
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN inst_id                              HEAD "Inst.|ID"
COLUMN owner         FORMAT a10             HEAD "Owner"
COLUMN name          FORMAT a30             HEAD "Name"
COLUMN db_link       FORMAT a7              HEAD "DB Link"
COLUMN namespace     FORMAT a25             HEAD "Namespace"
COLUMN type          FORMAT a18             HEAD "Type"
COLUMN sharable_mem  FORMAT 99,999,999,999  HEAD "Sharable|Memory"
COLUMN loads                                HEAD "Loads"
COLUMN executions    FORMAT 99,999,999      HEAD "Executions"
COLUMN locks                                HEAD "Locks"
COLUMN pins                                 HEAD "Pins"
COLUMN kept          FORMAT a5              HEAD "Kept?"
COLUMN child_latch                          HEAD "Child Latch"
COLUMN hash_value                           HEAD "Hash Value"
COLUMN address                              HEAD "Address"
COLUMN paddress                             HEAD "Paddress"
COLUMN crsr_plan_hash_value                 HEAD "Cursor Plan|Hash Value"
COLUMN kglobt02                             HEAD "kglobt02"

BREAK ON report

COMPUTE sum OF sharable_mem ON report

DEFINE spool_file=shared_pool_object_cache.lst

SPOOL &spool_file

SELECT
    inst_id                                 inst_id
  , kglnaown                                owner
  , kglnaobj                                name
--  , kglnadlk                                db_link
  , DECODE(   kglhdnsp
            , 0 , 'CURSOR'
            , 1 , 'TABLE/PROCEDURE'
            , 2 , 'BODY'
            , 3 , 'TRIGGER'
            , 4 , 'INDEX'
            , 5 , 'CLUSTER'
            , 6 , 'OBJECT'
            , 13, 'JAVA SOURCE'
            , 14, 'JAVA RESOURCE'
            , 15, 'REPLICATED TABLE OBJECT'
            , 16, 'REPLICATION INTERNAL PACKAGE'
            , 17, 'CONTEXT POLICY'
            , 18, 'PUB_SUB'
            , 19, 'SUMMARY'
            , 20, 'DIMENSION'
            , 21, 'APP CONTEXT'
            , 22, 'STORED OUTLINE'
            , 23, 'RULESET'
            , 24, 'RSRC PLAN'
            , 25, 'RSRC CONSUMER GROUP'
            , 26, 'PENDING RSRC PLAN'
            , 27, 'PENDING RSRC CONSUMER GROUP'
            , 28, 'SUBSCRIPTION'
            , 29, 'LOCATION'
            , 30, 'REMOTE OBJECT'
            , 31, 'SNAPSHOT METADATA'
            , 32, 'JAVA SHARED DATA'
            , 33, 'SECURITY PROFILE'
            , 'INVALID NAMESPACE'
    )                                       namespace
  , DECODE (   BITAND(kglobflg, 3)
             , 0, 'NOT LOADED'
             , 2, 'NON-EXISTENT'
             , 3, 'INVALID STATUS'
             , DECODE (   kglobtyp
                        , 0 , 'CURSOR'
                        , 1 , 'INDEX'
                        , 2 , 'TABLE'
                        , 3 , 'CLUSTER'
                        , 4 , 'VIEW'
                        , 5 , 'SYNONYM'
                        , 6 , 'SEQUENCE'
                        , 7 , 'PROCEDURE'
                        , 8 , 'FUNCTION'
                        , 9 , 'PACKAGE'
                        , 10, 'NON-EXISTENT'
                        , 11, 'PACKAGE BODY'
                        , 12, 'TRIGGER'
                        , 13, 'TYPE'
                        , 14, 'TYPE BODY'
                        , 15, 'OBJECT'
                        , 16, 'USER'
                        , 17, 'DBLINK'
                        , 18, 'PIPE'
                        , 19, 'TABLE PARTITION'
                        , 20, 'INDEX PARTITION'
                        , 21, 'LOB'
                        , 22, 'LIBRARY'
                        , 23, 'DIRECTORY'
                        , 24, 'QUEUE'
                        , 25, 'INDEX-ORGANIZED TABLE'
                        , 26, 'REPLICATION OBJECT GROUP'
                        , 27, 'REPLICATION PROPAGATOR'
                        , 28, 'JAVA SOURCE'
                        , 29, 'JAVA CLASS'
                        , 30, 'JAVA RESOURCE'
                        , 31, 'JAVA JAR'
                        , 32, 'INDEX TYPE'
                        , 33, 'OPERATOR'
                        , 34, 'TABLE SUBPARTITION'
                        , 35, 'INDEX SUBPARTITION'
                        , 36, 'REPLICATED TABLE OBJECT'
                        , 37, 'REPLICATION INTERNAL PACKAGE'
                        , 38, 'CONTEXT POLICY'
                        , 39, 'PUB_SUB'
                        , 40, 'LOB PARTITION'
                        , 41, 'LOB SUBPARTITION'
                        , 42, 'SUMMARY'
                        , 43, 'DIMENSION'
                        , 44, 'APP CONTEXT'
                        , 45, 'STORED OUTLINE'
                        , 46, 'RULESET'
                        , 47, 'RSRC PLAN'
                        , 48, 'RSRC CONSUMER GROUP'
                        , 49, 'PENDING RSRC PLAN'
                        , 50, 'PENDING RSRC CONSUMER GROUP'
                        , 51, 'SUBSCRIPTION'
                        , 52, 'LOCATION'
                        , 53, 'REMOTE OBJECT'
                        , 54, 'SNAPSHOT METADATA'
                        , 55, 'IFS'
                        , 56, 'JAVA SHARED DATA'
                        , 57, 'SECURITY PROFILE'
                        , 'INVALID TYPE'
               )
    )                                       type
  , kglobhs0 + 
    kglobhs1 + 
    kglobhs2 + 
    kglobhs3 + 
    kglobhs4 + 
    kglobhs5 + 
    kglobhs6                                sharable_mem
  , kglhdldc                                loads
  , kglhdexc                                executions
  , kglhdlkc                                locks
  , kglobpc0                                pins
  , DECODE(   kglhdkmk
            , 0 ,'NO'
            , 'YES'
    )                                       kept
--  , kglhdclt                                child_latch
--  , kglnahsh                                hash_value
--  , kglhdadr                                address
--  , kglhdpar                                paddress
--  , kglobt30                                crsr_plan_hash_value
--  , kglobt02                                kglobt02
FROM x$kglob
/ 

SPOOL OFF

SET TERMOUT ON

PROMPT 
PROMPT Report written to &spool_file
PROMPT
