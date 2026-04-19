FROM alpine:3.19

# dependencies
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-openssl \
    php82-curl \
    php82-dom \
    php82-phar \
    php82-iconv \
    php82-mbstring \
    php82-session \
    php82-zip \
    php82-xml \
    php82-gd \
    wget \
    curl \
    tar \
    mariadb-client

# install wp-cli
RUN curl -L -o wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on all interfaces
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/' /etc/php82/php-fpm.d/www.conf

# create wordpress directory
RUN mkdir -p /var/www/wordpress && \
    chmod -R 755 /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
