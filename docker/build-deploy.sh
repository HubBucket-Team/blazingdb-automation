#!/bin/bash
# Usage: version_build version_deploy

#BUILD
WORKSPACE=$PWD

cd $WORKSPACE/blazingsql-build/

workspace=$HOME/blazingsql/workspace/
output=$HOME/blazingsql/output3/
ssh_key=$HOME/.ssh_jenkins/
image_build="blazingsql/build:$1"
image_deploy="blazingdb/blazingsql:$2"


# Parametrize branchs
cudf_branch="cudf_branch=$3"
blazingdb_protocol_branch="blazingdb_protocol_branch=$4"
blazingdb_io_branch="blazingdb_io_branch=$5"
blazingdb_ral_branch="blazingdb_ral_branch=$6"
blazingdb_orchestrator_branch="blazingdb_orchestrator_branch=$7"
blazingdb_calcite_branch="blazingdb_calcite_branch=$8"
pyblazing_branch="pyblazing_branch=$9"


mkdir -p $workspace $output

sudo chown 1000:1000 -R $workspace
sudo chown 1000:1000 -R $output
sudo chown 1000:1000 -R $ssh_key


echo "### Copy properties ###"
cp blazingsql-build.properties $workspace

# Replace with input branchs
sed -ie "s/cudf_branch.*/$cudf_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_protocol_branch.*/$blazingdb_protocol_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_io_branch.*/$blazingdb_io_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_ral_branch.*/$blazingdb_ral_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_orchestrator_branch.*/$blazingdb_orchestrator_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/blazingdb_calcite_branch.*/$blazingdb_calcite_branch/g" $workspace/blazingsql-build.properties
sed -ie "s/pyblazing_branch.*/$pyblazing_branch/g" $workspace/blazingsql-build.properties

cat $workspace/blazingsql-build.properties


echo "### Build de Build ###"
echo "nvidia-docker build -t $image_build ."
nvidia-docker build -t $image_build .

# User builder uid=1000, but user jenkins uid=123
echo "### Run de Build ###"
echo "nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build"
nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build

echo "### Copy tar ###"
echo "cp $output/blazingsql-files.tar.gz $WORKSPACE/blazingsql/"
cp $output/blazingsql-files.tar.gz $WORKSPACE/blazingsql/

echo "WORKSPACE WHERE TAR IS ====> " $WORKSPACE/blazingsql/

echo "WORKSPACE ------->> " $workspace
echo "OUTPUT ------------>> " $output
echo "HOME ------------>> " $HOME

# BEFORE DEPLOY
cd $WORKSPACE/blazingsql/

#wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
#chmod +x Miniconda3-latest-Linux-x86_64.sh

#DEPLOY
echo "### Build de Deploy ###"
echo "nvidia-docker build -t $image_deploy ."
nvidia-docker build -t $image_deploy .

echo "### Run de Deploy ###"
nvidia-docker rm -f myjupyter
echo "nvidia-docker run --name myjupyter --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy"
nvidia-docker run --name myjupyter --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy

echo "### Open with browser ###"
echo "http://35.229.51.253:8884"
