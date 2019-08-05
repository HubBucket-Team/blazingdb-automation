#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/
echo "Decompressing blazingsql-files.tar.gz ..."
tar xf blazingsql-files.tar.gz
echo "blazingsql-files.tar.gz was decompressed at /tmp/blazing/"

cd $blazingsql_files

source activate cudf

# Install libhdfs3
cp -r $blazingsql_files/libhdfs3/* /usr/lib/

# Install UCX
#cp -r $blazingsql_files/ucx/*.so* /usr/lib/

# Install blazingsql
blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files/$blazingdb_ral_artifact_name /home/jupyter
cp $blazingsql_files/$blazingdb_orchestrator_artifact_name /home/jupyter
cp $blazingsql_files/$blazingdb_calcite_artifact_name /home/jupyter

# Install blazingdb-protocol/python
pip install $blazingsql_files/blazingdb-protocol/python/

# Install pyblazing
pip install $blazingsql_files/pyBlazing

cd $working_directory
