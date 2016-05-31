#!/usr/bin/env bash
set +x
if [ -z ${WORKSPACE+x} ]; then WORKSPACE=${PWD}; fi;
divider="\n==========================================\n"

bowerPath=$1
if [[ -z "$bowerPath" ]]; then echo -e $divider" Path to the bower.json file is\n required as the first parameter".$divider && exit 1; fi;
modulesDir="bower_components"
modulesPath="${WORKSPACE}/${modulesDir}"
archivePath="${WORKSPACE}/bower_cache.tar"
installMsg=$divider" Attempting to do an bower install!"$divider
updateMsg=$divider" Attempting to do an bower update!"$divider
list="bower.json"

#get bower.json and install Bower packages if the last time it was ran is different from the current

wget -q -N ${bowerPath} -O ${list} -P ${WORKSPACE} >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e $divider" Could not get the ${list} from\n ${bowerPath}."$divider;
    exit 1;
fi;
if [ ! -f ${WORKSPACE}/${list}.archive ]
	then
        echo -e "${divider} No archived ${list} file found${divider}"
        if [ -d ${modulesPath} ]
            then
                rm -rf ${modulesPath}
        fi

        if [ -f ${archivePath} ]
            then
                echo -e ${updateMsg}
                tar -C "${WORKSPACE}" -xf "${archivePath}"
                rm -f "${archivePath}"
                bower update
        else
            #install bower
            bower install
        fi
# if the archive file exists and the .tar file exists then extract and do an update
elif [ -f "${WORKSPACE}/${list}.archive" ] && [ -f "${archivePath}" ]
	then
        echo -e ${updateMsg}
        tar -C "${WORKSPACE}" -xf "${archivePath}"
        rm -f "${archivePath}"
        bower update
# if all else fails just to a install
else
    echo -e ${installMsg}
    bower install

fi;

if [ -f "${archivePath}" ]; then rm -f "${archivePath}"; fi;
if [ -d "${WORKSPACE}/${modulesDir}" ]; then tar -C "${WORKSPACE}" -cf "${archivePath}" "${modulesDir}"; rm -rf "${modulesPath}"; fi;
if [ -d "${WORKSPACE}/public_html/${modulesDir}" ]; then tar -C "${WORKSPACE}" -cf "${archivePath}" "public_html/${modulesDir}"; rm -rf "${WORKSPACE}/public_html/${modulesDir}"; fi;
test "$(ls -A "${WORKSPACE}/public_html" 2>/dev/null)" || rm -rf "${WORKSPACE}/public_html"
#cleanup
if [ -f "${WORKSPACE}/${list}.archive" ]; then rm "${WORKSPACE}/${list}.archive"; fi;
mv "${WORKSPACE}/${list}" "${WORKSPACE}/${list}.archive"