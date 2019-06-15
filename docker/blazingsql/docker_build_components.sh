#!/bin/bash
# Usage: simple blazingsql

solution=$1
component=$2

echo "### Calcite ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar
cp -f blazingsql-files/BlazingCalcite.jar calcite/
#docker build -t blazingdb/blazingsql:calcite calcite/

echo "### Orchestrator ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/blazingdb_orchestator_service
cp -f blazingsql-files/blazingdb_orchestator_service orchestator/
cp -f blazingsql-files/blazingdb_orchestator_service ral_orchestrator/
#docker build -t blazingdb/blazingsql:orchestator orchestator/

echo "### Ral ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/libcudf.so 
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/librmm.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVCategory.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVStrings.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/testing-libgdf
cp -rf ./blazingsql-files/ ral/
cp -rf ./blazingsql-files/ ral_orchestrator/
#docker build -t blazingdb/blazingsql:ral ral/

echo "### Pyblazing ###"
cp -rf data/ pyblazing/
cp -rf notebooks/ pyblazing/
cp blazingsql-files.tar.gz pyblazing/
# this is temporarily
cp -rf data/ ral_orch_pyblazing/
cp -rf notebooks/ ral_orch_pyblazing/
cp -f blazingsql-files.tar.gz ral_orch_pyblazing/
#docker build -t blazingdb/blazingsql:pyblazing pyblazing/

echo "### Ral_PyBlazing ###"
cp -rf data/ ral_pyblazing/
cp -rf notebooks/ ral_pyblazing/
cp -f blazingsql-files.tar.gz ral_pyblazing/

echo "### Simple distribution ###"
cp -rf data/ simple_distribution/
cp -rf notebooks/ simple_distribution/
cp -f blazingsql-files.tar.gz simple_distribution/

echo "### Docker build ###"
docker-compose -f docker-compose.$solution.yml build $component
