FROM nvidia/cuda:10.0-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

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

# Setup the Calcite database catalog
RUN mkdir /blazingsql
RUN chown -R jupyter:jupyter /blazingsql/

# Create conda dir & download conda from https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
#COPY Miniconda3-latest-Linux-x86_64.sh /miniconda.sh
RUN wget -O /miniconda.sh -nv https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /miniconda.sh
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

# Create the conda env called 'cudf'
# Build 'cudf' conda env
ARG PYTHON_VERSION=3.7
RUN conda create -n cudf python=${PYTHON_VERSION}

ARG NUMBA_VERSION=0.43.0
ARG NUMPY_VERSION=1.16.2
# Locked to Pandas 0.20.3 by https://github.com/rapidsai/cudf/issues/118
ARG PANDAS_VERSION=0.24.2
ARG PYARROW_VERSION=0.12.1

# Install default packages for the user env
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults numba=${NUMBA_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults numpy=${NUMPY_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pandas=${PANDAS_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pyarrow=${PYARROW_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults cmake=3.14
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults gtest=1.8.0

# libgdf dependencies
RUN source activate cudf && pip install --upgrade pip
# TODO percy mario edith uncomment this when we don't need to build nvstrings(custrings)
#RUN conda install -n cudf -y -c numba -c conda-forge -c nvidia -c defaults nvstrings

# blazingdb-protocol dependencies
RUN source activate cudf && pip install flatbuffers

# Pyblazing dependencies
RUN source activate cudf && conda install -c conda-forge jupyterlab
#RUN source activate cudf && pip install numba==0.40.1
#RUN source activate cudf && pip install pycuda==2018.1.1
RUN source activate cudf && pip install cython

# Demo dependencies
RUN source activate cudf && pip install xgboost
RUN source activate cudf && pip install sklearn

#extra dependencies (from cudf 0.7)
RUN source activate cudf && pip install cmake_setuptools

USER root

# Install hdfs stuff
RUN apt-get install -y --no-install-recommends libprotobuf9v5 libgsasl7

# NOTE Fix some numba issues (NvvmSupportError: libNVVM cannot be found)
ENV NUMBAPRO_NVVM /usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda/nvvm/libdevice/

# Setup Supervisord
RUN mkdir -p /var/log/supervisor
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord/blazing-calcite.conf /etc/supervisor/conf.d/blazing-calcite.conf
COPY supervisord/blazing-orchestrator.conf /etc/supervisor/conf.d/blazing-orchestrator.conf
COPY supervisord/blazing-ral.conf /etc/supervisor/conf.d/blazing-ral.conf
COPY supervisord/jupyterlab.conf /etc/supervisor/conf.d/jupyterlab.conf
COPY supervisord/run_jupyter.sh /usr/bin/run_jupyter.sh
RUN mkdir -p /var/log/supervisor/
RUN chown -R jupyter:jupyter /var/log/supervisor/
RUN chmod +x /usr/bin/run_jupyter.sh
RUN chown jupyter:jupyter /usr/bin/run_jupyter.sh

# Copy the demo files
RUN mkdir -p /blazingdb/data/
RUN mkdir -p /blazingdb/notebooks/
COPY data /blazingdb/data/
COPY notebooks/ /blazingdb/notebooks/
RUN chown -R jupyter:jupyter /blazingdb/

# Create the temporal installation directory for the BlazingSQL setup
RUN mkdir -p /tmp/blazing/
COPY blazingsql-files.tar.gz /tmp/blazing/
COPY setup.sh /tmp/blazing/
RUN chown -R jupyter:jupyter /tmp/blazing/

# Install BlazingSQL using the container user
USER jupyter
WORKDIR /home/jupyter

USER root
RUN bash /tmp/blazing/setup.sh
RUN rm -rf /tmp/blazing

# NOTE Expose CUDF runtime
ENV LD_LIBRARY_PATH /conda/envs/cudf/lib/

# If the user wants to persist the blazingsql catalog (schema store)
VOLUME /blazingsql

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL
EXPOSE 8890
EXPOSE 8891
EXPOSE 8892

# Supervisord HTTP port
EXPOSE 9001

# Jupyter
EXPOSE 8884

# haddop
EXPOSE 54310

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
