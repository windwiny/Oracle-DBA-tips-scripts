#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                        |
# | FILE       : iscsi-ls-map.ksh                                              |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : Script used to generate a full mapping of iSCSI target names  |
# |              to local SCSI device names.                                   |
# | PARAMETERS : None.                                                         |
# |                                                                            |
# | EXAMPLE                                                                    |
# | OUTPUT     : Host / SCSI ID    SCSI Device Name          iSCSI Target Name |
# |              ----------------  ------------------------  ----------------- |
# |              0                 /dev/sda1                 asm4              |
# |              1                 /dev/sdb1                 asm3              |
# |              2                 /dev/sdd1                 asm2              |
# |              3                 /dev/sdc1                 asm1              |
# |              4                 /dev/sde1                 crs               |
# |                                                                            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

RUN_USERID=root
export RUN_USERID

RUID=`id | awk -F\( '{print $2}'|awk -F\) '{print $1}'`
if [[ ${RUID} != "$RUN_USERID" ]];then
    echo " "
    echo "You must be logged in as $RUN_USERID to run this script."
    echo "Exiting script."
    echo " "
    exit 1
fi

dmesg | grep "^Attach"  \
      | awk -F" " '{ print "/dev/"$4 "1 " $6 }'  \
      | sed -e 's/,//' | sed -e 's/scsi//'  \
      | sort -n -k2  \
      | sed -e '/disk1/d' > /tmp/tmp_scsi_dev

iscsi-ls | egrep -e "TARGET NAME" -e "HOST ID"   \
         | awk -F" " '{ if ($0 ~ /^TARGET.*/) printf $4; if ( $0 ~ /^HOST/) printf " %s\n",$4}'  \
         | sort -n -k2  \
         | cut -d':' -f2-  \
         | cut -d'.' -f2- > /tmp/tmp_scsi_targets

join -t" " -1 2 -2 2 /tmp/tmp_scsi_dev /tmp/tmp_scsi_targets > MAP


echo "Host / SCSI ID    SCSI Device Name          iSCSI Target Name"
echo "----------------  ------------------------  -----------------"

cat MAP | sed -e 's/ /                 /g'

rm -f MAP
