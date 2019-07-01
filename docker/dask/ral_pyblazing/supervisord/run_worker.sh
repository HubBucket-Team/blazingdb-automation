#!/bin/bash

source activate cudf && CUDA_VISIBLE_DEVICES=0 dask-worker blazingdb-dask-scheduler-svc:8786
