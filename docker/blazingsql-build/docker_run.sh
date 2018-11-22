#!/bin/bash
nvidia-docker run --rm -v $src:/home/builder/src/ -v $output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$1
