FROM blazingdb/blazingsql:latest

MAINTAINER BlazingDB <percy@blazingdb.com>

LABEL Description="blazingdb/blazingsql is the official BlazingDB environment for BlazingSQL on NIVIDA RAPIDS." Vendor="BlazingDB" Version="1.0"

RUN source activate cudf && pip install pydrill

# Create the user 'tester'
RUN useradd -ms /bin/bash kharoly

USER kharoly
WORKDIR /home/kharoly/

RUN mkdir -p /home/kharoly/blazing

# For the tester user
VOLUME /home/kharoly/blazing

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# nvidia-docker build -t blazingsqltest
# nvidia-docker run --name bzsqlcontainer --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 -v /home/kharoly/:/home/kharoly/ blazingsqltest
