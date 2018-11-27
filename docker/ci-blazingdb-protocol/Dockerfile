FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/build:ubuntu16.04-cuda9.2 is the BlazingDB build environment (for the CI System) that uses CUDA 8.0 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN apt-get update && \
  apt-get install -y openjdk-8-jdk ssh maven wget curl git && \
  apt-get clean && \
  useradd -ms /bin/bash builder && \
  rm -rf /var/cache/* /tmp/* && \
  mkdir /blazingsql /home/builder/workspace /home/builder/output /home/builder/.ssh /home/builder/.m2 && \
  chown builder:builder /blazingsql && \
  chown builder:builder -R /home/builder/

USER builder
WORKDIR /home/builder/workspace

VOLUME /home/builder/workspace
VOLUME /home/builder/output
VOLUME /home/builder/.ssh
VOLUME /home/builder/.m2