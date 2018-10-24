#!/bin/bash
working_directory=$PWD

blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

# install libgdf and libgdf_cffi
cp libgdf_cffi/lib/libgdf.so /conda/envs/gdf/lib/
cd libgdf_cffi/
cp /tmp/blazing/libgdf_cffi/meta.yaml .
cp /tmp/blazing/libgdf_cffi/build.sh .
echo "replacing libgdf_cffi"
source activate gdf && conda-build .
pip install .
echo "libgdf_cffi is ready!"

# install blazingsql
cd $blazingsql_files
cp testing-libgdf /usr/bin
cp blazingdb_orchestator_service /usr/bin
cp BlazingCalcite.jar /usr/bin

# install pyblazing
cd blazingdb-protocol/python/
pip install .

cd $blazingsql_files
cd pyBlazing
pip install .

cd $working_directory
