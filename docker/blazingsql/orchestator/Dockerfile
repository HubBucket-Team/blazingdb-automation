FROM ubuntu:16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

COPY blazingdb_orchestator_service /usr/bin/

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL
EXPOSE 8890
#EXPOSE 8891
#EXPOSE 8892

CMD ["/usr/bin/blazingdb_orchestator_service"]
