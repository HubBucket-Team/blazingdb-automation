#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/
echo "Decompressing blazingsql-files.tar.gz ..."
tar xf blazingsql-files.tar.gz
echo "blazingsql-files.tar.gz was decompressed at /tmp/blazing/"

cd $blazingsql_files

source activate cudf

# Install libgdf
cudf_dir=$blazingsql_files/cudf
libgdf_dir=cpp

cp $cudf_dir/$libgdf_dir/install/lib/libcudf.so /conda/envs/cudf/lib/
cp $cudf_dir/$libgdf_dir/install/lib/librmm.so /conda/envs/cudf/lib/

# Install libgdf
cp -r $cudf_dir/$libgdf_dir/install/* /conda/envs/cudf/

# Install 
cp $blazingsql_files/nvstrings/lib/libNVStrings.so /conda/envs/cudf/lib/

# Install libhdfs3
cp -r $blazingsql_files/libhdfs3/* /usr/lib

# Install libgdf_cffi
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/python/libgdf_cffi/libgdf_build.py
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/python/librmm_cffi/librmm_build.py

pip install $cudf_dir/$libgdf_dir/python
RMM_HEADER=/tmp/blazing/blazingsql-files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h  pip install $cudf_dir/thirdparty/rmm/python

# Install cudf
CFLAGS=-I/conda/envs/cudf/include CXXFLAGS=-I/conda/envs/cudf/include pip install $cudf_dir/python

# Install blazingsql
blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

# Install jzmq & zeromq
cp -r $blazingsql_files/jzmq /home/jupyter/lib
cp -r $blazingsql_files/zeromq/* /home/jupyter/lib

cp $blazingsql_files/$blazingdb_ral_artifact_name /home/jupyter
cp $blazingsql_files/$blazingdb_orchestrator_artifact_name /home/jupyter
cp $blazingsql_files/$blazingdb_calcite_artifact_name /home/jupyter

# Install blazingdb-protocol/python
pip install $blazingsql_files/blazingdb-protocol/python/

# Install pyblazing
pip install $blazingsql_files/pyBlazing

cd $working_directory
