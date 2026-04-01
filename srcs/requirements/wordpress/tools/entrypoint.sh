#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"

# -----------------------------------------------
# 1. Aguardar MariaDB subir
# -----------------------------------------------
echo ">> Aguardando o MariaDB ficar acessível..."
while ! mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --silent; do
    sleep 1
done
echo ">> MariaDB conectado com sucesso!"

# -----------------------------------------------
# 2. Fazer download do WordPress apenas se vazio
# -----------------------------------------------
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo ">> WordPress não encontrado, iniciando download..."
    wp core download --path="$WP_PATH" --allow-root
fi

# -----------------------------------------------
# 3. Criar wp-config.php se não existir
# -----------------------------------------------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo ">> Criando wp-config.php..."
    wp config create \
        --path="$WP_PATH" \
        --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST"
fi

# -----------------------------------------------
# 4. Instalar WordPress apenas se ainda não instalado
# -----------------------------------------------
if ! wp core is-installed --path="$WP_PATH" --allow-root; then
    echo ">> Instalando WordPress pela primeira vez..."
    wp core install \
        --path="$WP_PATH" \
        --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"

    # Criar usuário comum opcional
    if [ -n "$WP_USER" ]; then
        echo ">> Criando usuário adicional '$WP_USER'..."
        wp user create "$WP_USER" "$WP_USER_EMAIL" \
            --role=author \
            --user_pass="$WP_USER_PASSWORD" \
            --allow-root \
            --path="$WP_PATH"
    fi
fi

echo ">> WordPress pronto! Iniciando PHP-FPM..."
exec "$@"
