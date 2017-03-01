#!/bin/sh

#version 1.2
#2017/02/27

REMOVEDEPENDENCIES="not";
REDOIMAGES="not";
ONECHECK="false";
TWOCHECKS="false";
VERBOSE="false";
ARG1="false";
ARG2="false";
ARG1="false"
NOT="not";
TRUE="true";
NONE='\033[00m';
BLINK='\033[5m';
BLACK='\033[01;30m';
RED='\033[01;31m';
GREEN='\033[01;32m';
YELLOW='\033[01;33m';
BLUE='\033[01;34m';
PURPLE='\033[01;35m';
CYAN='\033[01;36m';
WHITE='\033[01;37m';
BOLD='\033[1m';
UNDERLINE='\033[4m';

if [ -z $1 ]
then
  ARG1="false"
elif [ -n $1 ]
then
# otherwise make first arg as a rental
  ARG1=$1
fi

if [ -z $2 ]
then
  ARG2="false"
  ONECHECK="true"
elif [ -n $2 ]
then
# otherwise make first arg as a rental
  ARG2=$2
fi

if [ -z $3 ]
then
  ARG3="false"
  TWOCHECKS="true"
elif [ -n $3 ]
then
# otherwise make first arg as a rental
  ARG3=$3
fi
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#//// Docker start doesnt need any other file now //////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

MAINDIRECTORY=$(readlink -m "$PATH");
echo "this is the directory docker will work at : ${MAINDIRECTORY}";
cd "${MAINDIRECTORY}"
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
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

#echo "docker-compose check";
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#/// docker-compose check ///////////////////////////////////////////////////////////////////////////////////
#//////////////////////////////////////////////////////////////////////////////////////////////////////////
#COMPOSE="1";
#command -v docker-compose >/dev/null 2>&1 || COMPOSE="0";
#
#if [ "$COMPOSE" == "0" ]; then
#    curl -L https://github.com/docker/compose/releases/download/1.11.1/run.sh > /usr/local/bin/docker-compose;
#fi
#sudo chmod +x /usr/local/bin/docker-compose;
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

case $ARG1 in
    [-][hH]|[-][-][hH][eE][lL][pP])

    echo "${CYAN}########################################################################################${NONE}";
    echo "${CYAN}##############################${NONE} ${RED}parameters available${NONE} ${CYAN}####################################${NONE}";
    echo "${CYAN}########################################################################################${NONE}";
    echo " ";
    echo "${GREEN}   *${NONE} ${YELLOW}-h or --help${NONE}\n      ${RED} ->${NONE} to show this menu..... \n";
    echo "${GREEN}   *${NONE} ${YELLOW}open or -open or --open${NONE}\n      ${RED} ->${NONE} to do a normal docker-compose exec -T laravel bash..... just if you couldn't remember the command :P \n";
    echo "${GREEN}   *${NONE} ${YELLOW}down or -down or --down${NONE}\n      ${RED} ->${NONE} to do a normal docker-compose down..... just if you couldn't remember the command :P \n";
    echo "${GREEN}   *${NONE} ${YELLOW}-i or --images${NONE}\n      ${RED} ->${NONE} to tell the script that you want to build the images\n";
    echo "${GREEN}   *${NONE} ${YELLOW}-ni or --notimages${NONE}\n      ${RED} ->${NONE} to tell the script that you don't want to build the images\n";
    echo "${GREEN}   *${NONE} ${YELLOW}-d or --dependencies${NONE}\n      ${RED} ->${NONE} to tell the script that you want to install dependencies\n";
    echo "${GREEN}   *${NONE} ${YELLOW}-nd or --notdependencies${NONE}\n      ${RED} ->${NONE} to tell the script that you don't want to install dependencies\n";
    echo "${GREEN}   *${NONE} ${YELLOW}-a or --all${NONE}\n      ${RED} ->${NONE} to tell the script that you want to rebuild the images and to install dependencies\n";
    echo "${GREEN}   *${NONE} ${YELLOW}-n or --none${NONE}\n      ${RED} ->${NONE} to tell the script that you don't want to rebuild the images or to install dependencies\n";
    echo " ";
    echo "########################################################################################";
            exit;
    ;;
    [dD][oO][wW][nN]|[-][dD][oO][wW][nN]|[-][-][dD][oO][wW][nN])
            cd "${MAINDIRECTORY}"
            docker-compose down;
            exit;
    ;;
    [oO][pP][eE][nN]|[-][oO][pP][eE][nN]|[-][-][oO][pP][eE][nN])
            CONT=laravel
            LARAVELRUNNING="true"
            LARAVELRUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)
            if [ $? -eq 1 ]; then
              echo "Warning - $CONT is not running."
              LARAVELRUNNING="false"
            fi
            if  [ "$LARAVELRUNNING" != "false" ]; then
                cd "${MAINDIRECTORY}"
                docker-compose exec laravel bash
                exit;
            else
                REDOIMAGES="false";
                REMOVEDEPENDENCIES="false";
                ONECHECK="true";
            fi

    ;;
    [-][vV]|[-][-][vV][eE][rR][bB][oO][sS][eE])
          VERBOSE="true";
            echo "VERBOSE is true"
          ;;
    [-][iI]|[-][-][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="true";
            echo "REDOIMAGES is true"
    ;;
    [-][nN][iI]|[-][-][nN][oO][tT][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="false";
            echo "REDOIMAGES is false"
    ;;
    [-][dD]|[-][-][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="true";
            echo "REMOVEDEPENDENCIES is true"
    ;;
    [-][nN][dD]|[-][-][nN][oO][tT][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="false";
            echo "REMOVEDEPENDENCIES is false"
    ;;
    [-][aA]|[-][-][aA][lL][lL])
          REMOVEDEPENDENCIES="true";
          REDOIMAGES="true";
          ONECHECK="true";
            echo "REDOIMAGES is true"
            echo "REMOVEDEPENDENCIES is true"
    ;;
    [-][nN]|[-][-][nN][oO][nN][eE])
          REMOVEDEPENDENCIES="false";
          REDOIMAGES="false";
          ONECHECK="true";
            echo "REDOIMAGES is false"
            echo "REMOVEDEPENDENCIES is false"
    ;;
    *)
    ;;
esac
if [ "$ONECHECK" == "false" ]; then
    case $ARG2 in
    [-][vV]|[-][-][vV][eE][rR][bB][oO][sS][eE])
          VERBOSE="true";
            echo "VERBOSE is true"
          ;;
    [-][iI]|[-][-][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="true";
            echo "REDOIMAGES is true"
          ;;
    [-][nN][iI]|[-][-][nN][oO][tT][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="false";
            echo "REDOIMAGES is false"
    ;;
    [-][dD]|[-][-][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="true";
            echo "REMOVEDEPENDENCIES is true"
          ;;
    [-][nN][dD]|[-][-][nN][oO][tT][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="false";
            echo "REMOVEDEPENDENCIES is false"
    ;;
    *)
    ;;
    esac
else
    if [ "$ARG2" != "false" ]; then
        case $ARG2 in
        [-][vV]|[-][-][vV][eE][rR][bB][oO][sS][eE])
              VERBOSE="true";
                echo "VERBOSE is true"
              ;;
        esac
    fi
fi
if [ "$TWOCHECKS" == "false" ]; then
    case $ARG3 in
    [-][vV]|[-][-][vV][eE][rR][bB][oO][sS][eE])
          VERBOSE="true";
            echo "VERBOSE is true"
          ;;
    [-][iI]|[-][-][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="true";
            echo "REDOIMAGES is true"
          ;;
    [-][nN][iI]|[-][-][nN][oO][tT][iI][mM][aA][gG][eE][sS])
          REDOIMAGES="false";
            echo "REDOIMAGES is false"
    ;;
    [-][dD]|[-][-][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="true";
            echo "REMOVEDEPENDENCIES is true"
          ;;
    [-][nN][dD]|[-][-][nN][oO][tT][dD][eE][pP][eE][nN][dD][eE][nN][cC][iI][eE][sS])
          REMOVEDEPENDENCIES="false";
            echo "REMOVEDEPENDENCIES is false"
    ;;
    *)
    ;;
    esac
fi
##############################################################
##############################################################
#load variables of env file
##############################################################
function loadenv() {
cd "${MAINDIRECTORY}"
source ./.env
#  env=${1:-.env}
#  echo Loading $env
#  file=`mktemp -t tmp `
#  if [ -f $env ]; then
#    cat $env | while read line; do
#      echo export $line >> $file
#    done
#    source $file
#  else
#    echo No file $env
#  fi
}

##############################################################
#load the variables!! -->
loadenv
#variables loaded <--
##############################################################
##############################################################


echo "$REMOVEDEPENDENCIES" == "not";
#if  [  "$doc_jenkins" != "true" ]; then
    ##############################################################
    ##############################################################
    #if you have problems loading the docker machine, remove the # symbol from the beginning of the next two lines
    #docker-machine rm default
    #docker-machine create default --driver virtualbox
    CONTAINER=frontend
    FRONTENDRUNNING="true"
    #important this will set the default vb machine so is found every time
    ##set docker default image to default used one
    #eval "$(docker-machine env default)"
    #check if the front end is running. if not run it from scratch
    RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

    if [ $? -eq 1 ]; then
      echo "UNKNOWN - $CONTAINER does not exist."
      FRONTENDRUNNING="false"

    elif [ "$RUNNING" == "false" ]; then
      echo "CRITICAL - $CONTAINER is not running."
      FRONTENDRUNNING="false"

    fi

    if  [ "$FRONTENDRUNNING" == "false" ]; then

        cd "${MAINDIRECTORY}"

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


    ##############################################################
    ##############################################################
    #now added this to the host file if it doesnt exist
    ## this will only work on macs (I havent tested on windows --sorry Garrett)
    ##############################################################
    echo "#################"
    echo "check host"
    echo "#################"
    STARTED=$(docker inspect --format="{{ .State.StartedAt }}" $CONTAINER)
    #NETWORK=$(docker-machine ip default)
    # Fallback to localhost if docker-machine not found or error occurs
    #if [ -z "$NETWORK" ]; then
        NETWORK=127.0.0.1
    #fi

    matches_in_hosts="$(grep -n ${SERVER_NAME} /etc/hosts | cut -f1 -d:)"
    host_entry="${NETWORK} ${SERVER_NAME}"

    if [ "$REDOIMAGES" == "$NOT" ]; then
        echo "${CYAN}#########################################################################"
        echo "#########################################################################"
        echo "#########################################################################"
        echo "Would you like to build the docker images?"
        echo "Intro y and press enter to accept, anything else to skip this option"
        echo "-------------------------------------------------------------------------${RED}"
        read -e -p "##### (y??)>>: " build;
        echo "${NONE} ";
        case $build in
            [yY][eE][sS]|[yY])
              REDOIMAGES="true";;
              *)
              REDOIMAGES="false";;
        esac
    fi
#fi
cd "${MAINDIRECTORY}"
if [ "$REDOIMAGES" == "$TRUE" ]; then

    docker-compose build;
fi

docker-compose up -d;
echo "${RED}##########################################################################################################"
echo "##########################################################################################################"
echo "if you encounter errors, please check that the machines are not running before running this script";
echo "##########################################################################################################"
echo "##########################################################################################################${NONE}"
ImageName="$(docker-compose ps -q laravel)"

if [ "$REMOVEDEPENDENCIES" == "$NOT" ]; then
echo "${CYAN}#########################################################################"
echo "#########################################################################"
echo "Would you like to install dependencies?"
echo "Intro y and press enter to accept, anything else to skip this option"
echo "-------------------------------------------------------------------------${RED}"
read -e -p "##### (y??)>>: " answer;
echo "${NONE} ";
case $answer in
    [yY][eE][sS]|[yY])
      REMOVEDEPENDENCIES="true"
        ;;
        *)
      REMOVEDEPENDENCIES="false"
      ;;
esac
fi

echo "check folder path";
docker-compose exec -T laravel sh -c "cd ~; ls"
docker-compose exec -T laravel sh -c "cd ~; ${PATH}"
docker-compose exec -T laravel sh -c "cd ..; ls"
docker-compose exec -T laravel sh -c "cd ..; ${PATH}"
docker-compose exec -T laravel sh -c "cd /var/www/html; ls"
docker-compose exec -T laravel sh -c "cd /var/www/html; ${PATH}"
docker-compose exec -T laravel sh -c "cd .; ${PATH}"
echo "checked folder path";

if [ "$REMOVEDEPENDENCIES" == "$TRUE" ]; then
    if [ "$doc_jenkins" != "true" ]; then
        echo "${YELLOW}#########################################################################"
        echo "removing dependencies folders";
        echo "#########################################################################"
    #    rm -rf vendor;
    #    rm -rf node_modules;
    #      rm -rf /usr/local/share/.cache/yarn;

        cd "${MAINDIRECTORY}"
        docker-compose exec -T laravel sh -c "cd /var/www/html; rm -rf vendor;"
        docker-compose exec -T laravel sh -c "cd /var/www/html; rm -rf node_modules;"
        docker-compose exec -T laravel sh -c "cd /var/www/html; rm -rf /usr/local/share/.cache;"
        docker-compose exec -T laravel sh -c "cd /var/www/html; rm -rf ~/.npm;"
    fi
    echo "${CYAN}#########################################################################"
    echo "Now installing dependencies";
    echo "#########################################################################"
    echo "Opening laravel --> container ID: $ImageName";
#        docker-compose exec -T laravel npm
#        read -e -p "npm ... press enter" answer;
    echo "#########################################################################${YELLOW}"
    echo "#########################################################################"
    echo " npm cache clean"
    echo "#########################################################################"
    docker-compose exec -T laravel sh -c "cd /var/www/html; npm cache clean"
#        docker-compose exec -T laravel yarn
#        read -e -p "npm clean ... press enter" answer;
    echo "#########################################################################${BLUE}"
    echo "#########################################################################"
    echo "yarn upgrade"
    if [ "$VERBOSE" == "false" ]; then
        docker-compose exec -T laravel sh -c "cd /var/www/html; yarn upgrade --silent"
        docker-compose exec -T laravel sh -c "cd /var/www/html; yarn install --silent"
    else
        docker-compose exec -T laravel sh -c "cd /var/www/html; yarn upgrade"
        docker-compose exec -T laravel sh -c "cd /var/www/html; yarn install"
    fi
    echo "#########################################################################"
#        read -e -p "yarn install ... press enter" answer;
    echo "#########################################################################${RED}"
    echo "#########################################################################"
    echo "npm -g update"
    if [ "$VERBOSE" == "false" ]; then
        docker-compose exec -T laravel sh -c "cd /var/www/html; npm -g update --silent"
    else
        docker-compose exec -T laravel sh -c "cd /var/www/html;  npm -g update"
    fi
#        read -e -p "npm -g update ... press enter" answer;
    echo "#########################################################################${GREEN}"
    echo "#########################################################################"
    echo "bower update --force"
    if [ "$VERBOSE" == "false" ]; then
        docker-compose exec -T laravel sh -c "cd /var/www/html; bower update --force --allow-root --silent"
    else
        docker-compose exec -T laravel sh -c "cd /var/www/html; bower update --force --allow-root --quiet"
    fi
#        docker-compose exec -T laravel bower
#        read -e -p "npm -g install ... press enter" answer;
    echo "#########################################################################${PURPLE}"
    echo "#########################################################################"
if [ "$doc_jenkins" != "true" ]; then
    echo "composer update"
    if [ "$VERBOSE" == "false" ]; then
        docker-compose exec -T laravel sh -c "cd /var/www/html; composer update --quiet"
    else
        docker-compose exec -T laravel sh -c "cd /var/www/html; composer update"
    fi
fi
    echo "#########################################################################${CYAN}"
    echo "#########################################################################"
    echo "php artisan key:generate"
    docker-compose exec -T laravel sh -c "cd /var/www/html; php artisan key:generate"
    echo "#########################################################################${NONE}"
fi

    echo "${CYAN}#########################################################################"
    echo "Opening laravel --> container ID: $ImageName ${NONE}" ;
    echo "#########################################################################"
    echo "php artisan migrate"
    docker-compose exec -T laravel php artisan migrate
    echo "#########################################################################"
    echo "gulp"
    docker-compose exec -T laravel gulp
    echo "#########################################################################"
    echo "${YELLOW}Going into command line (type ${RED}exit ${YELLOW}and press enter to leave the container)${NONE}";

if [ "$doc_jenkins" != "true" ]; then
    docker-compose exec -T laravel bash
fi
    echo "#########################################################################"
    echo "#################/-------------------------------------\#################"
    echo "################|  Paul Bunyan Communications Rocks!!!  |################"
    echo "#################\-------------------------------------/#################"
    echo "#########################################################################"
    echo "── ── ── ── ── ── ── ██ ██ ██ ██ ── ██ ██ ██ ── "
    echo "── ── ── ── ── ██ ██ ▓▓ ▓▓ ▓▓ ██ ██ ░░ ░░ ░░ ██ "
    echo "── ── ── ── ██ ▓▓ ▓▓ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ██ "
    echo "── ── ── ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ░░ ░░ ██ "
    echo "── ── ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ░░ ██ "
    echo "── ── ██ ▓▓ ██ ██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ██ ██ ── "
    echo "── ██ ██ ██ ██ ░░ ░░ ░░ ██ ░░ ██ ░░ ██ ▓▓ ▓▓ ██ "
    echo "── ██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ░░ ██ ░░ ██ ▓▓ ▓▓ ██ "
    echo "██ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ██ "
    echo "██ ░░ ░░ ░░ ░░ ░░ ░░ ██ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ██ "
    echo "── ██ ░░ ░░ ░░ ░░ ██ ██ ██ ██ ░░ ░░ ██ ██ ██ ── "
    echo "── ── ██ ██ ░░ ░░ ░░ ░░ ██ ██ ██ ██ ██ ▓▓ ██ ── "
    echo "── ── ── ██ ██ ██ ░░ ░░ ░░ ░░ ░░ ██ ▓▓ ▓▓ ██ ── "
    echo "── ░░ ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ▓▓ ██ ── ── "
    echo "── ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ██ ░░ ░░ ░░ ██ ██ ── ── ── "
    echo "██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ░░ ░░ ██ ── ── ── "
    echo "██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ░░ ░░ ██ ── ── ── "
    echo "██ ██ ██ ▓▓ ▓▓ ▓▓ ▓▓ ██ ░░ ░░ ░░ ██ ██ ██ ██ ── "
    echo "── ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ── "
    echo "── ── ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ██ "
    echo "── ██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ "
    echo "██ ██ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ "
    echo "██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ██ ██ ██ ██ ▓▓ ▓▓ ▓▓ ██ "
    echo "██ ▓▓ ▓▓ ██ ██ ██ ██ ██ ── ── ── ██ ▓▓ ▓▓ ██ ██ "
    echo "██ ▓▓ ▓▓ ██ ██ ── ── ── ── ── ── ── ██ ██ ██ ── "
    echo "── ██ ██ ── ── ── ── ── ── ── ── ── ── ── ── ── "
    echo "#########################################################################"
    echo "#################/-------------------------------------\#################"
    echo "################|  Paul Bunyan Communications Rocks!!!  |################"
    echo "#################\-------------------------------------/#################"
    echo "#########################################################################"
