FROM alpine:3.19

RUN apk update && apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl /run/nginx

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
