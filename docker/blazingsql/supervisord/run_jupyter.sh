#!/bin/bash
source activate cudf && jupyter-lab --allow-root --ip=0.0.0.0 --no-browser --NotebookApp.token='rapids'
