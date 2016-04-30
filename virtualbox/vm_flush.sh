#!/bin/sh -e
# ===================================================
# Flush Virtual boxes by name
# Usage: . vm_flush.sh [-h <string - host name>] [-m <string - machine host name>] [-i <string - machine id>]

# --------------------------------------------------
# STEP 1
# do check to make sure VBoxManage is available

command -v VBoxManage >/dev/null 2>&1 || { echo "Virtualbox is not installed'. aborting" >&2; exit 1; }

# --------------------------------------------------
# STEP 2
# Get values from parameters passed to this script

hostName=""
machineName=""
machineId=""
# http://stackoverflow.com/a/16496491/405758
while getopts ":h:m:i:" o; do
    case "${o}" in
        h)
            hostName="${OPTARG}"
            ;;
        m)
            machineName="${OPTARG}"
            ;;
        i)
            machineId="_${OPTARG}"
            ;;
    esac
done
shift $((OPTIND-1))

# --------------------------------------------------
# STEP 3
# Collect possible matched box names

# start the boxes array, we'll look for each of these and destroy the box if found
boxes=()
boxes+=("${hostName}")
boxes+=("${machineName}")
boxes+=("${PWD##*/}")


# go though all the boxes and find the matching box
# to unset, should be named [directory]_[box_id]_[hash]
while read -r line; do
    if [[ ${line} == *"${machineId}"* ]]
        then
           echo "${line}" > tmp_vm.txt
           # http://unix.stackexchange.com/questions/137030/how-do-i-extract-the-content-of-quoted-strings-from-the-output-of-a-command
           boxes+=($(grep -o '".*"' tmp_vm.txt | sed 's/"//g'))
           rm -f tmp_vm.txt
        fi
done <<< "$(VBoxManage list vms)"

# --------------------------------------------------
# STEP 5
# Remove any existing boxes

# for each of the boxes found, unset it with VBoxManage
for i in "${boxes[@]}"; do
	VBoxManage unregistervm "${i}" --delete >/dev/null 2>&1
done

echo "==================================================="
echo "Virtual box cleanup complete"
echo "==================================================="
