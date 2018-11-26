FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/build:ubuntu16.04-cuda9.2 is the BlazingDB build environment (for the CI System) that uses CUDA 8.0 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

# Install BlazingSQL build dependencies
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get -yqq install ssh
RUN apt-get install -y maven
RUN apt-get install -y wget
RUN apt-get install curl -y
RUN apt-get install git -y
RUN apt-get clean

# Create the user 'builder'
RUN useradd -ms /bin/bash builder

USER builder
WORKDIR /home/builder
RUN mkdir workspace && mkdir output && mkdir .ssh

VOLUME /home/builder/src
VOLUME /home/builder/output
VOLUME /home/builder/.ssh