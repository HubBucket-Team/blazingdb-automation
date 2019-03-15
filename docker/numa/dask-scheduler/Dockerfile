FROM blazingdb/blazingsql:latest

RUN apt-get install -y socat netcat && apt-get clean
RUN source activate cudf && pip install "dask[complete]" && pip install bokeh

COPY pyblazing.demo3.ipynb /blazingdb/notebooks/

EXPOSE 8786
EXPOSE 8787

COPY ./start.sh /etc/start.sh
CMD ["/etc/start.sh"]
