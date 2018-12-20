#!/bin/bash
# Usage: input_path label

echo "nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/$2 -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh /tmp/$2 $3"
nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/$2 -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh /tmp/$2 $3
