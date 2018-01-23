-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_partition_range_number_oracle_8.sql                     |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL syntax used to create and maintain range partitions |
-- |            in Oracle8. The table in this example is partitioned by a       |
-- |            number range. In Oracle8, only range partitions are available.  |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CONNECT scott/tiger

/*
 ** +-----------------------------------+
 ** | DROP ALL OBJECTS                  |
 ** +-----------------------------------+
*/

DROP TABLE emp_part CASCADE CONSTRAINTS
/
DROP VIEW less_view
/
DROP TABLE new_less CASCADE CONSTRAINTS
/
DROP TABLE less50 CASCADE CONSTRAINTS
/
DROP TABLE less100 CASCADE CONSTRAINTS
/
DROP TABLE less150 CASCADE CONSTRAINTS
/
DROP TABLE less200 CASCADE CONSTRAINTS
/


DROP TABLESPACE part_1_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_2_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_3_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_4_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_5_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_6_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_7_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_8_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_9_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_10_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_max_data_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_move_data_tbs INCLUDING CONTENTS
/

DROP TABLESPACE part_1_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_2_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_3_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_4_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_5_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_6_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_7_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_8_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_9_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_10_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_max_idx_tbs INCLUDING CONTENTS
/
DROP TABLESPACE part_move_idx_tbs INCLUDING CONTENTS
/



/*
 ** +-----------------------------------+
 ** | CREATE data TABLESPACES           |
 ** +-----------------------------------+
*/


CREATE TABLESPACE part_1_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_1_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_2_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_2_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_3_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_3_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_4_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_4_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_5_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_5_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_6_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_6_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_7_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_7_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_8_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_8_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_9_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_9_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_10_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_10_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_max_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_max_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_move_data_tbs
  LOGGING DATAFILE '/u10/app/oradata/OEM1DB/part_move_data_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/


/*
 ** +-----------------------------------+
 ** | CREATE index TABLESPACES          |
 ** +-----------------------------------+
*/


CREATE TABLESPACE part_1_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_1_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_2_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_2_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_3_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_3_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_4_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_4_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_5_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_5_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_6_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_6_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_7_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_7_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_8_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_8_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_9_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_9_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_10_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_10_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_max_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_max_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/

CREATE TABLESPACE part_move_idx_tbs
  LOGGING DATAFILE '/u09/app/oradata/OEM1DB/part_move_idx_tbs01.dbf' SIZE 10M REUSE
  AUTOEXTEND ON NEXT 1M MAXSIZE UNLIMITED
  EXTENT MANAGEMENT LOCAL
/


/*
 ** +------------------------------------------+
 ** | CREATE (Range) PARTITIONED TABLE         |
 ** | ---------------------------------------- |
 ** | Create testing table partitioned by a    |
 ** | "range" of NUMERIC values.               |
 ** +------------------------------------------+
*/

CREATE TABLE emp_part (
    empno    NUMBER(15) NOT NULL
  , ename    VARCHAR2(100)
  , sal      NUMBER(10,2)
  , deptno   NUMBER(15)
)
TABLESPACE users
STORAGE (
  INITIAL      1M
  NEXT         1M
  PCTINCREASE  0
  MAXEXTENTS   UNLIMITED
)
PARTITION BY RANGE (empno) (
  PARTITION emp_part_50_part
    VALUES LESS THAN (50)
    TABLESPACE part_1_data_tbs,
  PARTITION emp_part_100_part
    VALUES LESS THAN (100)
    TABLESPACE part_2_data_tbs,
  PARTITION emp_part_150_part
    VALUES LESS THAN (150)
    TABLESPACE part_3_data_tbs,
  PARTITION emp_part_200_part
    VALUES LESS THAN (200)
    TABLESPACE part_4_data_tbs,
  PARTITION emp_part_MAX_part
    VALUES LESS THAN (MAXVALUE)
    TABLESPACE part_max_data_tbs
)
/

/*
 ** +-------------------------------------------------------------+
 ** | CREATE PARTITIONED INDEX (Local Prefixed)                   |
 ** | ----------------------------------------------------------- |
 ** | This index is considered "prefixed" because the index key   |
 ** | 'empno' is identical to the partitioning key. This index is |
 ** | defined as "local". It is thus partitioned automatically by |
 ** | Oracle on the same key as the emp_part table; the key being |
 ** | 'empno'.                                                    |
 ** +-------------------------------------------------------------+
*/

CREATE INDEX emp_part_idx1
  ON emp_part(empno)
  LOCAL (
    PARTITION emp_part_50_part  TABLESPACE part_1_idx_tbs,
    PARTITION emp_part_100_part TABLESPACE part_2_idx_tbs,
    PARTITION emp_part_150_part TABLESPACE part_3_idx_tbs,
    PARTITION emp_part_200_part TABLESPACE part_4_idx_tbs,
    PARTITION emp_part_MAX_part TABLESPACE part_max_idx_tbs
  )
/


/*
 ** +---------------------------------------------------------------+
 ** | CREATE PARTITIONED INDEX (Global Prefixed)                    |
 ** | ------------------------------------------------------------- |
 ** | This index is considered "prefixed" because the index key     |
 ** | 'deptno' is identical to the partitioning key. This index is  |
 ** | defined as "global". It is thus NOT partitioned automatically |
 ** | by Oracle on the same key as the emp_part table.              |
 ** |                                                               |
 ** | Note that global indexes MUST have a MAXVALUE partition       |
 ** | defined.                                                      |
 ** +---------------------------------------------------------------+
*/

CREATE INDEX emp_part_idx2
  ON emp_part(deptno)
  GLOBAL PARTITION BY RANGE (deptno) (
    PARTITION emp_part_D10_part
        VALUES LESS THAN (10)
        TABLESPACE part_1_idx_tbs,
    PARTITION emp_part_D20_part
        VALUES LESS THAN (20)
        TABLESPACE part_2_idx_tbs,
    PARTITION emp_part_D30_part
        VALUES LESS THAN (30)
        TABLESPACE part_3_idx_tbs,
    PARTITION emp_part_D40_part
        VALUES LESS THAN (40)
        TABLESPACE part_4_idx_tbs,
    PARTITION emp_part_D50_part
        VALUES LESS THAN (50)
        TABLESPACE part_5_idx_tbs,
    PARTITION emp_part_D60_part
        VALUES LESS THAN (60)
        TABLESPACE part_6_idx_tbs,
    PARTITION emp_part_D70_part
        VALUES LESS THAN (70)
        TABLESPACE part_7_idx_tbs,
    PARTITION emp_part_D80_part
        VALUES LESS THAN (80)
        TABLESPACE part_8_idx_tbs,
    PARTITION emp_part_D90_part
        VALUES LESS THAN (90)
        TABLESPACE part_9_idx_tbs,
    PARTITION emp_part_D100_part
        VALUES LESS THAN (100)
        TABLESPACE part_10_idx_tbs,
    PARTITION emp_part_DMAX_part
        VALUES LESS THAN (MAXVALUE)
        TABLESPACE part_max_idx_tbs
  )
/

/*
 ** +-------------------------------------------------------------+
 ** | INSERT VALUES                                               |
 ** | ----------------------------------------------------------- |
 ** | Insert test values into the "emp_part" table.               |
 ** +-------------------------------------------------------------+
*/

INSERT INTO emp_part VALUES (10, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (11, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (12, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (13, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (14, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (15, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (16, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (17, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (18, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (19, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (20, 'JHUNTER', '185000.00', 10);
INSERT INTO emp_part VALUES (21, 'MHUNTER', '125000.00', 10);
INSERT INTO emp_part VALUES (22, 'AHUNTER', '135000.00', 10);
INSERT INTO emp_part VALUES (23, 'MDUNN', '115000.00', 10);
INSERT INTO emp_part VALUES (24, 'JHUNTER', '115000.00', 10);
INSERT INTO emp_part VALUES (25, 'JHUNTER', '116000.00', 10);
INSERT INTO emp_part VALUES (26, 'MHUNTER', '117000.00', 10);
INSERT INTO emp_part VALUES (27, 'MHUNTER', '118000.00', 10);
INSERT INTO emp_part VALUES (28, 'MHUNTER', '119000.00', 10);
INSERT INTO emp_part VALUES (29, 'MHUNTER', '120000.00', 10);
INSERT INTO emp_part VALUES (30, 'MDUNN', '90000.00', 10);
INSERT INTO emp_part VALUES (50, 'AHUNTER', '80000.00', 20);
INSERT INTO emp_part VALUES (51, 'TFORNER', '125000.00', 20);
INSERT INTO emp_part VALUES (52, 'TFORNER', '135000.00', 20);
INSERT INTO emp_part VALUES (53, 'TFORNER', '145000.00', 20);
INSERT INTO emp_part VALUES (54, 'CROBERTS', '155000.00', 20);
INSERT INTO emp_part VALUES (55, 'AHUNTER', '165000.00', 20);
INSERT INTO emp_part VALUES (56, 'LBAACKE', '175000.00', 20);
INSERT INTO emp_part VALUES (99, 'JHUNTER', '185000.00', 20);
INSERT INTO emp_part VALUES (100, 'AHUNTER', '113000.00', 20);
INSERT INTO emp_part VALUES (101, 'LBAACKE', '112000.00', 30);
INSERT INTO emp_part VALUES (102, 'AHUNTER', '111000.00', 30);
INSERT INTO emp_part VALUES (103, 'GCRANE', '111000.00', 30);
INSERT INTO emp_part VALUES (104, 'AHUNTER', '115000.00', 30);
INSERT INTO emp_part VALUES (105, 'LBAACKE', '135000.00', 30);
INSERT INTO emp_part VALUES (106, 'AHUNTER', '100000.00', 30);
INSERT INTO emp_part VALUES (107, 'LBAACKE', '110000.00', 30);
INSERT INTO emp_part VALUES (108, 'AHUNTER', '119000.00', 30);
INSERT INTO emp_part VALUES (109, 'LBAACKE', '118000.00', 30);
INSERT INTO emp_part VALUES (110, 'AHUNTER', '117000.00', 30);
INSERT INTO emp_part VALUES (111, 'SCOLLINS', '116000.00', 30);
INSERT INTO emp_part VALUES (112, 'AHUNTER', '115000.00', 30);
INSERT INTO emp_part VALUES (113, 'ESMITH', '114000.00', 30);
INSERT INTO emp_part VALUES (114, 'AHUNTER', '113000.00', 30);
INSERT INTO emp_part VALUES (115, 'LBAACKE', '215000.00', 30);
INSERT INTO emp_part VALUES (120, 'AHUNTER', '515000.00', 30);
INSERT INTO emp_part VALUES (130, 'GCRANE', '415000.00', 30);
INSERT INTO emp_part VALUES (131, 'AHUNTER', '315000.00', 30);
INSERT INTO emp_part VALUES (150, 'LBAACKE', '215000.00', 40);
INSERT INTO emp_part VALUES (151, 'JHUNTER', '44000.00', 40);
INSERT INTO emp_part VALUES (152, 'MHUNTER', '55000.00', 40);
INSERT INTO emp_part VALUES (153, 'EDUNN', '65000.00', 40);
INSERT INTO emp_part VALUES (154, 'MDUNN', '75000.00', 40);
INSERT INTO emp_part VALUES (155, 'SCOLLINS', '85000.00', 40);
INSERT INTO emp_part VALUES (156, 'GCRANE', '95000.00', 40);
INSERT INTO emp_part VALUES (157, 'ESMITH', '25000.00', 40);
INSERT INTO emp_part VALUES (161, 'SCOLLINS', '25000.00', 40);
INSERT INTO emp_part VALUES (162, 'LBLACK', '25000.00', 40);
INSERT INTO emp_part VALUES (163, 'LBAACKE', '25000.00', 40);
INSERT INTO emp_part VALUES (164, 'TDRAKE', '25000.00', 40);
INSERT INTO emp_part VALUES (165, 'SCOLLINS', '25000.00', 40);
INSERT INTO emp_part VALUES (166, 'GCRANE', '35000.00', 40);
INSERT INTO emp_part VALUES (167, 'LBAACKE', '45000.00', 40);
INSERT INTO emp_part VALUES (168, 'LBLACK', '55000.00', 40);
INSERT INTO emp_part VALUES (169, 'SCOLLINS', '65000.00', 40);
INSERT INTO emp_part VALUES (170, 'TDRAKE', '75000.00', 40);
INSERT INTO emp_part VALUES (171, 'LBAACKE', '85000.00', 40);
INSERT INTO emp_part VALUES (172, 'ESMITH', '95000.00', 40);
INSERT INTO emp_part VALUES (192, 'SCOLLINS', '95000.00', 40);
INSERT INTO emp_part VALUES (193, 'TDRAKE', '95000.00', 40);
INSERT INTO emp_part VALUES (194, 'LBAACKE', '95000.00', 40);
INSERT INTO emp_part VALUES (195, 'LBLACK', '95000.00', 40);
INSERT INTO emp_part VALUES (196, 'LBAACKE', '95000.00', 40);
INSERT INTO emp_part VALUES (197, 'LBLACK', '95000.00', 40);
INSERT INTO emp_part VALUES (198, 'LBAACKE', '95000.00', 40);
INSERT INTO emp_part VALUES (199, 'ESMITH', '95000.00', 40);
INSERT INTO emp_part VALUES (200, 'SCOLLINS', '95000.00', 40);
INSERT INTO emp_part VALUES (201, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (202, 'LBAACKE', '95000.00', 50);
INSERT INTO emp_part VALUES (203, 'TDRAKE', '95000.00', 50);
INSERT INTO emp_part VALUES (204, 'SCOLLINS', '95000.00', 50);
INSERT INTO emp_part VALUES (205, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (206, 'LBAACKE', '95000.00', 50);
INSERT INTO emp_part VALUES (207, 'TFORNER', '95000.00', 50);
INSERT INTO emp_part VALUES (208, 'LBAACKE', '95000.00', 50);
INSERT INTO emp_part VALUES (209, 'ESMITH', '95000.00', 50);
INSERT INTO emp_part VALUES (210, 'LBAACKE', '95000.00', 50);
INSERT INTO emp_part VALUES (220, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (230, 'SCOLLINS', '95000.00', 50);
INSERT INTO emp_part VALUES (240, 'GCRANE', '95000.00', 50);
INSERT INTO emp_part VALUES (250, 'LBAACKE', '95000.00', 50);
INSERT INTO emp_part VALUES (260, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (270, 'ESMITH', '95000.00', 50);
INSERT INTO emp_part VALUES (280, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (290, 'TDRAKE', '95000.00', 50);
INSERT INTO emp_part VALUES (291, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (292, 'GCRANE', '95000.00', 50);
INSERT INTO emp_part VALUES (293, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (294, 'TDRAKE', '95000.00', 50);
INSERT INTO emp_part VALUES (295, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (296, 'JHUNTER', '95000.00', 50);
INSERT INTO emp_part VALUES (297, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (298, 'TDRAKE', '95000.00', 50);
INSERT INTO emp_part VALUES (299, 'LBLACK', '95000.00', 50);
INSERT INTO emp_part VALUES (300, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (301, 'LBLACK', '95000.00', 60);
INSERT INTO emp_part VALUES (302, 'GCRANE', '95000.00', 60);
INSERT INTO emp_part VALUES (303, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (304, 'JHUNTER', '95000.00', 60);
INSERT INTO emp_part VALUES (305, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (306, 'ESMITH', '95000.00', 60);
INSERT INTO emp_part VALUES (307, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (308, 'JHUNTER', '95000.00', 60);
INSERT INTO emp_part VALUES (309, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (310, 'GCRANE', '95000.00', 60);
INSERT INTO emp_part VALUES (320, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (330, 'ESMITH', '95000.00', 60);
INSERT INTO emp_part VALUES (340, 'TDRAKE', '95000.00', 60);
INSERT INTO emp_part VALUES (350, 'GCRANE', '95000.00', 70);
INSERT INTO emp_part VALUES (360, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (370, 'JHUNTER', '95000.00', 70);
INSERT INTO emp_part VALUES (380, 'GCRANE', '95000.00', 70);
INSERT INTO emp_part VALUES (390, 'ESMITH', '95000.00', 70);
INSERT INTO emp_part VALUES (391, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (392, 'GCRANE', '95000.00', 70);
INSERT INTO emp_part VALUES (393, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (394, 'ESMITH', '95000.00', 70);
INSERT INTO emp_part VALUES (395, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (396, 'GCRANE', '95000.00', 70);
INSERT INTO emp_part VALUES (397, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (398, 'JHUNTER', '95000.00', 70);
INSERT INTO emp_part VALUES (399, 'TDRAKE', '95000.00', 70);
INSERT INTO emp_part VALUES (400, 'GCRANE', '95000.00', 80);
INSERT INTO emp_part VALUES (401, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (402, 'ESMITH', '95000.00', 80);
INSERT INTO emp_part VALUES (403, 'GCRANE', '95000.00', 80);
INSERT INTO emp_part VALUES (404, 'GCRANE', '95000.00', 80);
INSERT INTO emp_part VALUES (405, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (406, 'JHUNTER', '95000.00', 80);
INSERT INTO emp_part VALUES (407, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (408, 'GCRANE', '95000.00', 80);
INSERT INTO emp_part VALUES (409, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (410, 'GCRANE', '95000.00', 80);
INSERT INTO emp_part VALUES (420, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (430, 'ESMITH', '95000.00', 80);
INSERT INTO emp_part VALUES (440, 'TDRAKE', '95000.00', 80);
INSERT INTO emp_part VALUES (450, 'GCRANE', '95000.00', 90);
INSERT INTO emp_part VALUES (460, 'ESMITH', '95000.00', 90);
INSERT INTO emp_part VALUES (470, 'TDRAKE', '95000.00', 90);
INSERT INTO emp_part VALUES (480, 'TDRAKE', '95000.00', 90);
INSERT INTO emp_part VALUES (490, 'JHUNTER', '95000.00', 90);
INSERT INTO emp_part VALUES (500, 'GCRANE', '95000.00', 90);
COMMIT;

/*
 ** +-------------------------------------------------------------+
 ** | MOVING PATITIONS                                            |
 ** | ----------------------------------------------------------- |
 ** | Allows the transfer of table partitions from one tablespace |
 ** | to another. The status of the index partitions tied to this |
 ** | partition become 'unusable'. In the case of a global index, |
 ** | the whole index has to be rebuilt.                          |
 ** |                                                             |
 ** | You can use the MOVE PARTITION clause of the ALTER TABLE    |
 ** | statement to re-cluster data and reduce fragmentation, move |
 ** | a partition to another tablespace, or modify create-time    |
 ** | attributes.                                                 |
 ** |                                                             |
 ** | When the partition you are moving contains data,            |
 ** | MOVE PARTITION marks the matching partition in each local   |
 ** | index, and all global index partitions as unusable. You     |
 ** | must rebuild these index partitions after issuing           |
 ** | MOVE PARTITION. Global indexes must also be rebuilt.        |
 ** |                                                             |
 ** | You can rebuild the entire index by rebuilding each         |
 ** | partition individually using the                            |
 ** | ALTER INDEX...REBUILD PARTITION statement. You can perform  |
 ** | these rebuilds concurrently. You can also simply drop the   |
 ** | index and re-create it.                                     |
 ** |                                                             |
 ** | If the partition is not empty, MOVE PARTITION marks all     |
 ** | corresponding local index partitions, all global            |
 ** | nonpartitioned indexes, and all the partitions of global    |
 ** | partitioned indexes, UNUSABLE.                              |
 ** |                                                             |
 ** | RESTRICTIONS:                                               |
 ** | You cannot MOVE an entire partitioned table (either heap or |
 ** | index organized). You must move individual partitions or    |
 ** | subpartitions.                                              |
 ** |                                                             |
 ** +-------------------------------------------------------------+
*/

ALTER TABLE emp_part
  MOVE PARTITION emp_part_50_part
  TABLESPACE part_move_data_tbs
/


/*
 ** +-------------------------------------------------------------------+
 ** | REBUILDING INDEXES                                                |
 ** | ----------------------------------------------------------------- |
 ** | At this point the local index defined on partition "50" is        |
 ** | marked as "unusable". You only need to rebuild that index         |
 ** | partition for the local index.                                    |
 ** | ORA_DEMO.EMP_PART_IDX1 / EMP_PART_50_PART / (EMPNO) / UNUSABLE/   |
 ** |                                                                   |
 ** | Note: All partitions in the global index are marked as "UNUSABLE" |
 ** |       and will need rebuilt as well.                              |
 ** |                                                                   |
 ** | You might rebuild index partitions for any of the following       |
 ** | reasons:                                                          |
 ** |  (+) To recover space and improve performance                     |
 ** |  (+) To repair a damaged index partition caused by media failure  |
 ** |  (+) To rebuild a local index partition after loading the         |
 ** |        underlying table partition with IMPORT or SQL*Loader       |
 ** |  (+) To rebuild index partitions that have been marked UNUSABLE   |
 ** |                                                                   |
 ** +-------------------------------------------------------------------+
*/


/*
 ** +-------------------------------------------------------------------+
 ** | LOCAL INDEXES                                                     |
 ** | ----------------------------------------------------------------- |
 ** |   1. ALTER INDEX...REBUILD PARTITION/SUBPARTITION--this statement |
 ** |      rebuilds an index partition or subpartition unconditionally. |
 ** |   2. ALTER TABLE...MODIFY PARTITION/SUBPARTITION...REBUILD        |
 ** |      UNUSABLE LOCAL INDEXES--this statement finds all of the      |
 ** |      unusable indexes for the given table partition or            |
 ** |      subpartition and rebuilds them. It only rebuilds an index    |
 ** |      partition if it has been marked UNUSABLE.                    |
 ** |                                                                   |
 ** | The REBUILD UNUSABLE LOCAL INDEXES clause of the                  |
 ** | ALTER TABLE...MODIFY PARTITION does not allow you to specify any  |
 ** | new attributes for the rebuilt index partition.                   |
 ** +-------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx1
  REBUILD PARTITION emp_part_50_part
  TABLESPACE part_move_idx_tbs
/

-- <-- ... OR ... -->

ALTER TABLE emp_part
  MODIFY PARTITION emp_part_50_part
  REBUILD UNUSABLE LOCAL INDEXES
/

/*
 ** +-------------------------------------------------------------------+
 ** | GLOBAL INDEXES                                                    |
 ** | ----------------------------------------------------------------- |
 ** | You can rebuild global index partitions in two ways:              |
 ** |   1. Rebuild each partition by issuing the                        |
 ** |      ALTER INDEX...REBUILD PARTITION statement (you can run the   |
 ** |      rebuilds concurrently).                                      |
 ** |   2. Drop the index and re-create it.                             |
 ** |   Note: This second method is more efficient because the table    |
 ** |         is scanned only once.                                     |
 ** |                                                                   |
 ** | NOTE: There is no short-cut to rebuilding all partitions within   |
 ** |       a global index partition. You will need to rebuild all      |
 ** |       partitions seperatley.                                      |
 ** +-------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D10_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D20_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D30_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D40_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D50_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D60_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D70_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D80_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D100_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_DMAX_part
/


/*
 ** +--------------------------------------------------------------------+
 ** | ADDING PARTITIONS                                                  |
 ** | ------------------------------------------------------------------ |
 ** | Allows you to add an extra partition beyond the last partition     |
 ** | as long as the upper limit is not equal to MAXVALUE. Should it     |
 ** | be equal, then adding a partition would be impossible. SPLIT       |
 ** | enables you to add intermediate partitions. SPLIT cuts an existing |
 ** | partition in half, making two distinct partitions. Applied to the  |
 ** | upper partition, SPLIT allows you to add an extra partition beyond |
 ** | the upper limit.                                                   |
 ** |                                                                    |
 ** | The first example below would fail since the upper limit is equal  |
 ** | to MAXVALUE.                                                       |
 ** |                                                                    |
 ** | In the case of indexes, partitions can only be added to global     |
 ** | indexes. The upper limit of a global index always being MAXVALUE   |
 ** | implies that SPLIT is the only possible command.                   |
 ** +--------------------------------------------------------------------+
*/

-- ALTER TABLE emp_part
--   ADD PARTITION emp_part_250_part 
--   VALUES LESS THAN (250)
--   TABLESPACE part_4_idx_tbs
-- /
-- ERROR at line 2:
-- ORA-14074: partition bound must collate higher than that of the last partition


ALTER TABLE emp_part
  SPLIT PARTITION emp_part_MAX_part AT (250)
  INTO (
    PARTITION emp_part_250_part
      TABLESPACE part_5_data_tbs,
    PARTITION emp_part_MAX_part
      TABLESPACE part_max_data_tbs
  )
/

/*
 ** +--------------------------------------------------------------------+
 ** | At the point after the split, the two upper partitions (or the     |
 ** | "split" partitions will render local partitions (and all global    |
 ** | indexes UNUSABLE. Local partitions will ONLY be marked as          |
 ** | 'UNUSABLE' if they contain data. If they do not contain data, they |
 ** | will remain as 'USABLE'.                                           |
 ** |                                                                    |
 ** |   EMP_PART_IDX1 / EMP_PART_250_PART / PART_MAX_DATA_TBS / UNUSABLE |
 ** |   EMP_PART_IDX1 / EMP_PART_MAX_PART / PART_MAX_DATA_TBS / UNUSABLE |
 ** |                                                                    |
 ** | Note that when I rebuild the indexes (to make them usable) I also  |
 ** | want to change the tablespaces they reside in since they are       |
 ** | split using the tablespace of the "DATA" partition.                |
 ** |                                                                    |
 ** | Note: As well as the above two partitions being rendered as        |
 ** |       all global indexe partitions are maked "UNUSABLE". They      |
 ** |       will all require to be rebuilt.                              |
 ** +--------------------------------------------------------------------+
*/


/*
 ** +--------------------------------------------------------------------+
 ** | REBUILD ALL LOCAL INDEXES...                                       |
 ** +--------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx1
  REBUILD PARTITION emp_part_250_part
  TABLESPACE part_5_idx_tbs
/

ALTER INDEX emp_part_idx1
  REBUILD PARTITION emp_part_max_part
  TABLESPACE part_max_idx_tbs
/

/*
 ** +--------------------------------------------------------------------+
 ** | REBUILD ALL GLOBAL INDEXES...                                      |
 ** +--------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D10_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D20_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D30_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D40_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D50_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D60_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D70_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D80_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D100_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_DMAX_part
/



/*
 ** +--------------------------------------------------------------------+
 ** | DROPPING TABLE PARTITIONS                                          |
 ** | ------------------------------------------------------------------ |
 ** | Allows the withdrawl of a table or global index partition. The     |
 ** | DROP of a table partition causes the status of all the partitions  |
 ** | of the global index to become "UNUSABLE". A complete rebuild of    |
 ** | the index has to occur to modify the status.                       |
 ** |                                                                    |
 ** | The current row count of "emp_part" is:   -> 152                   |
 ** +--------------------------------------------------------------------+
*/

ALTER TABLE emp_part DROP PARTITION emp_part_100_part
/

/*
 ** +---------------------------------------------------------------------+
 ** | After dropping partition "emp_part_100_part" the count is:  -> 144  |
 ** |                                                                     |
 ** | Note: Any global indexes are marked as "UNUSABLE". They will need   |
 ** |       rebuilt.                                                      |
 ** +---------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D10_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D20_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D30_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D40_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D50_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D60_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D70_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D80_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D100_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_DMAX_part
/


/*
 ** +--------------------------------------------------------------------+
 ** | DROPPING GLOBAL INDEX PARTITIONS                                   |
 ** | ------------------------------------------------------------------ |
 ** | You cannot explicitly drop a partition of a local index. Instead,  |
 ** | local index partitions are dropped only when you drop a partition  |
 ** | from the underlying table.                                         |
 ** |                                                                    |
 ** | If a global index partition is empty, you can explicitly drop it   |
 ** | by issuing the ALTER INDEX...DROP PARTITION statement. But, if a   |
 ** | global index partition contains data, dropping the partition       |
 ** | causes the next highest partition to be marked UNUSABLE. For       |
 ** | example, you would like to drop the index partition P1 and P2 is   |
 ** | the next highest partition. You must issue the following           |
 ** | statements:                                                        |
 ** |                                                                    |
 ** |   ALTER INDEX npr DROP PARTITION P1;                               |
 ** |   ALTER INDEX npr REBUILD PARTITION P2;                            |
 ** |                                                                    |
 ** | Note: You cannot drop the highest partition in a global index.     |
 ** +--------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx2 DROP PARTITION emp_part_D80_part
/

ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/


/*
 ** +--------------------------------------------------------------------+
 ** | TRUNCATING PARTITIONS                                              |
 ** | ------------------------------------------------------------------ |
 ** | Discards all the rows of a table partition while the storage       |
 ** | allocated may be preserved. This option is not available for       |
 ** | indexes. Local index partitions are automatically kept up to date  |
 ** | by Oracle and will remain in the 'USABLE' state. In the case of    |
 ** | global indexes, the status of ALL the partitions become 'UNUSABLE'.|
 ** |                                                                    |
 ** | The current row count of "emp_part" is:   -> 144                   |
 ** |                                                                    |
 ** +--------------------------------------------------------------------+
*/


ALTER TABLE emp_part TRUNCATE PARTITION emp_part_200_part
/


/*
 ** +--------------------------------------------------------------------+
 ** |                                                                    |
 ** | After truncating the "emp_part_200_part" partition, the count      |
 ** | is:  -> 116 and ALL global index partitions need to be rebuilt.    |
 ** |                                                                    |
 ** +--------------------------------------------------------------------+
*/


ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D10_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D20_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D30_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D40_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D50_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D60_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D70_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D100_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_DMAX_part
/


/*
 ** +--------------------------------------------------------------------+
 ** | SPLITTING PARTITIONS                                               |
 ** | ------------------------------------------------------------------ |
 ** | Separates the contents of a partition into two distinct partitions.|
 ** | The associated index partitions, global and local, become          |
 ** | 'UNUSABLE'. In the following example, the emp_part_150_part        |
 ** | partition is divided into two distinct partitions,                 |
 ** | emp_part_100_part and emp_part_150_part. The two partitions are    |
 ** | redefined in the following values: 50-100 and 100-150. This        |
 ** | functionality also works on global indexes.                        |
 ** +--------------------------------------------------------------------+
*/


ALTER TABLE emp_part
  SPLIT PARTITION emp_part_150_part AT (100)
  INTO (
    PARTITION emp_part_100_part
      TABLESPACE part_2_data_tbs,
    PARTITION emp_part_150_part
      TABLESPACE part_3_data_tbs
  )
/


/*
 ** +--------------------------------------------------------------------+
 ** | At the point after the split, the two upper partitions (or the     |
 ** | "split" partitions will render local partitions (and all global    |
 ** | indexes UNUSABLE. Local partitions will ONLY be marked as          |
 ** | 'UNUSABLE' if they contain data. If they do not contain data, they |
 ** | will remain as 'USABLE'.                                           |
 ** |                                                                    |
 ** |   EMP_PART_IDX1 / EMP_PART_100_PART / PART_2_DATA_TBS / UNUSABLE   |
 ** |   EMP_PART_IDX1 / EMP_PART_150_PART / PART_3_DATA_TBS / UNUSABLE   |
 ** |                                                                    |
 ** | Note that when I rebuild the indexes (to make them usable) I also  |
 ** | want to change the tablespaces they reside in since they are       |
 ** | split using the tablespace of the "DATA" partition.                |
 ** |                                                                    |
 ** | Note: As well as the above two partitions being rendered as        |
 ** |       ALL global indexe partitions are maked "UNUSABLE". They      |
 ** |       will all require to be rebuilt.                              |
 ** +--------------------------------------------------------------------+
*/


/*
 ** +--------------------------------------------------------------------+
 ** | REBUILD ALL LOCAL INDEXES...                                       |
 ** +--------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx1
  REBUILD PARTITION emp_part_100_part
  TABLESPACE part_2_idx_tbs
/

ALTER INDEX emp_part_idx1
  REBUILD PARTITION emp_part_150_part
  TABLESPACE part_3_idx_tbs
/

/*
 ** +--------------------------------------------------------------------+
 ** | REBUILD ALL GLOBAL INDEXES...                                      |
 ** +--------------------------------------------------------------------+
*/

ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D10_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D20_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D30_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D40_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D50_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D60_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D70_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D90_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_D100_part
/
ALTER INDEX emp_part_idx2
  REBUILD PARTITION emp_part_DMAX_part
/


/*
 ** +--------------------------------------------------------------------+
 ** | EXCHANGE PARTITIONS                                                |
 ** | ------------------------------------------------------------------ |
 ** | Allows the transfer of non-partitioned tables into partitions as   |
 ** | as the reverse. That is the transfer of partitions into            |
 ** | non-partitioned tables. This option is particualry useful in       |
 ** | migrating V7 partitioned views into table partitions. Consider the |
 ** | following partitioned view based on four tables: less50, less100,  |
 ** | less150, less200.
 ** +--------------------------------------------------------------------+
*/

CREATE TABLE less50  (empno NUMBER(15), empname VARCHAR2(100));
CREATE TABLE less100 (empno NUMBER(15), empname VARCHAR2(100));
CREATE TABLE less150 (empno NUMBER(15), empname VARCHAR2(100));
CREATE TABLE less200 (empno NUMBER(15), empname VARCHAR2(100));

CREATE VIEW less_view AS
  SELECT * FROM less50
  UNION ALL
  SELECT * FROM less100
  UNION ALL
  SELECT * FROM less150
  UNION ALL
  SELECT * FROM less200
/


/*
 ** +--------------------------------------------------------------------+
 ** | An empty partitioned table needs to be created, within the same    |
 ** | schema as the underlying tables of the partitioned view.           |
 ** +--------------------------------------------------------------------+
*/

CREATE TABLE new_less (
    empno NUMBER(15)
  , empname VARCHAR2(100)
)
PARTITION BY RANGE (empno) (
  PARTITION new_less_50_part
    VALUES LESS THAN (50),
  PARTITION new_less_100_part
    VALUES LESS THAN (100),
  PARTITION new_less_150_part
    VALUES LESS THAN (150),
  PARTITION new_less_200_part
    VALUES LESS THAN (200)
)
/

INSERT INTO less50 VALUES ( 0, 'JHUNTER');
INSERT INTO less50 VALUES (10, 'JHUNTER');
INSERT INTO less50 VALUES (20, 'JHUNTER');
INSERT INTO less50 VALUES (30, 'JHUNTER');
INSERT INTO less50 VALUES (40, 'JHUNTER');

INSERT INTO less100 VALUES (50, 'MHUNTER');
INSERT INTO less100 VALUES (60, 'MHUNTER');
INSERT INTO less100 VALUES (70, 'MHUNTER');
INSERT INTO less100 VALUES (80, 'MHUNTER');
INSERT INTO less100 VALUES (90, 'MHUNTER');

INSERT INTO less150 VALUES (100, 'AHUNTER');
INSERT INTO less150 VALUES (110, 'AHUNTER');
INSERT INTO less150 VALUES (120, 'AHUNTER');
INSERT INTO less150 VALUES (130, 'AHUNTER');
INSERT INTO less150 VALUES (140, 'AHUNTER');

INSERT INTO less200 VALUES (150, 'HUNTER');
INSERT INTO less200 VALUES (160, 'HUNTER');
INSERT INTO less200 VALUES (170, 'HUNTER');
INSERT INTO less200 VALUES (180, 'HUNTER');
INSERT INTO less200 VALUES (190, 'HUNTER');

COMMIT;

/*
 ** +---------------------------------------------------------------------+
 ** | Now transfer each underlying table of the view in the corresponding |
 ** | partition of the new partitioned table.                             |
 ** +---------------------------------------------------------------------+
*/

ALTER TABLE new_less
  EXCHANGE PARTITION new_less_50_part
  WITH TABLE less50
  WITH VALIDATION
/

ALTER TABLE new_less
  EXCHANGE PARTITION new_less_100_part
  WITH TABLE less100
  WITH VALIDATION
/

ALTER TABLE new_less
  EXCHANGE PARTITION new_less_150_part
  WITH TABLE less150
  WITH VALIDATION
/

ALTER TABLE new_less
  EXCHANGE PARTITION new_less_200_part
  WITH TABLE less200
  WITH VALIDATION
/


/*
 ** +--------------------------------------------------------------------+
 ** | This operation takes a very short time as the updates only take    |
 ** | place in the data dictionary. There is no physical movement of the |
 ** | segments. The structure of the tables to swap partitioned as well  |
 ** | as non-partitioned must be identical in terms of types, columns    |
 ** | and sizes, as well as number of columns.                           |
 ** +--------------------------------------------------------------------+
*/



/*
 ** +--------------------------------------------------------------------+
 ** | UNUSABLE INDEXES                                                   |
 ** | ------------------------------------------------------------------ |
 ** | Both local and global indexes can be renered with the status       |
 ** | of 'UNUSABLE'. This happens mostly during maintenance operations   |
 ** | on the partitioned table. (i.e. Truncates, Splits, Moves, etc.)    |
 ** | When an index partition is in the 'UNUSABLE' state, any DML        |
 ** | operation that require use of the partition are not allowed. This  | 
 ** | includes SELECT, INSERT, UPDATE and DELETE.                        |
 ** | The following examples assume the index partition:                 |
 ** | "emp_part_50_part" is in an 'UNUSABLE' state.                      |
 ** +--------------------------------------------------------------------+
*/


/*
 ** ------------------------------------------------------------
 ** FULL TABLE SCAN ALLOWED SINCE IT DOES NOT REQUIRE USE OF THE 
 ** PARTITIONED INDEX
 **
 ** SQL> select * from emp_part;
 ** 
 **  EMPNO ENAME              SAL     DEPTNO
 ** ------ ------------------ ---------- ----------
 **    10 JHUNTER            185000         10
 **    11 JHUNTER            185000         10
 **    12 JHUNTER            185000         10
 **    13 JHUNTER            185000         10
 ** 
 ** ------------------------------------------------------------
*/


/*
 ** ------------------------------------------------------------
 ** NOW TRY THE SAME QUERY BUT WITH THE INTENT OF USING THE
 ** PARTITIONED INDEX: "EMP_PART_IDX1"
 ** 
 ** SQL> select * from emp_part where empno < 200;
 ** select * from emp_part where empno < 200
 ** *
 ** ERROR at line 1:
 ** ORA-01502: index 'ORA_DEMO.EMP_PART_IDX1' or partition of such index is in unusable state
 **
 ** ------------------------------------------------------------
*/


/*
 ** ------------------------------------------------------------
 ** DML OPERATIONS LIKE INSERT, UPDATE AND DELETE WILL WORK
 ** AS LONG AS THEY DO NOT REQUIRE USE OF THE 'UNUSABLE'
 ** INDEX PARTITION.
 **
 ** SQL> delete from emp_part where empno > 100;
 ** 122 rows deleted.
 **
 ** ------------------------------------------------------------
*/


/*
 ** ------------------------------------------------------------
 ** BUT WHEN ONE OF THESE COMMANDS NEED TO UPDATE THE INDEX
 ** PARTITION, THEY WILL FAIL.
 **
 ** SQL> delete from emp_part where empno > 20;
 ** delete from emp_part where empno > 20
 ** *
 ** ERROR at line 1:
 ** ORA-01502: index 'ORA_DEMO.EMP_PART_IDX1' or partition of such index is in unusable state
 **
 ** ------------------------------------------------------------
*/

