FROM nvidia/cuda:9.2-devel-ubuntu16.04

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update

# Install supervisord
RUN apt-get install -y supervisor

# Install tools & utils
RUN apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools
RUN apt-get install -y unzip

# Install blazingdb-io runtime dependencies
RUN apt-get install -y --no-install-recommends libicu55 libcurl3 libssl1.0.0 zlib1g libuuid1

# UCX
RUN apt-get install -y libnuma-dev

RUN apt-get clean

# Create the container user
RUN useradd -ms /bin/bash jupyter

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
# Locked to Pandas 0.20.3 by https://github.com/rapidsai/cudf/issues/118
ARG PANDAS_VERSION=0.24.2
ARG PYARROW_VERSION=0.12.1

# Install default packages for the user env
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults numba=${NUMBA_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pandas=${PANDAS_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pyarrow=${PYARROW_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults cmake=3.14

# Dask
RUN conda install -n cudf -y dask
RUN source activate cudf && pip install bokeh
RUN conda install -n cudf -y -c nvidia -c rapidsai-nightly dask-cudf

# Conda Nightly
RUN conda install -n cudf -y -c rapidsai-nightly/label/cuda9.2 rmm=0.9.0a1
RUN conda install -n cudf -y -c rapidsai-nightly/label/cuda9.2 nvstrings=0.9.0a
RUN conda install -n cudf -y -c rapidsai-nightly/label/cuda9.2 cudf=0.9

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

# Dask
RUN source activate cudf && pip install "dask[complete]"

USER root

RUN ln -s /usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/libcuda.so /usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/libcuda.so.1

# Install hdfs stuff
RUN apt-get install -y --no-install-recommends libprotobuf9v5 libgsasl7

# NOTE Fix some numba issues (NvvmSupportError: libNVVM cannot be found)
ENV NUMBAPRO_NVVM /usr/local/cuda-9.2/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda-9.2/nvvm/libdevice/

# Setup Supervisord
RUN mkdir -p /var/log/supervisor
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor/
RUN chown -R jupyter:jupyter /var/log/supervisor/

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
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:/conda/envs/cudf/lib/:/usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# Jupyter
EXPOSE 80

# Supervisord (HTTP port)
EXPOSE 9901

# haddop
#EXPOSE 54310

# Orchestrator (Protocol)
EXPOSE 8889

# Orchestrator (Communication)
EXPOSE 9000

# RAL 1 (Protocol)
EXPOSE 8891

# RAL 1 (Communication)
EXPOSE 9001

# RAL 2 (Protocol)
EXPOSE 8892

# RAL 2 (Communication)
EXPOSE 9002

# RAL 3 (Protocol)
EXPOSE 8893

# RAL 3 (Communication)
EXPOSE 9003

# RAL 4 (Protocol)
EXPOSE 8894

# RAL 4 (Communication)
EXPOSE 9004


# UCX
RUN apt-get install -y libnuma1
#COPY ucx/*.so* /usr/lib/

COPY blazingdb_orchestator_service /usr/bin/

#RUN ln -s /usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/libcuda.so /usr/lib/libcuda.so.1

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL
EXPOSE 8889
#EXPOSE 8890
#EXPOSE 8891
#EXPOSE 8892

# Calcite
RUN apt-get update && apt-get install -y openjdk-8-jre

COPY BlazingCalcite.jar /usr/bin/

RUN mkdir /blazingsql
VOLUME /blazingsql
EXPOSE 8890

# Supervisor
COPY supervisord/run_scheduler.sh /usr/bin/run_scheduler.sh
COPY supervisord/blazing-calcite.conf /etc/supervisor/conf.d/
COPY supervisord/blazing-orchestrator.conf /etc/supervisor/conf.d/
COPY supervisord/dask-scheduler.conf /etc/supervisor/conf.d/

COPY supervisord/run_jupyter.sh /usr/bin/run_jupyter.sh
COPY supervisord/jupyterlab.conf /etc/supervisor/conf.d/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
