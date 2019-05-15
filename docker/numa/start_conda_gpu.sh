#!/bin/bash

echo "Activando cudf"
source activate cudf
python /blazingdb/data/results/gpu_workflow.py $1 $2 $3
