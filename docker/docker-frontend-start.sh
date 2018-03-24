#!/bin/sh
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
