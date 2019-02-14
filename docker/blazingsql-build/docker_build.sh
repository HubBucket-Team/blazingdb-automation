#!/bin/bash
# usage: ./docker_build.sh tag

tag="latest"
if [ ! -z $1 ];
then
  tag=$1
fi
echo "tag: $tag"

nvidia-docker build -t blazingdb/build:$tag .
