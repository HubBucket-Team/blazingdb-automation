#!/bin/bash
#nvidia-docker run --user $(id -u):$(id -g) -v $WORKSPACE/docker/ci-blazingdb-protocol/src_protocol:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v $HOME/.m2/:/home/builder/.m2 blazingdb/protocol
nvidia-docker run --user 1000:1000 --rm -v $WORKSPACE/docker/ci-blazingdb-protocol/src_protocol:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v $HOME/.m2/:/home/builder/.m2 blazingdb/protocol
