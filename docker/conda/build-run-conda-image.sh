#!/bin/bash

#BUILD
WORKSPACE=$PWD

cd $WORKSPACE/conda/

workspace=$HOME/blazingsql/workspace/
conda_output=$HOME/blazingsql/conda_output/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/conda:$1"



mkdir -p $workspace $output

sudo chown 1000:1000 -R $workspace
sudo chown 1000:1000 -R $output
sudo chown 1000:1000 -R $ssh_key



echo "### Build conda image ###"
nvidia-docker build -t $image_build .

# User builder uid=1000, but user jenkins uid=123
echo "### Run de conda image ###"
nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/jupyter/input -v $conda_output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ conda bash


# Compress conda output
tar czf blazingsql.tar.gz $conda_output/blazingsql/


# Execute conda buils
# is ncesary activate conda enviroment?\or into the container?
VERSION=0.1_dev BUILD=2 FILE_TAR=/home/edithbz/blazingdb/repositories/conda-workspace/blazingsql.tar.gz conda build . --output

echo "### Run de Deploy ###"
anaconda upload /home/edithbz/.conda/envs/dev1/conda-bld/linux-64/blazingsql-0.1-0.tar.bz2  --label demo
