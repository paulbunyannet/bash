#!/usr/bin/env bash

tools=(vagrant VBoxManage)

# for each tool, make sure it's available to the current user
for i in "${tools[@]}"; do
	command -v ${i} >/dev/null 2>&1 || { echo "${i} not installed, aborting!" >&2; exit 1;}
done

# download codecept.phar for running tests
 if [ ! -f "codecept.phar" ]
    then
        echo "Downloading codecept.phar"
        wget -q -N http://codeception.com/codecept.phar -O codecept.phar
    fi

# make .env if not already created
if [ ! -f ".env" ]
    then
    if [ -f ".env.example" ]
        then
            cp .env.example .env
            echo ".env was created from example file"
        else
            touch .env
            echo ".env was created"
    fi
fi

# load env vars
. "${PWD}/.env"

# make puphpet/config.yaml if not already created
if [ ! -f "puphpet/config.yaml" ]
    then
    cp puphpet/config.yaml.example puphpet/config.yaml
    echo "puphpet/config.yaml was created from example file"
    fi

# make puphpet/config-custom.yaml if not already created
if [ ! -f "puphpet/config-custom.yaml" ]
    then
    cp puphpet/config-custom.yaml.example puphpet/config-custom.yaml
    echo "puphpet/config-custom.yaml was created from example file"
    fi

# do vagrant stuff
vagrant up --provision

# get node dependencies
vagrant ssh -c "cd /var/www; npm install && npm update"

# run gulp for the first time
vagrant ssh -c "cd /var/www; sudo npm install -g gulp;"
vagrant ssh -c "cd /var/www; if [ ! -f 'gulpfile.js' ]; then gulp; fi;"

# get composer to get all dependencies
# http://stackoverflow.com/a/24750310/405758
latestComposerCommitHash=$(git ls-remote https://github.com/composer/getcomposer.org.git | grep HEAD | awk '{ print $1}')
vagrant ssh -c "cd /var/www; command -v composer >/dev/null 2>&1 || { wget https://raw.githubusercontent.com/composer/getcomposer.org/${latestComposerCommitHash}/web/installer -O - -q | php -- --quiet }"
vagrant ssh -c "cd /var/www; php composer.phar install"

# generate new Laravel app key
vagrant ssh -c "cd /var/www; php artisan key:generate;"

# generate new wordpress auth keys
vagrant ssh -c "cd /var/www; php artisan wp:keys --file=.env;"

# run artisan migration
vagrant ssh -c "cd /var/www; php artisan migrate"

# cleanup Wordpress install
if [ -d "public_html/wp/wp-content" ]
then
    rm -rf public_html/wp/wp-content
fi

if [ -f "public_html/wp/wp-config-sample.php" ]
then
    rm -f public_html/wp/wp-config-sample.php
fi

if [ -f "public_html/wp/.htaccess" ]
then
    rm -f public_html/wp/.htaccess
fi

#fin