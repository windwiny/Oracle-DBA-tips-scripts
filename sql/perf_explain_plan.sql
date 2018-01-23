-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_explain_plan.sql                                           |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Report the access path of a given STATEMENT_ID contained within |
-- |            a PLAN_TABLE.                                                   |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SELECT
    LPAD(' ',2*level)
  ||operation
  ||' '
  ||options
  ||' '
  ||object_name Q_PLAN
FROM
  plan_table
WHERE
  statement_id = '&&STATEMENT_ID'
CONNECT BY
      prior id     = parent_id
  AND statement_id = '&&STATEMENT_ID'
START WITH
  id = 1
/
