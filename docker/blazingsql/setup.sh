#!/bin/bash

#cd /tmp/blazing/ && tar -xf /tmp/blazingsql-files.tar.gz
blazingsql_files=/tmp/blazing/blazingsql-files

echo "### libhdfs ###"
cp -f $blazingsql_files/libhdfs3/libhdfs3.so /usr/lib/
if [ $? != 0 ]; then
  exit 1
fi

echo "### librmm ###"
cp -f $blazingsql_files/nvstrings-build/rmm/librmm.so /usr/lib/
if [ $? != 0 ]; then
  exit 1
fi
#export RMM_HEADER=$blazingsql_files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h
#pip3 install $blazingsql_files/nvstrings-src/thirdparty/rmm/python/
sed -i 's/..\/..\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\//g' $blazingsql_files/nvstrings-src/thirdparty/rmm/python/librmm_cffi/librmm_build.py
RMM_HEADER=$blazingsql_files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h $PIP install $blazingsql_files/nvstrings-src/thirdparty/rmm/python/
if [ $? != 0 ]; then
  exit 1
fi
#pip3 list

echo "### custrings ###"
cp $blazingsql_files/nvstrings-build/libNV* /usr/lib/
if [ $? != 0 ]; then
  exit 1
fi
cp -rf $blazingsql_files/nvstrings/include/* /usr/include/
if [ $? != 0 ]; then
  exit 1
fi
#export NVSTRINGS_INCLUDE=$blazingsql_files/nvstrings/include/
rm -rf $blazingsql_files/nvstrings-src/python/build/
$PIP install $blazingsql_files/nvstrings-src/python
if [ $? != 0 ]; then
  exit 1
fi
#pip3 list

echo "### cudf ###"
cp -rf $blazingsql_files/cudf/cpp/install/lib/* /usr/lib/
cp -rf $blazingsql_files/cudf/thirdparty/dlpack/include/dlpack/* /usr/lib/
if [ $? != 0 ]; then
  exit 1
fi
cp -rf $blazingsql_files/cudf/cpp/include/* /usr/include/
if [ $? != 0 ]; then
  exit 1
fi
export CUDF_INCLUDE_DIR=$blazingsql_files/cudf/cpp/include/cudf/
#$PIP install $blazingsql_files/cudf/cpp/python/
if [ $? != 0 ]; then
  exit 1
fi

sed -i 's/..\/cpp\/include\//\/tmp\/blazing\/blazingsql-files\/cudf\/cpp\/include\//g' $blazingsql_files/cudf/python/setup.py
sed -i 's/..\/cpp\/thirdparty\/dlpack\/include\/dlpack\//\/tmp\/blazing\/blazingsql-files\/cudf\/thirdparty\/dlpack\/include\/dlpack\//g' $blazingsql_files/cudf/python/setup.py
CFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" CXXFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" LD_FLASG="-L/usr/lib -lcudf" $PIP install $blazingsql_files/cudf/python/
if [ $? != 0 ]; then
  exit 1
fi

echo "### test cudf ###"
export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64/:/usr/lib/x86_64-linux-gnu/
# $PYTHON -c "import cudf"
# if [ $? != 0 ]; then
#   exit 1
# fi

echo "### protocol ###"
$PIP install $blazingsql_files/blazingdb-protocol/python
if [ $? != 0 ]; then
  exit 1
fi

echo "### pyblazing ###"
$PIP install $blazingsql_files/pyBlazing
if [ $? != 0 ]; then
  exit 1
fi
echo "### test pyblazing ###"
# $PYTHON -c "import pyblazing"
# if [ $? != 0 ]; then
#   exit 1
# fi

echo "### binaries ###"
cp -f $blazingsql_files/BlazingCalcite.jar /usr/bin/
cp -f $blazingsql_files/blazingdb_orchestator_service /usr/bin/
cp -f $blazingsql_files/testing-libgdf /usr/bin/
