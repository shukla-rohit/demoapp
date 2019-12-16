FROM alpine:3.10

RUN apk add --update curl php php-fpm php-mysqli php-json php-openssl php-curl \
    php-zlib php-xml php-phar php-intl php-dom php-xmlreader php-ctype php-session \
    php-mbstring php-gd nginx supervisor

# Create www-data user
RUN adduser -S www-data -u 1000

# Create directory structure.
RUN mkdir -p /srv/www/vhosts/Xento/

# Copy current code base.
COPY --chown=www-data . /srv/www/vhosts/Xento/

# Create directory structure for XentoCoreConfig
RUN mkdir -p /srv/www/vhosts/XentoCoreConfig

# Copy XentoCoreConfig
COPY --chown=www-data ./XentoCoreConfig/ /srv/www/vhosts/XentoCoreConfig/

# Copy test environment test.xento.lcl.php file
COPY --chown=www-data ./XentoCoreConfig/test.xento.lcl.php /srv/www/vhosts/XentoCoreConfig/test.xento.lcl.php

# Create Interface directoy
RUN mkdir -p /srv/www/vhosts/Interfaces/Website

# Change work directory
WORKDIR /srv/www/vhosts/Xento/

# Install dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev

# copy nginx.conf file.
COPY ./XentoCoreConfig/nginx.conf /etc/nginx/nginx.conf

# copy php-fpm file.
COPY ./XentoCoreConfig/fpm.conf /etc/php7/php-fpm.d/www.conf

# Configure supervisord
COPY ./XentoCoreConfig/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Configure vhost
COPY ./XentoCoreConfig/testvhost.conf /etc/nginx/conf.d/testvhost.conf
COPY ./XentoCoreConfig/devvhost.conf /etc/nginx/conf.d/devvhost.conf

# Change owner to www-data 
RUN chown -R www-data:www-data /srv/

# Change the owner for the process
RUN chown -R www-data:www-data /run && \
    chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /var/tmp/nginx && \
    chown -R www-data:www-data /var/log/nginx

# Switch user 
USER www-data

# Expose the port to reach to nginx
# EXPOSE 8080

# Start nginx and php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Check the health to validate everything is up & running.
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
