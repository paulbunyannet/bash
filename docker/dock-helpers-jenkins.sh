#!/bin/sh



################################################################################
################################################################################
# Output divider to end of screen
# Usage: divider [delimiter] [color]
# http://stackoverflow.com/questions/24367088/print-a-character-till-end-of-line
################################################################################
function divider {
    reset='\033[00m';
    div=$(for ((i=0; i<$(tput cols); i++));do printf "${2}${1}${reset}"; done; echo);
    echo ${div};
}
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