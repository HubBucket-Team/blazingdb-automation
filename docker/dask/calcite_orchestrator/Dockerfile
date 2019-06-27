FROM nvidia/cuda:9.2-runtime-ubuntu16.04
#FROM nvidia/cuda:9.2-devel-ubuntu16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64

RUN apt-get update

# UCX
RUN apt-get install -y libnuma1

COPY blazingdb_orchestator_service /usr/bin/
#COPY ucx/*.so* /usr/lib/

RUN ln -s /usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/libcuda.so /usr/lib/libcuda.so.1

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

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

# Dask
RUN apt-get install -y software-properties-common && \
   add-apt-repository -y ppa:deadsnakes/ppa && \
   apt-get update && \
   apt-get install -y python3.7 python3.7-dev python3-pip && \
   python3.7 -m pip install "dask[complete]" && python3.7 -m pip install bokeh

# Supervisor
RUN apt-get install -y supervisor
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord/blazing-calcite.conf /etc/supervisor/conf.d/
COPY supervisord/blazing-orchestrator.conf /etc/supervisor/conf.d/
COPY supervisord/dask-scheduler.conf /etc/supervisor/conf.d/



#CMD ["/usr/bin/blazingdb_orchestator_service"]
#CMD ["java", "-jar", "/usr/bin/BlazingCalcite.jar"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
