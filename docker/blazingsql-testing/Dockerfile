FROM demodeploy:latest

ARG USER=default_value
ENV USER=$USER

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y  git
RUN apt-get clean


RUN source activate cudf && pip install pydrill
RUN source activate cudf && pip install openpyxl

# Create the user 'tester'
RUN useradd -ms /bin/bash $USER

#No puede cambiar accesos
RUN touch /blazingsql/hi.txt
RUN chown -R $USER:$USER /blazingsql/

USER $USER
WORKDIR /home/$USER/

RUN mkdir -p /home/$USER/blazingdb
RUN chown -R $USER:$USER  /home/$USER/blazingdb
# For the tester user
VOLUME /home/$USER/blazingdb