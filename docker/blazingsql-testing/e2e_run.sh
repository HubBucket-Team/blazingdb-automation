#!/bin/bash
nvidia-docker run --name bzsqlcontainer --rm -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v /home/edith/blazingdb/workspace-testing/:/home/edith/blazingdb  -ti blazingsqltest  bash

#nvidia-docker run --rm -v $PWD/build.sh:/home/builder/build.sh -v $1:/home/builder/src/ -v $PWD/output/:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$2 /home/builder/build.sh

nvidia-docker run --name bzsqlcontainer -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v /home/edith/blazingdb/workspace-testing/:/home/edith/blazingdb  -d blazingsqltest  bash
