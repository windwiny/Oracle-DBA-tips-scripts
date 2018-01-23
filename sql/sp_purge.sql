-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : sp_purge.sql                                                    |
-- | CLASS    : Statspack                                                       |
-- | PURPOSE  : This is a wrapper script to the Oracle supplied sppurge.sql.    |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

PROMPT 
PROMPT =========================================================================
PROMPT The following script is a wrapper script to the Oracle supplied SQL
PROMPT script ?/rdbms/admin/sppurge.sql.
PROMPT 
PROMPT The Oracle supplied script sppurge.sql will prompt the user for two 
PROMPT snapshot IDs; a low snapshot ID and a high snapshot ID. The script
PROMPT will then remove all records contained in that range.
PROMPT 
PROMPT Note that this script should be run as the owner of the 
PROMPT STATSPACK repository.
PROMPT 
PROMPT Also note that a major portion of the sppurge.sql script is
PROMPT commented out for performance reasons. Search for the string
PROMPT "Delete any dangling SQLtext" and uncomment out the section
PROMPT below it.
PROMPT =========================================================================
PROMPT
PROMPT Hit [ENTER] to continue or CTRL-C to cancel ...
PAUSE

@?/rdbms/admin/sppurge.sql
