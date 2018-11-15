#!/bin/bash

rm -rf output && mkdir $PWD/output

nvidia-docker run --rm -v $HOME/repo/:/home/builder/src/ -v $PWD/output/:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$1
