ARG  CUDA_VERSION=9.2
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu16.04
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

ENV PYTHON="python3.7"
ENV PIP="${PYTHON} -m pip"

COPY ./requirements.txt /tmp/requirements.txt

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -qq -y --no-install-recommends \
    ${PYTHON} python3-pip python3-setuptools \
    ${PYTHON}-dev libffi-dev libprotobuf9v5 libgsasl7 libgsasl7-dev \
    bzip2 wget curl lsof \
    libcurl3 libssl1.0.0 zlib1g libuuid1 \
    supervisor openjdk-8-jre && \
    apt-get clean && \
    $PIP install --upgrade --force-reinstall setuptools && \
    $PIP install --upgrade pip && \
    ${PIP} install wheel==0.32.1 && \
    ${PIP} install -r /tmp/requirements.txt && \
    wget -q https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4-Linux-x86_64.sh && \
    bash cmake-3.12.4-Linux-x86_64.sh --skip-license --prefix=/usr && \
    rm -f cmake-3.12.4-Linux-x86_64.sh && \
    useradd -ms /bin/bash jupyter && \
    mkdir -p /blazingsql/ /blazingdb/data/ /blazingdb/notebooks/ /var/log/supervisor /tmp/blazing/ && \
    chown -R jupyter:jupyter /blazingsql/ /blazingdb/ /var/log/supervisor/

# Install conda using the container user
#USER jupyter
#WORKDIR /home/jupyter

#USER root

# NOTE Fix some numba issues (NvvmSupportError: libNVVM cannot be found)
ENV NUMBAPRO_NVVM /usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE /usr/local/cuda/nvvm/libdevice/

# Setup Supervisord
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf

COPY supervisord/blazing-calcite.conf /etc/supervisor/conf.d/blazing-calcite.conf
COPY supervisord/blazing-orchestrator.conf /etc/supervisor/conf.d/blazing-orchestrator.conf
COPY supervisord/blazing-ral.conf /etc/supervisor/conf.d/blazing-ral.conf

COPY supervisord/jupyterlab.conf /etc/supervisor/conf.d/jupyterlab.conf
COPY supervisord/run_jupyter.sh /usr/bin/run_jupyter.sh

# Copy the demo files
COPY data /blazingdb/data/
COPY notebooks /blazingdb/notebooks/
#RUN chown -R jupyter:jupyter /blazingdb/

# Create the temporal installation directory for the BlazingSQL setup
ADD ./blazingsql-files.tar.gz /tmp/blazing/
COPY setup.sh /tmp/blazing/

# Install BlazingSQL using the container user
#USER jupyter
#WORKDIR /blazingdb

#USER root
RUN bash /tmp/blazing/setup.sh && \
    rm -rf /tmp/blazing*

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
#EXPOSE 8888
EXPOSE 80

# haddop
#EXPOSE 54310

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
