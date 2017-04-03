#!/usr/bin/env bash
latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');

# for each of the customizable local files get them from the repo if they are not ignored and don't exist
for fileName in "docker-compose.yml" "Dockerfile" "Dockerfile.httpd" "php.ini" "docker-jenkins-start.sh" "dock.sh"
do
	# if the file is not ignored then get it from the repo is it does not exist
    if grep -Fxq "${fileName}" .gitignore;
    then
        echo "Downloading ${fileName}, it is ignored in this projects .gitignore"
        curl --silent https://raw.githubusercontent.com/paulbunyannet/bash/${latest}/docker/${fileName} > ${fileName};
    else
        echo "${fileName} is part of this project."

    fi;
done
chmod +x dock.sh
chmod +x docker-jenkins-start.sh
