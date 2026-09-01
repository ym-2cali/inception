#!/bin/bash

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

while ! mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for MariaDB to be available..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
    wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost="$MYSQL_HOST" --allow-root
    wp core install --url="$WP_URL" --title="$SITE_TITLE" --admin_user="$WP_ADMIN" --admin_email="$WP_ADMIN_EMAIL" --admin_password="$WP_ADMIN_PASS" --skip-email --allow-root
    wp user create "$WP_AUTHOR" "$WP_AUTHOR_EMAIL" --role=author --user_pass="$WP_AUTHOR_PASS" --allow-root
fi

chown -R www-data:www-data /var/www/html

exec "$@"