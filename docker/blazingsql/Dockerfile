FROM rapidsai/rapidsai:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingdb:ubuntu16.04-cuda9.1 is the official BlazingDB environment that uses CUDA 9.1 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN source activate gdf && pip install --upgrade pip

RUN mkdir /tmp/blazing
COPY /home/percy/Blazing/jenkins-workspace/blazingdb-build/___DOCKER_MVP_BUILD/blazingsql-files.tar.gz /tmp/blazing
RUN cd /tmp/blazing && tar xvf blazingsql-files.tar.gz
RUN bash /tmp/blazing/blazingsql-files/setup.sh
RUN rm -rf /tmp/blazing

RUN mkdir /blazingsql

# If the user wants to persist the blazingsql catalog (schema store)
VOLUME /blazingsql

# If the user wants to communicate by unix socket need to mount its /tmp folder
VOLUME /tmp
