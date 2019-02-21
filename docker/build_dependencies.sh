#!/bin/bash
# Usage: workspace_path

workspace=$HOME/blazingsql/workspace_dependencies/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/dependencies:latest"

cd $PWD/dependencies/

nvidia-docker build -t $image_build ./
if [ $? != 0 ]; then
  exit 1
fi

nvidia-docker run --user 1000:1000 --rm -v $workspace/:/home/builder/workspace/ -v $ssh_key/:/home/builder/.ssh/ $image_build
if [ $? != 0 ]; then
  exit 1
fi
