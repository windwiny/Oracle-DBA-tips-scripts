-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_move_table.sql                                          |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL syntax used to move a table to an alternative       |
-- |            tablespace.                                                     |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

ALTER TABLE emp MOVE TABLESPACE users2 STORAGE (INITIAL 10M NEXT 1M);
