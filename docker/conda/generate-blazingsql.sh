#!/bin/bash

blazingsql_files_tar_gz_path=$1
output_dir=$2

source activate user

blazingsql_dir=$output_dir/blazingsql
blazingsql_pkg=$blazingsql_dir/blazingsql

working_directory=$PWD

temp_dir=/tmp
blazingsql_files_dir_name=blazingsql-files
working_space_name=_safe_to_remove_
working_space=/tmp/"$blazingsql_files_dir_name$working_space_name"
blazingsql_files_dir=$working_space/$blazingsql_files_dir_name

mkdir -p $working_space

echo "Decompressing blazingsql-files.tar.gz ..."
# TODO percy uncomment this when finish this script
tar xf $blazingsql_files_tar_gz_path -C $working_space
echo "blazingsql-files.tar.gz was decompressed at $working_space"

# Creating the blazingsql python package using the template
mkdir -p $blazingsql_pkg
cp -r blazingsql-template/* $blazingsql_dir

# Copy the binaries
mkdir -p $blazingsql_dir/bin
mkdir -p $blazingsql_pkg/blazingdb
mkdir -p $blazingsql_pkg/pyblazing
mkdir -p $blazingsql_pkg/cudf

blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files_dir/$blazingdb_ral_artifact_name $blazingsql_dir/bin
cp $blazingsql_files_dir/$blazingdb_orchestrator_artifact_name $blazingsql_dir/bin
cp $blazingsql_files_dir/$blazingdb_calcite_artifact_name $blazingsql_dir/bin

# Copy the blazingdb-protocol/python and pyblazing
cp -r $blazingsql_files_dir/blazingdb-protocol/python/blazingdb/* $blazingsql_pkg/blazingdb
cp -r $blazingsql_files_dir/pyBlazing/pyblazing/* $blazingsql_pkg/pyblazing

# Copy cudf and change cudf* names to blazingdb_cudf* 
cp -r $blazingsql_files_dir/cudf/* $blazingsql_pkg/cudf




#cd $blazingsql_files_dir/user/python
#python setup.py build_ext --inplace
#pip install .
# --prefix $blazingsql_dir/runtime


#TEST the packages installation TODO percy make this using arguments

rm -rf /conda/envs/user/lib/python3.5/site-packages/blazing*
rm -rf /conda/envs/user/lib/python3.5/site-packages/pyblazing*

cd $blazingsql_dir
pip install -v .

ls -alh /conda/envs/user/lib/python3.5/site-packages/ | grep blazing

echo "DENTRO FUNKAAA"

ls -alh /conda/envs/user/lib/python3.5/site-packages/blazingsql 



cd $working_directory



