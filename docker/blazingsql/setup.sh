#!/bin/bash

working_directory=$PWD
blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

source activate gdf

# install libgdf and libgdf_cffi
echo "Installing custom libgdf_cffi"
rm -rf /conda/envs/gdf/lib/python3.5/site-packages/pygdf-*
cp libgdf_cffi/lib/libgdf.so /conda/envs/gdf/lib/
cp libgdf_cffi/lib/librmm.so /conda/envs/gdf/lib/
cd libgdf_cffi/ && \
cp /tmp/blazing/libgdf_cffi/meta.yaml .
cp /tmp/blazing/libgdf_cffi/build.sh .

echo "### Iniciando conda-build ###"
conda-build .
pip install .
echo "Custom libgdf_cffi is ready!"

echo "Installing custom cudf"
cd /tmp/blazing/blazingsql-files/cudf/conda-recipes/cudf/ 
cp /tmp/blazing/cudf/meta.yaml .
cp /tmp/blazing/cudf/build.sh .
echo "### Iniciando conda-build cudf ###"
conda-build .
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

#echo "### copiandoo bkp ###"
#cp -rf $blazingsql_files /root/blazingsql_files/

cd $working_directory
