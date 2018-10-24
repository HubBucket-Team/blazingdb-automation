FROM blazingdb/devel:ubuntu16.04-cuda9.2

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/build:ubuntu16.04-cuda9.2 is the BlazingDB build environment (for the CI System) that uses CUDA 8.0 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

# Create the user 'builder'
RUN useradd -ms /bin/bash builder

USER builder
WORKDIR /home/builder

RUN mkdir src
RUN mkdir output

USER root
COPY build.sh /home/builder/
RUN chown builder:builder /home/builder/build.sh

USER builder
WORKDIR /home/builder

VOLUME /home/builder/src
VOLUME /home/builder/output

ENTRYPOINT bash /home/builder/build.sh
