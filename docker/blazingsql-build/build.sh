#!/bin/bash

workspace=/home/builder/src
output=/home/builder/output/blazingsql-files

function build_blazingsql() {
    
    #TODO this version works only for eclipse projects, use if build folder exists


    echo "Cloning the image"
    cd ${workspace}
    # BLAZINGDB-PROTOCOL: java
    git clone git@github.com:BlazingDB/blazingdb-protocol.git
    cd ${workspace}/blazingdb-protocol && git checkout develop
    cd ${workspace}/blazingdb-protocol/java && mvn clean install
    
    #BLAZINGDB-PROTOCOL: Python
    cd ${workspace}/blazingdb-protocol/python && python3 setup.py install --user

    # BLAZINGDB-RAL
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-ral.git
    cd  ${workspace}/blazingdb-ral && git checkout feature/testdata-generator
    mkdir ${workspace}/blazingdb-ral/build && cd ${workspace}/blazingdb-ral/build
    cmake .. && make -j4

    # BLAZINGDB-ORCHESTRATOR
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-orchestrator.git
    cd  ${workspace}/blazingdb-orchestrator 
    mkdir ${workspace}/blazingdb-orchestrator/build && cd ${workspace}/blazingdb-orchestrator/build
    cmake .. && make -j8

    # BLAZINGDB-CALCITE
    cd ${workspace}
    git clone git@github.com:BlazingDB/blazingdb-calcite.git
    sudo mkdir /blazingsql
    cd ${workspace}/blazingdb-calcite
    mvn clean install -Dmaven.test.skip=true
    
    # pyBlazing
    cd ${workspace}
    git clone git@github.com:BlazingDB/pyBlazing.git
    cd ${workspace}/pyBlazing && git checkout develop


}

function zip_files() {
    
    
    mkdir -p ${output}/libgdf_cffi
    mkdir -p ${output}/blazingdb-protocol/python/

    cp $workspace/blazingdb-ral/build/testing-libgdf ${output}


    cp -r $workspace/blazingdb-ral/build/CMakeFiles/thirdparty/libgdf-src/python/* $output/libgdf_cffi/
    cp -r $workspace/blazingdb-ral/build/CMakeFiles/thirdparty/libgdf-install/* $output/libgdf_cffi/
    rm -rf $output/libgdf_cffi/lib/libgdf.a

    cp $workspace/blazingdb-orchestrator/build/blazingdb_orchestator_service ${output}
    cp $workspace/blazingdb-calcite/blazingdb-calcite-application/target/BlazingCalcite.jar ${output}

    cp -r $workspace/blazingdb-protocol/python/* $output/blazingdb-protocol/python/
    rm -rf ${output}/pyBlazing/.git/

    cp -r $workspace/pyBlazing/ ${output}/
    rm -rf ${output}/pyBlazing/.git/

    # compress files and delete temp folder
    cd /home/builder/output/ && tar czvf blazingsql-files.tar.gz blazingsql-files/
    rm -rf ${output}
}

#BEGIN MAIN

if [ -z "$(ls -A ${workspace})" ]; then
    build_blazingsql
    zip_files
else
    zip_files
fi

#END MAIN
