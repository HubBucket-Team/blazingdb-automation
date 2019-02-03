FROM demo:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get clean

#RUN wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
#RUN tar -xvzf apache-drill-1.12.0.tar.gz


RUN source activate cudf && pip install pydrill
RUN source activate cudf && pip install openpyxl

# Create the user 'tester'
RUN useradd -ms /bin/bash edith

RUN touch /blazingsql/hi.txt
RUN chown -R edith:edith /blazingsql/

USER edith
WORKDIR /home/edith/

RUN mkdir -p /home/edith/blazingdb
RUN mkdir -p /home/edith/blazingdb/config-files

#RUN cp configurationFile.json /home/edith/blazingdb/config-files


# For the tester user
VOLUME /home/edith/blazingdb


#CMD ["/bin/bash", "/home/edith/run-e2e-test.sh", "/home/builder/workspace", "/home/builder/output/"]



# nvidia-docker build -t blazingsqltest
# nvidia-docker run --name bzsqlcontainer --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 -v /home/kharoly/blazing:/home/kharoly/blazing -ti blazingsqltest bash
# 
# Start up BlazingSQL
# nvidia-docker exec bzsqlcontainer /usr/bin/testing-libgdf
# nvidia-docker exec bzsqlcontainer /usr/bin/blazingdb_orchestator_service

# Also these:
# nvidia-docker exec -u root bzsqlcontainer chown -R kharoly:kharoly /blazingsql/
# nvidia-docker exec -u root bzsqlcontainer chown -R kharoly:kharoly /home/kharoly/blazing/apache-drill-1.12.0/*
# nvidia-docker exec -u root bzsqlcontainer chown -R kharoly:kharoly /home/kharoly/blazing/blazingdb-testing/*

# nvidia-docker exec bzsqlcontainer java -jar /usr/bin/BlazingCalcite.jar

# Finally start spache drill too
# nvidia-docker exec bzsqlcontainer ./drill-embedded
