#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"

echo ">> waiting for MariaDB..."

until mariadb \
    -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    -e "SELECT 1;" >/dev/null 2>&1; do
    echo ">> waiting for MariaDB..."
    sleep 2
done

echo ">> MariaDB connected successfully!"

echo ">> MariaDB connected successfully!"

if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo ">> downloading WordPress..."
    php -d memory_limit=512M /usr/local/bin/wp core download \
        --path="$WP_PATH" \
        --allow-root
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo ">> creating wp-config.php..."

    wp config create \
        --path="$WP_PATH" \
        --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST"
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root; then
    echo ">> installing WordPress..."

    wp core install \
        --path="$WP_PATH" \
        --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"
fi

chown -R nobody:nobody "$WP_PATH"

echo ">> starting PHP-FPM..."

exec php-fpm83 -F
