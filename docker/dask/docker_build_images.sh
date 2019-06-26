#!/bin/bash

echo "### calcite_orchestrator ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/blazingdb_orchestator_service
cp -f blazingsql-files/blazingdb_orchestator_service calcite_orchestrator/

tar -xvf blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar
cp -f blazingsql-files/BlazingCalcite.jar calcite_orchestrator/

echo "### ral_pyblazing ###"
cp -f blazingsql-files.tar.gz ral_pyblazing/

echo "### docker build ###"
docker-compose build
