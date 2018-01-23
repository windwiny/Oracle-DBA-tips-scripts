-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : lob_fragmentation_user.sql                                      |
-- | CLASS    : LOBs                                                            |
-- | PURPOSE  : When a LOB segment is first created, its initial "allocated"    |
-- |            size is 64K, even though there are no rows in the table. As LOB |
-- |            data is entered into the LOB segment, the allocated space for   |
-- |            the segment will continue to increase. If over time, the LOB    |
-- |            segment starts to experience many deletes and updates, it is    |
-- |            possible for the LOB segment to become fragmented and possibly  |
-- |            waste a considerable amount of disk space. This occurs when the |
-- |            size of the actual LOB segment data is considerably less than   |
-- |            what is allocated by the LOB segment. Consider a situation      |
-- |            where a LOB segment has 16GB allocated for the segment but only |
-- |            contains 2GB worth of actual LOB data. Potentially, this is     |
-- |            nearly 14GB of wasted allocated space. This could occur when a  |
-- |            significant number of rows have been deleted from the table     |
-- |            storing the LOB column.                                         |
-- |                                                                            |
-- |            This script can be used to identify the size and amount of      |
-- |            fragmentation that exists in all LOB segments for a particular  |
-- |            user.                                                           |
-- |                                                                            |
-- |            To reclaim the wasted space within a fragmented LOB segment,    |
-- |            use the following SQL command:                                  |
-- |                                                                            |
-- |            ALTER TABLE <OWNER>.<TABLE_NAME> MODIFY LOB (<LOB_COLUMN>) (SHRINK SPACE);
-- |                                                                            |
-- |            NOTE: The time required to shrink the LOB segment is a function |
-- |                  of how much data needs to be coalesced. In many cases,    |
-- |                  the shrink operation can take minutes or possibly several |
-- |                  hours depending on the amount of data that needs to be    |
-- |                  moved.                                                    |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
COLUMN current_user NEW_VALUE current_user NOPRINT;
SELECT rpad(instance_name, 17) current_instance, rpad(user, 13) current_user FROM v$instance;
SET TERMOUT ON;

PROMPT 
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : LOB Fragmentation for the Current User                      |
PROMPT | Instance : &current_instance                                           |
PROMPT | User     : &current_user                                               |
PROMPT +------------------------------------------------------------------------+
PROMPT 

SET ECHO          OFF
SET FEEDBACK      6
SET HEADING       ON
SET LINESIZE      180
SET PAGESIZE      50000
SET TERMOUT       ON
SET SERVEROUTPUT  ON
SET TIMING        OFF
SET TRIMOUT       ON
SET TRIMSPOOL     ON
SET VERIFY        OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

declare
    v_actual_length                           number;
    v_allocated_length                        number;
    v_lob_fragmentation_pct                   number;
    v_actual_length_char                      varchar2(50);
    v_allocated_length_char                   varchar2(50);
    v_statement                               varchar2(2000);
    v_table_column_pad_length       constant  number := 45;
    v_actual_length_pad_length      constant  number := 20;
    v_allocated_length_pad_length   constant  number := 20;
    v_fragmentation_pad_length      constant  number := 15;
begin
    dbms_output.enable(1000000);

    -- Print column headers    
    dbms_output.put_line( rpad('LOB COLUMN - [OWNER.TABLE.COLUMN]', v_table_column_pad_length)    || ' ' ||
                          lpad('ALLOCATED LOB LENGTH', v_allocated_length_pad_length)             || ' ' ||
                          lpad('ACTUAL LOB LENGTH', v_actual_length_pad_length)                   || ' ' ||
                          lpad('FRAGMENTATION', v_fragmentation_pad_length)
                        );
    dbms_output.put_line( rpad('-', v_table_column_pad_length, '-')        || ' ' ||
                          lpad('-', v_allocated_length_pad_length, '-')    || ' ' ||
                          lpad('-', v_actual_length_pad_length, '-')       || ' ' ||
                          lpad('-', v_fragmentation_pad_length, '-')
                        );
    
    -- Get all LOB segments for the current user
    for v_lob_segment in (select user, l.table_name, l.column_name
                          from user_lobs l join user_segments s
                               using (segment_name, tablespace_name)
                          where l.column_name not like '"%'
                          order by 2,3)
    loop
        dbms_output.put(rpad(v_lob_segment.user || '.' || v_lob_segment.table_name || '.' || v_lob_segment.column_name, v_table_column_pad_length));
        dbms_output.put(' ');

        -- Get "allocated size" of the LOB segment
        v_statement :=     'begin '
                        || 'select to_char(a.bytes, ''999,999,999,999,999'') '
                        || 'into :col_val2 '
                        || 'from user_segments a join user_lobs b '
                        || 'using (segment_name) '
                        || 'where b.table_name  = ''' || v_lob_segment.table_name || ''''
                        || '  and b.column_name = ''' || v_lob_segment.column_name || ''';'
                        || 'end;';
        execute immediate v_statement using out v_allocated_length_char;
        v_allocated_length_char := regexp_replace(v_allocated_length_char, ' ', '');
        v_allocated_length      := regexp_replace(v_allocated_length_char, ',', '');
        dbms_output.put(lpad(v_allocated_length_char, v_allocated_length_pad_length));
        dbms_output.put(' ');
        
        begin
            -- Get "actual size" of the LOB segment        
            v_statement :=     'begin '
                            || 'select to_char(sum(dbms_lob.getlength(' || v_lob_segment.column_name || ')), ''999,999,999,999,999''  ) '
                            || 'into :col_val1 '
                            || 'from ' || v_lob_segment.table_name || ';'
                            || 'end;';
            execute immediate v_statement using out v_actual_length_char;
            v_actual_length_char := nvl(regexp_replace(v_actual_length_char, ' ', ''), '0');
            v_actual_length      := nvl(regexp_replace(v_actual_length_char, ',', ''), 0);
            dbms_output.put(lpad(v_actual_length_char, v_actual_length_pad_length));
            dbms_output.put(' ');
    
            -- Calculate LOB fragmentation
            if v_actual_length = 0 then
              v_actual_length := v_allocated_length;
            end if;
            
            v_lob_fragmentation_pct := round(((1-(v_actual_length/v_allocated_length))*100), 2);
            dbms_output.put(lpad(v_lob_fragmentation_pct || ' %', v_fragmentation_pad_length));
        exception
            when others then null;
        end;
        
        dbms_output.put_line('');

    end loop;
end;

/

