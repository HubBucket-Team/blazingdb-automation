FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql:user is the normal user environment for BlazingSQL over CUDA 9.2 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN apt-get update

# Install Java runtime
RUN apt-get install -y openjdk-8-jre

# Install tools & utils
RUN apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools

# Install blazingdb-io runtime dependencies
RUN apt-get install -y --no-install-recommends libicu55 libcurl3 libssl1.0.0 zlib1g libuuid1

RUN apt-get clean

# Create the container user
RUN useradd -ms /bin/bash theuser

# Create conda dir & download conda from https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
COPY Miniconda3-latest-Linux-x86_64.sh /miniconda.sh
RUN chown theuser:theuser /miniconda.sh
RUN mkdir -p /conda
RUN chown -R theuser:theuser /conda

# Install conda using the container user
USER theuser
WORKDIR /home/theuser

# NOTE -f force installation since /conda dir already exists 
RUN sh /miniconda.sh -f -b -p /conda && /conda/bin/conda update -n base conda
ENV PATH=${PATH}:/conda/bin
# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Build 'user' conda env
ARG PYTHON_VERSION=3.5
RUN conda create -n user python=${PYTHON_VERSION}

ARG NUMBA_VERSION=0.40.0
ARG NUMPY_VERSION=1.14.3
# Locked to Pandas 0.20.3 by https://github.com/rapidsai/cudf/issues/118
ARG PANDAS_VERSION=0.20.3
ARG PYARROW_VERSION=0.10.0

# Create the conda env called 'user' this env simulate the user env
RUN conda install -n user -y -c numba -c conda-forge -c defaults \
      numba=${NUMBA_VERSION} \
      numpy=${NUMPY_VERSION} \
      pandas=${PANDAS_VERSION} \
      pyarrow=${PYARROW_VERSION}

# Fix user permissions
USER root
RUN chown -R theuser:theuser /home/theuser/

# NOTE Always use this container with non-root user
USER theuser
WORKDIR /home/theuser

RUN mkdir -p /home/theuser/data

# NOTE Pre-install the conda dependencies for blazingsql package
RUN source activate user && pip install cython

VOLUME /home/theuser/data
