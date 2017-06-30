#!/bin/sh

#version 1
#2017/03/06

#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#//// Docker start doesnt need any other file now //////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
caches=('storage' 'cache');
for ((i=0; i<${#caches[@]}; i++))
do
    if [ ! -d "${caches[i]}" ]; then
        echo "Making the ${caches[i]} folder."
        mkdir ${caches[i]}
    fi;
    echo "Making the ${caches[i]} folder writable."
    chmod -R 777 ${caches[i]}
    touch ${caches[i]}/.gitignore;
    echo "*.*" > ${caches[i]}/.gitignore;
    echo "!.gitignore" >> ${caches[i]}/.gitignore;
done
if [ -f "c3_error.log" ]; then
    chmod -f 777 c3_error.log
fi;

USER_ID=$(id -u)

# make .env if not already created
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/update_docker_assets_file.sh > update_docker_assets_file.sh;
chmod +x update_docker_assets_file.sh;
sh ./update_docker_assets_file.sh;
chmod +x get_docker_assets.sh;
sh ./get_docker_assets.sh;

# make .env if not already created
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ".env was created from example file"
fi


##############################################################
##############################################################
# Load in Helper file
##############################################################

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
##############################################################
#load the variables!! -->
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

    docker run -d -p 8080:8080 -p 80:80 -p 443:443 --name=frontend  --restart=always -v /var/run/docker.sock:/var/run/docker.sock jenkins.paulbunyan.net:5000/traefik:latest

    docker network create frontend

    docker network connect frontend frontend

fi
##############################################################
##############################################################

echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running docker-compose build "
docker-compose build
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running docker-compose up -d "
docker-compose up -d

echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running Composer"
docker-compose exec -T code composer install
docker-compose exec -T code composer dump-autoload --optimize

if grep -Fxq "post-docker" composer.json; then
    docker-compose exec -T code composer post-docker
fi;
if [ -f "artisan" ]; then
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
  echo "Generating Laravel auth key"
  docker-compose exec -T code php artisan key:generate
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
  echo "Running Eloquent Migrations"
  docker-compose exec -T code php artisan migrate
fi
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running git_log.sh to get current commit hash"
# get git_log.sh file if it doesn't exist
if [ ! -f "git_log.sh" ]; then
    curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/git/git_log.sh > git_log.sh;
    echo "git_log.sh" >> .gitignore
fi
docker-compose exec -T code bash git_log.sh;
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"

echo "Latest commit hash: $(head -n 1 git_log.txt)"
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running Yarn"
docker-compose exec -T code yarn install
if grep -Fxq "postinstall" package.json; then
    docker-compose exec -T code yarn run postinstall
fi;
if [ -f "bower.json" ]; then
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
    echo "Running Bower"
fi;
docker-compose exec -T code bower install--allow-root --force
if [ -f "gulpfile.js" ]; then
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
    echo "Running Gulp"
    docker-compose exec -T code gulp
fi;

if ["$RUN_SCHEDULE"] && [ "$RUN_SCHEDULE" == "true" ] ; then
    docker-compose exec -T code php artisan schedule:run >> /dev/null 2>&1
fi
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
touch c3_error.log
chmod -fR 777 storage
chmod -f 777 c3_error.log
#echo "Running Tests"
#docker-compose exec -T code codecept run -vvv;
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
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
