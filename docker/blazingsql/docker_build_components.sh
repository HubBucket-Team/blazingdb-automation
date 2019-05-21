#!/bin/bash

echo "### Calcite ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar
cp -f blazingsql-files/BlazingCalcite.jar calcite/
#docker build -t blazingdb/blazingsql:calcite calcite/

echo "### Orchestrator ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/blazingdb_orchestator_service
cp -f blazingsql-files/blazingdb_orchestator_service orchestator/
#docker build -t blazingdb/blazingsql:orchestator orchestator/

echo "### Ral ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/libcudf.so 
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/librmm.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVCategory.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVStrings.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/testing-libgdf
cp -rf ./blazingsql-files/ ral/
#docker build -t blazingdb/blazingsql:ral ral/

echo "### Pyblazing ###"
cp -rf data/ pyblazing/
cp -rf notebooks/ pyblazing/
cp -f blazingsql-files.tar.gz pyblazing/
#docker build -t blazingdb/blazingsql:pyblazing pyblazing/

echo "### Docker build ###"
docker-compose build
