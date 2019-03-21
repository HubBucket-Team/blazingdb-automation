#!/bin/bash

echo "### supervisord ###"
supervisord -n -c /etc/supervisor/supervisord.conf &

echo "### dask worker ###"
source activate cudf && dask-worker 172.18.0.20:8786
