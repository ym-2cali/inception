#!/bin/sh

mariadbd --user=mysql &

until mariadb-admin ping --silent; do sleep 1; done

mariadb -u root < /etc/cr_us.sql

mariadb-admin -u root shutdown

exec mariadbd --user=mysql
