#!/usr/bin/env bash

################################################################################
################################################################################
# Output divider to end of screen
# Usage: divider [delimiter] [color]
# http://stackoverflow.com/questions/24367088/print-a-character-till-end-of-line
################################################################################

function divider {
    reset='\033[00m';
    if [ ${2} ] && [ ${2} != '' ] && [ ${1} ] && [ ${1} != '' ]; then
        div=$(for ((i=0; i<$(tput cols); i++));do printf "${2}${1}${reset}"; done; echo);
    else
        div=$(for ((i=0; i<$(tput cols); i++));do printf "\033[01;31m # ${reset}"; done; echo);
    fi
    echo ${div};
}
divider
################################################################################
################################################################################
#load variables of env file
################################################################################
function loadenv {
    env=${1:-.env}
    echo Loading $env
    file=`mktemp`
    if [ -f $env ]; then
            cat $env | while read line; do
            case $line in
                [a-zA-Z]* )
                    echo export $line >> $file;
                 ;;
                *)
                ;;
                esac
            done
            source $file
    else
            echo No file $env
    fi
    echo Loaded $env
}
loadenv