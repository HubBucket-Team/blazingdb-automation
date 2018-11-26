FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/build:ubuntu16.04-cuda9.2 is the BlazingDB build environment (for the CI System) that uses CUDA 8.0 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"
LABEL Version="1.0"

RUN apt-get update && \
  apt-get install -y build-essential libssl-dev \
    libboost-all-dev ssh wget curl git && \
  apt-get clean && \
  wget -O- https://cmake.org/files/v3.11/cmake-3.11.4-Linux-x86_64.tar.gz | tar zxf - -C /etc && \
  useradd -ms /bin/bash builder && \
  rm -rf /var/cache/* /tmp/* && \
  mkdir /blazingsql /home/builder/workspace /home/builder/output /home/builder/.ssh && \
  chown builder:builder /blazingsql && \
  chown builder:builder -R /home/builder/
ENV PATH $PATH:/etc/cmake-3.11.4-Linux-x86_64/bin

USER builder
WORKDIR /home/builder/workspace

VOLUME /home/builder/workspace
VOLUME /home/builder/output
VOLUME /home/builder/.ssh
