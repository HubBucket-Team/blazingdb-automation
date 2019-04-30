#!/bin/bash
# Usage: 
# build-deploy.sh 
# (arg 2) # blazingdb_toolchain_branch
# (arg 3) # custrings_branch
# (arg 4) # cudf_branch
# (arg 5) # protocol_branch
# (arg 6) # io_branch
# (arg 7) # blazingdb_communication_branch
# (arg 8) # ral_branch
# (arg 9) # orchestrator_branch
# (arg 10) # calcite_branch
# (arg 11) # pyblazing_branch
# (arg 12) # blazingdb_toolchain_clean_before_build
# (arg 13) # custrings_clean_before_build
# (arg 14) # cudf_clean_before_build
# (arg 15) # blazingdb_protocol_clean_before_build
# (arg 16) # blazingdb_io_clean_before_build
# (arg 17) # blazingdb_communication_clean_before_build
# (arg 18) # blazingdb_ral_clean_before_build
# (arg 19) # blazingdb_orchestrator_clean_before_build
# (arg 20) # blazingdb_calcite_clean_before_build
# (arg 21) # pyblazing_clean_before_build

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
blazingdb_toolchain_branch=$2
custrings_branch=$3
cudf_branch=$4
blazingdb_protocol_branch=$5
blazingdb_io_branch=$6
blazingdb_communication_branch=$7
blazingdb_ral_branch=$8
blazingdb_orchestrator_branch=$9
blazingdb_calcite_branch=${10}
pyblazing_branch=${11}

# Parametrize clean before build options
blazingdb_toolchain_clean_before_build=${12}
custrings_clean_before_build=${13}
cudf_clean_before_build=${14}
blazingdb_protocol_clean_before_build=${15}
blazingdb_io_clean_before_build=${16}
blazingdb_communication_clean_before_build=${17}
blazingdb_ral_clean_before_build=${18}
blazingdb_orchestrator_clean_before_build=${19}
blazingdb_calcite_clean_before_build=${20}
pyblazing_clean_before_build=${21}

workspace_maven_repository=${22}

if [ $workspace_maven_repository == true ]; then
      echo "clean maven-repository "
      sudo rm -r $workspace/maven-repository
fi

echo "Forcing build dependencies: $blazingdb_toolchain_clean_before_build"

# Mandatory args

if [ -z "$blazingdb_toolchain_branch" ]; then
    blazingdb_toolchain_branch=develop
fi

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

echo "Branches:"

echo "blazingdb_toolchain_branch: $blazingdb_toolchain_branch"
echo "custrings_branch: $cudf_branch"
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
blazingdb_toolchain_branch=$blazingdb_toolchain_branch
custrings_branch=$custrings_branch
cudf_branch=$cudf_branch
blazingdb_protocol_branch=$blazingdb_protocol_branch
blazingdb_io_branch=$blazingdb_io_branch
blazingdb_communication_branch=$blazingdb_communication_branch
blazingdb_ral_branch=$blazingdb_ral_branch
blazingdb_orchestrator_branch=$blazingdb_orchestrator_branch
blazingdb_calcite_branch=$blazingdb_calcite_branch
pyblazing_branch=$pyblazing_branch

#optional: enable build (default is true)
blazingdb_toolchain_enable=true
custrings_enable=true
cudf_enable=true
blazingdb_protocol_enable=true
blazingdb_io_enable=true
blazingdb_communication_enable=true
blazingdb_ral_enable=true
blazingdb_orchestrator_enable=true
blazingdb_calcite_enable=true
pyblazing_enable=true

#optional: build type for C/C++ projects (default is Release, i.e. -DCMAKE_BUILD_TYPE=Release)
# For debug mode use: Debug ... more info here: https://cmake.org/cmake/help/v3.12/variable/CMAKE_BUILD_TYPE.html#variable:CMAKE_BUILD_TYPE
custrings_build_type=Release
cudf_build_type=Release
blazingdb_protocol_build_type=Release
blazingdb_io_build_type=Release
blazingdb_communication_build_type=Release
blazingdb_ral_build_type=Release
blazingdb_orchestrator_build_type=Release

#optional: tests build & run (default is false)
blazingdb_toolchain_tests=false
custrings_tests=false
cudf_tests=false
blazingdb_protocol_tests=false
blazingdb_io_tests=false
blazingdb_communication_tests=false
blazingdb_ral_tests=false
blazingdb_orchestrator_tests=false
blazingdb_calcite_tests=false
pyblazing_tests=false

#optional: parallel builds for make -jX and mvn -T XC (default is 4)
blazingdb_toolchain_parallel=4
custrings_parallel=4
cudf_parallel=4
blazingdb_protocol_parallel=4
blazingdb_io_parallel=4
blazingdb_communication_parallel=4
blazingdb_ral_parallel=4
blazingdb_orchestrator_parallel=4
blazingdb_calcite_parallel=4

#optional: build options (precompiler definitions, etc.)
blazingdb_ral_definitions="-DLOG_PERFORMANCE"

#optional: clean options for selected branch (will delete the build folder before build)
blazingdb_toolchain_clean_before_build=$blazingdb_toolchain_clean_before_build
custrings_clean_before_build=$custrings_clean_before_build
cudf_clean_before_build=$cudf_clean_before_build
blazingdb_protocol_clean_before_build=$blazingdb_protocol_clean_before_build
blazingdb_io_clean_before_build=$blazingdb_io_clean_before_build
blazingdb_communication_clean_before_build=$blazingdb_communication_clean_before_build
blazingdb_ral_clean_before_build=$blazingdb_ral_clean_before_build
blazingdb_orchestrator_clean_before_build=$blazingdb_orchestrator_clean_before_build
blazingdb_calcite_clean_before_build=$blazingdb_calcite_clean_before_build
pyblazing_clean_before_build=$pyblazing_clean_before_build

EOF

echo "********************************"
echo "The blazingsql-build.properties:"
echo "********************************"
cat $workspace/blazingsql-build.properties
echo "********************************"
echo "********************************"


echo "### Build de Build ###"
echo "nvidia-docker rmi -f $image_build"
nvidia-docker rmi -f $image_build

echo "nvidia-docker build -t $image_build ."
#nvidia-docker build --build-arg CUDA_VERSION=10.0 -t $image_build .
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
#nvidia-docker build --build-arg CUDA_VERSION=10.0 -t $image_deploy .
nvidia-docker build -t $image_deploy .

