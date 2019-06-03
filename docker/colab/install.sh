#!/bin/bash

if [ -z $1 ];
then
  wget -O /tmp/blazingsql-files.tar.gz -q https://s3.amazonaws.com/blazingsql-colab/blazingsql-files.tar.gz
  if [ $? != 0 ]; then
    exit 1
  fi
fi
mkdir -p /tmp/blazing/ && cd /tmp/blazing/ && tar -xf /tmp/blazingsql-files.tar.gz
if [ $? != 0 ]; then
  exit 1
fi


echo "### dependencies ###"
apt-get update -qq > /dev/null
apt-get install -y -qq python3.7 python3-pip > /dev/null
#ln -s /usr/bin/python3 /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip
#apt-get install -y -qq git vim > /dev/null
apt-get install -y -qq --no-install-recommends bzip2 wget curl lsof > /dev/null
apt-get install -y -qq --no-install-recommends libcurl3 libssl1.0.0 zlib1g libuuid1 > /dev/null
apt-get install -y -qq supervisor openjdk-8-jre > /dev/null

echo "### cmake ###"
wget -q https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4-Linux-x86_64.sh
bash cmake-3.12.4-Linux-x86_64.sh --skip-license --prefix=/usr
if [ $? != 0 ]; then
  exit 1
fi
rm -f cmake-3.12.4-Linux-x86_64.sh

echo "### pip dependencies ###"
pip3 install wheel==0.32.1 > /dev/null
if [ $? != 0 ]; then
  exit 1
fi
pip3 install cmake_setuptools > /dev/null
if [ $? != 0 ]; then
  exit 1
fi
pip3 install pyarrow==0.12.1 > /dev/null
if [ $? != 0 ]; then
  exit 1
fi
pip3 install pandas==0.24.2 > /dev/null
if [ $? != 0 ]; then
  exit 1
fi
pip3 install numpy==1.16.2 > /dev/null
if [ $? != 0 ]; then
  exit 1
fi
pip3 install cython
if [ $? != 0 ]; then
  exit 1
fi

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
RMM_HEADER=$blazingsql_files/cudf/cpp/thirdparty/rmm/include/rmm/rmm_api.h pip3 install $blazingsql_files/nvstrings-src/thirdparty/rmm/python/
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
pip3 install $blazingsql_files/nvstrings-src/python
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
sed -i 's/..\/cpp\/thirdparty\/dlpack\/include\/dlpack\//\/tmp\/blazing\/blazingsql-files\/cudf\/thirdparty\/dlpack\/include\/dlpack\//g' $blazingsql_files/cudf/python/setup.py
pip3 install $blazingsql_files/cudf/python/

CFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" CXXFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" LD_FLASG="-L/usr/lib -lcudf" pip3 install /tmp/blazing/blazingsql-files/cudf/python/
if [ $? != 0 ]; then
  exit 1
fi

echo "### test cudf ###"
export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/
python3 -c "import cudf"

echo "### protocol ###"
pip3 install $blazingsql_files/blazingdb-protocol/python
if [ $? != 0 ]; then
  exit 1
fi

echo "### pyblazing ###"
pip3 install $blazingsql_files/pyBlazing
if [ $? != 0 ]; then
  exit 1
fi
echo "### test pyblazing ###"
python3 -c "import pyblazing"


echo "### binaries ###"
cp -f $blazingsql_files/BlazingCalcite.jar /usr/bin/
cp -f $blazingsql_files/blazingdb_orchestator_service /usr/bin/
cp -f $blazingsql_files/testing-libgdf /usr/bin/

mkdir -p /blazingsql/data/ && chmod 777 -R /blazingsql

echo "### supervisor ###"
wget -q -O /etc/supervisor/conf.d/blazing-calcite.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-calcite.conf
wget -q -O /etc/supervisor/conf.d/blazing-orchestrator.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-orchestrator.conf
wget -q -O /etc/supervisor/conf.d/blazing-ral.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-ral.conf
service supervisor start
#service supervisor status
wget -q -O /usr/bin/blazingsql https://s3.amazonaws.com/blazingsql-colab/blazingsql && chmod +x /usr/bin/blazingsql
blazingsql status

echo "### downloading demo files ###"
wget -q -O /blazingsql/data/nation.psv https://s3.amazonaws.com/blazingsql-colab/demo/data/nation.psv
wget -q -O /blazingsql/data/gpu.arrow https://s3.amazonaws.com/blazingsql-colab/demo/data/gpu.arrow
wget -q -O /blazingsql/demo1.py https://s3.amazonaws.com/blazingsql-colab/demo/demo1.py
wget -q -O /blazingsql/demo2.py https://s3.amazonaws.com/blazingsql-colab/demo/demo2.py
wget -q -O /blazingsql/demo3.py https://s3.amazonaws.com/blazingsql-colab/demo/demo3.py
wget -q -O /blazingsql/demo4.py https://s3.amazonaws.com/blazingsql-colab/demo/demo4.py

# Clean
rm -rf /tmp/blazing*

echo "### BlazingSQL installation finished ###"
echo "You can run the command to view status:"
echo "!blazingsql status"
echo "Demo files are in /blazingsql/"
ls -la /blazingsql/

echo "Run command, copy content and execute it:"
#echo $(cat /blazingsql/demo1.py)
echo "!cat /blazingsql/demo1.py"
