#!/bin/bash
nvidia-docker run --user $(id -u):$(id -g) --rm -v $PWD/src_calcite:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v /$HOME/.m2/:/home/builder/.m2 blazingdb/calcite

