#!/bin/bash

#BUILD
cd blazingsql-build/

workspace=$HOME/blazingsql/workspace/
output=$HOME/blazingsql/output/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/build:$1"
image_deploy="blazingsql/deploy:$1"

mkdir -p $workspace $output

sudo chown 1000:1000 -R $workspace
sudo chown 1000:1000 -R $output
sudo chown 1000:1000 -R $ssh_key

cp blazingsql-build.properties $workspace


nvidia-docker build -t $image_build .
# User builder uid=1000, but user jenkins uid=123
nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build

cp $output/blazingsql-files.tar.gz ./blazingsql/


# BEFORE DEPLOY
cd blazingsql 

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh

#DEPLOY
nvidia-docker build -t $image_deploy .
nvidia-docker run --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy

