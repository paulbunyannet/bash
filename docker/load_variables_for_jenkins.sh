#!/bin/sh

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ".env was created from example file"
fi

echo $'\nXDEBUG_CONFIG="remote_host=172.17.0.1"\n' >> .env
# cleanup wordpress install

##############################################################
##############################################################
#load variables of env file
##############################################################
function loadenv() {
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

##############################################################
#load the variables!! -->
loadenv