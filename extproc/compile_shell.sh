#!/bin/bash

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : compile_shell.sh                                              |
# | CLASS      : External Procedures                                           |
# | PURPOSE    : This script is responsible for compiling and building the     |
# |              shared library for the example PL/SQL external procedures     |
# |              demo. A new PL/SQL specification procedure (wrapper procedure)|
# |              named shell and  mailx will be created using the shared       |
# |              library.                                                      |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# ----------------------------------------
# Linux
# ----------------------------------------
gcc -fPIC -c shell.c
gcc -shared -static-libgcc -o shell.so shell.o
chmod 775 shell.so
# --- or ---------------------------------
# gcc -fPIC -DSHARED_OBJECT -c shell.c
# ld -shared -o shell.so shell.o
# chmod 775 shell.so

# ----------------------------------------
# Solaris
# ----------------------------------------
# gcc -m64 -fPIC -c shell.c
# gcc -m64 -shared -static-libgcc -o shell.so shell.o
# chmod 775 shell.so
# --- or ---------------------------------
# gcc -G -c shell.c
# ld -r -o shell.so shell.o
# chmod 775 shell.so

# ----------------------------------------
# Create PL/SQL specification procedure.
# ----------------------------------------
sqlplus -silent scott/tiger <<EOF
CREATE OR REPLACE LIBRARY shell_lib is '/u01/app/oracle/extproc/shell.so';
/
CREATE OR REPLACE PROCEDURE shell(command IN char)
  AS EXTERNAL
     NAME "sh"
     LIBRARY shell_lib
     LANGUAGE C
     PARAMETERS (command string);
/
CREATE OR REPLACE PROCEDURE mailx(send_to IN char, subject IN char, message IN char)
  AS EXTERNAL
     NAME "mailx"
     LIBRARY shell_lib
     LANGUAGE C
     PARAMETERS (send_to string, subject string, message string);
/
EOF

# ----------------------------------------
# Execute PL/SQL external procedure.
# ----------------------------------------
sqlplus -silent scott/tiger <<EOF
SET SERVEROUTPUT on
BEGIN
    shell('ls');
    mailx('jhunter@dbazone.com', 'EXTPROC Test', 'This is a test');
END;
EOF
