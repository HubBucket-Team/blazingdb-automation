#!/bin/bash

workspace=$1
output=$2
image_build=$3

echo "********************************"
echo "The blazingsql-build.properties:"
echo "********************************"
head -n 11 $workspace/blazingsql-build.properties
echo "********************************"

nvidia-docker run --rm -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) -v /lib/modules:/lib/modules -v /usr/src:/usr/src -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ $image_build