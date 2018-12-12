#!/bin/bash

blazingsql_files_tar_gz_path=$1

temp_directory=/tmp

working_directory=$PWD
cd $working_directory


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

