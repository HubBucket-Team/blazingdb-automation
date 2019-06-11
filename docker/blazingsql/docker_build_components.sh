#!/bin/bash

<<<<<<< HEAD
component=$1
=======
echo "### Ucx ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/ucx/
cp -rf blazingsql-files/ucx orchestator/
cp -rf blazingsql-files/ucx ral/
>>>>>>> feature/simple-distribution-tcp

echo "### Calcite ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/BlazingCalcite.jar
mv blazingsql-files/BlazingCalcite.jar calcite/
#docker build -t blazingdb/blazingsql:calcite calcite/

echo "### Orchestrator ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/blazingdb_orchestator_service
<<<<<<< HEAD
cp -f blazingsql-files/blazingdb_orchestator_service orchestator/
cp -f blazingsql-files/blazingdb_orchestator_service ral_orchestrator/
=======
mv blazingsql-files/blazingdb_orchestator_service orchestator/
>>>>>>> feature/simple-distribution-tcp
#docker build -t blazingdb/blazingsql:orchestator orchestator/


echo "### Ral ###"
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/libcudf.so 
tar -xvf blazingsql-files.tar.gz blazingsql-files/cudf/cpp/install/lib/librmm.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVCategory.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/nvstrings/lib/libNVStrings.so
tar -xvf blazingsql-files.tar.gz blazingsql-files/testing-libgdf
<<<<<<< HEAD
cp -rf ./blazingsql-files/ ral/
cp -rf ./blazingsql-files/ ral_orchestrator
=======
mv ./blazingsql-files/ ral/
>>>>>>> feature/simple-distribution-tcp
#docker build -t blazingdb/blazingsql:ral ral/

echo "### Pyblazing ###"
cp -rf data/ pyblazing/
cp -rf notebooks/ pyblazing/
cp blazingsql-files.tar.gz pyblazing/
#docker build -t blazingdb/blazingsql:pyblazing pyblazing/

echo "### Docker build ###"
docker-compose -f docker-compose.tcp.yml build $component
