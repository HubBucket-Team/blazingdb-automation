#!/bin/bash
# Usage: tag_deploy cudf_branch protocol_branch io_branch ral_branch orchestrator_branch calcite_branch pyblazing_branch

#BUILD
WORKSPACE=$PWD

cd $WORKSPACE/blazingsql-build/

workspace=$HOME/blazingsql/workspace/
output=$HOME/blazingsql/output3/
ssh_key=$HOME/.ssh/
image_build="blazingsql/build:latest"
image_deploy="blazingdb/blazingsql:$1"


# Parametrize branchs
cudf_branch="cudf_branch=$2"
blazingdb_protocol_branch="blazingdb_protocol_branch=$3"
blazingdb_io_branch="blazingdb_io_branch=$4"
blazingdb_ral_branch="blazingdb_ral_branch=$5"
blazingdb_orchestrator_branch="blazingdb_orchestrator_branch=$6"
blazingdb_calcite_branch="blazingdb_calcite_branch=$7"
pyblazing_branch="pyblazing_branch=$8"
clean_workspace=$9


echo "Aqui esta el indicador para limpiar workspace "  $clean_workspace
if [ $clean_workspace==true ]; then
      echo "Removiendo todo wl workspace dentro de "
      sudo rm -r $workspace/*
fi

mkdir -p $workspace $output

#sudo chown 1000:1000 -R $workspace
#sudo chown 1000:1000 -R $output
#sudo chown 1000:1000 -R $ssh_key


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
echo "nvidia-docker rmi -f $image_build"
nvidia-docker rmi -f $image_build
echo "nvidia-docker build -t $image_build ."
nvidia-docker build -t $image_build .
if [ $? != 0 ]; then
  exit 1
fi

echo "### Remove previous tar ###"
echo "rm -f $output/blazingsql-files.tar.gz"

# User builder uid=1000, but user jenkins uid=123
echo "### Run de Build ###"
#echo "nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build"
#nvidia-docker run --user 1000:1000 --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build
echo "nvidia-docker run --rm -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) --rm -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build"
nvidia-docker run --rm -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) -v $workspace:/home/builder/workspace/ -v $output:/home/builder/output -v $ssh_key:/home/builder/.ssh/ $image_build
#echo "Resultado: $?"
if [ $? != 0 ]; then
  exit 1
fi

echo "### Copy tar ###"
echo "cp $output/blazingsql-files.tar.gz $WORKSPACE/blazingsql/"
cp $output/blazingsql-files.tar.gz $WORKSPACE/blazingsql/

echo "WORKSPACE WHERE TAR IS ====> " $WORKSPACE/blazingsql/

echo "workspace ------->> " $workspace
echo "OUTPUT ------------>> " $output
echo "HOME ------------>> " $HOME

# BEFORE DEPLOY
cd $WORKSPACE/blazingsql/

#wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
#chmod +x Miniconda3-latest-Linux-x86_64.sh

#DEPLOY
echo "### Build de Image Deploy ###"
echo "nvidia-docker rm -f $image_deploy"
nvidia-docker rmi -f $image_deploy
echo "nvidia-docker build -t $image_deploy ."
nvidia-docker build -t $image_deploy .

