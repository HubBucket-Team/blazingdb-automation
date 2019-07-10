#!/bin/bash

export IP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)

export LD_LIBRARY_PATH="/usr/local/nvidia/lib64:/conda/envs/cudf/lib/:/usr/local/cuda-9.2/targets/x86_64-linux/lib/stubs/"

/home/jupyter/testing-libgdf 1 blazingdb-dask-scheduler-svc 9000 $IP 9000 8891
