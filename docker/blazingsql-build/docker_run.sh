#!/bin/bash
# Usage: ./docker_run source_dir tag
# Example: ./docker_run $HOME/repo/ 11

nvidia-docker run --rm -v $PWD/build.sh:/home/builder/build.sh -v $1:/home/builder/src/ -v $PWD/output/:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$2 /home/builder/build.sh
