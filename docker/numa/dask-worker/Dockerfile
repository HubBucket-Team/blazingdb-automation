FROM blazingdb/blazingsql:netflowdemo

RUN apt-get install -y socat netcat && apt-get clean
RUN source activate cudf && pip install "dask[complete]"

COPY start_conda_gpu.sh /blazingdb/notebooks/
COPY gpu_workflow.py /blazingdb/notebooks/

EXPOSE 8786

COPY ./start.sh /etc/start.sh
CMD ["/etc/start.sh"]
