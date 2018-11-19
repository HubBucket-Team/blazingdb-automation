#!/bin/bash

src=$HOME/blazingdb/repositories/blazingsql/
output=$HOME/blazingdb/repositories/output/

nvidia-docker run --rm -v $src:/home/builder/src/ -v $output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$1
