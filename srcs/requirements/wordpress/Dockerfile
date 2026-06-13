FROM alpine:3.22

RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-openssl \
    php83-curl \
    php83-dom \
    php83-phar \
    php83-iconv \
    php83-mbstring \
    php83-session \
    php83-zip \
    php83-xml \
    php83-gd \
    curl \
    wget \
    tar \
    mariadb-client

RUN curl -L -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

RUN sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' \
    /etc/php83/php-fpm.d/www.conf

RUN mkdir -p /var/www/wordpress /run/php && \
    chown -R nobody:nobody /var/www/wordpress

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
