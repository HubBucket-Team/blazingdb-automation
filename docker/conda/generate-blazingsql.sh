#!/bin/bash

blazingsql_files_tar_gz_path=$1
#TODO percy make this easy to use in local (avoid hardcode)
conda_recipes_dir=/home/jupyter/recipes/
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
#echo "blazingsql-files.tar.gz was decompressed at $working_space"

# Creating the blazingsql python package using the template
mkdir -p $blazingsql_pkg
cp -r blazingsql-template/* $blazingsql_dir

# Copy the BlazingSQL binaries
mkdir -p $blazingsql_dir/cudf
mkdir -p $blazingsql_pkg/blazingdb
mkdir -p $blazingsql_pkg/pyblazing
mkdir -p $blazingsql_pkg/runtime/bin
mkdir -p $blazingsql_pkg/runtime/lib

blazingdb_ral_artifact_name=testing-libgdf
blazingdb_orchestrator_artifact_name=blazingdb_orchestator_service
blazingdb_calcite_artifact_name=BlazingCalcite.jar

cp $blazingsql_files_dir/$blazingdb_ral_artifact_name $blazingsql_pkg/runtime/bin
cp $blazingsql_files_dir/$blazingdb_orchestrator_artifact_name $blazingsql_pkg/runtime/bin
cp $blazingsql_files_dir/$blazingdb_calcite_artifact_name $blazingsql_pkg/runtime/bin

chmod +x $blazingsql_pkg/runtime/bin/*

# Copy the blazingdb-protocol/python and pyblazing
cp -r $blazingsql_files_dir/blazingdb-protocol/python/blazingdb/* $blazingsql_pkg/blazingdb
cp -r $blazingsql_files_dir/pyBlazing/pyblazing/* $blazingsql_pkg/pyblazing

# Copy cudf and change cudf* names to blazingdb_cudf* 
cp -r $blazingsql_files_dir/cudf/* $blazingsql_dir/cudf

# NOTE This is super important: the lines creates the folder to build & install libgdf_cffi & librmm_cffi
mkdir -p $blazingsql_dir/cudf/cpp/build/python
cp -r $blazingsql_files_dir/cudf/cpp/python/* $blazingsql_dir/cudf/cpp/build/python

# Copy NVStrings lib into the runtime
cp -r $blazingsql_files_dir/nvstrings/lib/* $blazingsql_pkg/runtime/lib

# Copy cudf libs into the runtime
cp -r $blazingsql_files_dir/cudf/cpp/install/lib/* $blazingsql_pkg/runtime/lib

chmod +x $blazingsql_pkg/runtime/lib/*

# Compress the python package
cd $output_dir
#echo "Compress the python package ..."
tar zcf blazingsql.tar.gz blazingsql
#echo "$output_dir/blazingsql.tar.gz python package is ready!"

#cd $blazingsql_dir
#pip install -v .

# Generate the conda package
conda_build_tmp_dir_name=_conda_safe_to_remove_
conda_build_tmp_dir=/tmp/"$blazingsql_files_dir_name$conda_build_tmp_dir_name"
mkdir -p $conda_build_tmp_dir
cd $conda_recipes_dir

echo "Inciiando conda build"
# Va a hacer conda-build e imprimir ruta
#PKG=$(FILE_TAR=/home/jupyter/output/blazingsql.tar.gz conda build --output --no-test --output-folder $conda_build_tmp_dir blazingsql)

# Clean all packages to conda, and then generate a new package
rm -rf /home/jupyter/output/blazingsql-.*

FILE_TAR=/home/jupyter/output/blazingsql.tar.gz VERSION=$3 BUILD=$4 conda build --no-test --output-folder $conda_build_tmp_dir blazingsql

echo "package: $PKG"
echo "VERSIONN: $3"
echo "BUILD_NUMBERR: $4"
#cp $PKG /home/jupyter/output/

echo "COPYY"

cp /tmp/blazingsql-files_conda_safe_to_remove_/linux-64/blazingsql-$3-$5_$4.tar.bz2  /home/jupyter/output/




#FILE_TAR=/home/jupyter/output/blazingsql.tar.gz  conda build --no-test --debug --output-folder $conda_build_tmp_dir blazingsql

#cp $conda_build_tmp_dir/linux-64/blazingsql*.tar.bz2 /home/jupyter/output


#conda install --offline /full/path/to/my_package-....tar.bz2

#anaconda upload blazingsql-0.1-py35_0.tar.bz2

cd $working_directory
