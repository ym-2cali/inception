#!/bin/bash

unset MYSQL_HOST

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

mariadbd --user=mysql --skip-networking --skip-grant-tables &
pid="$!"

while ! mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent 2>/dev/null; do
    sleep 1
done

mariadb --socket=/run/mysqld/mysqld.sock -u root <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

kill "$pid"
wait "$pid" 2>/dev/null

exec "$@"