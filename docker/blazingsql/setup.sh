#!/bin/bash
working_directory=$PWD

blazingsql_files=/tmp/blazing/blazingsql-files

cd /tmp/blazing/ && tar xvf blazingsql-files.tar.gz
cd $blazingsql_files

source activate gdf

# install libgdf and libgdf_cffi
echo "Installing custom libgdf_cffi"
rm -rf /conda/envs/gdf/lib/python3.5/site-packages/libgdf_cffi*
cp libgdf_cffi/lib/libgdf.so /conda/envs/gdf/lib/
cd libgdf_cffi/
cp /tmp/blazing/libgdf_cffi/meta.yaml .
cp /tmp/blazing/libgdf_cffi/build.sh .
conda-build .
pip install .
echo "Custom libgdf_cffi is ready!"

echo "Installing custom pygdf"
#cd /root
#git clone git@github.com:BlazingDB/cudf.git && cd cudf
#git checkout 6b7de97b21047c68747c327ea9f87ac921f478f0
#mkdir conda-recipes/cudf/ &&
cd /tmp/blazing/blazingsql-files/cudf/conda-recipes/cudf/ 
cp /tmp/blazing/cudf/meta.yaml .
cp /tmp/blazing/cudf/build.sh .
conda-build .
rm -rf /conda/envs/gdf/lib/python3.5/site-packages/pygdf*
cd ../../ && pip install .
python -c "import pygdf"
echo "Custom pygdf is ready"

# install blazingsql
cd $blazingsql_files
cp testing-libgdf /usr/bin
cp blazingdb_orchestator_service /usr/bin
cp BlazingCalcite.jar /usr/bin

# install pyblazing
cd blazingdb-protocol/python/
pip install .

cd $blazingsql_files
cd pyBlazing
pip install .

cd $working_directory
