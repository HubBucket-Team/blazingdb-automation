#!/bin/bash

#docker run --runtime=nvidia -ti nvidia/cuda:10.0-devel-ubuntu18.04 bash

apt-get update
apt-get install -y python3.7 python3-pip git vim
apt-get install -y --no-install-recommends sudo bzip2 wget curl nano vim-tiny lsof htop net-tools
apt-get install -y --no-install-recommends libcurl3 libssl1.0.0 zlib1g libuuid1
apt-get install -y supervisor openjdk-8-jre 

wget https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4-Linux-x86_64.sh
bash cmake-3.12.4-Linux-x86_64.sh --skip-license --prefix=/usr


pip3 install wheel==0.32.1
pip3 install cmake_setuptools

pip3 install pyarrow==0.12.1
pip3 install pandas==0.24.2
pip3 install numpy==1.16.2

pip3 install cython

# Previamente copiar blazingsql-files.tar.gz a /tmp/
mkdir /tmp/blazing/
cd /tmp/blazing/ && tar -xvf /tmp/blazingsql-files.tar.gz 

# libhdfs
cp /tmp/blazing/blazingsql-files/libhdfs3/libhdfs3.so /usr/lib/

# Install librmm
cp /tmp/blazing/blazingsql-files/nvstrings-build/rmm/librmm.so /usr/lib/
export RMM_HEADER=/tmp/blazing/blazingsql-files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h
pip3 install /tmp/blazing/blazingsql-files/nvstrings-src/thirdparty/rmm/python/
pip3 list

# Install custrings
cp /tmp/blazing/blazingsql-files/nvstrings-build/libNV* /usr/lib/
cp -rf /tmp/blazing/blazingsql-files/nvstrings/include/* /usr/include/
#export NVSTRINGS_INCLUDE=/tmp/blazing/blazingsql-files/nvstrings/include/
pip3 install /tmp/blazing/blazingsql-files/nvstrings-src/python
pip3 list

# Install cudf
cp -rf /tmp/blazing/blazingsql-files/cudf/cpp/install/lib/* /usr/lib/
export CUDF_INCLUDE_DIR=/tmp/blazing/blazingsql-files/cudf/cpp/include/cudf/
pip3 install /tmp/blazing/blazingsql-files/cudf/cpp/python
CFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/" CXXFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack" LD_FLASG="-L/usr/lib -lcudf" pip3 install /tmp/blazing/blazingsql-files/cudf/python/
python3 -c "import cudf"

# Install protocol
pip3 install /tmp/blazing/blazingsql-files/blazingdb-protocol/python

# Install pyblazing
pip3 install /tmp/blazing/blazingsql-files/pyBlazing

export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/

# Copiar binarios
cp /tmp/blazing/blazingsql-files/BlazingCalcite.jar /usr/bin/
cp /tmp/blazing/blazingsql-files/blazingdb_orchestator_service /usr/bin/
cp /tmp/blazing/blazingsql-files/testing-libgdf /usr/bin/

mkdir /blazingsql && chmod 777 /blazingsql

# Copiar configs a /etc/supervisor/conf.d/ y ejecutar supervisor
#supervisord -c /etc/supervisor/supervisord.conf

#CONTAINER_ID="a62a560bc8c6"
#docker cp ./cudf/cpp/install/lib/librmm.so a62a560bc8c6:/tmp/
#docker cp ./cudf/cpp/install/lib/libcudf.so a62a560bc8c6:/tmp/
#docker cp ./libhdfs3/libhdfs3.so a62a560bc8c6:/tmp/

#docker cp ./nvstrings/lib/libNVText.so a62a560bc8c6:/tmp/
#docker cp ./nvstrings/lib/libNVStrings.so a62a560bc8c6:/tmp/
#docker cp ./nvstrings/lib/libNVCategory.so a62a560bc8c6:/tmp/



