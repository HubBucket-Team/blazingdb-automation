#!/bin/bash

#BUILD
cd blazingsql-build

mkdir -R $HOME/blazingsql/workspace/
mkdir -R $HOME/blazingsql/output/

workspace=$HOME/blazingsql/workspace/
output=$HOME/blazingsql/output/

chown 1000:1000 -R $HOME/workspace
chown 1000:1000 -R $HOME/output
chown 1000:1000 -R $HOME/.ssh

cp blazingsql-build.properties $HOME/workspace/

nvidia-docker build -t test .

nvidia-docker run --user 1000:1000 --rm -v $workspace/:/home/builder/workspace/ -v $output/:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ 

cp $output/blazingsql-files.tar.gz blazingsql/


#BEFORE DEPLOY
cd blazingsql
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh

#DEPLOY
nvidia-docker build -t deploytest .

nvidia-docker run --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 deploytest

#JOB PUBLISH
