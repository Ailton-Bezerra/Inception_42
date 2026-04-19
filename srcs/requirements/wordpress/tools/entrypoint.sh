#!/bin/sh
set -e

WP_PATH="/var/www/wordpress"

echo ">> waiting for MariaDB to be ready..."
while ! mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" --silent -e "SELECT 1;" >/dev/null 2>&1; do
    echo ">> waiting for MariaDB... ($MYSQL_HOST)"
    sleep 2
done
echo ">> MariaDB connected successfully!"

if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo ">> WordPress not found, starting download..."
    wp core download --path="$WP_PATH" --allow-root
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
    echo ">> installing WordPress for the first time..."
    wp core install \
        --path="$WP_PATH" \
        --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"
fi

echo ">> WordPress ready, initializing PHP-FPM..."
exec php-fpm82 -F
