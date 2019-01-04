FROM ubuntu:16.04

MAINTAINER BlazingDB 

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update 

#JAVA
RUN apt-get install default-jdk -y && \
  apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools &&\
  apt-get clean

#HADOOP
RUN wget -O /tmp/hadoop.tar.gz https://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz &&\
  tar -xvf /tmp/hadoop.tar.gz -C /usr/local/ &&\
  ln -s /usr/local/hadoop-2.7.7/ /usr/local/hadoop &&\
  sed -i "s/\${JAVA_HOME}/\/usr\/lib\/jvm\/java-8-openjdk-amd64\/jre/g" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# SPARK
RUN wget -O /tmp/spark.tar.gz https://www-eu.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz &&\
  tar -xvf /tmp/spark.tar.gz -C /usr/local/ &&\
  ln -s /usr/local/spark-2.3.1-bin-hadoop2.7/ /usr/local/spark

COPY entrypoint_master.sh /etc/entrypoint_master.sh
COPY entrypoint_slave.sh /etc/entrypoint_slave.sh

ENV SPARK_HOME=/usr/local/spark
ENV PATH=${PATH}:/usr/local/spark/bin/:/usr/local/hadoop/bin/
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/hadoop/lib/native

# XGBOOST
RUN apt-get install -y python3-pip
RUN pip3 install -U xgboost

EXPOSE 8081
EXPOSE 8080

WORKDIR $SPARK_HOME
#CMD ["sbin/start-master.sh", "org.apache.spark.deploy.master.Master"]
#CMD ["sbin/stop-master.sh", "org.apache.spark.deploy.master.Master"]
