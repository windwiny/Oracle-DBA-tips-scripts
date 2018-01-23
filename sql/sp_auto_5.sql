-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_auto_5.sql                                                   |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : This script is responsible to configure a DBMS Job to be run    |
-- |            every 5 minutes starting at the quarter of each hour. For       |
-- |            example, if this script is run at 10:32 pm, the first job will  |
-- |            be run at 10:35 pm, then the next job at 10:40 pm and so on     |
-- |            every 5 minutes.                                                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

PROMPT 
PROMPT =========================================================================
PROMPT The following script will create a new DBMS Job to be run at the quarter
PROMPT of each hour. (i.e. Every 5 minutes). The job will perform a Statspack
PROMPT snapshot using the Oracle supplied STATSPACK package.
PROMPT 
PROMPT Note that this script should be run as the owner of the 
PROMPT STATSPACK repository. (i.e. PERFSTAT)
PROMPT This script will prompt you for the PERFSTAT password.
PROMPT 
PROMPT Also note that in order to submit and run a job, the init.ora parameter
PROMPT job_queue_processes must be set to a value greater than zero.
PROMPT =========================================================================
PROMPT
PROMPT Hit [ENTER] to continue or CTRL-C to cancel ...
PAUSE

PROMPT Supply the password for the PERFSTAT user:
CONNECT perfstat


-- +------------------------------------------------------------------------+
-- | SCHEDULE A SNAPSHOT TO BE RUN EVERY 5 MINUTES.                         |
-- +------------------------------------------------------------------------+

VARIABLE jobno  NUMBER;
VARIABLE instno NUMBER;

BEGIN

  SELECT instance_number into :instno
  FROM   v$instance;

  DBMS_JOB.SUBMIT(   :jobno
                   , 'statspack.snap;'
                   , TRUNC(sysdate,'HH24')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,'MI'))/5)+1)*5)/(24*60)
                   , 'TRUNC(sysdate,''HH24'')+((FLOOR(TO_NUMBER(TO_CHAR(sysdate,''MI''))/5)+1)*5)/(24*60)'
                   , TRUE
                   , :instno);

  COMMIT;

END;
/

PROMPT 
PROMPT 
PROMPT +----------------------------------+
PROMPT | JOB NUMBER                       |
PROMPT |------------------------------------------------------------------+
PROMPT | The following job number should be noted as it will be required  |
PROMPT | when modifying or removing prompt the job:                       |
PROMPT +------------------------------------------------------------------+
PROMPT 

PRINT jobno


PROMPT 
PROMPT 
PROMPT +----------------------------------+
PROMPT | JOB QUEUE PROCESS CONFIGURATION  |
PROMPT |------------------------------------------------------------------+
PROMPT | Below is the current setting of the job_queue_processes init.ora |
PROMPT | parameter - the value for this parameter must be greater than 0  |
PROMPT | to use automatic statistics gathering:                           |
PROMPT +------------------------------------------------------------------+
PROMPT 

SHOW PARAMETER job_queue_processes

PROMPT 
PROMPT 
PROMPT +----------------------------------+
PROMPT | NEXT SCHEDULED RUN               |
PROMPT |------------------------------------------------------------------+
PROMPT | The next scheduled run for this job is:                          |
PROMPT +------------------------------------------------------------------+
PROMPT 

SELECT job, next_date, next_sec
FROM   user_jobs
WHERE  job = :jobno;

