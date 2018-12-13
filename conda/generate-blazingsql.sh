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
mkdir -p blazingsql/bin blazingsql/pyblazing
cp -r blazingsql-template/* blazingsql

blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files_dir/$blazingdb_ral_artifact_name blazingsql/bin
cp $blazingsql_files_dir/$blazingdb_orchestrator_artifact_name blazingsql/bin
cp $blazingsql_files_dir/$blazingdb_calcite_artifact_name blazingsql/bin

cp -r $blazingsql_files_dir/blazingdb-protocol/python/blazingdb/* blazingsql/blazingdb
cp -r $blazingsql_files_dir/pyBlazing/pyblazing/* blazingsql/pyblazing

cd $working_directory

exit







# Define binaries path
blazingdb_ral_artifact_name=$workspace_dir/testing-libgdf
blazingdb_calcite_artifact_name=$workspace_dir/BlazingCalcite.jar
blazingdb_orchestrator_artifact_name=$workspace_dir/blazingdb_orchestator_service
blazingdb_protocol_current_dir=$workspace_dir
pyblazing_current_dir=$workspace_dir

# Create basic folders
conda_workspace=${workspace_package}/blazingsql
mkdir -p ${conda_workspace}/blazingdb-protocol/python/
mkdir -p ${conda_workspace}/pyBlazing/
#mkdir -p ${conda_workspace}/blazingsql/

# Copy the binaries into package
cp $blazingdb_ral_artifact_name ${conda_workspace}/
cp $blazingdb_calcite_artifact_name ${conda_workspace}/
cp $blazingdb_orchestrator_artifact_name ${conda_workspace}/
cp -r $blazingdb_protocol_current_dir/blazingdb-protocol/python/* ${conda_workspace}/blazingdb-protocol/python/
cp -r $pyblazing_current_dir/pyBlazing/* ${conda_workspace}/pyBlazing/

# Generate the packages
cd ${workspace_package} && tar czf blazingsql.tar.gz blazingsql/


