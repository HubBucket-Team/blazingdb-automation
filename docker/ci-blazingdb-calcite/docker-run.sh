#!/bin/bash
# Usage:   ./docker-run.sh dir_src dir_ssh dir_m2
# Example: ./docker-run.sh src_calcite_develop/ $HOME/.ssh/ $HOME/.m2/

nvidia-docker run --user $(id -u):$(id -g) --rm -v $1:/home/builder/workspace -v $2:/home/builder/.ssh/ -v $3:/home/builder/.m2 blazingdb/calcite

