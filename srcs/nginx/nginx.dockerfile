FROM alpine:3.24

RUN apk update 

RUN echo "apk update\n"

RUN apk add nginx

RUN echo "installing nginx\n"

COPY nginx.conf /etc/nginx/nginx.conf

RUN echo "copyin nginx config\n"

RUN apk add openssl

RUN openssl req -x509 -new -newkey rsa:2048 -keyout /etc/cert.key -noenc -days 365  -out /etc/cert.crt  -subj "/C=MA/CN=1337.ma"


CMD ["nginx", "-g",  "daemon off;"]
