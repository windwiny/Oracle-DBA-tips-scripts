#!/bin/bash

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : metalink_download_patch.sh                                    |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : Unix BASH script used to download Oracle patch files from     |
# |              the My Oracle Support (MOS) website; formerly Metalink.       |
# |              Oracle has replaced the previous FTP site with HTTP downloads |
# |              using wget.                                                   |
# | PARAMETERS :                                                               |
# |              PATCH_FILE             Filename of the patch.                 |
# |              HTTP_USERNAME          Username on an HTTP server used by     |
# |                                     Wget.                                  |
# |              HTTP_PASSWORD          Password for username on an HTTP       |
# |                                     used by Wget.                          |
# |                                                                            |
# | EXAMPLE RUN:                                                               |
# |              metalink_download_patch.sh \                                  |
# |                  p10404530_112030_Linux-x86-64_1of7.zip \                  |
# |                  jhunter@idevelopment.info \                               |
# |                  myMOSPassword                                             |
# |                                                                            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT PARAMETER VARIABLES
# ----------------------------
PATCH_FILE=$1
HTTP_USERNAME=$2
HTTP_PASSWORD=$3

if [[ -z $HTTP_USERNAME ]]; then
    EXPECTED_NUM_SCRIPT_PARAMS=1
else
    EXPECTED_NUM_SCRIPT_PARAMS=3
fi

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%.?*}

# ----------------------------
# MISCELLANEOUS VARIABLES
# ----------------------------
HOST_RVAL_SUCCESS=0
HOST_RVAL_WARNING=2
HOST_RVAL_FAILED=2
SPROP_NUM_SCRIPT_PARAMS=$#
CURRENT_YEAR=`date +"%Y"`;
MOS_URL="https://updates.oracle.com/Orion/Download/download_patch/$PATCH_FILE"

# ----------------------------
# SHOW SIGN-ON BANNER
# ----------------------------
echo " "
echo "${SCRIPT_NAME}"
echo "Copyright (c) 1998-${CURRENT_YEAR} Jeffrey M. Hunter. All rights reserved."
echo " "

# ----------------------------
# GLOBAL FUNCTIONS
# ----------------------------

function showUsage {

    echo " "
    echo "Usage: ${SCRIPT_NAME} patch_file [http_username [http_password]]"
    echo " "

    return

}

# ----------------------------------------
# CHECK IF USER ASKED FOR HELP
# ----------------------------------------
if [[ $1 = "-H" || $1 = "-HELP" || $1 = "--HELP" || -z $1 ]]; then
    showUsage
    exit $HOST_RVAL_SUCCESS
fi

# ----------------------------------------
# VERIFY CORRECT NUMBER OF PARAMETERS
# ----------------------------------------
if (( $SPROP_NUM_SCRIPT_PARAMS != $EXPECTED_NUM_SCRIPT_PARAMS )); then
    showUsage
    echo " "
    echo "JMA-0001: Number of script parameters passed to this script = $SPROP_NUM_SCRIPT_PARAMS."
    echo "JMA-0002: Number of expected script parameters to this script = $EXPECTED_NUM_SCRIPT_PARAMS."
    echo " "
    exit $HOST_RVAL_SUCCESS
fi

# ----------------------------------------
# VERIFY HTTP USERNAME / PASSWORD
# ----------------------------------------
while [ -z $HTTP_USERNAME ]; do
   echo -n "Enter My Oracle Support username: "
   read HTTP_USERNAME
done

while [ -z $HTTP_PASSWORD ]; do
   echo -n "Enter My Oracle Support password: "
   stty -echo
   read HTTP_PASSWORD
   stty echo
done

# ----------------------------------------
# RETRIEVE ORACLE PATCH FILE
# ----------------------------------------
wget --http-user="$HTTP_USERNAME" \
--http-password="$HTTP_PASSWORD" \
--no-check-certificate  \
--output-document=$PATCH_FILE $MOS_URL

exit $HOST_RVAL_SUCCESS
