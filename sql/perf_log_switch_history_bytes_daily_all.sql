-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_log_switch_history_bytes_daily_all.sql                     |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports the amount of redo activity (in MB) each hour using     |
-- |            the archived redo log size per switch. It will query all active |
-- |            archived records from v$archived_log. This script can be used   |
-- |            with Oracle 8 database or higher.                               |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+
SET LINESIZE 250
SET PAGESIZE 9999
SET TRIMSPOOL ON
SET VERIFY   off
COLUMN H00   FORMAT 99,999     HEADING '00'
COLUMN H01   FORMAT 99,999     HEADING '01'
COLUMN H02   FORMAT 99,999     HEADING '02'
COLUMN H03   FORMAT 99,999     HEADING '03'
COLUMN H04   FORMAT 99,999     HEADING '04'
COLUMN H05   FORMAT 99,999     HEADING '05'
COLUMN H06   FORMAT 99,999     HEADING '06'
COLUMN H07   FORMAT 99,999     HEADING '07'
COLUMN H08   FORMAT 99,999     HEADING '08'
COLUMN H09   FORMAT 99,999     HEADING '09'
COLUMN H10   FORMAT 99,999     HEADING '10'
COLUMN H11   FORMAT 99,999     HEADING '11'
COLUMN H12   FORMAT 99,999     HEADING '12'
COLUMN H13   FORMAT 99,999     HEADING '13'
COLUMN H14   FORMAT 99,999     HEADING '14'
COLUMN H15   FORMAT 99,999     HEADING '15'
COLUMN H16   FORMAT 99,999     HEADING '16'
COLUMN H17   FORMAT 99,999     HEADING '17'
COLUMN H18   FORMAT 99,999     HEADING '18'
COLUMN H19   FORMAT 99,999     HEADING '19'
COLUMN H20   FORMAT 99,999     HEADING '20'
COLUMN H21   FORMAT 99,999     HEADING '21'
COLUMN H22   FORMAT 99,999     HEADING '22'
COLUMN H23   FORMAT 99,999     HEADING '23'
COLUMN TOTAL FORMAT 999,999    HEADING 'Total'
SELECT
    SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)                                                               DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',ROUND(((blocks*block_size)/1024/1024)),0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',ROUND(((blocks*block_size)/1024/1024)),0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',ROUND(((blocks*block_size)/1024/1024)),0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',ROUND(((blocks*block_size)/1024/1024)),0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',ROUND(((blocks*block_size)/1024/1024)),0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',ROUND(((blocks*block_size)/1024/1024)),0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',ROUND(((blocks*block_size)/1024/1024)),0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',ROUND(((blocks*block_size)/1024/1024)),0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',ROUND(((blocks*block_size)/1024/1024)),0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',ROUND(((blocks*block_size)/1024/1024)),0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',ROUND(((blocks*block_size)/1024/1024)),0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',ROUND(((blocks*block_size)/1024/1024)),0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',ROUND(((blocks*block_size)/1024/1024)),0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',ROUND(((blocks*block_size)/1024/1024)),0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',ROUND(((blocks*block_size)/1024/1024)),0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',ROUND(((blocks*block_size)/1024/1024)),0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',ROUND(((blocks*block_size)/1024/1024)),0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',ROUND(((blocks*block_size)/1024/1024)),0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',ROUND(((blocks*block_size)/1024/1024)),0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',ROUND(((blocks*block_size)/1024/1024)),0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',ROUND(((blocks*block_size)/1024/1024)),0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',ROUND(((blocks*block_size)/1024/1024)),0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',ROUND(((blocks*block_size)/1024/1024)),0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',ROUND(((blocks*block_size)/1024/1024)),0)) H23
  , ROUND(SUM((blocks*block_size)/1024/1024))                                                                                                           TOTAL
FROM
  v$archived_log  a
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
/

