-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_profile_resource_parameters.sql                  |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : The following script provides syntax on how to create an Oracle |
-- |            profile to be used in limiting resources. The profile in this   |
-- |            example does not provide parameters related to password         |
-- |            security.                                                       |
-- |                                                                            |
-- |            Oracle Database enforces resource limits in the following ways: |
-- |                                                                            |
-- |              (*) If a user exceeds the CONNECT_TIME or IDLE_TIME session   |
-- |                  resource limit, then the database rolls back the current  |
-- |                  transaction and ends the session. When the user process   |
-- |                  next issues a call, the database returns an error.        |
-- |                                                                            |
-- |              (*) If a user attempts to perform an operation that exceeds   |
-- |                  the limit for other session resources, then the database  |
-- |                  aborts the operation, rolls back the current statement,   |
-- |                  and immediately returns an error. The user can then       |
-- |                  commit or roll back the current transaction, and must     |
-- |                  then end the session.                                     |
-- |                                                                            |
-- |              (*) If a user attempts to perform an operation that exceeds   |
-- |                  the limit for a single call, then the database aborts the |
-- |                  operation, rolls back the current statement, and returns  |
-- |                  an error, leaving the current transaction intact.         |
-- |                                                                            |
-- |            NOTES:                                                          |
-- |                                                                            |
-- |              (*) You can use fractions of days for all parameters that     |
-- |                  limit time, with days as units. For example, 1 hour is    |
-- |                  1/24 and 1 minute is 1/1440. None of the resource         |
-- |                  parameters are specified in days!                         |
-- |                                                                            |
-- |              (*) You can specify resource limits for users regardless of   |
-- |                  whether the resource limits are enabled. However, Oracle  |
-- |                  Database does not enforce the limits until you enable     |
-- |                  them.                                                     |
-- |                                                                            |
-- |              (*) After you set up the new profile, you must edit your      |
-- |                  INIT.ORA file and set:                                    |
-- |                                                                            |
-- |                      RESOURCE_LIMIT = TRUE                                 |
-- |                                                                            |
-- |                  if you attempt to limit any of the profile resources      |
-- |                  below:                                                    |
-- |                                                                            |
-- |                      SESSIONS_PER_USER                                     |
-- |                      CPU_PER_SESSION                                       |
-- |                      CPU_PER_CALL                                          |
-- |                      CONNECT_TIME                                          |
-- |                      IDLE_TIME                                             |
-- |                      LOGICAL_READS_PER_SESSION                             |
-- |                      COMPOSITE_LIMIT                                       |
-- |                      PRIVATE_SGA                                           |
-- |                                                                            |
-- |                  You can also modify the "RESOURCE_LIMIT" parameter on the |
-- |                  SYSTEM level via:                                         |
-- |                                                                            |
-- |                      ALTER SYSTEM SET RESOURCE_LIMIT = TRUE;               |
-- |                                                                            |
-- |                  Note though; this will only apply for new users login     |
-- |                  onto the database - not the existing users currently      |
-- |                  logged on.                                                |
-- |                                                                            |
-- |                  It is possible to check the current information on this   |
-- |                  parameter by performing the below SELECT:                 |
-- |                                                                            |
-- |                      SELECT * FROM V$PARAMETER                             |
-- |                      WHERE NAME = 'resource_limit';                        |
-- |                                                                            |
-- |              (*) When specified with a resource parameter (like those      |
-- |                  parameters defined in this example script), UNLIMITED     |
-- |                  indicates that a user assigned this profile can use an    |
-- |                  unlimited amount of this resource. When specified with a  |
-- |                  password parameter, UNLIMITED indicates that no limit has |
-- |                  been set for the parameter.                               |
-- |                                                                            |
-- |              (*) Specify DEFAULT if you want to omit a limit for this      |
-- |                  resource in this profile. A user assigned this profile is |
-- |                  subject to the limit for this resource specified in the   |
-- |                  DEFAULT profile. The DEFAULT profile initially defines    |
-- |                  unlimited resources. You can change those limits with the |
-- |                  ALTER PROFILE statement.                                  |
-- |                                                                            |
-- |                  Any user who is not explicitly assigned a profile is      |
-- |                  subject to the limits defined in the DEFAULT profile.     |
-- |                  Also, if the profile that is explicitly assigned to a     |
-- |                  user omits limits for some resources or specifies DEFAULT |
-- |                  for some limits, then the user is subject to the limits   |
-- |                  on those resources defined by the DEFAULT profile.        |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CONNECT / as sysdba


/*
 ** +-----------------------------------------------------------------------------------+
 ** | CREATE PASSWORD PROFILE: developer_profile                                        |
 ** | --------------------------------------------------------------------------------- |
 ** |                                                                                   |
 ** | => SESSIONS_PER_USER            : Specify the number of concurrent sessions to    |
 ** |                                   which you want to limit the user. When a user   |
 ** |                                   attempts to create a new session that exceeds   |
 ** |                                   the given threshold, they will not be allowed   |
 ** |                                   to login with that new session and presented    |
 ** |                                   with an ORA-02391 error.                        |
 ** |                                                                                   |
 ** | => CPU_PER_SESSION              : Specify the CPU time limit for a session,       |
 ** |                                   expressed in hundredth of seconds. If the user  |
 ** |                                   exceeds this time limit, they are logged off    |
 ** |                                   with an ORA-02392 error.                        |
 ** |                                                                                   |
 ** | => CPU_PER_CALL                 : Specify the CPU time limit for a call (a parse, |
 ** |                                   execute, or fetch), expressed in hundredths of  |
 ** |                                   seconds. If the user exceeds this time limit,   |
 ** |                                   they are logged off with an ORA-02393 error.    |
 ** |                                                                                   |
 ** | => CONNECT_TIME                 : Specify the total elapsed time limit for a      |
 ** |                                   session, expressed in minutes. When a user      |
 ** |                                   session exceeds the given threshold, they are   |
 ** |                                   logged off and presented with an ORA-02399      |
 ** |                                   error.                                          |
 ** |                                                                                   |
 ** | => IDLE_TIME                    : Specify the permitted periods of continuous     |
 ** |                                   inactive time during a session, expressed in    |
 ** |                                   minutes. Long-running queries and other         |
 ** |                                   operations are not subject to this limit. When  |
 ** |                                   a user session exceeds the given threshold,     |
 ** |                                   they are logged off and presented with an       |
 ** |                                   ORA-02396 error.                                |
 ** |                                                                                   |
 ** | => LOGICAL_READS_PER_SESSION    : Specify the permitted number of data blocks     |
 ** |                                   read in a session, including blocks read from   |
 ** |                                   memory and disk. When a user session exceeds    |
 ** |                                   the given threshold, they are logged off and    |
 ** |                                   presented with an ORA-02394 error.              |
 ** |                                                                                   |
 ** | => LOGICAL_READS_PER_CALL       : Specify the permitted number of data blocks     |
 ** |                                   read for a call to process a SQL statement      |
 ** |                                   (a parse, execute, or fetch). When a user       |
 ** |                                   session exceeds the given threshold, they are   |
 ** |                                   logged off and presented with an ORA-02395      |
 ** |                                   error.                                          |
 ** |                                                                                   |
 ** | => PRIVATE_SGA                  : Specify the amount of private space a session   |
 ** |                                   can allocate in the shared pool of the system   |
 ** |                                   global area (SGA) specified using the           |
 ** |                                   "size_clause". The size_clause lets you specify |
 ** |                                   a number of bytes, kilobytes (K), megabytes (M),|
 ** |                                   gigabytes (G), terabytes (T), petabytes (P), or |
 ** |                                   exabytes (E) in any statement that lets you     |
 ** |                                   establish amounts of disk or memory space. Use  |
 ** |                                   the size_clause to specify a number or multiple |
 ** |                                   of bytes. If you do not specify any of the      |
 ** |                                   multiple abbreviations, the integer is          |
 ** |                                   interpreted as bytes.                           |
 ** |                                                                                   |
 ** |                                   NOTE:                                           |
 ** |                                   This limit applies only if you are using shared |
 ** |                                   server architecture. The private space for a    |
 ** |                                   session in the SGA includes private SQL and     |
 ** |                                   PL/SQL areas, but not shared SQL and PL/SQL     |
 ** |                                   areas.                                          |
 ** |                                                                                   |
 ** | => COMPOSITE_LIMIT              : Specify the total resource cost for a session,  |
 ** |                                   expressed in service units. Oracle Database     |
 ** |                                   calculates the total service units as a         |
 ** |                                   weighted sum of CPU_PER_SESSION, CONNECT_TIME,  |
 ** |                                   LOGICAL_READS_PER_SESSION, and PRIVATE_SGA.     |
 ** |                                                                                   |
 ** +-----------------------------------------------------------------------------------+
*/


/*
 ** +-----------------------------------------------------------------------------------+
 ** | If you assign the developer_profile profile to a user (as defined below), the     |
 ** | user is subject to the following limits in subsequent sessions:                   |
 ** |                                                                                   |
 ** |   =>  The user can have any number of concurrent sessions.                        |
 ** |   =>  In a single session, the user cannot consume more than 120 seconds          |
 ** |       (2 minutes) of CPU time.                                                    |
 ** |   =>  A single call made by the user cannot consume more than 30 seconds of CPU   |
 ** |       time.                                                                       |
 ** |   =>  A single session cannot last for more than 45 minutes.                      |
 ** |   =>  A single session cannot be idle for more than 5 minutes.                    |
 ** |   =>  In a single session, the number of data blocks read from memory and disk    |
 ** |       is subject to the limit specified in the DEFAULT profile.                   |
 ** |   =>  A single call made by the user cannot read more than 1000 data blocks from  |
 ** |       memory and disk.                                                            |
 ** |   =>  A single session cannot allocate more than 15 kilobytes of memory in the    |
 ** |       SGA.                                                                        |
 ** |   =>  In a single session, the total resource cost cannot exceed 5 million        |
 ** |       service units. The formula for calculating the total resource cost is       |
 ** |       specified by the ALTER RESOURCE COST statement.                             |
 ** |   =>  Since the developer_profile profile omits a limit for password limits, the  |
 ** |       user is subject to the limits on these resources specified in the DEFAULT   |
 ** |       profile.                                                                    |
 ** +-----------------------------------------------------------------------------------+
*/


CREATE PROFILE developer_profile LIMIT 
    SESSIONS_PER_USER          UNLIMITED
    CPU_PER_SESSION            12000
    CPU_PER_CALL               3000
    CONNECT_TIME               45
    IDLE_TIME                  5
    LOGICAL_READS_PER_SESSION  DEFAULT
    LOGICAL_READS_PER_CALL     1000
    PRIVATE_SGA                15K
    COMPOSITE_LIMIT            5000000
/

