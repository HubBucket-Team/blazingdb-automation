FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql:conda is the conda build environment for BlazingSQL over CUDA 9.2 on Ubuntu 16.04." Vendor="BlazingDB" Version="1.0"

RUN apt-get update

# Install Java runtime
RUN apt-get install -y openjdk-8-jre

# Install supervisord
RUN apt-get install -y supervisor

# Install tools & utils
RUN apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools

# Install blazingdb-io runtime dependencies
RUN apt-get install -y --no-install-recommends libicu55 libcurl3 libssl1.0.0 zlib1g libuuid1

RUN apt-get clean

# Create the container user
RUN useradd -ms /bin/bash jupyter

# Create conda dir & download conda from https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
#COPY Miniconda3-latest-Linux-x86_64.sh /miniconda.sh
RUN wget -O /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN chown jupyter:jupyter /miniconda.sh
RUN mkdir -p /conda
RUN chown -R jupyter:jupyter /conda

# Install conda using the container user
USER jupyter
WORKDIR /home/jupyter

# NOTE -f force installation since /conda dir already exists 
RUN sh /miniconda.sh -f -b -p /conda && /conda/bin/conda update -n base conda
ENV PATH=${PATH}:/conda/bin
# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Create the conda env called 'user' this env simulate the user env
# Build 'user' conda env
ARG PYTHON_VERSION=3.5
RUN conda create -n user python=${PYTHON_VERSION}

ARG NUMBA_VERSION=0.40.0
ARG NUMPY_VERSION=1.14.3
# Locked to Pandas 0.20.3 by https://github.com/rapidsai/cudf/issues/118
ARG PANDAS_VERSION=0.20.3
ARG PYARROW_VERSION=0.10.0

# Install default packages for the user env
RUN conda install -n user -y -c numba -c conda-forge -c defaults numba=${NUMBA_VERSION}
RUN conda install -n user -y -c numba -c conda-forge -c defaults numpy=${NUMPY_VERSION}
RUN conda install -n user -y -c numba -c conda-forge -c defaults pandas=${PANDAS_VERSION}
RUN conda install -n user -y -c numba -c conda-forge -c defaults pyarrow=${PYARROW_VERSION}

USER root

# NOTE Fix some numba issues (NvvmSupportError: libNVVM cannot be found)
ENV NUMBAPRO_NVVM /usr/local/cuda-9.2/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda-9.2/nvvm/libdevice/

# NOTE Expose 'user' runtime
ENV LD_LIBRARY_PATH /conda/envs/user/lib/

USER jupyter
WORKDIR /home/jupyter

# Install conda tools
RUN source activate user && conda install anaconda-client
RUN source activate user && conda install conda-build
RUN source activate user && conda install conda-verify

# NOTE Pre-install the conda dependencies for blazingsql package
RUN source activate user && conda install -c rapidsai/label/cuda9.2 cudf
RUN source activate user && conda install -c conda-forge flatbuffers 

# NOTE Pre-install the conda dependencies for cudf package
RUN source activate user && pip install cython

RUN mkdir -p /home/jupyter/input
RUN mkdir -p /home/jupyter/output

# Prepare the conda build script & files
RUN mkdir -p /home/jupyter/blazingsql-template
RUN mkdir -p /home/jupyter/recipes
COPY blazingsql-template /home/jupyter/blazingsql-template/
COPY recipes /home/jupyter/recipes/
COPY generate-blazingsql.sh /home/jupyter/

# Fix user permissions
USER root
RUN chown -R jupyter:jupyter /home/jupyter/

# NOTE Always use this container with non-root user
USER jupyter
WORKDIR /home/jupyter

VOLUME /home/jupyter/input
VOLUME /home/jupyter/output

#CMD ["/bin/bash", "/home/jupyter/generate-blazingsql.sh", "/home/jupyter/input/blazingsql-files.tar.gz", "/home/jupyter/output"]
