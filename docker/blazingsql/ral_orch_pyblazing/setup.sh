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

# Install libhdfs3
cp -r $blazingsql_files/libhdfs3/* /usr/lib/

# Install UCX
cp -r $blazingsql_files/ucx/*.so* /usr/lib/

# Install rmm (from nvstrings)
cp -f $blazingsql_files/nvstrings-build/rmm/*.so /conda/envs/cudf/lib/

# Install nvstrings (custrings)
cp -f $blazingsql_files/nvstrings-build/*.so /conda/envs/cudf/lib/
cp -rf $blazingsql_files/nvstrings/include/* /conda/envs/cudf/include/

echo "Installing custrings ..."
working_directory_tmp=$PWD
cd $blazingsql_files/nvstrings-src/python/
rm -rf $blazingsql_files/nvstrings-src/python/build/
python setup.py install
cd $working_directory_tmp
echo "custrings DONE"

# Install libgdf_cffi
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/python/libgdf_cffi/libgdf_build.py
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $cudf_dir/$libgdf_dir/thirdparty/rmm/python/librmm_cffi/librmm_build.py

pip install $cudf_dir/$libgdf_dir/python
RMM_HEADER=/tmp/blazing/blazingsql-files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h pip install $cudf_dir/thirdparty/rmm/python

# Install cudf
CFLAGS="-I/conda/envs/cudf/include -I$cudf_dir/thirdparty/dlpack/include/dlpack -I$cudf_dir/thirdparty/dlpack/include/" CXXFLAGS="-I/conda/envs/cudf/include -I$cudf_dir/thirdparty/dlpack/include/dlpack -I$cudf_dir/thirdparty/dlpack/include/" pip install $cudf_dir/python

# Install blazingsql
blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service

cp $blazingsql_files/$blazingdb_ral_artifact_name /home/jupyter
cp $blazingsql_files/$blazingdb_orchestrator_artifact_name /home/jupyter

# Install blazingdb-protocol/python
pip install $blazingsql_files/blazingdb-protocol/python/

# Install pyblazing
pip install $blazingsql_files/pyBlazing

cd $working_directory
