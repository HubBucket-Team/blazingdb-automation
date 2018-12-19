#!/bin/bash
# Usage: /path/input/files /path/output/files

nvidia-docker run  --user 1000:1000 --rm -v $1:/home/jupyter/input -v $2:/home/jupyter/output blazingdb/conda
