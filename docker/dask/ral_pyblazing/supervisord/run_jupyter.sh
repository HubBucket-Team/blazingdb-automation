#!/bin/bash
source activate cudf && jupyter-lab --notebook=/blazingsql/ --allow-root --ip=0.0.0.0 --port=80 --no-browser --NotebookApp.token='rapids'
