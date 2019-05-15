#!/bin/bash
# usage: quarter year path_perf_file

echo "Activando cudf"
source activate cudf 
/blazingdb/notebooks/gpu_workflow.py $1 $2 $3
