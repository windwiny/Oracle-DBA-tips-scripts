:

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# +----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# +----------------------------------------------------------------------------|
# | DATABASE : Oracle                                                          |
# | FILE     : asm_disk_mappings.ksh                                           |
# | CLASS    : UNIX Shell Scripts                                              |
# | PURPOSE  : Display ASM volume mappings to their physical devices. If the   |
# |            volumes are using ASMLib, this script will display their ASM    |
# |            name (i.e. ORCL:VOL1) as well as the [major,minor] numbers that |
# |            match the physical device.                                      |
# | NOTE     : As with any code, ensure to test this script in a development   |
# |            environment before attempting to run it in production.          |
# +----------------------------------------------------------------------------+

# ----------------------------
# SCRIPT NAME VARIABLES
# ----------------------------
VERSION="1.1"
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
CURRENT_YEAR=`${DATE_BIN} +"%Y"`;

echo " "
echo "$SCRIPT_NAME - Version $VERSION"
echo "Copyright (c) 1998-${CURRENT_YEAR} Jeffrey M. Hunter. All rights reserved."
echo " "

ORACLE_HOME=`grep ASM /etc/oratab | cut -d: -f2`
export ORACLE_HOME

PATH=$PATH:/u01/app/oracle/dba_scripts/bin:$ORACLE_HOME/bin
export PATH

ORACLE_SID=`grep ASM /etc/oratab | cut -d: -f1`
export ORACLE_SID

printf "\n"
printf "%-12s : %-25s\n" "HOSTNAME" `hostname`
printf "%-12s : %-25s\n" "ORACLE_HOME" "$ORACLE_HOME"
printf "%-12s : %-25s\n" "ORACLE_SID" "$ORACLE_SID"
printf "\n"

printf "\n%-15s %-14s %-11s %-7s\n" "ASM Disk" "Based On" "Minor,Major" "Size (MB)"
printf "%-15s %-14s %-11s %-7s\n" "---------------" "-------------" "-----------" "---------"

for i in `/etc/init.d/oracleasm listdisks`
do
    v_asmdisk=`/etc/init.d/oracleasm querydisk -d $i | awk '{print $2}'| sed 's/\"//g'`
    v_minor=`/etc/init.d/oracleasm querydisk -d $i | awk -F[ '{print $2}'| awk -F] '{print $1}' | awk '{print $1}'`
    v_major=`/etc/init.d/oracleasm querydisk -d $i | awk -F[ '{print $2}'| awk -F] '{print $1}' | awk '{print $2}'`
    v_device=`ls -la /dev | awk -v v_minor=$v_minor -v v_major=$v_major '{if ( $5==v_minor ) { if ( $6==v_major ) { print $10}}}'`
    v_size=`${ORACLE_HOME}/bin/kfod asm_diskstring='ORCL:*' disks=all | grep ${v_asmdisk} | awk '{print $2}'`
    total_size=`expr $total_size + $v_size`
    Formated_size=`echo $v_size | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'`
    printf "%-15s %-14s %-11s %-7s\n" $v_asmdisk "/dev/$v_device" "[$v_minor $v_major]" $Formated_size
done

printf "                                           ---------"
formated_total_size=`echo $total_size | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'`
printf "\nTotal: %43s\n\n" $formated_total_size

exit
