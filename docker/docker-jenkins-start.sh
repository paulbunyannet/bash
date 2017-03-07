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

##############################################################
##############################################################
#load variables of env file
##############################################################
source ./.env


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
directory = /var/www/html/database/dump/wordpress.sql
if [ -d $directory ]
    docker-compose exec -T mysql -u "$DB_USERNAME" -p "$DB_PASSWORD" "$DB_DATABASE" < "$directory";
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
echo "docker will start running tests"
docker-compose exec -T laravel codecept run
echo "--------------------------------------"
echo "--------------------------------------"
docker-compose exec -T docker-compose down
echo "--------------------------------------"
echo "--------------------------------------"
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
