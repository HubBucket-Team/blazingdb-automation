FROM blazingdb/blazingsql:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql:conda is the conda build environment for BlazingSQL over CUDA 9.2 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

USER jupyter
WORKDIR /home/jupyter

RUN mkdir -p /home/jupyter/input
RUN mkdir -p /home/jupyter/output

# Prepare the conda build script & files
RUN mkdir -p /home/jupyter/blazingsql-template
RUN mkdir -p /home/jupyter/recipes
COPY generate-blazingsql.sh /home/jupyter/
COPY blazingsql-template /home/jupyter/blazingsql-template
COPY recipes /home/jupyter/recipes

# Fix user permissions
USER root
RUN chown -R jupyter:jupyter /home/jupyter/
RUN chown -R jupyter:jupyter /conda/

USER jupyter
WORKDIR /home/jupyter

VOLUME /home/jupyter/input
VOLUME /home/jupyter/output

CMD ["/bin/bash", "/home/jupyter/generate-blazingsql.sh", "/home/jupyter/input/blazingsql-files.tar.gz", "/home/jupyter/output"]
