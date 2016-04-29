#!/usr/bin/env bash

# Initial setup of items for Jenkens deployment job
# things this script assumes:
# 0. That there is configuration information passed to script from jenkins environment variables (See step 6)
# 1. The tool list of external tools are all accessible by the Jenkins user
# 2. There is a .env or .env.example file in the repo
#   a. There should be a "APP_URL" key in the .env file
#   b. There should be a "APP_BOX_NAME" key in the .env file
#      that matches the name of the box used in vagrant
#   c. There should be a "APP_BOX_ID" key in the .env file
#      that matches the id of the box used in vagrant
# 3. Repo should have some sort of vagrant configuration
# 4. There is a install.sh file that does additional compiling/installing in repository
# 5. there's a build/build.xml that will run phing build tasks with actions "package" and "extract_package"
#   a. The "package" action will collect all the file needed for deployment, running any tests prior to collection
#   b. The "extract_package" extracts to the "build/jenkins-deployment" directory, these files will be deployed if tests pass
# 6. The Jenkins job has environment variables set that will be passed into phing

# --------------------------------------------------
# STEP 0
# Preparation

# if WORKSPACE is missing then use current directory
if [ -z ${WORKSPACE+x} ]; then
    WORKSPACE=${PWD}
fi;

# if ENV is missing then set to jenkins
if [ -z ${ENV+x} ]; then
    ENV="jenkins"
fi;

# make sure all the host config info is passed to the script
if [ -z ${DEPLOYMENT_HTTP_ADDRESS+x} ] || [ -z ${DEPLOYMENT_HOST+x} ] || [ -z ${SSH_USERNAME+x} ] || [ -z ${SSH_PASSWORD+x} ] || [ -z ${SSH_PORT+x} ]; then
    echo "Missing connection configuration for host, aborting." >&2; exit 1;
fi;

# --------------------------------------------------
# STEP 1
# for all tools needed, if any of them are missing fail out of the job
tools=(bash virtualbox VBoxManage vagrant ruby gem phing npm)

# for each tool, make sure it's available to the Jenkins user
for i in "${tools[@]}"; do
	command -v "${i}" >/dev/null 2>&1 || { echo "${i} not installed, aborting!" >&2; exit 1;}
done

# --------------------------------------------------
# STEP 2
# make .env from  .env.example and load env variables
if [ ! -f ".env" ]
    then
        cp .env.example .env
        echo ".env was created from example file"
    fi
# load .env file
. "${WORKSPACE}/.env"

# --------------------------------------------------
# STEP 3
# destroy the box(s)

if [ ! -f "Vagrantfile" ]
    then
        echo "There is no Vagrantfile to spin up the vagrant box, aborting!" >&2; exit 1;
    fi

if [ ! -f "vm_flush.sh" ]; then
    wget https://raw.githubusercontent.com/paulbunyannet/bash/master/vm_flush.sh
fi
. ${WORKSPACE}/vm_flush.sh -h "$(basename ${APP_URL})" -m "$(basename ${APP_BOX_NAME})" -i "${APP_BOX_ID}"
rm -f vm_flush.sh

# --------------------------------------------------
# STEP 4
# run the install script
. ${WORKSPACE}/install.sh

# make sure vagrant is up and running
if [[ "$(vagrant status)" != *"running (virtualbox)"* ]]
    then
        vagrant up
    fi

# --------------------------------------------------
# STEP 5
# go into the build direction and run build tasks
cd ${WORKSPACE}/build
if [ ! -f "build.xml" ]
    then
        echo "There is no build.xml file, aborting!" >&2; exit 1;
    fi;

# --------------------------------------------------
# STEP 6
# this action will create the jenkins.config
# and jenkins.host files needed for the rest
# of the build to run correctly
# Variables from Jenkins:
# DEPLOYMENT_HTTP_ADDRESS: url of the production site
# DEPLOYMENT_HOST: Host used for deployments
# SSH_USERNAME: username of ssh user on host
# SSH_PASSWORD: password of ssh user on host
# SSH_PORT: port for ssh on host

# do packing
phing package -Denv=${ENV} -Durl.deploy=${DEPLOYMENT_HTTP_ADDRESS} -Dftp.host=${DEPLOYMENT_HOST} -Dftp.username=${SSH_USERNAME} -Dftp.password=${SSH_PASSWORD} -Dssh.port=${SSH_PORT}
# extract the package
phing extract_package -Denv=${ENV}

cd ${WORKSPACE}

