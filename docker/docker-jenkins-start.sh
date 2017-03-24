#!/bin/sh

#version 1
#2017/03/06

#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#//// Docker start doesnt need any other file now //////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

chmod -R 755 public_html
chmod -R 755 storage/framework


# make .env if not already created
 if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ".env was created from example file"
 fi

# cleanup wordpress install
if [ -d "public_html/wp/wp-content" ];then
    rm -rf public_html/wp/wp-content
fi

if [ -f "public_html/wp/wp-config-sample.php" ];then
    rm -f public_html/wp/wp-config-sample.php
fi

if [ -f "public_html/wp/.htaccess" ];then
    rm -f public_html/wp/.htaccess
fi
# this is not need it anymore as I am loading the file directly from jenkins configuration
###############################################################
###############################################################
##load variables of env file
###############################################################
#function loadenv() {
#  env=${WORKSPACE}/.env
#  source "$env";
##  echo Loading $env
##  file=`mktemp -p tmp `
##  if [ -f $env ]; then
##    cat $env | while read line; do
##      echo export $line >> $file
##      echo $line
##    done
##    source $file
##  else
##    echo No file $env
##  fi
#if [ -z ${DB_CONNECTION+x} ]; then
#DB_CONNECTION="mysql"
#else
#echo $DB_CONNECTION
#fi
#if [ -z ${DB_USERNAME+x} ]; then
#DB_USERNAME="wordpress_user"
#else
#echo $DB_USERNAME
#fi
#if [ -z ${DB_PASSWORD+x} ]; then
#DB_PASSWORD="wordpress_password"
#else
#echo $DB_PASSWORD
#fi
#if [ -z ${DB_DATABASE+x} ]; then
#DB_DATABASE="wordpress"
#else
#echo $DB_DATABASE
#fi
#if [ -z ${DB_HOST+x} ]; then
#DB_HOST="db"
#else
#echo $DB_HOST
#fi
#if [ -z ${DB_PREFIX+x} ]; then
#DB_PREFIX="wp_"
#else
#echo $DB_PREFIX
#fi
#if [ -z ${DB_CHARSET+x} ]; then
#DB_CHARSET="utf8"
#else
#echo $DB_CHARSET
#fi
#if [ -z ${IMAGE_NAME+x} ]; then
#IMAGE_NAME="laravelwordpress"
#else
#echo $IMAGE_NAME
#fi
#if [ -z ${SUB_IMAGE_NAME+x} ]; then
#SUB_IMAGE_NAME="laravelwordp"
#else
#echo $SUB_IMAGE_NAME
#fi
#if [ -z ${SERVER_NAME+x} ]; then
#SERVER_NAME="laravelwordpress.localhost"
#else
#echo $SERVER_NAME
#fi
#}
###############################################################
##load the variables!! -->
#loadenv
##variables loaded <--
###############################################################

echo "$REMOVEDEPENDENCIES" == "not"
####################################
CONTAINER=frontend
FRONTENDRUNNING="true"

RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "UNKNOWN - $CONTAINER does not exist."
  FRONTENDRUNNING="false"

elif [ "$RUNNING" == "false" ]; then
  echo "CRITICAL - $CONTAINER is not running."
  FRONTENDRUNNING="false"

fi

if  [ "$FRONTENDRUNNING" == "false" ]; then

    mkdir traefik-temp

    cd traefik-temp

    git clone https://github.com/castillo-n/traefik-image

    cd traefik-image

    sh init.sh

    cd ..

    cd ..

    rm -rf traefik-temp
fi
##############################################################
##############################################################

docker-compose build;

docker-compose up -d;

echo $PWD

echo "Pushing db dump :)"
DUMPFILE="dump.sql"
DUMPFOLDER="/tests/_data/"
DUMPCOMBINE=$DUMPFOLDER$DUMPFILE
FULLDUMPFOLDER=$WORKSPACE$DUMPFOLDER
FULLDUMPFILE=$FULLDUMPFOLDER$DUMPFILE

cd $FULLDUMPFOLDER

echo $PWD
if [ $(find "$DUMPFOLDER" -name "$DUMPFILE") ]; then
echo "I FOUND IT!!!!"
fi
if [ -f "$DUMPCOMBINE" ];then
    echo "got it!"
else
    echo "did not got it!"
    echo ${DUMPCOMBINE}
fi

if [ -f "$FULLDUMPFILE" ];then
    echo "got it! old way"
    echo $PWD
    cd ${WORKSPACE}
    echo $PWD
    echo "Pushing db dump"
    chmod 744 tests/_data/dump.sql
    echo ${cwd}
    docker-compose exec -T db mysql -u "$DB_USERNAME" -p "$DB_PASSWORD" "$DB_DATABASE" < "$directory";
else
    echo "still didnt get the file"
fi
docker-compose exec -T laravel npm cache clean


echo "Running Composer"
docker-compose exec -T laravel composer install >/dev/null 2>&1;
docker-compose exec -T laravel composer dump-autoload --optimize >/dev/null 2>&1;
echo "Running git_log.sh to get current commit hash"
docker-compose exec -T laravel bash git_log.sh;
echo "Latest commit hash: $(head -n 1 git_log.txt)"
echo "Running Yarn"
docker-compose exec -T laravel yarn >/dev/null 2>&1 | true
docker-compose exec -T laravel yarn upgrade >/dev/null 2>&1 | true
docker-compose exec -T laravel yarn run postinstall >/dev/null 2>&1 | true
echo "Running Bower"
docker-compose exec -T laravel bower install >/dev/null 2>&1
echo "Running Gulp"
docker-compose exec -T laravel gulp --production;
#echo "docker will start running tests"
#docker-compose exec -T laravel codecept run
echo "--------------------------------------"
echo "--------------------------------------"
#docker-compose exec -T docker-compose down
#echo "--------------------------------------"
#echo "--------------------------------------"
echo "#####################################################################"
echo "#################/---------------------------------------------------\#################"
echo "################|   Paul Bunyan Communications Rocks!!!   |################"
echo "#################\---------------------------------------------------/#################"
echo "#####################################################################"
echo " ── ── ── ── ── ── ── ── ── ██ ██ ██ ██ ── ██ ██ ██ ── ── ── "
echo " ── ── ── ── ── ── ── ██ ██ ▓▓ ▓▓ ▓▓ ██ ██ ░░ ░░ ░░ ██ ── ── "
echo " ── ── ── ── ── ── ██ ▓▓ ▓▓ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ██ ── ── "
echo " ── ── ── ── ── ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ░░ ░░ ██ ── ── "
echo " ── ── ── ── ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ░░ ██ ── ── "
echo " ── ── ── ── ██ ▓▓ ██ ██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ██ ██ ── ── ── "
echo " ── ── ── ██ ██ ██ ██ ░░ ░░ ░░ ██ ░░ ██ ░░ ██ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ── ██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ░░ ██ ░░ ██ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ██ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ██ ── ── "
echo " ── ── ██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ██ ── ── "
echo " ── ── ── ██ ░░ ░░ ░░ ░░ ██ ██ ██ ██ ░░ ░░ ██ ██ ██ ── ── ── "
echo " ── ── ── ── ██ ██ ░░ ░░ ░░ ░░ ██ ██ ██ ██ ██ ▓▓ ██ ── ── ── "
echo " ── ── ── ── ── ██ ██ ██ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ▓▓ ██ ── ── ── "
echo " ── ── ── ░░ ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ▓▓ ██ ── ── ── ── "
echo " ── ── ── ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ██ ░░ ░░ ░░ ██ ██ ── ── ── ── ── "
echo " ── ── ██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ░░ ░░ ██ ── ── ── ── ── "
echo " ── ── ██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ░░ ░░ ██ ── ── ── ── ── "
echo " ── ── ██ ██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ██ ██ ██ ██ ── ── ── "
echo " ── ── ── ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ── ── ── "
echo " ── ── ── ── ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ── ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ██ ██ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ ── ── "
echo " ── ── ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ── ── ── ██ ▓▓ ▓▓ ██ ██ ── ── "
echo " ── ── ██ ▓▓ ▓▓ ██ ██ ── ── ── ── ── ── ── ██ ██ ██ ── ── ── "
echo " ── ── ── ██ ██ ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── "
echo "#####################################################################"
echo "#################/---------------------------------------------------\#################"
echo "################|   Paul Bunyan Communications Rocks!!!   |################"
echo "#################\---------------------------------------------------/#################"
echo "#####################################################################"
