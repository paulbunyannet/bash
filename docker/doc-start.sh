#!/bin/sh

cd /var/www/html

chmod -R 755 /var/www/html/public_html
chmod -R 755 /var/www/html/storage/framework

php-fpm