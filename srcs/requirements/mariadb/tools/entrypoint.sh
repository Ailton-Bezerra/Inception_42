#!/bin/sh
set -e

MYSQL_DIR="/var/lib/mysql"

if [ ! -d "$MYSQL_DIR/mysql" ]; then
    echo ">> Initializing database..."

    mariadb-install-db --user=mysql --datadir="$MYSQL_DIR" > /dev/null 2>&1

    mysqld --user=mysql --bootstrap << EOF
USE mysql;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo ">> Database initialized."
else
    echo ">> Database already initialized."
fi

echo ">> Starting mysqld..."
exec mysqld --user=mysql --console --bind-address=0.0.0.0 --port=3306 --skip-networking=0
