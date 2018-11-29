#!/bin/bash
# Usage: ./docker-run.sh dir_src

nvidia-docker run --user $(id -u):$(id -g) --rm -v $1:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v $HOME/.m2/:/home/builder/.m2 blazingdb/calcite

