#!/bin/bash

source activate cudf && CUDA_VISIBLE_DEVICES=0 dask-scheduler --show
