#!/usr/bin/env bash

# Start duplicate run check
toProjectRoot=$(pwd);
NL="\n"
me=`basename "$0"`
logFile="${me}.log"
touch ${logFile}
if ( [ $(grep -c "${toProjectRoot}" ${logFile}) -ge 1 ])
then
    printf "The ${me} already ran in this location \`${toProjectRoot}\`!${NL}"
    printf "Clear the line \`${toProjectRoot}\` in ${me}.log to run it again.${NL}"
    exit 0
fi;
echo ${toProjectRoot} >> ${logFile}
# End duplicate run check

latest=$(git ls-remote https://github.com/paulbunyannet/bash.git | grep HEAD | awk '{ print $1}');

# for each of the customizable local files get them from the repo if they are not ignored and don't exist
for fileName in "update_docker_assets_file.sh" "dock-helpers.sh" "docker-compose.yml" "docker-jenkins-start.sh" "dock.sh" "stacks.sh" "lighthouse.sh"
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

# get getUid.php and run to update the .env.
# This file should be ignored so add a line the the
# .gitignore if it's not already ignored
echo "Downloading https://gitlab.paulbunyan.net/snippets/1/raw, Get the current user's ID and update environment file"
getUidFile="getUid.php"
curl --silent https://gitlab.paulbunyan.net/snippets/1/raw > ${getUidFile};
if ! grep -q "${getUidFile}" .gitignore; then
    echo -e "\n${getUidFile}" >> .gitignore
fi
php ${getUidFile}

# if jenkins is not set/is null then set to false otherwise set to true?
if [ -z ${jenkins+x} ]; then jenkins=false; else jenkins=true; fi;
# if jenkins is true and there's no line for XDEBUG_CONFIG in the .env
if [[ "${jenkins}" == "true" || "${jenkins}" = true ]] && ! grep -q XDEBUG_CONFIG ./.env; then
    echo "\nXDEBUG_CONFIG=\"remote_host=172.17.0.1\"" >> ./.env
fi

chmod a+x dock-helpers.sh
chmod a+x dock.sh
chmod a+x update_docker_assets_file.sh
chmod a+x docker-jenkins-start.sh
sh dock-helpers.sh
