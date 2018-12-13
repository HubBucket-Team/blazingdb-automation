#!/bin/bash

blazingsql_files_tar_gz_path=$1

working_directory=$PWD

temp_dir=/tmp
blazingsql_files_dir_name=blazingsql-files
working_space_name=_safe_to_remove_
working_space=/tmp/"$blazingsql_files_dir_name$working_space_name"
blazingsql_files_dir=$working_space/$blazingsql_files_dir_name

mkdir -p $working_space

echo "Decompressing blazingsql-files.tar.gz ..."
# TODO percy uncomment this when finish this script
#tar xf $blazingsql_files_tar_gz_path -C $working_space
echo "blazingsql-files.tar.gz was decompressed at $working_space"

# Creating the blazingsql python package
mkdir -p blazingsql/bin blazingsql/pyblazing blazingsql/runtime
cp -r blazingsql-template/* blazingsql

blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files_dir/$blazingdb_ral_artifact_name blazingsql/bin
cp $blazingsql_files_dir/$blazingdb_orchestrator_artifact_name blazingsql/bin
cp $blazingsql_files_dir/$blazingdb_calcite_artifact_name blazingsql/bin

cp -r $blazingsql_files_dir/blazingdb-protocol/python/blazingdb/* blazingsql/blazingdb
cp -r $blazingsql_files_dir/pyBlazing/pyblazing/* blazingsql/pyblazing

cd $blazingsql_files_dir/cudf/python
python setup.py install --prefix $working_directory/blazingsql/runtime

cd $working_directory
