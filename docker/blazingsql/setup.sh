#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

source activate cudf

# Install libgdf
cudf_dir=$blazingsql_files/cudf
libgdf_dir=cpp

cp $cudf_dir/$libgdf_dir/install/lib/libcudf.so /conda/envs/cudf/lib/
cp $cudf_dir/$libgdf_dir/install/lib/librmm.so /conda/envs/cudf/lib/
cp $cudf_dir/$libgdf_dir/install/lib/libcudf.so /usr/lib/
cp $cudf_dir/$libgdf_dir/install/lib/librmm.so /usr/lib/
cp /conda/envs/cudf/lib/libNVStrings.so /usr/lib/

# Install libgdf
cp -r $cudf_dir/$libgdf_dir/install/* /usr/

# Install libgdf_cffi
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/python/libgdf_cffi/libgdf_build.py
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/python/librmm_cffi/librmm_build.py

pip install $cudf_dir/$libgdf_dir/python

# Install cudf
pip install $cudf_dir/python

# Install blazingsql
blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

# Install jzmq & zeromq
cp -r $blazingsql_files/jzmq /usr/lib
cp -r $blazingsql_files/zeromq/* /usr/lib

cp $blazingsql_files/$blazingdb_ral_artifact_name /usr/bin
cp $blazingsql_files/$blazingdb_orchestrator_artifact_name /usr/bin
cp $blazingsql_files/$blazingdb_calcite_artifact_name /usr/bin

# Install blazingdb-protocol/python
pip install $blazingsql_files/blazingdb-protocol/python/

# Install pyblazing
pip install $blazingsql_files/pyBlazing

cd $working_directory
