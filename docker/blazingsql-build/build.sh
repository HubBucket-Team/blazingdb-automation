#!/bin/bash

workspace_dir=/home/builder/workspace
output=/home/builder/output/blazingsql-files

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
blazingdb_ral_branch_name=$(normalize_branch_name $blazingdb_ral_branch)
blazingdb_orchestrator_branch_name=$(normalize_branch_name $blazingdb_orchestrator_branch)
blazingdb_calcite_branch_name=$(normalize_branch_name $blazingdb_calcite_branch)
pyblazing_branch_name=$(normalize_branch_name $pyblazing_branch)

cd $workspace_dir

if [ ! -d dependencies ]; then
    mkdir dependencies
fi

if [ $cudf_enable == true ]; then
    #BEGIN nvstrings
    
    cd dependencies
    
    nvstrings_package=nvstrings-0.0.3-cuda9.2_py35_0
    nvstrings_url=https://anaconda.org/nvidia/nvstrings/0.0.3/download/linux-64/"$nvstrings_package".tar.bz2
    
    if [ ! -d $nvstrings_package ]; then
        wget $nvstrings_url
        mkdir $nvstrings_package
        tar xvf "$nvstrings_package".tar.bz2 -C $nvstrings_package
    fi
    
    nvstrings_install_dir=$workspace_dir/dependencies/$nvstrings_package
    
    #END nvstrings
    
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
    
    cd $cudf_current_dir/cudf/$libgdf_dir
    
    if [ ! -d build ]; then
        mkdir build
        cd build
        NVSTRINGS_ROOT=$nvstrings_install_dir cmake -DCMAKE_CUDA_FLAGS="-Xptxas" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir ..
    fi
    
    libgdf_build_dir=$cudf_current_dir/cudf/$libgdf_dir/build/
    cd $libgdf_build_dir
    NVSTRINGS_ROOT=$nvstrings_install_dir cmake -DCMAKE_CUDA_FLAGS="-Xptxas" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$libgdf_install_dir ..
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
    
    if [ ! -d build ]; then
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir ..
    fi
    
    blazingdb_protocol_cpp_build_dir=$blazingdb_protocol_current_dir/blazingdb-protocol/cpp/build/
    cd $blazingdb_protocol_cpp_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=$blazingdb_protocol_install_dir ..
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
    
    if [ ! -d build ]; then
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DNVSTRINGS_HOME=$nvstrings_install_dir -DLIBGDF_HOME=$libgdf_install_dir -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
    fi
    
    blazingdb_ral_build_dir=$blazingdb_ral_current_dir/blazingdb-ral/build/
    cd $blazingdb_ral_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release -DNVSTRINGS_HOME=$nvstrings_install_dir -DLIBGDF_HOME=$libgdf_install_dir -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
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
    
    if [ ! -d build ]; then
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
    fi
    
    blazingdb_orchestrator_build_dir=$blazingdb_orchestrator_current_dir/blazingdb-orchestrator/build/
    cd $blazingdb_orchestrator_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release -DBLAZINGDB_PROTOCOL_HOME=$blazingdb_protocol_install_dir ..
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
cd /home/builder/output/ && tar czvf blazingsql-files.tar.gz blazingsql-files/
rm -rf ${output}

cd $working_directory

#END main
