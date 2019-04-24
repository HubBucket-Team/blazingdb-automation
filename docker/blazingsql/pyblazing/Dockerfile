FROM nvidia/cuda:9.2-devel-ubuntu16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update && \
    apt-get install -y sudo bzip2 wget curl nano vim-tiny lsof htop net-tools && \
    apt-get install -y libicu55 libcurl3 libssl1.0.0 zlib1g libuuid1 && \
    apt-get clean

# Create the container user
RUN useradd -ms /bin/bash jupyter

# Create conda dir & download conda from https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN wget -O /miniconda.sh -nv --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
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
ARG PYTHON_VERSION=3.6
RUN conda create -n cudf python=${PYTHON_VERSION}

ARG NUMBA_VERSION=0.40.0
ARG NUMPY_VERSION=1.14.3
# Locked to Pandas 0.20.3 by https://github.com/rapidsai/cudf/issues/118
ARG PANDAS_VERSION=0.20.3
ARG PYARROW_VERSION=0.10.0

# Install default packages for the user env
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults numba=${NUMBA_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults numpy=${NUMPY_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pandas=${PANDAS_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults pyarrow=${PYARROW_VERSION}
RUN conda install -n cudf -y -c numba -c conda-forge -c defaults cmake=3.12
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

USER root

# Install hdfs stuff
RUN apt-get install -y --no-install-recommends libprotobuf9v5 libgsasl7

# NOTE Fix some numba issues (NvvmSupportError: libNVVM cannot be found)
ENV NUMBAPRO_NVVM /usr/local/cuda-9.2/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda-9.2/nvvm/libdevice/

# Setup Jupyter
COPY run_jupyter.sh /usr/bin/run_jupyter.sh
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

# Jupyter
EXPOSE 80

CMD ["/usr/bin/run_jupyter.sh"]
