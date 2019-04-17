#!/bin/bash

echo "### Calcite ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar
mv blazingsql-files/BlazingCalcite.jar calcite/

echo "### Orchestrator ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/blazingdb_orchestator_service
mv blazingsql-files/blazingdb_orchestator_service orchestator/

echo "### Ral ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/libcudf.so 
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/librmm.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVCategory.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVStrings.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/testing-libgdf
mv ./blazingsql-files/ ral/

echo "### Pyblazing ###"
cp -rf data/ pyblazing/
cp -rf notebooks/ pyblazing/
cp blazingsql-files.tar.gz pyblazing/

echo "### Build ###"
docker-compose build

echo "### Up ###"
docker-compose -d up

echo "### Logs ###"
docker-compose logs -f
