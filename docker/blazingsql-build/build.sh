#!/bin/bash

# NOTE you need to have the blazingsql-build.properties file inside the workspace_dir
workspace_dir=/home/builder/workspace/
output_dir=/home/builder/output/
if [ ! -z $1 ]; then
  workspace_dir=$1
fi
if [ ! -z $2 ]; then
  output_dir=$2
fi

BUILD_TYPE='Release'
if [ $# -eq 3 ]; then
    BUILD_TYPE=$3
fi


# Expand args to absolute/full paths (if the user pass relative paths as args)
workspace_dir=$(readlink -f $workspace_dir)
output_dir=$(readlink -f $output_dir)

output=$output_dir/blazingsql-files
if [ ! -d "$output" ]; then
  rm -rf $output
  echo "mkdir -p $output"
  mkdir -p $output 
fi

working_directory=$PWD
blazingsql_build_properties=blazingsql-build.properties

cd $workspace_dir

# Clean the FAILED file (in case exists)
rm -rf FAILED 

# Load the build properties file
source $blazingsql_build_properties

#BEGIN check mandatory arguments

if [ -z "$cudf_branch" ]; then
    echo "Error: Need the 'cudf_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_protocol_branch" ]; then
    echo "Error: Need the 'blazingdb_protocol_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_io_branch" ]; then
    echo "Error: Need the 'blazingdb_io_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_communication_branch" ]; then
    echo "Error: Need the 'blazingdb_communication_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_ral_branch" ]; then
    echo "Error: Need the 'blazingdb_ral_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_orchestrator_branch" ]; then
    echo "Error: Need the 'blazingdb_orchestrator_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$blazingdb_calcite_branch" ]; then
    echo "Error: Need the 'blazingdb_calcite_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

if [ -z "$pyblazing_branch" ]; then
    echo "Error: Need the 'pyblazing_branch' argument in order to run the build process."
    touch FAILED
    exit 1
fi

#END check mandatory arguments

#BEGIN set default optional arguments for active/enable the build

if [ -z "$cudf_enable" ]; then
    cudf_enable=true
fi

if [ -z "$blazingdb_protocol_enable" ]; then
    blazingdb_protocol_enable=true
fi

if [ -z "$blazingdb_io_enable" ]; then
    blazingdb_io_enable=true
fi

if [ -z "$blazingdb_communication_enable" ]; then
    blazingdb_communication_enable=true
fi

if [ -z "$blazingdb_ral_enable" ]; then
    blazingdb_ral_enable=true
fi

if [ -z "$blazingdb_orchestrator_enable" ]; then
    blazingdb_orchestrator_enable=true
fi

if [ -z "$blazingdb_calcite_enable" ]; then
    blazingdb_calcite_enable=true
fi

if [ -z "$pyblazing_enable" ]; then
    pyblazing_enable=true
fi

#END set default optional arguments for active/enable the build

#BEGIN set default optional arguments for parallel build

if [ -z "$cudf_parallel" ]; then
    cudf_parallel=4
fi

if [ -z "$blazingdb_protocol_parallel" ]; then
    blazingdb_protocol_parallel=4
fi

if [ -z "$blazingdb_io_parallel" ]; then
    blazingdb_io_parallel=4
fi

if [ -z "$blazingdb_communication_parallel" ]; then
    blazingdb_communication_parallel=4
fi

if [ -z "$blazingdb_ral_parallel" ]; then
    blazingdb_ral_parallel=4
fi

if [ -z "$blazingdb_orchestrator_parallel" ]; then
    blazingdb_orchestrator_parallel=4
fi

if [ -z "$blazingdb_calcite_parallel" ]; then
    blazingdb_calcite_parallel=4
fi

#END set default optional arguments for parallel build

#BEGIN set default optional arguments for tests

if [ -z "$cudf_tests" ]; then
    cudf_tests=false
fi

if [ -z "$blazingdb_protocol_tests" ]; then
    blazingdb_protocol_tests=false
fi

if [ -z "$blazingdb_io_tests" ]; then
    blazingdb_io_tests=false
fi

if [ -z "$blazingdb_communication_tests" ]; then
    blazingdb_communication_tests=false
fi

if [ -z "$blazingdb_ral_tests" ]; then
    blazingdb_ral_tests=false
fi

if [ -z "$blazingdb_orchestrator_tests" ]; then
    blazingdb_orchestrator_tests=false
fi

if [ -z "$blazingdb_calcite_tests" ]; then
    blazingdb_calcite_tests=false
fi

if [ -z "$pyblazing_tests" ]; then
    pyblazing_tests=false
fi

#END set default optional arguments for tests

#BEGIN set default optional arguments for build options (precompiler definitions, etc.)

if [ -z "$blazingdb_ral_definitions" ]; then
    blazingdb_ral_definitions="-DLOG_PERFORMANCE"
fi

#END set default optional arguments for build options (precompiler definitions, etc.)

#BEGIN functions

#usage: replace_str "hi jack :)" "jack" "mike" ... result "hi mike :)" 
function replace_str() {
    input=$1
    replace=$2
    with=$3
    result=${input/${replace}/${with}}
    echo $result
}

# converts string feature/branchx to feature_branchx
function normalize_branch_name() {
    branch_name=$1
    result=$(replace_str $branch_name "/" "_")
    echo $result
}

#END functions

#BEGIN main

cudf_branch_name=$(normalize_branch_name $cudf_branch)
blazingdb_protocol_branch_name=$(normalize_branch_name $blazingdb_protocol_branch)
blazingdb_io_branch_name=$(normalize_branch_name $blazingdb_io_branch)
blazingdb_communication_branch_name=$(normalize_branch_name $blazingdb_communication_branch)
blazingdb_ral_branch_name=$(normalize_branch_name $blazingdb_ral_branch)
blazingdb_orchestrator_branch_name=$(normalize_branch_name $blazingdb_orchestrator_branch)
blazingdb_calcite_branch_name=$(normalize_branch_name $blazingdb_calcite_branch)
pyblazing_branch_name=$(normalize_branch_name $pyblazing_branch)

cd $workspace_dir

#BEGIN dependencies

if [ ! -d dependencies ]; then
    mkdir dependencies
fi

cd $workspace_dir/dependencies/

if [ ! -d $workspace_dir/dependencies/blazingdb-dependencies/build ]; then
    git clone git@github.com:BlazingDB/blazingdb-dependencies.git
    cd blazingdb-dependencies
    git checkout feature/easy-build
    mkdir -p build
    cd build
    CUDACXX=/usr/local/cuda-9.2/bin/nvcc cmake -DCMAKE_INSTALL_PREFIX=$workspace_dir/dependencies/ ..
    make -j8 install
fi

#BEGIN boost

boost_install_dir=$workspace_dir/dependencies/

#END boost

#BEGIN nvstrings

nvstrings_install_dir=$workspace_dir/dependencies/

#END nvstrings

#BEGIN libstd libhdfs3 

libhdfs3_package=libhdfs3
libhdfs3_install_dir=$workspace_dir/dependencies/$libhdfs3_package

if [ ! -d $libhdfs3_install_dir ]; then
    echo "### Libhdfs3 - start ###"
    cd $workspace_dir/dependencies/
    libhdfs3_url=https://s3-us-west-2.amazonaws.com/blazing-public-downloads/_libs_/libhdfs3/libhdfs3.tar.gz
    wget $libhdfs3_url
    mkdir $libhdfs3_package
    tar xvf "$libhdfs3_package".tar.gz -C $libhdfs3_package
    if [ $? != 0 ]; then
      exit 1
    fi
    echo "### Libhdfs3 - end ###"
fi

cd $workspace_dir
mkdir -p $output/$libhdfs3_package/
cp -r $libhdfs3_install_dir/* $output/$libhdfs3_package/

#END libhdfs3

#BEGIN googletest

googletest_install_dir=$workspace_dir/dependencies/

#END googletest

#BEGIN flatbuffers

flatbuffers_install_dir=$workspace_dir/dependencies/

#END flatbuffers

#BEGIN lz4

lz4_install_dir=$workspace_dir/dependencies/

#END lz4

#BEGIN zstd

zstd_install_dir=$workspace_dir/dependencies/

#END zstd

#BEGIN brotli

brotli_install_dir=$workspace_dir/dependencies/

#END brotli

#BEGIN snappy

snappy_install_dir=$workspace_dir/dependencies/

#END snappy

#BEGIN thrift

thrift_install_dir=$workspace_dir/dependencies/

#END thrift

#BEGIN arrow

arrow_install_dir=$workspace_dir/dependencies/

#END arrow

#BEGIN aws-sdk-cpp

aws_sdk_cpp_build_dir=$workspace_dir/dependencies/build/aws-sdk-cpp

#END aws-sdk-cpp

#END dependencies

if [ $cudf_enable == true ]; then
    #BEGIN cudf
    echo "### Cudf - start ###"
    
    cd $workspace_dir
    
    if [ ! -d cudf_project ]; then
        mkdir cudf_project
    fi
    
    cudf_project_dir=$workspace_dir/cudf_project
    
    cd $cudf_project_dir
    
    if [ ! -d $cudf_branch_name ]; then
        mkdir $cudf_branch_name
        cd $cudf_branch_name
        git clone git@github.com:BlazingDB/cudf.git
    fi
    
    cudf_current_dir=$cudf_project_dir/$cudf_branch_name/
    
    cd $cudf_current_dir/cudf
    git checkout $cudf_branch
    git pull
    git submodule update --init --recursive
    
    libgdf_install_dir=$cudf_current_dir/install
    libgdf_dir=cpp
    
    libgdf_build_dir=$cudf_current_dir/cudf/$libgdf_dir/build/

    mkdir -p $libgdf_build_dir

    build_testing_cudf="OFF"
    if [ $cudf_tests == true ]; then
        build_testing_cudf="ON"
    fi

    echo "build_testing_cudf: $build_testing_cudf"

    echo "### CUDF - cmake ###"
    cd $libgdf_build_dir
    BOOST_ROOT=$boost_install_dir CUDACXX=/usr/local/cuda-9.2/bin/nvcc NVSTRINGS_ROOT=$nvstrings_install_dir cmake \
        -DCMAKE_BUILD_TYPE=Release  \
        -DBUILD_TESTS=$build_testing_cudf  \
        -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir  \
        ..
    echo "### CUDF - make install ###"
    make -j$cudf_parallel install
    if [ $? != 0 ]; then
      exit 1
    fi
    
    #END cudf
    
    # Package cudf
    cd $workspace_dir
    mkdir -p ${output}/cudf/$libgdf_dir/install

    cp -r $cudf_current_dir/cudf/* ${output}/cudf/
    if [ $? != 0 ]; then
      exit 1
    fi

    cp -r $libgdf_install_dir/* ${output}/cudf/$libgdf_dir/install
    if [ $? != 0 ]; then
      exit 1
    fi

    rm -rf ${output}/cudf/.git/
    rm -rf ${output}/cudf/$libgdf_dir/build/

    echo "### Cudf - end ###"
fi

if [ $blazingdb_protocol_enable == true ]; then
    echo "### Protocol - start ###"
    #BEGIN blazingdb-protocol
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-protocol_project ]; then
        mkdir blazingdb-protocol_project
    fi
    
    blazingdb_protocol_project_dir=$workspace_dir/blazingdb-protocol_project
    
    cd $blazingdb_protocol_project_dir
    
    if [ ! -d $blazingdb_protocol_branch_name ]; then
        mkdir $blazingdb_protocol_branch_name
        cd $blazingdb_protocol_branch_name
        git clone git@github.com:BlazingDB/blazingdb-protocol.git
    fi
    
    blazingdb_protocol_current_dir=$blazingdb_protocol_project_dir/$blazingdb_protocol_branch_name/
    
    cd $blazingdb_protocol_current_dir/blazingdb-protocol
    git checkout $blazingdb_protocol_branch
    git pull
    
    cd cpp
    
    blazingdb_protocol_install_dir=$blazingdb_protocol_current_dir/install
    
    blazingdb_protocol_cpp_build_dir=$blazingdb_protocol_current_dir/blazingdb-protocol/cpp/build/
    mkdir -p $blazingdb_protocol_cpp_build_dir
    
    cd $blazingdb_protocol_cpp_build_dir
    
    blazingdb_protocol_artifact_name=libblazingdb-protocol.a
    rm -rf lib/$blazingdb_protocol_artifact_name
    
    echo "### Protocol - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=$workspace_dir/dependencies/ \
          -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Protocol - make install ###"
    make -j$blazingdb_protocol_parallel install
    if [ $? != 0 ]; then
      exit 1
    fi
    
    cd $blazingdb_protocol_current_dir/blazingdb-protocol/java
    echo "### Protocol - mvn ###"
    mvn clean install -Dmaven.test.skip=true
    if [ $? != 0 ]; then
      exit 1
    fi

    blazingdb_protocol_java_build_dir=$blazingdb_protocol_current_dir/blazingdb-protocol/java/target/
    
    #END blazingdb-protocol
    
    # Package blazingdb-protocol/python
    cd $workspace_dir
    mkdir -p $output/blazingdb-protocol/python/
    cp -r $blazingdb_protocol_current_dir/blazingdb-protocol/python/* $output/blazingdb-protocol/python/

    echo "### Protocol - end ###"
fi

if [ $blazingdb_io_enable == true ]; then
    #BEGIN blazingdb-io
    echo "### Blazingdb IO - start ###"
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-io_project ]; then
        mkdir blazingdb-io_project
    fi
    
    blazingdb_io_project_dir=$workspace_dir/blazingdb-io_project
    
    cd $blazingdb_io_project_dir
    
    if [ ! -d $blazingdb_io_branch_name ]; then
        mkdir $blazingdb_io_branch_name
        cd $blazingdb_io_branch_name
        git clone git@github.com:BlazingDB/blazingdb-io.git
    fi
    
    blazingdb_io_current_dir=$blazingdb_io_project_dir/$blazingdb_io_branch_name/
    
    cd $blazingdb_io_current_dir/blazingdb-io
    git checkout $blazingdb_io_branch
    git pull
    
    blazingdb_io_install_dir=$blazingdb_io_current_dir/install
    blazingdb_io_cpp_build_dir=$blazingdb_io_current_dir/blazingdb-io/build/
    
    mkdir -p $blazingdb_io_cpp_build_dir
    
    cd $blazingdb_io_cpp_build_dir
    
    blazingdb_io_artifact_name=libblazingdb-io.a
    rm -rf $blazingdb_io_artifact_name
    
    echo "### Blazingdb IO - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=$workspace_dir/dependencies/ \
          -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_io_install_dir \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Blazingdb IO - make ###"
    make -j$blazingdb_io_parallel install
    if [ $? != 0 ]; then
      exit 1
    fi
    
    echo "### Blazingdb IO - end ###"
    #END blazingdb-io
fi

if [ $blazingdb_communication_enable == true ]; then
    #BEGIN blazingdb-communication
    echo "### Blazingdb communication - start ###"
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-communication_project ]; then
        mkdir blazingdb-communication_project
    fi
    
    blazingdb_communication_project_dir=$workspace_dir/blazingdb-communication_project
    
    cd $blazingdb_communication_project_dir
    
    if [ ! -d $blazingdb_communication_branch_name ]; then
        mkdir $blazingdb_communication_branch_name
        cd $blazingdb_communication_branch_name
        git clone git@github.com:BlazingDB/blazingdb-communication.git
    fi
    
    blazingdb_communication_current_dir=$blazingdb_communication_project_dir/$blazingdb_communication_branch_name/
    
    cd $blazingdb_communication_current_dir/blazingdb-communication
    git checkout $blazingdb_communication_branch
    git pull
    
    blazingdb_communication_install_dir=$blazingdb_communication_current_dir/install
    blazingdb_communication_cpp_build_dir=$blazingdb_communication_current_dir/blazingdb-communication/build/
    
    mkdir -p $blazingdb_communication_cpp_build_dir
    
    cd $blazingdb_communication_cpp_build_dir
    
    blazingdb_communication_artifact_name=libblazingdb-communication.a
    rm -rf $blazingdb_communication_artifact_name
    
    echo "### Blazingdb communication - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=$workspace_dir/dependencies/ \
          -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_communication_install_dir \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Blazingdb communication - make ###"
    make -j$blazingdb_communication_parallel install
    if [ $? != 0 ]; then
      exit 1
    fi
    
    echo "### Blazingdb communication - end ###"
    #END blazingdb-communication
fi

if [ $blazingdb_ral_enable == true ]; then
    #BEGIN blazingdb-ral
    echo "### Ral - start ###"
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-ral_project ]; then
        mkdir blazingdb-ral_project
    fi
    
    blazingdb_ral_project_dir=$workspace_dir/blazingdb-ral_project
    
    cd $blazingdb_ral_project_dir
    
    if [ ! -d $blazingdb_ral_branch_name ]; then
        mkdir $blazingdb_ral_branch_name
        cd $blazingdb_ral_branch_name
        git clone git@github.com:BlazingDB/blazingdb-ral.git
    fi
    
    blazingdb_ral_current_dir=$blazingdb_ral_project_dir/$blazingdb_ral_branch_name/
    
    cd $blazingdb_ral_current_dir/blazingdb-ral
    git checkout $blazingdb_ral_branch
    git pull
    git submodule update --init --recursive
    
    blazingdb_ral_install_dir=$blazingdb_ral_current_dir/install
    blazingdb_ral_build_dir=$blazingdb_ral_current_dir/blazingdb-ral/build/
    
    mkdir -p $blazingdb_ral_build_dir
    
    cd $blazingdb_ral_build_dir
    
    #TODO fix the artifacts name
    blazingdb_ral_artifact_name=testing-libgdf
    rm -rf $blazingdb_ral_artifact_name
    
    build_testing_ral="OFF"
    if [ $blazingdb_ral_tests == true ]; then
        build_testing_ral="ON"
    fi
    
    echo "### Ral - cmake ###"
    # Configure blazingdb-ral with dependencies
    CUDACXX=/usr/local/cuda-9.2/bin/nvcc cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DBUILD_TESTING=$build_testing_ral \
          -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=$workspace_dir/dependencies/ \
          -DLIBGDF_INSTALL_DIR=$libgdf_install_dir \
          -DBLAZINGDB_PROTOCOL_INSTALL_DIR=$blazingdb_protocol_install_dir \
          -DBLAZINGDB_IO_INSTALL_DIR=$blazingdb_io_install_dir \
          -DBLAZINGDB_COMMUNICATION_INSTALL_DIR=$blazingdb_communication_install_dir \
          -DCUDA_DEFINES=$blazingdb_ral_definitions \
          -DCXX_DEFINES=$blazingdb_ral_definitions \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Ral - make ###"
    make -j$blazingdb_ral_parallel
    if [ $? != 0 ]; then
      exit 1
    fi
    
    #END blazingdb-ral
    
    # Package blazingdb-ral
    cd $workspace_dir
    blazingdb_ral_artifact_name=testing-libgdf
    cp $blazingdb_ral_build_dir/$blazingdb_ral_artifact_name $output
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Ral - end ###"
fi

if [ $blazingdb_orchestrator_enable == true ]; then
    #BEGIN blazingdb-orchestrator
    echo "### Orchestrator - start ###"
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-orchestrator_project ]; then
        mkdir blazingdb-orchestrator_project
    fi
    
    blazingdb_orchestrator_project_dir=$workspace_dir/blazingdb-orchestrator_project
    
    cd $blazingdb_orchestrator_project_dir
    
    if [ ! -d $blazingdb_orchestrator_branch_name ]; then
        mkdir $blazingdb_orchestrator_branch_name
        cd $blazingdb_orchestrator_branch_name
        git clone git@github.com:BlazingDB/blazingdb-orchestrator.git
    fi
    
    blazingdb_orchestrator_current_dir=$blazingdb_orchestrator_project_dir/$blazingdb_orchestrator_branch_name/
    
    cd $blazingdb_orchestrator_current_dir/blazingdb-orchestrator
    git checkout $blazingdb_orchestrator_branch
    git pull
    
    blazingdb_orchestrator_install_dir=$blazingdb_orchestrator_current_dir/install
    blazingdb_orchestrator_build_dir=$blazingdb_orchestrator_current_dir/blazingdb-orchestrator/build/
    
    mkdir -p $blazingdb_orchestrator_build_dir
    cd $blazingdb_orchestrator_build_dir
    
    #TODO fix the artifacts name
    blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
    rm -f $blazingdb_orchestrator_artifact_name
    
    # TODO percy FIX orchestrator
    #-DBLAZINGDB_PROTOCOL_INSTALL_DIR=$blazingdb_protocol_install_dir \
    # -DFLATBUFFERS_INSTALL_DIR=$flatbuffers_install_dir \
    # -DGOOGLETEST_INSTALL_DIR=$googletest_install_dir \
    echo "### Orchestrator - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE  \
          -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=$workspace_dir/dependencies/ \
          -DBLAZINGDB_PROTOCOL_INSTALL_DIR=$blazingdb_protocol_install_dir \
          -DBLAZINGDB_COMMUNICATION_INSTALL_DIR=$blazingdb_communication_install_dir \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Orchestrator - make ###"
    make -j$blazingdb_orchestrator_parallel
    if [ $? != 0 ]; then
      exit 1
    fi
    
    #END blazingdb-orchestrator
    
    # Package blazingdb-orchestrator
    cd $workspace_dir
    blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
    cp $blazingdb_orchestrator_build_dir/$blazingdb_orchestrator_artifact_name $output

    echo "### Orchestrator - end ###"
fi

if [ $blazingdb_calcite_enable == true ]; then
    #BEGIN blazingdb-calcite
    echo "### Calcite - start ###"
    
    cd $workspace_dir
    
    if [ ! -d blazingdb-calcite_project ]; then
        mkdir blazingdb-calcite_project
    fi
    
    blazingdb_calcite_project_dir=$workspace_dir/blazingdb-calcite_project
    
    cd $blazingdb_calcite_project_dir
    
    if [ ! -d $blazingdb_calcite_branch_name ]; then
        mkdir $blazingdb_calcite_branch_name
        cd $blazingdb_calcite_branch_name
        git clone git@github.com:BlazingDB/blazingdb-calcite.git
    fi
    
    blazingdb_calcite_current_dir=$blazingdb_calcite_project_dir/$blazingdb_calcite_branch_name/
    
    cd $blazingdb_calcite_current_dir/blazingdb-calcite
    git checkout $blazingdb_calcite_branch
    git pull
    
    blazingdb_calcite_install_dir=$blazingdb_calcite_current_dir/install
    
    echo "### Calcite - mvn clean install ###"
    mvn clean install -Dmaven.test.skip=true
    if [ $? != 0 ]; then
      exit 1
    fi

    blazingdb_calcite_build_dir=$blazingdb_calcite_current_dir/blazingdb-calcite/blazingdb-calcite-application/target/
    
    #END blazingdb-calcite
    
    # Package blazingdb-calcite
    cd $workspace_dir
    blazingdb_calcite_artifact_name=BlazingCalcite.jar
    cp $blazingdb_calcite_build_dir/$blazingdb_calcite_artifact_name ${output}

    echo "### Calcite - end ###"
fi

if [ $pyblazing_enable == true ]; then
    #BEGIN pyblazing
    echo "### Pyblazing - start ###"
    
    cd $workspace_dir
    
    if [ ! -d pyblazing_project ]; then
        mkdir pyblazing_project
    fi
    
    pyblazing_project_dir=$workspace_dir/pyblazing_project
    
    cd $pyblazing_project_dir
    
    if [ ! -d $pyblazing_branch_name ]; then
        mkdir $pyblazing_branch_name
        cd $pyblazing_branch_name
        git clone git@github.com:BlazingDB/pyBlazing.git
    fi
    
    pyblazing_current_dir=$pyblazing_project_dir/$pyblazing_branch_name/
    
    cd $pyblazing_current_dir/pyBlazing
    git checkout $pyblazing_branch
    git pull
    
    pyblazing_install_dir=$pyblazing_current_dir/install
    
    #END pyblazing
    
    # Package PyBlazing
    cd $workspace_dir
    mkdir -p ${output}/pyBlazing/
    cp -r $pyblazing_current_dir/pyBlazing/* ${output}/pyBlazing/
    if [ $? != 0 ]; then
      exit 1
    fi

    rm -rf ${output}/pyBlazing/.git/
    echo "### Pyblazing - end ###"
fi

# Final step: compress files and delete temp folder

cd $output_dir && tar czf blazingsql-files.tar.gz blazingsql-files/

if [ -d $output ]; then
    echo "###################### BUILT STATUS #####################"
    if [ $blazingdb_ral_enable == true ]; then
        if [ -f $output/testing-libgdf ]; then
            echo "RAL - built OK."
        else
            echo "RAL - compiled with errors."
        fi
    fi

    if [ $blazingdb_orchestrator_enable == true ]; then
        if [ -f $output/blazingdb_orchestator_service ]; then
            echo "ORCHESTRATOR - built OK."
        else
            echo "ORCHESTRATOR - compiled with errors."
        fi
    fi

    if [ $blazingdb_calcite_enable == true ]; then
        if [ -f $output/BlazingCalcite.jar ]; then
            echo "CALCITE - built OK."
        else
            echo "CALCITE - compiled with errors."
        fi
    fi
fi

rm -rf ${output}

cd $working_directory

echo "######################## SUMMARY ########################"

if [ $cudf_enable == true ]; then
    echo "CUDF: "
    cudf_dir=$workspace_dir/cudf_project/$cudf_branch_name/cudf
    cd $cudf_dir
    cudf_commit=$(git log | head -n 1)
    echo '      '$cudf_commit
    echo '      '"branch "$cudf_branch_name
fi

if [ $blazingdb_protocol_enable == true ]; then
    echo "PROTOCOL: "
    protocol_dir=$workspace_dir/blazingdb-protocol_project/$blazingdb_protocol_branch_name/blazingdb-protocol
    cd $protocol_dir
    protocol_commit=$(git log | head -n 1)
    echo '      '$protocol_commit
    echo '      '"branch "$blazingdb_protocol_branch_name
fi

if [ $blazingdb_io_enable == true ]; then
    echo "BLAZING-IO: "
    io_dir=$workspace_dir/blazingdb-io_project/$blazingdb_io_branch_name/blazingdb-io
    cd $io_dir
    io_commit=$(git log | head -n 1)
    echo '      '$io_commit
    echo '      '"branch "$blazingdb_io_branch_name
fi

if [ $blazingdb_communication_enable == true ]; then
    echo "COMMUNICATION: "
    communication_dir=$workspace_dir/blazingdb-communication_project/$blazingdb_communication_branch_name/blazingdb-communication
    cd $communication_dir
    communication_commit=$(git log | head -n 1)
    echo '      '$communication_commit
    echo '      '"branch "$blazingdb_communication_branch_name
fi

if [ $blazingdb_ral_enable == true ]; then
    echo "RAL: "
    ral_dir=$workspace_dir/blazingdb-ral_project/$blazingdb_ral_branch_name/blazingdb-ral
    cd $ral_dir
    ral_commit=$(git log | head -n 1)
    echo '      '$ral_commit
    echo '      '"branch "$blazingdb_ral_branch_name
fi

if [ $blazingdb_orchestrator_enable == true ]; then
    echo "ORCHESTRATOR: "
    orch_dir=$workspace_dir/blazingdb-orchestrator_project/$blazingdb_orchestrator_branch_name/blazingdb-orchestrator
    cd $orch_dir
    orch_commit=$(git log | head -n 1)
    echo '      '$orch_commit
    echo '      '"branch "$blazingdb_orchestrator_branch_name
fi

if [ $blazingdb_calcite_enable == true ]; then
    echo "CALCITE: "
    calcite_dir=$workspace_dir/blazingdb-calcite_project/$blazingdb_calcite_branch_name/blazingdb-calcite
    cd $calcite_dir
    calcite_commit=$(git log | head -n 1)
    echo '      '$calcite_commit
    echo '      '"branch "$blazingdb_calcite_branch_name
fi

if [ $pyblazing_enable == true ]; then
    echo "PYBLAZING: "
    pyblazing_dir=$workspace_dir/pyblazing_project/$pyblazing_branch_name/pyBlazing
    cd $pyblazing_dir
    pyblazing_commit=$(git log | head -n 1)
    echo '      '$pyblazing_commit
    echo '      '"branch "$pyblazing_branch_name
fi

echo "##########################################################"

#END main
