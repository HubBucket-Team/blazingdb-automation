#!/bin/bash
# Usage:   ./docker-run.sh dir_src dir_ssh dir_m2
# Example: ./docker-run.sh src_calcite_develop/ $HOME/.ssh/ $HOME/.m2/

nvidia-docker run --user $(id -u):$(id -g)  --rm -v $WORKSPACE/docker/ci-blazingdb-protocol/src_protocol:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v $HOME/.m2/:/home/builder/.m2 blazingdb/calcite
