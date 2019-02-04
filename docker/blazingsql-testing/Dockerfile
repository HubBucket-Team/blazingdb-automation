FROM demo:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y  git
RUN apt-get clean

#RUN wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
#RUN tar -xvzf apache-drill-1.12.0.tar.gz


RUN source activate cudf && pip install pydrill
RUN source activate cudf && pip install openpyxl

# Create the user 'tester'
RUN useradd -ms /bin/bash edith

#No puede cambiar accesos
RUN touch /blazingsql/hi.txt
RUN chown -R edith:edith /blazingsql/

USER edith
WORKDIR /home/edith/

RUN mkdir -p /home/edith/blazingdb
RUN chown -R edith:edith  /home/edith/blazingdb
# For the tester user
VOLUME /home/edith/blazingdb

#CMD ["/bin/bash", "/home/edith/blazingdb/run-e2etest.sh"]