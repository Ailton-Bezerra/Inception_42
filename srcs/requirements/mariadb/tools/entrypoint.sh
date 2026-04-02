#!/bin/sh
set -e

MYSQL_DIR="/var/lib/mysql"

# init only in first run
if [ ! -d "$MYSQL_DIR/mysql" ]; then
    echo "[INFO] Inicializando banco de dados..."

    mysql_install_db --user=mysql --datadir="$MYSQL_DIR" > /dev/null

    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "[INFO] Banco configurado."
else
    echo "[INFO] Banco já existe. Pulando inicialização."
fi

echo "[INFO] Iniciando mysqld..."
exec mysqld --user=mysql --console