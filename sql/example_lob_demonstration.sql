-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_lob_demonstration.sql                                   |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example script that demonstrates how to manipulate LOBs using   |
-- |            SQL.                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

Prompt
Prompt Dropping all testing LOB tables...
Prompt ----------------------------------

DROP TABLE test_lobs;
DROP DIRECTORY tmp_dir;
DROP TABLE long_data;



Prompt Create TEST_LOB table...
Prompt ------------------------

CREATE TABLE test_lobs (
    c1 NUMBER
  , c2 CLOB
  , c3 BFILE
  , c4 BLOB
)
LOB (c2) STORE AS (ENABLE STORAGE IN ROW)
LOB (c4) STORE AS (DISABLE STORAGE IN ROW)
/


Prompt Inserting row with NO LOB locators...
Prompt -------------------------------------

INSERT INTO test_lobs
  VALUES (1, null, null, null)
/

Prompt Inserting row with LOB locators (locators created but point to nothing) ...
Prompt ---------------------------------------------------------------------------

INSERT INTO test_lobs
  VALUES (2, empty_clob(), BFILENAME(null,null), empty_blob())
/


Prompt +------------------------------------------------------------------------+
Prompt | It is possible to insert data directly up to 4K.                       |
Prompt | Even though you are only really accessing the locator, the data is     |
Prompt | stored as appropriate behind the scenes. When inserting directly into  |
Prompt | a BLOB either the string must be hex as an implicit HEXTORAW will be   |
Prompt | done or you can call UTL_RAW.CAST_TO_RAW('the string') to convert it   |
Prompt | for you. Note '48656C6C6F' = 'Hello'.                                  |
Prompt +------------------------------------------------------------------------+
Prompt

INSERT INTO test_lobs
  VALUES (   3
           , 'Some data for record 3.'
           , BFILENAME(null,null)
           , '48656C6C6F'||UTL_RAW.CAST_TO_RAW(' there!'))
/


Prompt +---------------------------------------------------------------------------+
Prompt | Now it is time to select back the data. If you were to try to SELECT      |
Prompt | all three columns from the test_lobs table, SQL*Plus would give you an    |
Prompt | error:                                                                    |
Prompt |        SQL> SELECT * FROM test_lobs;                                      |
Prompt |        SQL> Column or attribute type can not be displayed by SQL*Plus     |
Prompt |                                                                           |
Prompt | SQL*Plus cannot convert the data behind the locator to hex for the BLOB   |
Prompt | column (c3) nor can it interpret a locator for a BFILE (even when null).  |
Prompt | In order for this query to run successfully, you would need to enter:     |
Prompt |                                                                           |
Prompt |        column c2 format a60 wrap                                          |
Prompt |                                                                           |
Prompt | and ONLY select columns c1 and c2:                                        |
Prompt +---------------------------------------------------------------------------+
Prompt

COLUMN c2 FORMAT a60 WRAP

Prompt Query CLOB records...
Prompt ---------------------

SELECT c1, c2 FROM test_lobs;


Prompt +---------------------------------------------------------------------------+
Prompt | In the above query, we are really fetching only the LOB locator. SQL*Plus |
Prompt | will also then fetch the corresponding data. If we use a 3GL or PL/SQL we |
Prompt | can insert data from a character string variable but not select it into   |
Prompt | one. For example:                                                         |
Prompt +---------------------------------------------------------------------------+
Prompt

DECLARE
  c_lob  VARCHAR2(10);
BEGIN
  c_lob := 'Record 4.';
  INSERT INTO test_lobs
  VALUES (4,c_lob,BFILENAME(null,null), EMPTY_BLOB());
END;
/

DECLARE
  c_lob  VARCHAR2(10);
BEGIN
  SELECT c2 INTO c_lob
  FROM test_lobs
  WHERE c1 = 4;
END;
/


Prompt +-------------------------------------------------------------+
Prompt | NEW IN 8i                                                   |
Prompt | =========                                                   |
Prompt | From version 8.1 it is now possible to convert data stored  |
Prompt | in longs and long raws to CLOBs and BLOBs respectively.     |
Prompt | This is done using the TO_LOB function.                     |
Prompt +-------------------------------------------------------------+

Prompt
Prompt Create LONG_DATA table...
Prompt -------------------------

CREATE TABLE long_data (
    c1 NUMBER
  , c2 LONG
)
/

INSERT INTO long_data
  VALUES (1, 'This is some long data to be migrated to a CLOB')
/


Prompt TO_LOB may be used in CREATE TABLE AS SELECT or INSERT...SELECT  statements
Prompt ---------------------------------------------------------------------------

INSERT INTO test_lobs
  SELECT 5, TO_LOB(c2), null, null
  FROM  long_data
/

Prompt Query CLOB records...
Prompt ---------------------

SELECT c1, c2
FROM   test_lobs
WHERE  c1 = 5;

ROLLBACK
/

Prompt Creating text file /tmp/rec2.txt...
Prompt -----------------------------------

!echo "This is some data for record 2's BFILE column.  The data is\nstored in a file called \"rec2.txt\". The file is placed in \n/tmp.\nThe file comprises a total of 4 lines of text." > /tmp/rec2.txt

Prompt Creating text file /tmp/rec3.txt...
Prompt -----------------------------------

!echo "This is some data for record 3's BFILE column.  The data is\nstored in a file called \"rec3.txt\". The file is placed in\n/tmp.  The file comprises a total of 5 lines of text and\nwill be used to demonstrate the functionality of the  \nDBMS_LOB package." > /tmp/rec3.txt


Prompt First create the ALIAS for the directory /tmp
Prompt ---------------------------------------------

CREATE DIRECTORY tmp_dir AS '/tmp'
/


Prompt +------------------------------------------------------------+
Prompt | Now update the records to associate the BFILE column with  |
Prompt | the two files created above.                               |
Prompt +------------------------------------------------------------+
Prompt

UPDATE  test_lobs
  SET   c3 = BFILENAME('TMP_DIR','rec2.txt')
  WHERE c1 = 2
/

UPDATE  test_lobs
  SET   c3 = BFILENAME('TMP_DIR','rec3.txt')
  WHERE c1 = 3
/

commit;

Prompt +---------------------------------------------------------------------+
Prompt | Note the files associated with these columns are READ-ONLY through  |
Prompt | Oracle.                                                             |
Prompt | They must be maintained via the operating system itself. To access  |
Prompt | the BFILE columns you must use the DBMS_LOB package or OCI.         |
Prompt |                                                                     |
Prompt | Getting lengths of the LOB data. Notice the zero lengths where      |
Prompt | "empty" locators were specified.                                    |
Prompt +---------------------------------------------------------------------+

COLUMN len_c2 FORMAT 9999
COLUMN len_c3 FORMAT 9999
COLUMN len_c4 FORMAT 9999

SELECT
    c1
  , DBMS_LOB.GETLENGTH(c2) len_c2
  , DBMS_LOB.GETLENGTH(c3) len_c3
  , DBMS_LOB.GETLENGTH(c4) len_c4
FROM test_lobs
/


Prompt +---------------------------------------------------------------------------------+
Prompt | Using SUBSTR/INSTR - both may be used on all 3 types (CLOB, BLOB and  --BFILE)  |
Prompt | however for BFILEs the file must first have been opened - hence the functions   |
Prompt | may only be used within PL/SQL in this case.                                    |
Prompt | For SUBSTR the parameters are LOB, amount, offset - the opposite to the         |
Prompt | standard substr function; for INSTR they are LOB, string, offset, occurence,    |
Prompt | the latter 2 defaulting to 1 if omitted. So the following does a substr from    |
Prompt | offset 3 in the CLOB for 9 characters and returns the first occurence of the    |
Prompt | binary string representing "ello" in the BLOB.                                  |
Prompt +---------------------------------------------------------------------------------+

COLUMN sub_c2 FORMAT a10
COLUMN ins_c4 FORMAT 99

SELECT
    c1
  , DBMS_LOB.SUBSTR(c2,9,3) sub_c2
  , DBMS_LOB.INSTR(c4,UTL_RAW.CAST_TO_RAW('ello'),1,1) ins_c4
FROM test_lobs
/


Prompt +----------------------------------------------------------------+
Prompt | The following PL/SQL block demonstrates some of the DBMS_LOB   |
Prompt | functionality. Note the use of "set long 1000" to prevent the  |
Prompt | output data from being truncated.                              |
Prompt +----------------------------------------------------------------+

SET SERVEROUTPUT ON 
SET LONG 1000 

DECLARE
    b_lob BLOB; 
    c_lob CLOB; 
    c_lob2 CLOB; 
    bf BFILE; 
    buf varchar2(100) := 
        'This is some text to put into a CLOB column in the' || 
        chr(10) ||
        'database. The data spans 2 lines.'; 
    n number; 
    fn varchar2(50); --Filename 
    fd varchar2(50); --Directory alias 

    --Procedure to print out the LOB value from c_lob, one line  
    --at a time.. 

    PROCEDURE print_clob IS
 
        offset number; 
        len number; 
        o_buf varchar2(200); 
        amount number;      --} 
        f_amt number := 0;  --}To hold the amount of data 
        f_amt2 number;      --}to be read or that has been 
        amt2 number := -1;  --}read 

    BEGIN 
        len := DBMS_LOB.GETLENGTH(c_lob); 
        offset := 1; 
        WHILE len > 0 loop 
            amount := DBMS_LOB.INSTR(c_lob,chr(10),offset,1); 
            --Amount returned is the count from the start of the file, 
            --not from the offset. 
            IF amount = 0 THEN 
                --No more linefeeds so need to read remaining data. 
                amount := len; 
                amt2 := amount; 
            ELSE 
                f_amt2 := amount;         --Store position of next LF 
                amount := amount - f_amt; --Calc position from last LF 
                f_amt  := f_amt2;         --Store position for next time 
                amt2   := amount - 1;     --Read up to but not the LF 
            END IF; 

            IF amt2 != 0 THEN 
                --If there is a linefeed as the first character then ignore. 
                DBMS_LOB.READ(c_lob,amt2,offset,o_buf); 
                dbms_output.put_line(o_buf); 
            END IF; 

            len    := len - amount; 
            offset := offset+amount;
        END LOOP; 
    END;
 
    BEGIN 
        --For record 1 we did not initialise the locators so do so now. 
        --Note the RETURNING clause will retrieve the new lob locators so 
        --we do not need to perform an extra select. The update also 
        --ensures the corresponding row is locked. 

        UPDATE test_lobs SET c2 = EMPTY_CLOB(), c4 = EMPTY_BLOB() 
            WHERE c1 = 1 RETURNING c2, c4 INTO c_lob, b_lob;

        --Also select the CLOB locator for record 2. 
        SELECT c2 INTO c_lob2 FROM test_lobs where c1 = 3; 

        --Write the above buffer into the CLOB column. Offset is 1, amount 
        --is the size of the buffer. 
        DBMS_LOB.WRITE(c_lob,length(buf),1,buf); 

        --See what we've got - a line at a time. 
        print_clob; 

        --Add some more data to the above column and row. First commit what 
        --we have. Note when we commit, under 8.0, our LOB locators we 
        --previously held in c_lob, b_lob and c_lob2 will be lost and so must be 
        --reselected. **NEW 8i**: under 8.1 LOB locators may span transactions 
        --for read purposes, thus we no longer need to reselect c_lob2. 
        commit; 

        --We must lock the row we are going to update through DBMS_LOB. 
        SELECT c2 INTO c_lob FROM test_lobs WHERE c1 = 1 FOR UPDATE; 

        --**NEW 8i**: no longer need this select: 
        --select c2 into c_lob2 from test_lobs where c1 = 3; 
        --First append a linefeed then some data from another CLOB. 
        --Under 8.0 this was a two step process, first you had to get the 
        --the length of the LOB and secondly write the data using an offset 
        --of the length plus one. **NEW 8i**: with 8.1 you have a WRITEAPPEND
        --function that does the two steps in a single call. 
        --**NEW 8i**: no longer need to get the length: 
        --n := DBMS_LOB.GETLENGTH(c_lob)+1; 
        --DBMS_LOB.WRITE(c_lob,1,n,chr(10)); -- 1 char from offset n 

        DBMS_LOB.WRITEAPPEND(c_lob,1,chr(10)); -- **NEW 8i** 
        DBMS_LOB.APPEND(c_lob,c_lob2); 
        dbms_output.put_line(chr(10)); 
        print_clob; 

        --Compare c_lob2 with the third line of c_lob - they should be 
        --the same - in which case remove it. Note the TRIM function takes 
        --the size at which you wish the LOB to end up, NOT how much you 
        --want to remove. 
        n := DBMS_LOB.GETLENGTH(c_lob) - DBMS_LOB.GETLENGTH(c_lob2); 

        IF DBMS_LOB.COMPARE(c_lob,c_lob2,DBMS_LOB.GETLENGTH(c_lob2),n+1,1) = 0 THEN 
            DBMS_LOB.TRIM(c_lob,n-1); 
        END IF; 

        dbms_output.put_line(chr(10)); 
        print_clob; 

        --Remove the data from the column completely, ie use ERASE to 
        --remove all bytes from offset 1. Note unlike TRIM, ERASE does not 
        --cause the length of the LOB to be shortened - all bytes are simply 
        --set to zero. Thus GETLENGTH will return 0 after TRIM'ing all bytes 
        --but the original length after ERASE'ing. 
        n := DBMS_LOB.GETLENGTH(c_lob); 
        DBMS_LOB.ERASE(c_lob,n,1); 

        --Add data from c_lob2 plus a trailing linefeed. 
        DBMS_LOB.COPY(c_lob,c_lob2,DBMS_LOB.GETLENGTH(c_lob2),1,1); 

        --**NEW 8i**: could simply use WRITEAPPEND here. 
        n := DBMS_LOB.GETLENGTH(c_lob2)+1; 
        DBMS_LOB.WRITE(c_lob,1,n,chr(10)); -- 1 char from offset n 

        --Now append the column with data read from one of the BFILE 
        --columns.
        select c3 into bf from test_lobs where c1 = 3; 

        --First get and output the file details. 
        DBMS_LOB.FILEGETNAME(bf,fd,fn); 
        dbms_output.put_line(chr(10)); 
        dbms_output.put_line('Appending data from file '||fn|| 
            ' in directory aliased by '||fd||':'); 
        dbms_output.put_line(chr(10)); 
        --Open the file to read from it - first checking that it does in 
        --fact still exist in the O/S and that it is not already open. 

        IF DBMS_LOB.FILEEXISTS(bf) = 1 and 
            DBMS_LOB.FILEISOPEN(bf) = 0 THEN 
            DBMS_LOB.FILEOPEN(bf); 
        END IF;
 
        DBMS_LOB.LOADFROMFILE(c_lob,bf,DBMS_LOB.GETLENGTH(bf),n+1,1); 
        DBMS_LOB.FILECLOSE(bf); -- could use DBMS_LOB.FILECLOSEALL; 
        print_clob; 

        commit; 
    END; 
/

COMMIT;

SELECT c1, c2
FROM test_lobs
/


Prompt +------------------------------------------------------------------------+
Prompt | An important thing to note when using LOB locators within DBMS_LOB     |
Prompt | and PL/SQL is that a given locator always gives a read consistent      |
Prompt | image from when it was selected. You will see any changes that you     |
Prompt | make to the LOB using that locator and DBMS_LOB, but not those made,   |
Prompt | even in the same transaction, through other LOB locators pointing to   |
Prompt | the same LOB values or made via SQL directly. For example:             |
Prompt +------------------------------------------------------------------------+

DECLARE 
  c_lob CLOB; 
BEGIN 

  SELECT  c2
  INTO    c_lob
  FROM    test_lobs
  WHERE   c1 = 1;

  DBMS_OUTPUT.PUT_LINE('Before update length of c2 is '||
                       DBMS_LOB.GETLENGTH(c_lob)); 

  UPDATE TEST_LOBS
      SET c2 = 'This is a string.' where c1 = 1;

  DBMS_OUTPUT.PUT_LINE('After update length of c2 is '||
                       DBMS_LOB.GETLENGTH(c_lob)); 

  SELECT  c2
  INTO    c_lob
  FROM    test_lobs
  WHERE   c1 = 1;

  DBMS_OUTPUT.PUT_LINE('After reselecting locator length of c2 is '||
                       DBMS_LOB.GETLENGTH(c_lob));

  ROLLBACK;

END; 
/

COMMIT;

Prompt +--------------------------------------------------------------------------+
Prompt | NEW IN 8i                                                                |
Prompt | =========                                                                |
Prompt | The following PL/SQL blocks demonstrate the remaining new DBMS_LOB       |
Prompt | functionality introduced in version 8.1.                                 |
Prompt |                                                                          |
Prompt | Temporary LOBs                                                           |
Prompt | ==============                                                           |
Prompt | In version 8.1 it is now possible to create temporary LOBs. These are    |
Prompt | LOB locators that point to LOB values held in the user's temporary       |
Prompt | tablespace. Temporary LOBs are automatically initialised upon creation   |
Prompt | and exist for the duration specified in the create command or until      |
Prompt | explicitly freed by the user. The duration of a temporary LOB may be     |
Prompt | be session or call. At the end of the given duration the temporary       |
Prompt | LOB is automatically deleted. Temporary LOBs can be used in the          |
Prompt | same way as normal internal LOBs through the DBMS_LOB package (note      |
Prompt | there is no temporary version of a BFILE), however being only part of    |
Prompt | the temporary tablespace they are not permanently stored in the database |
Prompt | and they cause no rollback or undo information to be generated.          |
Prompt | Temporary LOBs may be cached though. Because versioning (ie keeping      |
Prompt | copies of pages prior to updates) is not performed for temporary LOBs,   |
Prompt | if a temporary LOB locator is copied and then used to update the LOB     |
Prompt | value, the whole LOB value must be copied in order to maintain a read    |
Prompt | consistent image via both locators. For this reason it is recommended    |
Prompt | that whenever LOB locators are passed as IN OUT or OUT parameters to     |
Prompt | procedures, functions or methods, NOCOPY is specified so they are        |
Prompt | passed by reference.                                                     |
Prompt |                                                                          |
Prompt | The following example uses a temporary LOB to reverse one of the LOB     |
Prompt | values in the table and then inserts the reversed LOB as a new row.      |
Prompt +--------------------------------------------------------------------------+

DECLARE 
    c_lob  CLOB;                --permanent LOB locator 
    t_lob  CLOB;                --temporary LOB locator 
    buf    varchar2(32000);     --}this example assumes the LOB is 
    buf2   varchar2(32000);     --}less than 32K. 
    chunk  number; 
    len    number; 
    offset number; 
    amount number;

    BEGIN 

        SELECT c2 INTO c_lob FROM test_lobs WHERE c1 = 1;  
 
        --Create a temporary LOB.  The parameters to CREATETEMPORARY are 
        --locator, use caching or not and duration.  Set no caching and a  
        --duration of call since the temporary LOB is not required outside 
        --of this PL/SQL block. 
        DBMS_LOB.CREATETEMPORARY(t_lob,FALSE,DBMS_LOB.CALL); --**NEW 8i** 
 
        --**NEW 8i**: Use GETCHUNKSIZE to get the amount of space used in a LOB  
        --chunk for storing the LOB value.   Using this amount for reads and  
        --writes of the LOB will improve performance. 
        chunk := DBMS_LOB.GETCHUNKSIZE(c_lob);		 
        DBMS_OUTPUT.PUT_LINE('Chunksize of column c2 is '||chunk); 
        DBMS_OUTPUT.PUT_LINE('Chunksize of temporary LOB is '|| 
            DBMS_LOB.GETCHUNKSIZE(t_lob));  --for info only 
 
        len := DBMS_LOB.GETLENGTH(c_lob); 
        offset := 1; 
        buf := null; 

        WHILE offset < len loop 
            IF len - (offset-1) > chunk then 
                amount := chunk; 
	    ELSE 
               amount := len - (offset-1); 
            END IF; 
            buf2 := null; 
            DBMS_LOB.READ(c_lob,amount,offset,buf2); 
            buf := buf||buf2; 
            offset := offset + amount; 
        END LOOP; 
 
        --Reverse the read data and write it to the temporary LOB. 
        buf2 := null; 
        FOR i IN reverse 1..len LOOP 
            buf2 := buf2||substr(buf,i,1); 
        END LOOP; 

        --Write the whole lot in one go.  Note, if this was a large  
        --amount of data then ideally it should be written using the  
        --available chunksize of the temporary LOB. 
        DBMS_LOB.WRITEAPPEND(t_lob,len,buf2);  --**NEW 8i** 
 
        --Now insert a new row into the table setting the CLOB column to 
        --the value of the temporary LOB.  This can be done in one of 
        --two ways: 
        --(i)  A new row can be inserted with an empty locator, the locator 
        --     retrieved and the LOB value copied with DBMS_LOB.COPY. 
        --(ii) A new row can be inserted passing the temporary LOB locator 
        --     as a bind variable to the insert. 
        -- 
        --Using the second method: 
        INSERT INTO test_lobs VALUES (5,t_lob,null,null) RETURNING c2 INTO c_lob; 
 
        --Free the temporary LOB explicitly. 
        IF DBMS_LOB.ISTEMPORARY(t_lob) = 1 THEN 
            DBMS_LOB.FREETEMPORARY(t_lob); 
        END IF; 
 
        DBMS_OUTPUT.PUT_LINE('Length of CLOB inserted into record 5 is '|| 
            DBMS_LOB.GETLENGTH(c_lob)); 
       COMMIT;
 
    END; 
/

Prompt Query CLOB records...
Prompt ---------------------

SELECT  c1, c2
FROM    test_lobs 
WHERE   c1 = 5 
/

Prompt +---------------------------------------------------------------------------+
Prompt | OPEN AND CLOSE OPERATIONS                                                 |
Prompt | =========================                                                 |
Prompt | Under version 8.0 the only concept of opening and closing a LOB applies   |
Prompt | to BFILEs and the opening and closing of the physical O/S files they      |
Prompt | represent.  **NEW 8i**: With 8.1 it is now possible to open and close     |
Prompt | any type of LOB.  The new calls introduced for this functionality are     |
Prompt | DBMS_LOB.OPEN, DBMS_LOB.CLOSE and DBMS_LOB.ISOPEN.  When the given        |
Prompt | locator is a BFILE, these three routines behave as DBMS_LOB.FILEOPEN,     |
Prompt | DBMS_LOB.FILECLOSE and DBMS_LOB.FILEISOPEN.  When applied to internal     |
Prompt | LOBs they have the effect of batching up any writes such that triggers    |
Prompt | on an extensible index will not fire until the DBMS_LOB.CLOSE is called.  |  
Prompt | When a LOB is opened it is with a mode of either read-only or read/write. |
Prompt | Setting this mode to read-only, prevents any writes from being performed  | 
Prompt | on the LOB in the current transaction until the LOB is closed.  Note it   |
Prompt | is an error to attempt to open a BFILE for read/write.  The concept of    |
Prompt | openness itself applies to a LOB rather than a locator, hence a LOB may   |
Prompt | only be opened once within a transaction and closed only when open.       |
Prompt | Attempting to do otherwise will result in an error.                       |
Prompt |                                                                           |
Prompt | NOTE:                                                                     |
Prompt | =====                                                                     |
Prompt | The following code segment will give:                                     | 
Prompt |                                                                           |
Prompt |     ORA-22294: cannot update a LOB opened in read-only mode               |
Prompt |     Closing LOB via locator 2                                             |
Prompt +---------------------------------------------------------------------------+

DECLARE

    c_lob1 CLOB; 
    c_lob2 CLOB; 

    BEGIN 
        -- Select without locking the LOB. 
        SELECT c2 INTO c_lob1 FROM test_lobs WHERE c1 = 2; 
        c_lob2 := c_lob1; 
  
        -- Open the LOB as read-only using locator 1. 
        DBMS_LOB.OPEN(c_lob1,DBMS_LOB.LOB_READONLY);    --**NEW 8i** 
    
        --Writes are not permitted.  The following gives an error: 
        BEGIN 
            DBMS_LOB.WRITEAPPEND(c_lob1,5,'Hello');      --**NEW 8i** 
        EXCEPTION 
            WHEN others THEN 
                DBMS_OUTPUT.PUT_LINE(sqlerrm); 
        END;
 
        -- Commit and rollback are allowed because no transaction is started. 
	-- The LOB will still be open afterwards.	 

        ROLLBACK; 
 
        -- Close - can use either locator. 
        IF DBMS_LOB.ISOPEN(c_lob2) = 1 THEN             --**NEW 8i** 
            DBMS_OUTPUT.PUT_LINE('Closing LOB via locator 2'); 
            DBMS_LOB.CLOSE(c_lob2);                      --**NEW 8i** 
        END IF;

        IF DBMS_LOB.ISOPEN(c_lob1) = 1 THEN             --**NEW 8i** 
            DBMS_OUTPUT.PUT_LINE('Closing LOB via locator 1'); 
            DBMS_LOB.CLOSE(c_lob1);                      --**NEW 8i** 
        END IF; 
 
        -- To open for read/write the record in the database must be locked. 
        SELECT c2 INTO c_lob1 FROM test_lobs WHERE c1 = 2 FOR UPDATE; 

        DBMS_LOB.OPEN(c_lob1,DBMS_LOB.LOB_READWRITE);   --**NEW 8i**
        DBMS_LOB.WRITEAPPEND(c_lob1,5,'Hello');         --**NEW 8i**
        DBMS_LOB.WRITEAPPEND(c_lob1,7,' there.');       --**NEW 8i**

        -- The LOB MUST be closed before committing or rolling back. 
        DBMS_LOB.CLOSE(c_lob1);                         --**NEW 8i** 

       COMMIT;

    END;
/

Prompt Query CLOB records...
Prompt ---------------------

SELECT  c2
FROM    test_lobs
WHERE   c1 = 2 
/
