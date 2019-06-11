FROM ubuntu:16.04
MAINTAINER BlazingDB <percy@blazingdb.com>
LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update && apt-get install -y openjdk-8-jre && apt-get clean

COPY BlazingCalcite.jar /usr/bin/

#COPY blazingsql-files.tar.gz /tmp/
RUN mkdir /blazingsql
#RUN mkdir /blazingsql && \
#    tar -C /tmp/ -xvf /tmp/blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar && \
#    mv /tmp/blazingsql-files/BlazingCalcite.jar /usr/bin/BlazingCalcite.jar &&\
#    mv /tmp/blazingsql-files/BlazingCalcite.jar /usr/bin/BlazingCalcite.jar &&\
#    rm -rf /tmp/blazingsql-files.tar.gz

# If the user wants to persist the blazingsql catalog (schema store)
VOLUME /blazingsql

# If the user wants to communicate by unix socket need to mount his /tmp folder
VOLUME /tmp

# 8890 for Orchestrator, 8891 for Calcite, 8892 for RAL

EXPOSE 8890
#EXPOSE 8891
#EXPOSE 8892

CMD ["java", "-jar", "/usr/bin/BlazingCalcite.jar"]
