FROM httpd:alpine

MAINTAINER Garrett
MAINTAINER Nelson

RUN echo "Include conf/extra/httpd.conf" >> /usr/local/apache2/conf/httpd.conf

COPY httpd.conf /usr/local/apache2/conf/extra/httpd.conf

COPY server.crt /var/www/server_certs/

COPY server.key /var/www/server_certs/
