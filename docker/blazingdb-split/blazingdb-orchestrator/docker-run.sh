#!/bin/bash
src=/var/lib/jenkins/workspace/ci.orchestrator/docker/blazingsql-build/blazingdb-orchestrator/src_orchestrator
nvidia-docker run --user $(id -u):$(id -g) --rm -v $src:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/orchestrator:build_v$1

#nvidia-docker run --user $(id -u):$(id -g) --rm -v $PWD/build.sh:/home/builder/build.sh -v $PWD/$1:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/orchestrator:build_v4 /home/builder/build.sh

