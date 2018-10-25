#!/bin/bash
source activate gdf && jupyter-lab --allow-root --ip=0.0.0.0 --no-browser --NotebookApp.token='rapids'
