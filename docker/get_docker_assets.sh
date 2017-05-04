#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');

# for each of the customizable local files get them from the repo if they are not ignored and don't exist
for fileName in "update_docker_assets_file.sh" "dock-helpers.sh" "docker-compose.yml" "Dockerfile" "Dockerfile.httpd" "php-override.ini" "docker-jenkins-start.sh" "dock.sh" "httpd.conf" "server.crt" "server.key"
do
	# if the file isn't part of the current project then get it from the repo
    if [ ! -f ${fileName} ] || ( [ $(grep -c "${fileName}" .gitignore) -ge 1 ] && [ ! $(grep -c "!${fileName}" .gitignore) -ge 1 ] ) ;
    then
        echo "Downloading ${fileName} $(if [ -n ${fileName} ]; then echo "and replacing existing"; fi).";
        curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/${fileName} > ${fileName};
    else
        echo "${fileName} is part of this project."
    fi;
done

chmod a+x dock-helpers.sh
chmod a+x dock.sh
chmod a+x update_docker_assets_file.sh
chmod a+x docker-jenkins-start.sh
sh dock-helpers.sh

if [ -z ${jenkins+x} ]; then jenkins=false; else jenkins=true; fi;
if [ ${jenkins} == "true" ] && [ ${jenkins} == "true" ]; then
    echo $'\nXDEBUG_CONFIG="remote_host=172.17.0.1"\n' >> .env
fi

# Some sites are not ready to make the jump to PHP 7 and require PHP 5.6 instead
if [ -z ${php56+x} ]; then getPhp65=false; else getPhp65=true; fi;
if [ ${getPhp65} == "true" ] && [ ${php56} == "true" ]; then
	echo "Downloading PHP 5.6 version of Dockerfile"
	curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/DockerfilePhp56 > Dockerfile;
fi

