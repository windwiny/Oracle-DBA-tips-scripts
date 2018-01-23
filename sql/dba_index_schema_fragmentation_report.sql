-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_index_schema_fragmentation_report.sql                       |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Rebuilds an index to determine how fragmented it is.            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Index Fragmentation Report for a Specified Schema                      |
PROMPT |------------------------------------------------------------------------|
PROMPT | Rebuild the index when:                                                |
PROMPT |     [*] deleted entries represent 20% or more of the current entries   |
PROMPT |     [*] the index depth is more then 4 levels                          |
PROMPT |                                                                        |
PROMPT | Possible candidate for bitmap index:                                   |
PROMPT |     [*] when distinctiveness is more than 99%                          |
PROMPT +------------------------------------------------------------------------+

PROMPT 
ACCEPT schema CHAR prompt 'Schema name (% allowed) : '
PROMPT 

SPOOL index_schema_fragmentation_report_&schema..lst

SET SERVEROUTPUT    ON

SET ECHO            OFF
SET FEEDBACK        6
SET HEADING         ON
SET LINESIZE        180
SET PAGESIZE        50000
SET TERMOUT         ON
SET TIMING          OFF
SET TRIMOUT         ON
SET TRIMSPOOL       ON
SET VERIFY          OFF

DECLARE

    c_name          INTEGER;
    ignore          INTEGER;
    height          index_stats.height%TYPE := 0;
    lf_rows         index_stats.lf_rows%TYPE := 0;
    del_lf_rows     index_stats.del_lf_rows%TYPE := 0;
    distinct_keys   index_stats.distinct_keys%TYPE := 0;

    CURSOR c_indx IS
        SELECT owner, table_name, index_name
        FROM dba_indexes
        WHERE owner LIKE upper('&schema')
          AND owner NOT IN ('SYS','SYSTEM');

BEGIN 
    dbms_output.enable (1000000);
    dbms_output.put_line ('Owner           Index Name                              % Deleted Entries Blevel Distinctiveness');
    dbms_output.put_line ('--------------- --------------------------------------- ----------------- ------ ---------------');

    c_name := DBMS_SQL.OPEN_CURSOR;

    FOR r_indx in c_indx LOOP
        DBMS_SQL.PARSE(c_name,'analyze index ' || r_indx.owner || '.' || r_indx.index_name || ' validate structure', DBMS_SQL.NATIVE);
        ignore := DBMS_SQL.EXECUTE(c_name);

        SELECT
              height
            , DECODE (lf_rows, 0, 1, lf_rows)
            , del_lf_rows
            , DECODE (distinct_keys, 0, 1, distinct_keys)  
        INTO
              height
            , lf_rows
            , del_lf_rows
            , distinct_keys
        FROM index_stats;

        -- 
        -- Index is considered as candidate for rebuild when :
        --   - when deleted entries represent 20% or more of the current entries
        --   - when the index depth is more then 4 levels.(height starts counting from 1 so > 5)
        -- Index is (possible) candidate for a bitmap index when :
        --   - distinctiveness is more than 99% 
        -- 
        IF ( height > 5 ) OR ( (del_lf_rows/lf_rows) > 0.2 ) THEN 
            dbms_output.put_line (      RPAD(r_indx.owner, 16, ' ')
                                    ||  RPAD(r_indx.index_name, 40, ' ')
                                    ||  LPAD(ROUND((del_lf_rows/lf_rows)*100,3),17,' ')
                                    ||  LPAD(height-1,7,' ')
                                    ||  LPAD(ROUND((lf_rows-distinct_keys)*100/lf_rows,3),16,' '));
        END IF;

    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(c_name);
END;
/ 
 
SPOOL OFF 

PROMPT Report written to index_schema_fragmentation_report_&schema..lst
PROMPT 
