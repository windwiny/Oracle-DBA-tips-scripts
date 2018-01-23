-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_table_buffer_pools.sql                           |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create tables that  |
-- |            will exist in separate buffer pools.                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

/*
 ** +---------------------------------------------------------------------------+
 ** | NOTES:                                                                    |
 ** |                                                                           |
 ** | DEFAULT Buffer Pool                                                       |
 ** | -------------------                                                       |
 ** | (Still refered to as the database buffer cache) is always allocated in    |
 ** | Oracle8 and higher. As with Oracle7, the normal LRU algorithm manages the |
 ** | data blocks in the default buffer pool.                                   |
 ** |                                                                           |
 ** |                                                                           |
 ** | KEEP Buffer Pool                                                          |
 ** | ----------------                                                          |
 ** | In Oracle7, the database allowed the DBA to define tables with the CACHE  |
 ** | option. This allowed tables that where read in from a full table scan to  |
 ** | be placed on the 'most recently used' (MTU) end of the 'least recently    |
 ** | used' (LRU) list, as opposed to the LRU end. The idea was to keep database|
 ** | blocks that where read from a full table scan in the database buffer      |
 ** | cache for a longer period of time before being aged out. These tables     |
 ** | where | typically small tables, such as lookup tables. Oracle8 introduced |
 ** | the capability of reserving part of the default buffer pool for a "KEEP"  |
 ** | buffer pool. This pool can be used as a cache for database blocks that    |
 ** | should not be aged out. Keep in mind that as you allocate memory for the  |
 ** | keep buffer pool, that you are taking away memory from the default buffer |
 ** | pool. If you undersize the KEEP buffer pool, objects will be aged out     |
 ** | using the LRU algorithm, as with the default buffer pool. Also take care  |
 ** | not to oversize this pool as this memory will go wasted and unused.       |
 ** |                                                                           |
 ** | RECYCLE Buffer Pool                                                       |
 ** | -------------------                                                       |
 ** | The purpose of the RECYCLE buffer pool is to store memory blocks that are |
 ** | not likely to be reused again soon. This are usually very large objects,  |
 ** | access to individual blocks may be very random and scattered. A prime     |
 ** | candidate for the RECYCLE buffer pool. It is important to not create the  |
 ** | size of this pool too small. Doing so may cause blocks to age out of the  |
 ** | pool before an application of SQL statement uses them completely. If the  |
 ** | block is aged out before the transaction is done with it, it needs to be  |
 ** | re-read from disk, causing more I/O.                                      |
 ** |                                                                           |
 ** |                                                                           |
 ** | Init.ora Settings                                                         |
 ** | -----------------                                                         |
 ** | DB_BLOCK_BUFFERS = 2000       # Allocate 2000 blocks to the default buffer|
 ** |                               #   cache.                                  |
 ** | DB_BLOCK_LRU_LATCHES = 6      # Configure the number of LRU latches. The  |
 ** |                               #   default is CPU_COUNT/2 and the maximum  |
 ** |                               #   is CPU_COUNT.                           |
 ** | BUFFER_POOL_KEEP = (BUFFERS:100, LRU_LATCHES:2)                           |
 ** |                               # Configure the keep buffer pool. Assign 100|
 ** |                               #   blocks to it from the default buffer    |
 ** |                               #   pool and 2 LRU latches.                 |
 ** | BUFFER_POOL_RECYCLE = (BUFFERS:100, LRU_LATCHES:1)                        |
 ** |                               # Configure the recycle buffer pool. Assign |
 ** |                               #   100 blocks to it from the database      |
 ** |                               #   buffer pool and 1 LRU latch.            |
 ** |                                                                           |
 ** | NOTE: Some documentation states to use 'nbuf,nlat' but this may not work  |
 ** |       correctly - use the full string ("buffers:nbuf","lru_latches:Nlat") |
 ** |                                                                           |
 ** | Oracle9i NOTE !!!                                                         |
 ** | -----------------                                                         |
 ** | The above database block cache parameters are deprecated in               |
 ** | Oracle9i in favor of:   -->   <Parameter:DB_CACHE_SIZE>                   |
 ** |                         -->   <Parameter:DB_KEEP_CACHE_SIZE>              |
 ** |                         -->   <Parameter:DB_RECYCLE_CACHE_SIZE>           |
 ** | Oracle recommends that you use these new parameters instead. Also,        |
 ** | BUFFER_POOL_KEEP cannot be combined with the new dynamic                  |
 ** | DB_KEEP_CACHE_SIZE parameter just as BUFFER_POOL_RECYCLE cannot be used   |
 ** | with the dynamic parameter DB_RECYCLE_CACHE_SIZE. Combining these         |
 ** | parameters in the same parameter file will produce an error.              |
 ** | DB_BLOCK_BUFFERS, BUFFER_POOL_KEEP and BUFFER_POOL_RECYCLE are being      |
 ** | retained for backward compatibility only.                                 |
 ** +---------------------------------------------------------------------------+
*/

/*
 ** --------------------------------------------------------
 ** -----------      CREATE TABLE (EMP)      ---------------
 ** -----------       BUFFER_POOL_KEEP       ---------------
 ** --------------------------------------------------------
*/

prompt Dropping Table (emp)...

DROP TABLE emp CASCADE CONSTRAINTS
/

prompt Creating Table (emp)...

CREATE TABLE emp (
      empno     NUMBER(4)
    , ename     VARCHAR2(10)
    , job       VARCHAR2(9)
    , mgr       NUMBER(4)
    , hiredate  DATE
    , sal       NUMBER(7,2)
    , comm      NUMBER(7,2)
    , deptno    NUMBER(2)
)
TABLESPACE users
STORAGE (
    INITIAL      128K
    NEXT         128K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
    BUFFER_POOL  KEEP
)
/

/*
 ** --------------------------------------------------------
 ** -----------      CREATE TABLE (DEPT)      --------------
 ** -----------      BUFFER_POOL_RECYCLE      --------------
 ** --------------------------------------------------------
*/

prompt Dropping Table (dept)...

DROP TABLE dept CASCADE CONSTRAINTS
/

prompt Creating Table (dept)...

CREATE TABLE dept (
      deptno   NUMBER(2)
    , dname    VARCHAR2(14)
    , loc      VARCHAR2(13)
)
TABLESPACE users
STORAGE (
    INITIAL      128K
    NEXT         128K
    MINEXTENTS   1
    MAXEXTENTS   121
    PCTINCREASE  0
    BUFFER_POOL  RECYCLE
)
/

