#!/bin/ksh

# +----------------------------------------------------------------------------+
# |                          Jeffrey M. Hunter                                 |
# |                      jhunter@idevelopment.info                             |
# |                         www.idevelopment.info                              |
# |----------------------------------------------------------------------------|
# |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
# |----------------------------------------------------------------------------|
# | DATABASE   : N/A                                                           |
# | FILE       : iscsi_client_services_solaris.ksh                             |
# | CLASS      : UNIX Shell Scripts                                            |
# | PURPOSE    : Example KSH script used to add or remove iSCSI services from  |
# |              a node running the Solaris Operating Environment.             |
# | PARAMETERS : SCRIPT_ACTION        Used to instruct this script whether to  |
# |                                   add or remove iSCSI services. Possible   |
# |                                   values are "add" or "remove".            |
# | NOTE       : As with any code, ensure to test this script in a development |
# |              environment before attempting to run it in production.        |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# | GLOBAL CUSTOM VARIABLES                                                    |
# +----------------------------------------------------------------------------+
iSCSI_MOUNT_POINTS="u04"          # Separate multiple values with a single space
iSCSI_TARGET_IP="192.168.2.195"
iSCSI_TARGET_PORT="3260"


# +----------------------------------------------------------------------------+
# | GLOBAL INTERNAL VARIABLES                                                  |
# +----------------------------------------------------------------------------+
SCRIPT_NAME_FULL=$0
SCRIPT_NAME=${SCRIPT_NAME_FULL##*/}
SCRIPT_NAME_NOEXT=${SCRIPT_NAME%.?*}
SCRIPT_NUM_PARAMS=$#
HOSTNAME=`hostname`
HOST_RVAL_SUCCESS=0
HOST_RVAL_ERROR=2
ERRORS=NULL


# +----------------------------------------------------------------------------+
# | GLOBAL FUNCTIONS                                                           |
# +----------------------------------------------------------------------------+

function showUsage {

    echo " "
    echo "Usage: ${SCRIPT_NAME} script_action"
    echo " "
    echo "       parameters:  script_action: ADD|REMOVE"

    return

}

function initializeScript {

    typeset -ru L_FIRST_PARAMETER=${1}

    if [[ $L_FIRST_PARAMETER = "-H" || $L_FIRST_PARAMETER = "-HELP" || $L_FIRST_PARAMETER = "--HELP" || -z $L_FIRST_PARAMETER ]]; then
        showUsage
        echo " "
        exit $HOST_RVAL_SUCCESS
    fi

    ERRORS="NO"

    return

}

function exitError {

    echo " "
    echo "+----------------------------------------------+"
    echo "|    !!!!!!!!    CRITICAL ERROR    !!!!!!!!    |"
    echo "+----------------------------------------------+"
    echo " "
    echo "Exiting script (${HOST_RVAL_ERROR})."
    echo " "

    exit ${HOST_RVAL_ERROR}

}

function exitSuccess {

    echo " "
    echo "+----------------------------------------------+"
    echo "|                  SUCCESSFUL                  |"
    echo "+----------------------------------------------+"
    echo " "
    echo "Exiting script (${HOST_RVAL_SUCCESS})."
    echo " "

    exit ${HOST_RVAL_SUCCESS}

}


function promptUser {

    typeset -r L_SCRIPT_ACTION=${1}

    echo " "
    echo "Are you sure you would like to ${L_SCRIPT_ACTION} iSCSI services on ${HOSTNAME} (y/[n])?"
    echo " "
    
    read userResponse
    
    if [[ ${userResponse} == "" || ${userResponse} == "N" || ${userResponse} == "n" ]]; then
      echo "Exiting script as per user request. No actions were performed."
      echo "Good-bye!"
      echo " "
      exit ${HOST_RVAL_SUCCESS}
    fi

    return

}


function configureNewDiskInstructionsSolaris {

    echo " "
    echo "------------------------------------------------------------"
    echo "Configure New Disk Example (Solaris)"
    echo "------------------------------------------------------------"

    echo " "
    echo "------------------------------------------------------------"
    echo "Format Disk"
    echo "------------------------------------------------------------"
    echo "# format"
    echo "Searching for disks...done"
    echo " "    
    echo "    AVAILABLE DISK SELECTIONS:"
    echo "       0. c0t0d0 <WDC WD400BB-22DEA0 cyl 19156 alt 2 hd 16 sec 255>"
    echo "          /pci@1f,0/ide@d/dad@0,0"
    echo "       1. c0t2d0 <WDC WD400BB-22DEA0 cyl 19156 alt 2 hd 16 sec 255>"
    echo "          /pci@1f,0/ide@d/dad@2,0"
    echo "       2. c1t0d0 <Openfile-Virtualdisk-0 cyl 1626 alt 2 hd 64 sec 256>"
    echo "          /iscsi/disk@0000iqn.2006-01.com.openfiler%3Ascsi.alex-data-10001,0"
    echo "Specify disk (enter its number): 2"
    echo "selecting c1t0d0"
    echo "[disk formatted]"
    echo " "
    echo " "
    echo "FORMAT MENU:"
    echo "        disk       - select a disk"
    echo "        type       - select (define) a disk type"
    echo "        partition  - select (define) a partition table"
    echo "        current    - describe the current disk"
    echo "        format     - format and analyze the disk"
    echo "        fdisk      - run the fdisk program"
    echo "        repair     - repair a defective sector"
    echo "        label      - write label to the disk"
    echo "        analyze    - surface analysis"
    echo "        defect     - defect list management"
    echo "        backup     - search for backup labels"
    echo "        verify     - read and display labels"
    echo "        save       - save new disk/partition definitions"
    echo "        inquiry    - show vendor, product and revision"
    echo "        volname    - set 8-character volume name"
    echo "        !<cmd>     - execute <cmd>, then return"
    echo "        quit"
    echo "format> fdisk"
    echo "No fdisk table exists. The default partition for the disk is:"
    echo " "
    echo "  a 100% \"SOLARIS System\" partition"
    echo " "
    echo "Type \"y\" to accept the default partition,  otherwise type \"n\" to edit the"
    echo " partition table."
    echo "y"
    echo "format> partition"
    echo " "
    echo "PARTITION MENU:"
    echo "        0      - change '0' partition"
    echo "        1      - change '1' partition"
    echo "        2      - change '2' partition"
    echo "        3      - change '3' partition"
    echo "        4      - change '4' partition"
    echo "        5      - change '5' partition"
    echo "        6      - change '6' partition"
    echo "        7      - change '7' partition"
    echo "        select - select a predefined table"
    echo "        modify - modify a predefined partition table"
    echo "        name   - name the current table"
    echo "        print  - display the current table"
    echo "        label  - write partition map and label to the disk"
    echo "        !<cmd> - execute <cmd>, then return"
    echo "        Quit"
    echo " "
    echo "partition> modify"
    echo "Select partitioning base:"
    echo "        0. Current partition table (original)"
    echo "        1. All Free Hog"
    echo "Choose base (enter number) [0]? 1"
    echo " "
    echo "Part      Tag    Flag     Cylinders        Size            Blocks"
    echo "  0       root    wm       0               0         (0/0/0)           0"
    echo "  1       swap    wu       0               0         (0/0/0)           0"
    echo "  2     backup    wu       0 - 1625       12.70GB    (1626/0/0) 26640384"
    echo "  3 unassigned    wm       0               0         (0/0/0)           0"
    echo "  4 unassigned    wm       0               0         (0/0/0)           0"
    echo "  5 unassigned    wm       0               0         (0/0/0)           0"
    echo "  6        usr    wm       0               0         (0/0/0)           0"
    echo "  7 unassigned    wm       0               0         (0/0/0)           0"
    echo " "
    echo "Do you wish to continue creating a new partition"
    echo "table based on above table[yes]? yes"
    echo "Free Hog partition[6]? 7"
    echo "Enter size of partition '0' [0b, 0c, 0.00mb, 0.00gb]: 128mb"
    echo "Enter size of partition '1' [0b, 0c, 0.00mb, 0.00gb]:"
    echo "Enter size of partition '3' [0b, 0c, 0.00mb, 0.00gb]:"
    echo "Enter size of partition '4' [0b, 0c, 0.00mb, 0.00gb]:"
    echo "Enter size of partition '5' [0b, 0c, 0.00mb, 0.00gb]:"
    echo "Enter size of partition '6' [0b, 0c, 0.00mb, 0.00gb]: 12.575gb"
    echo " "
    echo "Part      Tag    Flag     Cylinders        Size            Blocks"
    echo "  0       root    wm       0 -   15      128.00MB    (16/0/0)     262144"
    echo "  1       swap    wu       0               0         (0/0/0)           0"
    echo "  2     backup    wu       0 - 1625       12.70GB    (1626/0/0) 26640384"
    echo "  3 unassigned    wm       0               0         (0/0/0)           0"
    echo "  4 unassigned    wm       0               0         (0/0/0)           0"
    echo "  5 unassigned    wm       0               0         (0/0/0)           0"
    echo "  6        usr    wm      16 - 1625       12.58GB    (1610/0/0) 26378240"
    echo "  7 unassigned    wm       0               0         (0/0/0)           0"
    echo " "
    echo "Okay to make this the current partition table[yes]? yes"
    echo "Enter table name (remember quotes): \"data1\""
    echo " "
    echo "Ready to label disk, continue? yes"
    echo " " 
    echo "partition> quit"
    echo " "    
    echo "FORMAT MENU:"
    echo "    disk       - select a disk"
    echo "    type       - select (define) a disk type"
    echo "    partition  - select (define) a partition table"
    echo "    current    - describe the current disk"
    echo "    format     - format and analyze the disk"
    echo "    repair     - repair a defective sector"
    echo "    label      - write label to the disk"
    echo "    analyze    - surface analysis"
    echo "    defect     - defect list management"
    echo "    backup     - search for backup labels"
    echo "    verify     - read and display labels"
    echo "    save       - save new disk/partition definitions"
    echo "    inquiry    - show vendor, product and revision"
    echo "    volname    - set 8-character volume name"
    echo "    !<cmd>     - execute <cmd>, then return"
    echo "    quit"
    echo "format> quit"

    echo " "
    echo "------------------------------------------------------------"
    echo "Create UFS File System"
    echo "------------------------------------------------------------"

    echo " "
    echo "Create a UFS file system on the new disk using the newfs command."
    echo "The device name should be /dev/rdsk/c1t0d0s6 if you partitioned as above."

    echo " "
    echo "# newfs /dev/rdsk/c1t0d0s6"
    echo "newfs: construct a new file system /dev/rdsk/c1t0d0s6: (y/n)? y"
    echo "Warning: 4096 sector(s) in last cylinder unallocated"
    echo "/dev/rdsk/c1t0d0s6:     26378240 sectors in 4294 cylinders of 48 tracks, 128 sectors"
    echo "        12880.0MB in 269 cyl groups (16 c/g, 48.00MB/g, 5824 i/g)"
    echo "super-block backups (for fsck -F ufs -o b=#) at:"
    echo " 32, 98464, 196896, 295328, 393760, 492192, 590624, 689056, 787488, 885920,"
    echo " 25461152, 25559584, 25658016, 25756448, 25854880, 25953312, 26051744,"
    echo " 26150176, 26248608, 26347040"

    echo " "
    echo "------------------------------------------------------------"
    echo "Create Mount Point"
    echo "------------------------------------------------------------"

    echo "Create a mount point that will be used to mount the new disk "
    echo "somewhere in the current file system: "
    
    echo " "
    echo "# mkdir -p /u04"

    echo " "
    echo "------------------------------------------------------------"
    echo "Modify /etc/vfstab"
    echo "------------------------------------------------------------"

    echo " "
    echo "Edit /etc/vfstab and add a line for the new file system."
    echo "It should look like this (all one line with tabs separating the fields):"

    echo "/dev/dsk/c1t0d0s6       /dev/rdsk/c1t0d0s6      /u04    ufs     2       yes     -"

    echo " "
    echo "This will mount the file system to /u04 at boot time."

    echo " "
    echo "------------------------------------------------------------"
    echo "Manually Mount New File System"
    echo "------------------------------------------------------------"
    
    echo " "
    echo "# mount /u04"
    
    return

}

function performAddService {

    echo " "
    echo "------------------------------------------------------------"
    echo "Configure iSCSI Target Discovery"
    echo "------------------------------------------------------------"

    iscsiadm add discovery-address ${iSCSI_TARGET_IP}:${iSCSI_TARGET_PORT}
    
    echo " "
    echo "------------------------------------------------------------"
    echo "Enable the iSCSI Target Discovery Method"
    echo "------------------------------------------------------------"

    iscsiadm modify discovery --sendtargets enable

    echo " "
    echo "------------------------------------------------------------"
    echo "Create the iSCSI Device Links for the Local System"
    echo "------------------------------------------------------------"

    devfsadm -i iscsi

    echo " "
    echo "------------------------------------------------------------"
    echo "Configure New Disk Instructions"
    echo "------------------------------------------------------------"
    echo " "
    echo "Use the following \"example\" as a template to configure the new disk for Solaris"
    
    configureNewDiskInstructionsSolaris

    return
    
}

function performRemoveService {

    cd /

    for mount_point in $iSCSI_MOUNT_POINTS; do
        echo " "
        echo "Unmounting ${mount_point}"
        umount $mount_point
    done
    
    echo " "
    echo "------------------------------------------------------------"
    echo "Removing the iSCSI Target Discovery Method"
    echo "------------------------------------------------------------"

    iscsiadm remove discovery-address ${iSCSI_TARGET_IP}:${iSCSI_TARGET_PORT}

    echo " "
    echo "------------------------------------------------------------"
    echo "Disabling iSCSI Target Discovery"
    echo "------------------------------------------------------------"

    iscsiadm modify discovery --sendtargets disable

    echo " "
    echo "------------------------------------------------------------"
    echo "Remove or comment out the following entry to /etc/vfstab"
    echo "------------------------------------------------------------"
    
    echo " "
    echo "/dev/dsk/c1t0d0s6       /dev/rdsk/c1t0d0s6      /u04    ufs     2       yes     -"

    echo " "
    echo "------------------------------------------------------------"
    echo "Create the iSCSI Device Links for the Local System"
    echo "------------------------------------------------------------"

    devfsadm -C

    return
    
}


# +----------------------------------------------------------------------------+
# |                                                                            |
# |                            SCRIPT STARTS HERE                              |
# |                                                                            |
# +----------------------------------------------------------------------------+

initializeScript "${1}"

if (( $SCRIPT_NUM_PARAMS != 1 )); then
    showUsage
    echo " "
    echo "Invalid number of parameters."
    exitError
fi

SCRIPT_ACTION=$1
SCRIPT_ACTION=`echo $SCRIPT_ACTION | tr '[:lower:]' '[:upper:]'`

promptUser $SCRIPT_ACTION

echo " "
echo "------------------------------------------------------------"
echo "SCRIPT PARAMETERS"
echo "------------------------------------------------------------"
echo "SCRIPT_NAME                 : $SCRIPT_NAME"
echo "HOSTNAME                    : $HOSTNAME"
echo "SCRIPT_NUM_PARAMS           : $SCRIPT_NUM_PARAMS"
echo "iSCSI_MOUNT_POINTS          : $iSCSI_MOUNT_POINTS"
echo "iSCSI_TARGET_IP             : $iSCSI_TARGET_IP"
echo "iSCSI_TARGET_PORT           : $iSCSI_TARGET_PORT"

case ${SCRIPT_ACTION} in
    ADD)    performAddService
            ;;
    REMOVE) performRemoveService
            ;;
    *)      showUsage
            echo " "
            echo "Invalid parameter value: SCRIPT_ACTION"
            exitError
            ;;
esac


if [[ $ERRORS = "YES" ]]; then
    exitError
else
    exitSuccess
fi
