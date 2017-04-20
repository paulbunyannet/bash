FROM php:7-fpm

MAINTAINER Garrett
MAINTAINER Nelson

#Download NodeJS
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

#Download Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
#Update and Install Dependencies
RUN apt-get update && apt-get install -y zip unzip curl mysql-client git nodejs yarn libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev zlib1g-dev libicu-dev g++ git curl

#Install mysqli, mcrypt, pdo_mysql, php-intl, php-zip
RUN docker-php-ext-install -j$(nproc) mysqli mcrypt pdo_mysql zip

#install xdebug
RUN pecl install xdebug \
    && rm -rf /tmp/pear \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)\n" >> /usr/local/etc/php/conf.d/xdebug.ini \
        && docker-php-ext-enable xdebug \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# Get GD ready to install
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/bin --filename=composer && php -r "unlink('composer-setup.php');"

#Install Codeception
RUN curl -O http://codeception.com/codecept.phar && chmod +x codecept.phar && mv codecept.phar /usr/local/bin/codecept

#Install gulp bower and grunt
RUN yarn global add --no-bin-links gulp-cli gulp bower grunt-cli

# Disable composer warnings
ENV COMPOSER_ALLOW_SUPERUSER 1

#Install Prestissimo
RUN composer global require "hirak/prestissimo:^0.3"

COPY php-override.ini /usr/local/etc/php/conf.d/php-override.ini