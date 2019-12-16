FROM alpine:3.10

RUN apk add --update curl php php-fpm php-mysqli php-json php-openssl php-curl \
    php-zlib php-xml php-phar php-intl php-dom php-xmlreader php-ctype php-session \
    php-mbstring php-gd nginx supervisor

# Create www-data user
RUN adduser -S www-data -u 1000

# Create directory structure.
RUN mkdir -p /srv/www/vhosts/demoapp/

# Copy current code base.
COPY --chown=www-data . /srv/www/vhosts/demoapp/

# Change work directory
WORKDIR /srv/www/vhosts/demoapp/

# copy nginx.conf file.
COPY ./nginx.conf /etc/nginx/nginx.conf

# copy php-fpm file.
COPY ./fpm.conf /etc/php7/php-fpm.d/www.conf

# Configure supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Configure vhost
COPY ./testvhost.conf /etc/nginx/conf.d/testvhost.conf

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
EXPOSE 80

# Start nginx and php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Check the health to validate everything is up & running.
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
