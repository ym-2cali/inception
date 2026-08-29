FROM alpine:3.24

RUN apk update 

RUN echo "apk update\n"

RUN apk add nginx

RUN echo "installing nginx\n"

COPY inception.conf /etc/nginx/nginx.conf

RUN echo "copyin nginx config\n"

RUN mkdir -p /etc/nginx/ssl

RUN echo "ssl directory created\n"

COPY ssl/inception.crt /etc/nginx/ssl

RUN echo "copying .crt\n"

COPY ssl/inception.key /etc/nginx/ssl

RUN echo "nginx is running\n"

CMD ["nginx", "-g",  "daemon off;"]
