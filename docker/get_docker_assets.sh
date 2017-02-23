#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}')
if [ ! -f .env.example ]; then curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/.env.example > .env.example ; fi;
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/Dockerfile > Dockerfile
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/Dockerfile.httpd > Dockerfile.httpd
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/docker-compose.yml > docker-compose.yml
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/docker-start.sh > docker-start.sh
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/doc-install.sh > doc-install.sh
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/php.ini > php.ini
curl https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/doc-start.sh > doc-start.sh