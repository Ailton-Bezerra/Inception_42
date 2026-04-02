FROM alpine:3.19

# dependencies
RUN apk update && apk add --no-cache \
    php \
    php-fpm \
    php-mysqli \
    php-json \
    php-openssl \
    php-curl \
    php-dom \
    php-phar \
    php-iconv \
    php-mbstring \
    php-session \
    php-zip \
    php-xml \
    php-gd \
    wget \
    curl \
    tar \
    mariadb-client

# install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# creat worpress directory
RUN mkdir -p /var/www/wordpress && \
    chmod -R 755 /var/www/wordpress && \
    chown -R nobody:nobody /var/www/wordpress

# 
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm", "-F"]
