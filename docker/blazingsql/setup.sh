#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

source activate cudf

# install libgdf, libgdf/python and cudf
cudf_dir=$blazingsql_files/cudf
cp $cudf_dir/libgdf/install/lib/libgdf.so /conda/envs/cudf/lib/
cp $cudf_dir/libgdf/install/lib/librmm.so /conda/envs/cudf/lib/
cp -r $cudf_dir/libgdf/install/* $cudf_dir/libgdf/python
pip install $cudf_dir/libgdf/python


exit
cp /tmp/blazing/libgdf_cffi/meta.yaml .
cp /tmp/blazing/libgdf_cffi/build.sh .

echo "### Iniciando conda-build ###"
#conda-build .
pip install .
echo "Custom libgdf_cffi is ready!"

echo "Installing custom cudf"
rm -rf /conda/envs/cudf/lib/python3.5/site-packages/pygdf-*
cd /tmp/blazing/blazingsql-files/cudf/conda-recipes/cudf/ 
cp /tmp/blazing/cudf/meta.yaml .
cp /tmp/blazing/cudf/build.sh .
echo "### Iniciando conda-build cudf ###"
#conda-build .
cd $blazingsql_files/cudf/ && pip install .
python -c "import cudf"
echo "Custom cudf is ready"

# install blazingsql
cd $blazingsql_files
cp testing-libgdf /usr/bin
cp blazingdb_orchestator_service /usr/bin
cp BlazingCalcite.jar /usr/bin

# install pyblazing
echo "### Iniciando blazingdg-protocol/python ###"
cd blazingdb-protocol/python/
pip install .

echo "### Iniciando pyblazing ###"
cd $blazingsql_files
cd pyBlazing
pip install .

echo "### Copiando los .so ###"
mkdir -p /usr/local/nvidia/lib
cp /conda/envs/cudf/lib/libgdf.so /usr/local/nvidia/lib/
cp /conda/envs/cudf/lib/librmm.so /usr/local/nvidia/lib/
cp /conda/envs/cudf/lib/libNVStrings.so /usr/local/nvidia/lib/

#echo "### copiandoo bkp ###"
#cp -rf $blazingsql_files /root/blazingsql_files/

cd $working_directory
