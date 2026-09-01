FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/nginx/ssl && \
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/nginx/ssl/yael-maa.key \
    -out /etc/nginx/ssl/yael-maa.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=1337/OU=1337/CN=yael-maa.42.fr"

COPY conf/config.conf /etc/nginx/sites-enabled/default

ENTRYPOINT ["nginx", "-g", "daemon off;"]