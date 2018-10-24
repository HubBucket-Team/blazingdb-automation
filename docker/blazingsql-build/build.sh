#!/bin/bash

function build_blazingsql() {
    #TODO
    echo "build"
}

function zip_files() {
    #TODO this version works only for eclipse projects, use if build folder exists
    workspace=/home/builder/src/
    output=/home/builder/output/blazingsql-files
    mkdir -p $output/libgdf_cffi
    mkdir -p $output/blazingdb-protocol/python/

    cp $workspace/blazingdb-ral/testing-libgdf $output

    cp -r $workspace/blazingdb-ral/CMakeFiles/thirdparty/libgdf-src/python/* $output/libgdf_cffi/
    cp -r $workspace/blazingdb-ral/CMakeFiles/thirdparty/libgdf-install/* $output/libgdf_cffi/
    rm -rf $output/libgdf_cffi/lib/libgdf.a

    cp $workspace/blazingdb-orchestrator/blazingdb_orchestator_service $output
    cp $workspace/blazingdb-calcite/blazingdb-calcite-application/target/BlazingCalcite.jar $output

    cp -r $workspace/blazingdb-protocol/python/* $output/blazingdb-protocol/python/
    rm -rf $output/pyBlazing/.git/

    cp -r $workspace/pyBlazing/ $output/
    rm -rf $output/pyBlazing/.git/

    # compress files and delete temp folder
    cd /home/builder/output/ && tar czvf blazingsql-files.tar.gz blazingsql-files/
    rm -rf $output
}

#BEGIN MAIN

if [ -z "$(ls -A /home/builder/src/)" ]; then
    build_blazingsql
    zip_files
else
    zip_files
fi

#END MAIN
