FROM blazingdb/blazingsql:netflowdemo

RUN apt-get install -y socat netcat && apt-get clean
RUN source activate cudf && pip install "dask[complete]"

EXPOSE 8786

COPY ./start.sh /etc/start.sh
CMD ["/etc/start.sh"]
