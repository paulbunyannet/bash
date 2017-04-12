#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');

# for each of the customizable local files get them from the repo if they are not ignored and don't exist
for fileName in "docker-compose.yml" "Dockerfile" "Dockerfile.httpd" "php.ini" "docker-jenkins-start.sh" "dock.sh" "httpd.conf"
do
	# if the file isn't part of the current project then get it from the repo
    if [ ! -n ${fileName} ] || ( [ $(grep -c "${fileName}" .gitignore) -ge 1 ] && [ ! $(grep -c "!${fileName}" .gitignore) -ge 1 ] ) ;
    then
        echo "Downloading ${fileName} $(if [ -n ${fileName} ]; then echo "and replacing existing"; fi).";
        curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/${fileName} > ${fileName};
    else
        echo "${fileName} is part of this project."
    fi;
done
chmod +x dock.sh
chmod +x docker-jenkins-start.sh
