FROM ubuntu:16.04

MAINTAINER BlazingDB 

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update 

#JAVA

RUN apt-get install default-jdk -y
RUN apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools

RUN readlink -f /usr/bin/java | sed "s#bin/java##"


#HADOOP
RUN wget https://www-eu.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
RUN tar -xvf hadoop-2.7.7.tar.gz
RUN mv hadoop-2.7.7 /usr/local/hadoop
#RUN sed -i 's|JAVA_HOME' "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/"/g  /usr/local/hadoop/etc/hadoop/hadoop-env.sh



# SPARK
RUN wget https://www-eu.apache.org/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz
RUN tar -xvf spark-2.3.1-bin-hadoop2.7.tgz
RUN mv spark-2.3.1-bin-hadoop2.7 /usr/local/
RUN ln -s /usr/local/spark-2.3.1-bin-hadoop2.7/ /usr/local/spark

ENV SPARK_HOME /usr/local/spark

RUN $SPARK_HOME/sbin/start-master.sh

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/hadoop/lib/native


EXPOSE 8081
EXPOSE 8080

WORKDIR $SPARK_HOME
#CMD ["sbin/start-master.sh", "org.apache.spark.deploy.master.Master"]
#CMD ["sbin/stop-master.sh", "org.apache.spark.deploy.master.Master"]