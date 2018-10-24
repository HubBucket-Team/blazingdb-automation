FROM rapidsai/rapidsai:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingdb:ubuntu16.04-cuda9.1 is the official BlazingDB environment that uses CUDA 9.1 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jre

RUN source activate gdf && pip install --upgrade pip
RUN source activate gdf && conda install -c gpuopenanalytics/label/cuda9.2 libgdf_cffi
RUN source activate gdf && conda install conda-build

RUN mkdir /tmp/blazing/
COPY blazingsql-files.tar.gz /tmp/blazing/
COPY setup.sh /tmp/blazing/
COPY libgdf_cffi/ /tmp/blazing/libgdf_cffi/
RUN bash /tmp/blazing/setup.sh
RUN rm -rf /tmp/blazing

RUN mkdir /blazingsql
COPY bz3.trace.db /blazingsql
COPY bz3.mv.db /blazingsql

# If the user wants to persist the blazingsql catalog (schema store)
VOLUME /blazingsql

# If the user wants to communicate by unix socket need to mount its /tmp folder
VOLUME /tmp
