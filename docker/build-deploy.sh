#!/bin/bash
# Usage: tag_deploy cudf_branch protocol_branch io_branch blazingdb_communication_branch ral_branch orchestrator_branch calcite_branch pyblazing_branch

#BUILD
WORKSPACE=$PWD

cd $WORKSPACE/blazingsql-build/

workspace=$HOME/blazingsql/workspace/
if [ ! -d "$workspace" ]; then
  rm -rf $workspace
  echo "mkdir -p $workspace"
  mkdir -p $workspace
fi

output=$HOME/blazingsql/output3/
if [ ! -d "$output" ]; then
  rm -rf $output
  echo "mkdir -p $output"
  mkdir -p $output
fi
ssh_key=$HOME/.ssh/
image_build="blazingsql/build:latest"
image_deploy="blazingdb/blazingsql:$1"


# Parametrize branchs
cudf_branch=$2
blazingdb_protocol_branch=$3
blazingdb_io_branch=$4
blazingdb_communication_branch=$5
blazingdb_ral_branch=$6
blazingdb_orchestrator_branch=$7
blazingdb_calcite_branch=$8
pyblazing_branch=$9

if [ -z "$cudf_branch" ]; then
    cudf_branch=develop
fi

if [ -z "$blazingdb_protocol_branch" ]; then
    blazingdb_protocol_branch=develop
fi

if [ -z "$blazingdb_io_branch" ]; then
    blazingdb_io_branch=develop
fi

if [ -z "$blazingdb_communication_branch" ]; then
    blazingdb_communication_branch=develop
fi

if [ -z "$blazingdb_ral_branch" ]; then
    blazingdb_ral_branch=develop
fi

if [ -z "$blazingdb_orchestrator_branch" ]; then
    blazingdb_orchestrator_branch=develop
fi

if [ -z "$blazingdb_calcite_branch" ]; then
    blazingdb_calcite_branch=develop
fi

if [ -z "$pyblazing_branch" ]; then
    pyblazing_branch=develop
fi

mkdir -p $workspace $output

#sudo chown 1000:1000 -R $workspace
#sudo chown 1000:1000 -R $output
#sudo chown 1000:1000 -R $ssh_key


echo "### Copy properties ###"
cp blazingsql-build.properties $workspace

echo "Branches"

echo "cudf_branch: $cudf_branch"
echo "blazingdb_protocol_branch: $blazingdb_protocol_branch"
echo "blazingdb_io_branch: $blazingdb_io_branch"
echo "blazingdb_communication_branch: $blazingdb_communication_branch"
echo "blazingdb_ral_branch: $blazingdb_ral_branch"
echo "blazingdb_orchestrator_branch: $blazingdb_orchestrator_branch"
echo "blazingdb_calcite_branch: $blazingdb_calcite_branch"
echo "pyblazing_branch: $pyblazing_branch"

# define the properties template
cat << EOF > $workspace/blazingsql-build.properties
#mandatory: branches
cudf_branch=$cudf_branch
blazingdb_protocol_branch=$blazingdb_protocol_branch
blazingdb_io_branch=$blazingdb_io_branch
blazingdb_communication_branch=$blazingdb_communication_branch
blazingdb_ral_branch=$blazingdb_ral_branch
blazingdb_orchestrator_branch=$blazingdb_orchestrator_branch
blazingdb_calcite_branch=$blazingdb_calcite_branch
pyblazing_branch=$pyblazing_branch

#optional: enable build (default is true)
cudf_enable=true
blazingdb_protocol_enable=true
blazingdb_io_enable=true
blazingdb_communication_enable=true
blazingdb_ral_enable=true
blazingdb_orchestrator_enable=true
blazingdb_calcite_enable=true
pyblazing_enable=true

#optional: parallel builds for make -jX and mvn -T XC (default is 4)
cudf_parallel=4
blazingdb_protocol_parallel=4
blazingdb_io_parallel=4
blazingdb_communication_parallel=4
blazingdb_ral_parallel=4
blazingdb_orchestrator_parallel=4
blazingdb_calcite_parallel=4

#optional: tests build & run (default is false)
cudf_tests=false
blazingdb_protocol_tests=false
blazingdb_io_tests=false
blazingdb_communication_tests=false
blazingdb_ral_tests=false
blazingdb_orchestrator_tests=false
blazingdb_calcite_tests=false
pyblazing_tests=false

#optional: build options (precompiler definitions, etc.)
blazingdb_ral_definitions="-DLOG_PERFORMANCE"

EOF

# The blazingsql-build.properties:
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

