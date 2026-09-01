FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    mariadb-client \
    php \
    php-fpm \
    php-mysql \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

COPY tools/wordpress.sh /tmp/wordpress.sh
RUN chmod 755 /tmp/wordpress.sh

ENTRYPOINT ["/tmp/wordpress.sh"]
CMD ["php-fpm8.2", "-F"]