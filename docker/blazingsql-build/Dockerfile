FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/build:ubuntu16.04-cuda9.2 is the BlazingDB build environment (for the CI System) that uses CUDA 8.0 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

# Install BlazingSQL build dependencies
RUN apt-get update
RUN apt-get install build-essential libssl-dev -y
RUN apt-get install libboost-all-dev -y
RUN apt-get install -y openjdk-8-jdk
RUN apt-get -yqq install ssh
RUN apt-get install -y maven
RUN apt-get install -y wget
RUN apt-get install curl -y
RUN apt-get install git -y
RUN apt-get clean

RUN wget -O- https://cmake.org/files/v3.11/cmake-3.11.4-Linux-x86_64.tar.gz | tar zxf - -C /etc 
ENV PATH $PATH:/etc/cmake-3.11.4-Linux-x86_64/bin

# Create the user 'builder'
RUN useradd -ms /bin/bash builder

USER builder
WORKDIR /home/builder

RUN mkdir src
RUN mkdir output

USER root
COPY build.sh /home/builder/
RUN  chown builder:builder /home/builder/build.sh
RUN  chmod +x /home/builder/build.sh

USER builder
WORKDIR /home/builder


RUN mkdir -p /home/builder/.ssh

VOLUME /home/builder/src
VOLUME /home/builder/output
VOLUME /home/builder/.ssh

ENTRYPOINT bash /home/builder/build.sh
