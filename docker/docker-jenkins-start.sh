#!/bin/sh


# Verbosity check
VERBOSE=false
# help CHECK
HELP=false

# new line
NL="\n"

#colors
NONE='\033[00m';
CYAN='\033[01;36m';
RED='\033[01;31m';
GREEN='\033[01;32m';
YELLOW='\033[01;33m';

# Get the command options
# http://stackoverflow.com/a/14203146/405758
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--verbose)
    VERBOSE=true
    shift # past argument
    #shift # past value
    ;;
    -h|--help)
    HELP=true
    shift # past argument
    #shift # past value
    ;;
esac
done

if [ "$HELP" = true ]; then
  printf "${NONE} ${RED} parameters available${NONE}${NL}"
  printf "${GREEN}   *${NONE} ${YELLOW}-h or --help${NONE}${NL}      ${RED} ->${NONE} to show this menu..... ${NL}"
  printf "${GREEN}   *${NONE} ${YELLOW}-v or --verbose ${NONE}${NL}      ${RED} ->${NONE} run scripts in verbose mode${NL}"
  exit
fi;

#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#//// Docker start doesnt need any other file now //////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

caches=('storage' 'cache')

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
RUN_SCHEDULE="false"
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
DOCKER_VERBOSE=" "
if [ "$VERBOSE" = true ]; then
    DOCKER_VERBOSE=" --verbose "
fi;
echo "Running docker-compose${DOCKER_VERBOSE}build"
eval "docker-compose${DOCKER_VERBOSE}build"

echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running docker-compose${DOCKER_VERBOSE}up -d "
eval "docker-compose${DOCKER_VERBOSE}up -d"

if [ -f "codeception_jenkins.yml" ]; then
    if [ -f "codeception.yml" ]; then
        rm -f codeception.yml
    fi;
    mv codeception_jenkins.yml codeception.yml
fi;

echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running Composer"

eval "docker-compose${DOCKER_VERBOSE}exec -T code chmod -fR 777 /var/www/.composer/cache/"
eval "docker-compose${DOCKER_VERBOSE}exec -T code rm -rf vendor"
eval "docker-compose${DOCKER_VERBOSE}exec -T code composer clearcache"

COMPOSER_QUIET=" "
if [ "$VERBOSE" = false ]; then
    COMPOSER_QUIET=" --no-progress --no-suggest"
fi;
eval "docker-compose${DOCKER_VERBOSE}exec -T code composer install${COMPOSER_QUIET}-o"

eval "docker-compose${DOCKER_VERBOSE}exec -T code composer dump-autoload --optimize"

if grep -Fxq "post-docker" composer.json; then
    eval "docker-compose${DOCKER_VERBOSE}exec -T code composer post-docker"
fi;
if [ -f "artisan" ]; then
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
  echo "Generating Laravel auth key"
  eval "docker-compose${DOCKER_VERBOSE}exec -T code php artisan key:generate"
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
  echo "Running Eloquent Migrations"
  eval "docker-compose${DOCKER_VERBOSE}exec -T code php artisan migrate"
fi
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "Running git_log.sh to get current commit hash"
# get git_log.sh file if it doesn't exist
if [ ! -f "git_log.sh" ]; then
    curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/git/git_log.sh > git_log.sh;
    echo "git_log.sh" >> .gitignore
fi
eval "docker-compose${DOCKER_VERBOSE}exec -T code bash git_log.sh"
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
BOWEREXEC='true'
GULPEXEC='true'
GRUNTEXEC='true'
echo "Latest commit hash: $(head -n 1 git_log.txt)"
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"

if [ -f "yarn.lock" ]; then
    echo "------------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------------"
    echo "Running Yarn"
    eval "docker-compose${DOCKER_VERBOSE}exec -T code yarn install"
    if grep -Fxq "postinstall" package.json; then
        eval "docker-compose${DOCKER_VERBOSE}exec -T code yarn run postinstall"
    fi;

    if [ -f "bower.json" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Yarn run bower"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code yarn run bower"
        BOWEREXEC='false'
    fi;

    if [ -f "gulpfile.js" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Yarn run gulp production"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code yarn run gulp production"
        GULPEXEC='false'
    fi;

    if [ -f "Gruntfile.js" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Yarn run grunt production"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code yarn run grunt production"
        GRUNTEXEC='false'
    fi;
fi;
if [ -f "Gemfile" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Gems"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code apt-get install ruby-full -y"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code gem install bundler"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code bundler install"
fi;

if [ -f "bower.json" ]; then
    if [ "$BOWEREXEC" == "true" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Bower"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code bower install --allow-root --force"
    fi;
fi;

if [ -f "gulpfile.js" ]; then
    if [ "$GULPEXEC" == "true" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Gulp"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code gulp production"
    fi;
fi;

if [ -f "Gruntfile.js" ]; then
    if [ "$GRUNTEXEC" == "true" ]; then
        echo "------------------------------------------------------------------------------------"
        echo "------------------------------------------------------------------------------------"
        echo "Running Grunt"
        eval "docker-compose${DOCKER_VERBOSE}exec -T code grunt production"
    fi;
fi;

if [ -f "artisan" ] && ["$RUN_SCHEDULE"] && [ "$RUN_SCHEDULE" == "true" ] ; then
    eval "docker-compose${DOCKER_VERBOSE}exec -T code php artisan schedule:run >> /dev/null 2>&1"
fi
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
touch c3_error.log
chmod -fR 777 storage
chmod -fR 777 tests
chmod -f 777 c3_error.log
#echo "Running Tests"
#docker-compose exec -T code codecept run -vvv;
echo "------------------------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------"
echo "#####################################################################"
echo "#################/---------------------------------------------------\#################"
echo "################|    Paul Bunyan Communications Rocks!!    |################"
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
echo "################|    Paul Bunyan Communications Rocks!!    |################"
echo "#################\---------------------------------------------------/#################"
echo "#####################################################################"
