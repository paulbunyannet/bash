#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}')
if [ ! -f .env.example ]; then curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/.env.example > .env.example ; fi;
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/Dockerfile > Dockerfile
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/Dockerfile.httpd > Dockerfile.httpd
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/docker-compose.yml > docker-compose.yml
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/docker-start.sh > docker-start.sh
curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/php.ini > php.ini
