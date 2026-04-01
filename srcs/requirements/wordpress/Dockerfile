# base image
FROM alpine:3.19

# install packages
RUN apk update && apk add --no-cache \
    php php-fpm php-mysqli php-json php-openssl php-dom \
    php-phar php-iconv php-mbstring php-session php-zip php-xml \
    php-gd wget curl tar maria-client

# build and istall wordpress
RUN wget https://wordpress.org/latest.tar.gz && \