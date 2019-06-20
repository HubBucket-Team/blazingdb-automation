FROM blazingdb/blazingsql:netflowdemo

RUN apt-get install -y socat netcat && apt-get clean
RUN source activate cudf && pip install "dask[complete]" && pip install bokeh

COPY start_conda_gpu.sh /blazingdb/notebooks/
COPY gpu_workflow.py /blazingdb/notebooks/

#COPY pyblazing.demo3.ipynb /blazingdb/notebooks/
COPY demo_with_dask.ipynb /blazingdb/notebooks/
COPY demo_without_dask.ipynb /blazingdb/notebooks/

EXPOSE 8786
EXPOSE 8787

COPY ./start.sh /etc/start.sh
CMD ["/etc/start.sh"]
