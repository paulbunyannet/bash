#!/usr/bin/env bash
set +x
if [ -z ${WORKSPACE+x} ]; then WORKSPACE=${PWD}; fi;
divider="\n==========================================\n"
packagePath=$1
if [[ -z "$packagePath" ]]; then echo -e $divider" Path to the package.json file is\n required as the first parameter."$divider && exit 1; fi;
modulesDir="node_modules"
modulesPath="${WORKSPACE}/${modulesDir}"
archivePath="${WORKSPACE}/npm_cache.tar"
list="package.json"
installMsg=$divider" Attempting to do an npm install!"$divider
updateMsg=$divider" Attempting to do an npm update!"$divider

# get package.json and install NPM packages
wget -q -N ${packagePath} -O ${list} -P ${WORKSPACE} >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e $divider" Could not get the ${list} from\n ${packagePath}."$divider;
    exit 1;
fi;

# if there is no archive build it now
if [ ! -f "${WORKSPACE}/${list}.archive" ]
    then
        echo -e "${divider} No archived ${list} file found${divider}"
        if [ -d "${modulesPath}" ]
            then
                rm -rf "${modulesPath}"
        fi
        if [ -f "${archivePath}" ]
            then
                echo -e ${updateMsg}
                tar -C "${WORKSPACE}" -xf "${archivePath}"
                rm -f "${archivePath}"
                npm update
        else
			#install all node modules
            echo -e ${installMsg}
            npm install
        fi

# if the archive file exists and the .tar file exists then extract and do an update
elif [ -f "${WORKSPACE}/${list}.archive" ] && [ -f "${archivePath}" ]
	then
        echo -e ${updateMsg}
        tar -C "${WORKSPACE}" -xf "${archivePath}"
        rm -f "${archivePath}"
        npm update
# if all else fails just to a install
else
    echo -e ${installMsg}
    npm install

fi;

# remove the old archive and save
if [ -f "${archivePath}" ]; then rm -f "${archivePath}"; fi;
tar -C "${WORKSPACE}" -cf "${archivePath}" "${modulesDir}"
rm -rf "${modulesPath}"

#save the archive list for later
if [ -f "${WORKSPACE}/${list}.archive" ]; then rm "${WORKSPACE}/${list}.archive"; fi;
mv "${WORKSPACE}/${list}" "${WORKSPACE}/${list}.archive"