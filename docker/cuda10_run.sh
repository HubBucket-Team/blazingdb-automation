#!/bin/bash
# Usage: container_name

CONTAINER_NAME=$1

docker rm -f $CONTAINER_NAME

docker run --runtime=nvidia --name $CONTAINER_NAME -d -ti nvidia/cuda:10.0-devel-ubuntu16.04 bash
