#!/bin/bash
source activate cudf && jupyter-lab --notebook=/blazingdb/ --allow-root --ip=0.0.0.0 --no-browser --NotebookApp.token='rapids'
