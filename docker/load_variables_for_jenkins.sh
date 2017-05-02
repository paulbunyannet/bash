#!/bin/sh
##############################################################
##############################################################
# Load in Helper file
##############################################################
. dock-helpers.sh

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ".env was created from example file"
fi

echo $'\nXDEBUG_CONFIG="remote_host=172.17.0.1"\n' >> .env
# cleanup wordpress install

##############################################################
#load the variables!! -->
loadenv