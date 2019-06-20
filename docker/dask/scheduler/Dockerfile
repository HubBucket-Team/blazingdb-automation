#FROM blazingdb/blazingsql:latest
FROM python:3.7

#RUN apt-get install -y socat netcat && apt-get clean
RUN pip3 install "dask[complete]" && \
    pip3 install bokeh

EXPOSE 8786
EXPOSE 8787

#COPY ./start.sh /etc/start.sh
#CMD ["/etc/start.sh"]
