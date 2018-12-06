#!/bin/bash

# NOTE you need to have the blazingsql-build.properties file inside the workspace_dir
workspace_dir=$1
output_dir=$2

# Expand args to absolute/full paths (if the user pass relative paths as args)
workspace_dir=$(readlink -f $workspace_dir)
output_dir=$(readlink -f $output_dir)

output=$output_dir/blazingsql-files

mkdir -p $output 

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
    blazingdb_protocol_enable=true
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
    blazingdb_protocol_parallel=4
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
    blazingdb_protocol_tests=false
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
blazingdb_ral_branch_name=$(normalize_branch_name $blazingdb_ral_branch)
blazingdb_orchestrator_branch_name=$(normalize_branch_name $blazingdb_orchestrator_branch)
blazingdb_calcite_branch_name=$(normalize_branch_name $blazingdb_calcite_branch)
pyblazing_branch_name=$(normalize_branch_name $pyblazing_branch)

cd $workspace_dir

#BEGIN dependencies

if [ ! -d dependencies ]; then
    mkdir dependencies
fi

#BEGIN nvstrings

nvstrings_package=nvstrings-0.0.3-cuda9.2_py35_0
nvstrings_install_dir=$workspace_dir/dependencies/$nvstrings_package

if [ ! -d $nvstrings_install_dir ]; then
    cd $workspace_dir/dependencies/
    nvstrings_url=https://anaconda.org/nvidia/nvstrings/0.0.3/download/linux-64/"$nvstrings_package".tar.bz2
    wget $nvstrings_url
    mkdir $nvstrings_package
    tar xvf "$nvstrings_package".tar.bz2 -C $nvstrings_package
fi

#END nvstrings

#BEGIN googletest

googletest_install_dir=$workspace_dir/dependencies/googletest_install_dir

if [ ! -d $googletest_install_dir ]; then
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/googletest.git
    cd $workspace_dir/dependencies/googletest
    git checkout release-1.8.0

    googletest_build_dir=$workspace_dir/dependencies/googletest/build/
    mkdir -p $googletest_build_dir
    cd $googletest_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$googletest_install_dir \
          -Dgtest_build_samples=ON \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          ..
    make -j4 install
fi

#END googletest

#BEGIN flatbuffers

flatbuffers_install_dir=$workspace_dir/dependencies/flatbuffers_install_dir

if [ ! -d $flatbuffers_install_dir ]; then
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/flatbuffers.git
    cd $workspace_dir/dependencies/flatbuffers
    git checkout 02a7807dd8d26f5668ffbbec0360dc107bbfabd5

    flatbuffers_build_dir=$workspace_dir/dependencies/flatbuffers/build/

    mkdir -p $flatbuffers_build_dir
    cd $flatbuffers_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$flatbuffers_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          ..
    make -j4 install
fi

#END flatbuffers

#BEGIN arrow

arrow_install_dir=$workspace_dir/dependencies/arrow_install_dir

if [ ! -d $arrow_install_dir ]; then
    cd $workspace_dir/dependencies/
    git clone https://github.com/apache/arrow.git
    cd $workspace_dir/dependencies/arrow
    git checkout apache-arrow-0.11.1

    arrow_build_dir=$workspace_dir/dependencies/arrow/cpp/build/
    
    mkdir -p $arrow_build_dir
    cd $arrow_build_dir
    
    # NOTE for the arrow cmake arguments:
    # -DARROW_IPC=ON \ # need ipc for blazingdb-ral (because cudf)
    # -DARROW_HDFS=ON \ # disable when blazingdb-io don't use arrow for hdfs
    # -DARROW_TENSORFLOW=ON \ # enable old ABI for C/C++
    # -DARROW_PARQUET=OFF \ # we don't need parquet for blazingdb-
    
    # If you enable ARROW_BOOST_USE_SHARED=ON and have ARROW_BOOST_USE_SHARED=OFF then will fail:
    # /usr/bin/ld: /usr/lib/x86_64-linux-gnu/libboost_system.a(error_code.o): relocation
    # R_X86_64_32 against `.rodata.str1.1' can not be used when making a shared object; recompile with -fPIC
    # /usr/lib/x86_64-linux-gnu/libboost_system.a: error adding symbols: Bad value
    
    FLATBUFFERS_HOME=$flatbuffers_install_dir cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=$arrow_install_dir \
        -DARROW_WITH_LZ4=ON \
        -DARROW_WITH_ZSTD=ON \
        -DARROW_WITH_BROTLI=ON \
        -DARROW_WITH_SNAPPY=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_BUILD_STATIC=ON \
        -DARROW_BUILD_SHARED=OFF \
        -DARROW_BOOST_USE_SHARED=OFF \
        -DARROW_BUILD_TESTS=OFF \
        -DARROW_TEST_MEMCHECK=OFF \
        -DARROW_BUILD_BENCHMARKS=OFF \
        -DARROW_IPC=ON \
        -DARROW_COMPUTE=ON \
        -DARROW_GPU=OFF \
        -DARROW_JEMALLOC=OFF \
        -DARROW_BOOST_VENDORED=OFF \
        -DARROW_PYTHON=OFF \
        -DARROW_HDFS=ON \
        -DARROW_TENSORFLOW=ON \
        -DARROW_PARQUET=ON \
        ..
    make -j4 install
fi

#END arrow

#BEGIN aws-sdk-cpp

aws_sdk_cpp_build_dir=$workspace_dir/dependencies/aws-sdk-cpp/build

if [ ! -d $aws_sdk_cpp_build_dir ]; then
    cd $workspace_dir/dependencies/
    git clone https://github.com/aws/aws-sdk-cpp.git
    cd $workspace_dir/dependencies/aws-sdk-cpp
    git checkout 864eb0bca8b48427f94850b7a8311ef0ae0f433b

    mkdir -p $aws_sdk_cpp_build_dir
    cd $aws_sdk_cpp_build_dir
    
    # NOTE we only need core, s3 and s3-encryption, also we don't need to install this package
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_ONLY="core;s3;s3-encryption" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTING=OFF \
        -DENABLE_UNITY_BUILD=ON \
        -DCUSTOM_MEMORY_MANAGEMENT=0 \
        -DCPP_STANDARD=14 \
        -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
        -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
        ..
    make -j4
fi

#END aws-sdk-cpp

#END dependencies

if [ $cudf_enable == true ]; then
    #BEGIN cudf
    
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
    
    #TODO percy felipe : remove this line when nvidia fix the current state of ptx build
    echo "Patch cudf CMakeLists.txt"
    git checkout $cudf_current_dir/cudf/$libgdf_dir/CMakeLists.txt
    sed -i 's/-Xptxas/-Xptxas --maxrregcount=48/g' $cudf_current_dir/cudf/$libgdf_dir/CMakeLists.txt
    cat $cudf_current_dir/cudf/$libgdf_dir/CMakeLists.txt
    
    libgdf_build_dir=$cudf_current_dir/cudf/$libgdf_dir/build/

    mkdir -p $libgdf_build_dir
    cd $libgdf_build_dir
    CUDACXX=/usr/local/cuda-9.2/bin/nvcc NVSTRINGS_ROOT=$nvstrings_install_dir cmake  \
        -DCMAKE_BUILD_TYPE=Release  \
        -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir  \
        ..
    make -j$cudf_parallel install
    
    #TODO remove this patch once cudf can install rmm
    cp $cudf_current_dir/cudf/$libgdf_dir/src/rmm/memory.h $libgdf_install_dir/include
    cp $cudf_current_dir/cudf/$libgdf_dir/src/rmm/rmm.h $libgdf_install_dir/include
    
    #END cudf
    
    # Package cudf
    cd $workspace_dir
    mkdir -p ${output}/cudf/$libgdf_dir/install
    cp -r $cudf_current_dir/cudf/* ${output}/cudf/
    cp -r $libgdf_install_dir/* ${output}/cudf/$libgdf_dir/install
    rm -rf ${output}/cudf/.git/
    rm -rf ${output}/cudf/$libgdf_dir/build/src
    rm -rf ${output}/cudf/$libgdf_dir/build/Testing
    rm -rf ${output}/cudf/$libgdf_dir/build/CMakeFiles
fi

if [ $blazingdb_protocol_enable == true ]; then
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
    rm -rf lib/$blazingdb_ral_artifact_name
    
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DFLATBUFFERS_INSTALL_DIR=$flatbuffers_install_dir \
          -DGOOGLETEST_INSTALL_DIR=$googletest_install_dir \
          -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          ..
    make -j$blazingdb_protocol_parallel install
    
    cd $blazingdb_protocol_current_dir/blazingdb-protocol/java
    mvn clean install -Dmaven.test.skip=true
    blazingdb_protocol_java_build_dir=$blazingdb_protocol_current_dir/blazingdb-protocol/java/target/
    
    #END blazingdb-protocol
    
    # Package blazingdb-protocol/python
    cd $workspace_dir
    mkdir -p $output/blazingdb-protocol/python/
    cp -r $blazingdb_protocol_current_dir/blazingdb-protocol/python/* $output/blazingdb-protocol/python/
fi

if [ $blazingdb_io_enable == true ]; then
    #BEGIN blazingdb-io
    
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
    rm -rf $blazingdb_ral_artifact_name
    
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DAWS_SDK_CPP_BUILD_DIR=${aws_sdk_cpp_build_dir} \
          -DARROW_INSTALL_DIR=${arrow_install_dir} \
          -DGOOGLETEST_INSTALL_DIR=$googletest_install_dir \
          -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_io_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          ..
    make -j$blazingdb_io_parallel install
    
    #END blazingdb-io
fi

if [ $blazingdb_ral_enable == true ]; then
    #BEGIN blazingdb-ral
    
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
    rm -f $blazingdb_ral_artifact_name
    
    CUDACXX=/usr/local/cuda-9.2/bin/nvcc cmake -DCMAKE_BUILD_TYPE=Release \
          -DNVSTRINGS_INSTALL_DIR=$nvstrings_install_dir \
          -DLIBGDF_INSTALL_DIR=$libgdf_install_dir \
          -DFLATBUFFERS_INSTALL_DIR=$flatbuffers_install_dir \
          -DARROW_INSTALL_DIR=$arrow_install_dir \
          -DAWS_SDK_CPP_BUILD_DIR=${aws_sdk_cpp_build_dir} \
          -DBLAZINGDB_PROTOCOL_INSTALL_DIR=$blazingdb_protocol_install_dir \
          -DBLAZINGDB_IO_INSTALL_DIR=$blazingdb_io_install_dir \
          -DGOOGLETEST_INSTALL_DIR=$googletest_install_dir \
          ..
    make -j$blazingdb_ral_parallel
    
    #END blazingdb-ral
    
    # Package blazingdb-ral
    cd $workspace_dir
    blazingdb_ral_artifact_name=testing-libgdf
    cp $blazingdb_ral_build_dir/$blazingdb_ral_artifact_name $output
fi

if [ $blazingdb_orchestrator_enable == true ]; then
    #BEGIN blazingdb-orchestrator
    
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
    cmake -DCMAKE_BUILD_TYPE=Release \
          ..
    make -j$blazingdb_orchestrator_parallel
    
    #END blazingdb-orchestrator
    
    # Package blazingdb-orchestrator
    cd $workspace_dir
    blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
    cp $blazingdb_orchestrator_build_dir/$blazingdb_orchestrator_artifact_name $output
fi

if [ $blazingdb_calcite_enable == true ]; then
    #BEGIN blazingdb-calcite
    
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
    
    mvn clean install -Dmaven.test.skip=true
    blazingdb_calcite_build_dir=$blazingdb_calcite_current_dir/blazingdb-calcite/blazingdb-calcite-application/target/
    
    #END blazingdb-calcite
    
    # Package blazingdb-calcite
    cd $workspace_dir
    blazingdb_calcite_artifact_name=BlazingCalcite.jar
    cp $blazingdb_calcite_build_dir/$blazingdb_calcite_artifact_name ${output}
fi

if [ $pyblazing_enable == true ]; then
    #BEGIN pyblazing
    
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
    rm -rf ${output}/pyBlazing/.git/
fi

# Final step: compress files and delete temp folder
cd $output_dir && tar czf blazingsql-files.tar.gz blazingsql-files/
rm -rf ${output}

cd $working_directory

#END main
