#!/bin/bash
nvidia-docker run --rm -v $WORKSPACE/docker/ci-blazingdb-protocol/src_protocol:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v $HOME/.m2/:/home/builder/.m2 blazingdb/protocol
