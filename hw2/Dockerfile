FROM ubuntu:18.04

RUN apt update && apt upgrade -y

RUN apt install build-essential flex bison libbison-dev cmake -y && \
    apt clean -y && \
    apt autoclean -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY . /src

WORKDIR /src