FROM kindest/node:v1.20.15

RUN apt update && apt install -y python3

COPY ./files/helm /usr/local/bin/