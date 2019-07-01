#!/bin/bash

source activate cudf && NVIDIA_VISIBLE_DEVICES=0 dask-scheduler --show
