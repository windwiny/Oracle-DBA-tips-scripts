-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_not_null_constraints.sql                         |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : It is important when designing tables to name your NOT NULL     |
-- |            constraints. The following example provides the syntax necessary|
-- |            to name your NOT NULL constraints.                              |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+


ALTER TABLE user_names
MODIFY (   name            CONSTRAINT user_names_nn1  NOT NULL
         , age             CONSTRAINT user_names_nn2  NOT NULL
         , update_log_date CONSTRAINT user_names_nn3  NOT NULL
)
/

