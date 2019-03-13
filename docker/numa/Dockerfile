FROM blazingdb/blazingsql:latest

RUN apt-get install -y socat netcat && apt-get clean
RUN source activate cudf && pip install "dask[complete]" && pip install bokeh

USER root
COPY ./start.sh /etc/start.sh
CMD ["/etc/start.sh"]

#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#CMD "socat -d -d TCP4-LISTEN:9090,fork UNIX-CONNECT:/tmp/calcite.socket"
#CMD "socat -d -d TCP4-LISTEN:9091,fork UNIX-CONNECT:/tmp/orchestrator.socket"
#CMD "socat -d -d TCP4-LISTEN:9092,fork UNIX-CONNECT:/tmp/ral.socket"
