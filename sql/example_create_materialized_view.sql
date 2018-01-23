-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_materialized_view.sql                            |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script that demonstrates how to create several      |
-- |            materialized views.                                             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CREATE MATERIALIZED VIEW flight_fact_mv
  BUILD IMMEDIATE
  REFRESH COMPLETE ON COMMIT
  ENABLE QUERY REWRITE
  AS
  SELECT
      plane_id           PLANE_ID
    , sum(sale_amount)   SUM_SALE_AMOUNT
  FROM   scott.flight_fact
  GROUP BY plane_id
/


CREATE MATERIALIZED VIEW monthly_salary_mv
  BUILD IMMEDIATE
  REFRESH COMPLETE ON COMMIT
  ENABLE QUERY REWRITE
  AS
  SELECT
      b.name            DEPT_NAME
    , a.monthly_salary  AVG_MONTHLY_SALARY
  FROM emp a, dept b
/

