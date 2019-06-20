#FROM nvidia/cuda:9.2-runtime-ubuntu16.04
FROM nvidia/cuda:9.2-devel-ubuntu16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64

RUN apt-get update

# UCX
RUN apt-get install -y libnuma1

COPY blazingdb_orchestator_service /usr/bin/

COPY ucx/*.so* /usr/lib/

RUN ln -s /usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/libcuda.so /usr/lib/libcuda.so.1

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL
EXPOSE 8889
#EXPOSE 8890
#EXPOSE 8891
#EXPOSE 8892

CMD ["/usr/bin/blazingdb_orchestator_service"]
