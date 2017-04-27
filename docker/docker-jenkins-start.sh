#!/bin/sh

#version 1
#2017/03/06

#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#//// Docker start doesnt need any other file now //////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
echo "chmoding storage 777"
chmod -fR 777 storage
chmod -f 777 c3_error.log


latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/get_docker_assets.sh > get_docker_assets.sh;
sh get_docker_assets.sh;

# make .env if not already created
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
if [ -d "public_html/wp/wp-content" ];then
    rm -rf public_html/wp/wp-content
fi

if [ -f "public_html/wp/wp-config-sample.php" ];then
    rm -f public_html/wp/wp-config-sample.php
fi

if [ -f "public_html/wp/.htaccess" ];then
    rm -f public_html/wp/.htaccess
fi
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

echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running docker-compose build "
docker-compose build --quiet
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running docker-compose up -d "
docker-compose up -d --quiet

echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running docker-compose exec -T code npm cache clean"
docker-compose exec -T code npm cache clean

echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running Composer"
docker-compose exec -T code composer install --quiet
docker-compose exec -T code composer update --quiet
docker-compose exec -T code composer dump-autoload --optimize --quiet
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Generating Key"
docker-compose exec -T code php artisan key:generate
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running Migrations"
docker-compose exec -T code php artisan migrate
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running git_log.sh to get current commit hash"
docker-compose exec -T code bash git_log.sh;
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Latest commit hash: $(head -n 1 git_log.txt)"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running Yarn"
docker-compose exec -T code yarn --silent
docker-compose exec -T code yarn upgrade --silent
docker-compose exec -T code yarn run postinstall --silent
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running Bower"
docker-compose exec -T code bower install --silent
docker-compose exec -T code bower update --force  --allow-root --silent
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "Running Gulp"

docker-compose exec -T code gulp production --silent
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
touch c3_error.log
chmod -fR 777 storage
chmod -f 777 c3_error.log
#echo "Running Tests"
#docker-compose exec -T code codecept run -vvv;
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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
