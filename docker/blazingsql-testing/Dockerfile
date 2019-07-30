FROM blazingdb/blazingsql:latest

USER root

#ARG USER=default_value
#ENV USER=$USER

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y git netcat
RUN apt-get clean
RUN apt-get install -y mysql-client 

RUN source activate cudf && pip install pydrill
RUN source activate cudf && pip install openpyxl
RUN source activate cudf && pip install pymysql
RUN source activate cudf && pip install gitpython
RUN source activate cudf && pip install pynvml

# Create the user 'tester'
#RUN useradd -ms /bin/bash $USER
ENV TMP_USER=tester
ENV TMP_UID=1001
ENV TMP_GID=1001
RUN groupadd -g $TMP_GID $TMP_USER
RUN useradd -ms /bin/bash $TMP_USER -u $TMP_UID -g $TMP_GID

RUN wget -O /tmp/apache_drill.tar.gz -nv http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz && \
    tar -xvzf /tmp/apache_drill.tar.gz -C /etc/
RUN DRILL_JAVA_OPTS_VAR='export DRILL_JAVA_OPTS="-Duser.timezone=UTC" ' && \
    echo $DRILL_JAVA_OPTS_VAR >> /etc/apache-drill-1.12.0/conf/drill-env.sh
RUN mkdir -p /etc/apache-drill-1.12.0/log && chmod 777 /etc/apache-drill-1.12.0/log
#RUN chown tester:tester -R /etc/apache-drill-1.12.0/

#No puede cambiar accesos
#RUN touch /blazingsql/hi.txt
#RUN chown -R $USER:$USER /blazingsql/
RUN chmod 777 /blazingsql/

#USER $USER
#WORKDIR /home/$USER/

#RUN mkdir -p /home/$USER/blazingdb
#RUN chown -R $USER:$USER  /home/$USER/blazingdb
# For the tester user
#VOLUME /home/$USER/blazingdb

COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
