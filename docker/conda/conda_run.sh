#!/bin/bash
# Usage: /path/input/files /path/output/files
nvidia-docker run  --user $(id -u):$(id -g) --rm -v $1:/home/jupyter/input -v $2:/home/jupyter/output blazingdb/conda:latest /home/jupyter/generate-blazingsql.sh /home/jupyter/input/blazingsql-files.tar.gz /home/jupyter/output $3 $4 $5 
 
