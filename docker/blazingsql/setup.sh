#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

source activate cudf

# Install libgdf
cudf_dir=$blazingsql_files/cudf

#TODO change this to cpp for cudf >= 0.3.0
libgdf_dir=libgdf

cp $cudf_dir/$libgdf_dir/install/lib/libgdf.so /conda/envs/cudf/lib/
cp $cudf_dir/$libgdf_dir/install/lib/librmm.so /conda/envs/cudf/lib/
cp $cudf_dir/$libgdf_dir/install/lib/libgdf.so /usr/lib/
cp $cudf_dir/$libgdf_dir/install/lib/librmm.so /usr/lib/
cp /conda/envs/cudf/lib/libNVStrings.so /usr/lib/

# Install libgdf_cffi
cp -r $cudf_dir/$libgdf_dir/install/* $cudf_dir/libgdf/python
pip install $cudf_dir/libgdf/python

# Install cudf
pip install $cudf_dir

# Install blazingsql
blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files/$blazingdb_ral_artifact_name /usr/bin
cp $blazingsql_files/$blazingdb_orchestrator_artifact_name /usr/bin
cp $blazingsql_files/$blazingdb_calcite_artifact_name /usr/bin

# Install blazingdb-protocol/python
pip install $blazingsql_files/blazingdb-protocol/python/

# Install pyblazing
pip install $blazingsql_files/pyBlazing

cd $working_directory
