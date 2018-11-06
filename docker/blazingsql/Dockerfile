FROM rapidsai/rapidsai:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jre
RUN apt-get install -y supervisor
RUN apt-get install -y --no-install-recommends bzip2 wget curl nano lsof htop net-tools
RUN apt-get clean

# libgdf dependencies
RUN source activate gdf && conda install conda-build
RUN source activate gdf && pip install --upgrade pip

# blazingdb-protocol dependencies
RUN source activate gdf && pip install flatbuffers

# Pyblazing dependencies
RUN source activate gdf && pip install numba==0.40.1
RUN source activate gdf && pip install pycuda==2018.1.1

# Setup Supervisord
RUN mkdir -p /var/log/supervisor
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord/blazing-calcite.conf /etc/supervisor/conf.d/blazing-calcite.conf
COPY supervisord/blazing-orchestrator.conf /etc/supervisor/conf.d/blazing-orchestrator.conf
COPY supervisord/blazing-ral.conf /etc/supervisor/conf.d/blazing-ral.conf
COPY supervisord/jupyterlab.conf /etc/supervisor/conf.d/jupyterlab.conf
COPY supervisord/run_jupyter.sh /usr/bin/run_jupyter.sh
RUN chmod +x /usr/bin/run_jupyter.sh

# Setup BlazingSQL
RUN mkdir /tmp/blazing/
COPY blazingsql-files.tar.gz /tmp/blazing/
COPY setup.sh /tmp/blazing/
COPY libgdf_cffi/ /tmp/blazing/libgdf_cffi/
RUN bash /tmp/blazing/setup.sh
RUN rm -rf /tmp/blazing

# Setup the Calcite database catalog
RUN mkdir /blazingsql
RUN chown -R jupyter:jupyter /blazingsql/

# Copy the demo files
RUN mkdir -p /blazingdb/data/
RUN mkdir -p /blazingdb/notebooks/
COPY data /blazingdb/data/
COPY notebooks/ /blazingdb/notebooks/

# If the user wants to persist the blazingsql catalog (schema store)
VOLUME /blazingsql

# If the user wants to communicate by unix socket need to mount its /tmp folder
VOLUME /tmp

# Supervisord HTTP port
EXPOSE 9001

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
