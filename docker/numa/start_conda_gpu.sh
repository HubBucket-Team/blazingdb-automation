#!/bin/bash
# usage: quarter year path_perf_file

echo "Activando cudf"
source activate cudf 
/blazingdb/data/tpch/gpu_workflow.py $1 $2 $3
