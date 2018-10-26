#!/bin/bash

workspace=/home/builder/src
output=/home/builder/output/blazingsql-files

# this function build the stack
function build_blazingsql() {
    cd ${workspace}

    # blazingdb-protocol
    git clone git@github.com:BlazingDB/blazingdb-protocol.git
    cd ${workspace}/blazingdb-protocol && git checkout develop
    cd ${workspace}/blazingdb-protocol/java && mvn clean install

    # blazingdb-ral
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-ral.git
    cd  ${workspace}/blazingdb-ral && git checkout feature/testdata-generator
    mkdir ${workspace}/blazingdb-ral/build && cd ${workspace}/blazingdb-ral/build
    cmake .. && make -j4

    # blazingdb-orchestrator
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-orchestrator.git
    cd  ${workspace}/blazingdb-orchestrator 
    mkdir ${workspace}/blazingdb-orchestrator/build && cd ${workspace}/blazingdb-orchestrator/build
    cmake .. && make -j8

    # blazingdb-calcite
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-calcite.git
    sudo mkdir /blazingsql
    cd ${workspace}/blazingdb-calcite
    mvn clean install -Dmaven.test.skip=true

    # PyBlazing
    cd ${workspace}
    git clone git@github.com:BlazingDB/pyBlazing.git
    cd ${workspace}/pyBlazing && git checkout develop
}

# this function just read the content of /home/builder/src and copy the binary files
function zip_files() {
    mkdir -p ${output}/libgdf_cffi
    mkdir -p ${output}/blazingdb-protocol/python/

    # Package blazingdb-ral
    cp $workspace/blazingdb-ral/build/testing-libgdf ${output}

    # Package libgdf and libgdf_cffi from blazingdb-ral
    cp -r $workspace/blazingdb-ral/build/CMakeFiles/thirdparty/libgdf-src/python/* $output/libgdf_cffi/
    cp -r $workspace/blazingdb-ral/build/CMakeFiles/thirdparty/libgdf-install/* $output/libgdf_cffi/
    rm -rf $output/libgdf_cffi/lib/libgdf.a

    # Package blazingdb-orchestrator
    cp $workspace/blazingdb-orchestrator/build/blazingdb_orchestator_service ${output}

    # Package blazingdb-calcite
    cp $workspace/blazingdb-calcite/blazingdb-calcite-application/target/BlazingCalcite.jar ${output}

    # Package blazingdb-protocol/python
    cp -r $workspace/blazingdb-protocol/python/* $output/blazingdb-protocol/python/

    # Package PyBlazing
    cp -r $workspace/pyBlazing/ ${output}/
    rm -rf ${output}/pyBlazing/.git/

    # compress files and delete temp folder
    cd /home/builder/output/ && tar czvf blazingsql-files.tar.gz blazingsql-files/
    rm -rf ${output}
}

#BEGIN MAIN

# if the user did'nt mount /home/builder/src then build inside the container
if [ -z "$(ls -A ${workspace})" ]; then
    build_blazingsql
    zip_files
else
    zip_files
fi

#END MAIN
