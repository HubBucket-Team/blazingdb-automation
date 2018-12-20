#!/bin/bash
# Usage: input_path label

echo "nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/tar/ -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh $1 $2"
nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/tar/ -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh $1 $2
