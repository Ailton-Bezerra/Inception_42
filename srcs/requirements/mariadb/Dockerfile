FROM alpine:3.19

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld && \
    chmod 777 /run/mysqld && \
    mkdir -p /var/lib/mysql

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld", "--bind-address=0.0.0.0"]
