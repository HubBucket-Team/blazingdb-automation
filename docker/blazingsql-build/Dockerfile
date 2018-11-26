FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql:ubuntu16.04-cuda9.2-devel is the BlazingSQL build environment (for the CI System) that uses CUDA 9.2 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN apt-get update

# Install tools & utils
RUN apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools

# Install common dev tools
RUN apt-get install -y build-essential libssl-dev
RUN apt-get install -y ssh wget curl
RUN apt-get install -y git

# Install BlazingSQL build dependencies
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y maven

RUN apt-get clean

# Install CMake 3.12
RUN wget https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4-Linux-x86_64.sh
RUN bash cmake-3.12.4-Linux-x86_64.sh --skip-license --prefix=/usr

# Create the user 'builder'
RUN useradd -ms /bin/bash builder

# Create blazingsql directory
RUN  mkdir /blazingsql
RUN  chown builder:builder /blazingsql

# Prepare the build script
COPY build.sh /home/builder/
RUN  chmod +x /home/builder/build.sh
RUN  chown builder:builder /home/builder/build.sh

USER builder
WORKDIR /home/builder
RUN mkdir workspace && mkdir output && mkdir .ssh

VOLUME /home/builder/workspace
VOLUME /home/builder/output
VOLUME /home/builder/.ssh

CMD ["/bin/bash", "/home/builder/build.sh"]
