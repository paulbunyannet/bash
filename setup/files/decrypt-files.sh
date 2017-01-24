#!/usr/bin/env bash
# ----------------------------------
# decrypt-files.sh
# Decrypt files that were encrypted with the encrypt-files.sh bash script originally
# usage `$ bash decrypt-files.sh -w current/workspace/folder -p passwordThatWasUsedToEncryptFilesOriginally`

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
    if [ -f "${ws}/${prefix[i]}.enc" ];
        then
            echo "Decrypting: ${ws}/${prefix[i]}.enc, ${desc[i]}"
            openssl enc -aes-256-cbc -d -in ${ws}/${prefix[i]}.enc -out ${ws}/${prefix[i]}${suffix[i]} -pass pass:${password}
        else
            echo "File ${ws}/${prefix[i]}.enc is missing, skipping decrypting of file"
    fi;
done
