#!/bin/bash
nvidia-docker run --rm -v $PWD:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v /$HOME/.m2/:/home/builder/.m2 blazingdb/calcite

