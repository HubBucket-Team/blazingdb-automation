#!/bin/bash

#BUILD
WORKSPACE=$PWD

cd $WORKSPACE/blazingsql-build/

workspace=$HOME/blazingsql/workspace/
output=$HOME/blazingsql/output/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/build:test"
image_deploy="blazingdb/blazingsql:test"

mkdir -p $workspace $output

sudo chown 1000:1000 -R $workspace
sudo chown 1000:1000 -R $output
sudo chown 1000:1000 -R $ssh_key

echo "### Copy properties ###"
cp blazingsql-build.properties $workspace

echo "### Build de Build ###"
nvidia-docker build -t $image_build .
# User builder uid=1000, but user jenkins uid=123
echo "### Run de Build ###"
nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build

echo "### Copy tar ###"
cp $output/blazingsql-files.tar.gz $WORKSPACE/blazingsql/


# BEFORE DEPLOY
cd $WORKSPACE/blazingsql/

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh

#DEPLOY
echo "### Build de Deploy ###"
nvidia-docker build -t $image_deploy .

echo "### Run de Deploy ###"
nvidia-docker rm -f myjupyter
nvidia-docker run --name myjupyter --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy

echo "### Open with browser ###"
echo "http://35.229.51.253:8884"
