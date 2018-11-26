#!/bin/bash
#src=/var/lib/jenkins/workspace/ci.orchestrator/docker/blazingsql-build/blazingdb-orchestrator/src_orchestrator
#nvidia-docker run --user $(id -u):$(id -g) --rm -v $src:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/orchestrator:build_v$1

nvidia-docker run --rm -v $PWD:/home/builder/workspace -v $HOME/.ssh/:/home/builder/.ssh/ -v /$HOME/.m2/:/home/builder/.m2 -ti blazingdb/orchestrator
