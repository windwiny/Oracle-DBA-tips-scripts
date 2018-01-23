-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_log_switch_history_count_daily_7.sql                       |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports on how often log switches occur in your database on a   |
-- |            daily basis. This script is to be used with an Oracle 7         |
-- |            database.                                                       |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY   off

ACCEPT startDate PROMPT 'Enter start date (DD-MON-YYYY): '
ACCEPT endDate   PROMPT 'Enter end date   (DD-MON-YYYY): '

COLUMN H00   FORMAT 999     HEADING '00'
COLUMN H01   FORMAT 999     HEADING '01'
COLUMN H02   FORMAT 999     HEADING '02'
COLUMN H03   FORMAT 999     HEADING '03'
COLUMN H04   FORMAT 999     HEADING '04'
COLUMN H05   FORMAT 999     HEADING '05'
COLUMN H06   FORMAT 999     HEADING '06'
COLUMN H07   FORMAT 999     HEADING '07'
COLUMN H08   FORMAT 999     HEADING '08'
COLUMN H09   FORMAT 999     HEADING '09'
COLUMN H10   FORMAT 999     HEADING '10'
COLUMN H11   FORMAT 999     HEADING '11'
COLUMN H12   FORMAT 999     HEADING '12'
COLUMN H13   FORMAT 999     HEADING '13'
COLUMN H14   FORMAT 999     HEADING '14'
COLUMN H15   FORMAT 999     HEADING '15'
COLUMN H16   FORMAT 999     HEADING '16'
COLUMN H17   FORMAT 999     HEADING '17'
COLUMN H18   FORMAT 999     HEADING '18'
COLUMN H19   FORMAT 999     HEADING '19'
COLUMN H20   FORMAT 999     HEADING '20'
COLUMN H21   FORMAT 999     HEADING '21'
COLUMN H22   FORMAT 999     HEADING '22'
COLUMN H23   FORMAT 999     HEADING '23'
COLUMN TOTAL FORMAT 999,999 HEADING 'Total'


SELECT
    SUBSTR(time,1,5)                        DAY
  , SUM(DECODE(SUBSTR(time,10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(time,10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(time,10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(time,10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(time,10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(time,10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(time,10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(time,10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(time,10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(time,10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(time,10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(time,10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(time,10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(time,10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(time,10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(time,10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(time,10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(time,10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(time,10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(time,10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(time,10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(time,10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(time,10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(time,10,2),'23',1,0)) H23
  , COUNT(*)                                TOTAL
FROM
    v$log_history  a
WHERE
    (TO_DATE(SUBSTR(time, 1,8), 'MM/DD/RR')
     >=
     TO_DATE('&startDate', 'DD-MON-YYYY')
     )
     AND
    (TO_DATE(SUBSTR(time, 1,8), 'MM/DD/RR')
     <=
     TO_DATE('&endDate', 'DD-MON-YYYY')
     )
GROUP BY SUBSTR(time,1,5)
/

