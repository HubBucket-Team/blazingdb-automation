#!/bin/bash
# Usage: full_path_tar label
# ./conda_run_upload.sh /tmp/blazingsql.tar.bz python35

file_name=$(basename "$1")
#echo "nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/$2 -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh /tmp/$file_name $2"
nvidia-docker run --user 1000:1000 --rm -v $1:/tmp/$file_name -v $PWD/conda_upload.sh:/tmp/conda_upload.sh blazingdb/conda /tmp/conda_upload.sh /tmp/$file_name $2
