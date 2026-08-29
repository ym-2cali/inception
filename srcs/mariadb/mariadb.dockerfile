FROM alpine:3.24

RUN apk update && apk add mariadb mariadb-client

RUN mariadb-install-db --user=mysql --datadir=/var/lib/mysql

RUN mkdir -p /run/mysqld

RUN chown mysql:mysql /run/mysqld

COPY my.cnf /etc/my.cnf

COPY my.cnf.d   etc/my.cnf.d

COPY cr_us.sql /etc

COPY run_db.sh /etc 

RUN chmod +x /etc/run_db.sh

EXPOSE 3306

CMD ["/etc/run_db.sh"]
