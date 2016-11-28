#!/usr/bin/env bash
# ----------------------------------
# encrypt-files.sh
# Encrypt files that for storage in repository. This would be for files that need to be decrypted for a CI job for instance
# usage `$ bash encrypt-files.sh -w current/workspace/folder -p passwordThatWasUsedToEncryptFilesOriginally`

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -p|--pass)
    password="$1"
    shift
    ;;
esac
case $key in
    -w|--workspace)
    ws="$1"
    shift
    ;;
esac
done

if [ -z ${ws+x} ]; then ws=${PWD}; fi
echo "Workspace is '$ws'"

# check for enc-files file, if missing show message and exit
if [ ! -f "enc-files" ];
    then
        echo "enc-files file is missing, see enc-files-example to example of how the file should be formatted"
        exit 1
fi;

source ${ws}/enc-files

for ((i=0; i<${#prefix[@]}; i++))
do
    echo "Encrypting: ${ws}/${prefix[i]}${suffix[i]}, ${desc[i]}"
    openssl enc -aes-256-cbc -salt -in ${ws}/${prefix[i]}${suffix[i]} -out ${ws}/${prefix[i]}.enc.temp -pass pass:${password}
    if [ -f ${ws}/${prefix[i]}.enc ]
    then
        mv ${ws}/${prefix[i]}.enc.temp ${ws}/${prefix[i]}.enc
        continue
    fi

    if [[ $(stat -c%s ${ws}/${prefix[i]}.enc.temp) -ge $(stat -c%s ${ws}/${prefix[i]}${suffix[i]}) ]];
    then
        echo "Old file ${ws}/${prefix[i]}${suffix[i]} does not match the file size of the new file so it will be replaced."
        mv ${ws}/${prefix[i]}.enc.temp ${ws}/${prefix[i]}.enc
    fi
    if [ -f ${ws}/${prefix[i]}.enc.temp ]
    then
        rm ${ws}/${prefix[i]}.enc.temp
    fi
done