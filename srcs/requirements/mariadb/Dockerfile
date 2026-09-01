FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/script.sh /script.sh
RUN chmod 755 /script.sh

ENTRYPOINT ["/script.sh"]
CMD ["mysqld_safe"]