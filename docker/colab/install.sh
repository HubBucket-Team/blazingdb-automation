#!/bin/bash
# Usage: path_tar verbose sudo path_usr
# Usage: /tmp/blazingsql-files.tar.gz true true $PYENV_VIRTUAL_ENV/

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

PYTHON="python3.7"
PIP="$PYTHON -m pip"

VERBOSE="/dev/null"
if [ ! -z $2 ];
then
  VERBOSE="/dev/stdout"
fi

SUDO=""
if [ ! -z $3 ];
then
  SUDO="sudo"
fi

PATH_USR="/usr/"
if [ ! -z $4 ];
then
  PATH_USR=$4
fi

echo "PYTHON: $PYTHON"
echo "PIP: $PIP"
echo "VERBOSE: $VERBOSE"
echo "SUDO: $SUDO"
echo "PATH_USR: $PATH_USR"

source /etc/lsb-release
if [ $DISTRIB_RELEASE == "16.04" ];
then
  echo "Installing python 3.7"
  $SUDO apt-get update -qq > $VERBOSE
  if [ $? != 0 ]; then
    exit 1
  fi

  $SUDO apt-get install -y software-properties-common > $VERBOSE
  $SUDO add-apt-repository -y ppa:deadsnakes/ppa
  if [ $? != 0 ]; then
    exit 1
  fi
fi

echo "### update ###"
$SUDO apt-get update -qq > $VERBOSE

echo "### dependencies ###"
$SUDO apt-get install -y -qq $PYTHON python3-pip > $VERBOSE
$SUDO apt-get install -y -qq $PYTHON-dev libffi-dev libgsasl7 libgsasl7-dev > $VERBOSE
#ln -s /usr/bin/python3 /usr/bin/python
#ln -s /usr/bin/pip3 /usr/bin/pip
#apt-get install -y -qq git vim > $VERBOSE
$SUDO apt-get install -y -qq --fix-missing bzip2 wget curl lsof > $VERBOSE
$SUDO apt-get install -y -qq --fix-missing libcurl3 libssl1.0.0 zlib1g libuuid1 > $VERBOSE
$SUDO apt-get install -y -qq --fix-missing supervisor openjdk-8-jre > $VERBOSE

echo "### cmake ###"
if ! [ -x "$(command -v cmake)" ]; then
  echo "cmake not installed"
  wget -q https://github.com/Kitware/CMake/releases/download/v3.12.4/cmake-3.12.4-Linux-x86_64.sh
  bash cmake-3.12.4-Linux-x86_64.sh --skip-license --prefix=/usr
  if [ $? != 0 ]; then
    exit 1
  fi
  rm -f cmake-3.12.4-Linux-x86_64.sh
fi
cmake --version
if [ $? != 0 ]; then
  exit 1
fi

echo "### pip dependencies ###"
#echo "PIP: $PIP"
$PIP install --upgrade --force-reinstall setuptools
$PIP install --upgrade pip

$PIP install wheel==0.32.1 > $VERBOSE
if [ $? != 0 ]; then
  exit 
fi
$PIP install cmake_setuptools > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install numba==0.43.0 > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install numpy==1.16.2 > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install pandas==0.24.2 > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install pyarrow==0.12.1 > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi

$PIP install flatbuffers > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi

$PIP install cython > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install xgboost > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi
$PIP install sklearn > $VERBOSE
if [ $? != 0 ]; then
  exit 1
fi


blazingsql_files=/tmp/blazing/blazingsql-files

export PYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
export PYTHON_LIBRARY=$(python3.7 -c "import distutils.sysconfig as sysconfig; import os; print(os.path.join(sysconfig.get_config_var('LIBDIR'), sysconfig.get_config_var('LDLIBRARY')))")
export CMAKE_COMMON_VARIABLES="-DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR -DPYTHON_LIBRARY=$PYTHON_LIBRARY"

echo "PYTHON_INCLUDE_DIR: $PYTHON_INCLUDE_DIR"
echo "PYTHON_LIBRARY: $PYTHON_LIBRARY"
echo "CMAKE_COMMON_VARIABLES: $CMAKE_COMMON_VARIABLES"

echo "### libhdfs ###"
cp -f $blazingsql_files/libhdfs3/libhdfs3.so $PATH_USR/lib/
if [ $? != 0 ]; then
  exit 1
fi

echo "### librmm ###"
cp -f $blazingsql_files/nvstrings-build/rmm/librmm.so $PATH_USR/lib/
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
cp $blazingsql_files/nvstrings-build/libNV* $PATH_USR/lib/
if [ $? != 0 ]; then
  exit 1
fi
cp -rf $blazingsql_files/nvstrings/include/* $PATH_USR/include/
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
cp -rf $blazingsql_files/cudf/cpp/install/lib/* $PATH_USR/lib/
cp -rf $blazingsql_files/cudf/thirdparty/dlpack/include/dlpack/* $PATH_USR/lib/
if [ $? != 0 ]; then
  exit 1
fi
cp -rf $blazingsql_files/cudf/cpp/include/* $PATH_USR/include/
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
CFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" CXXFLAGS="-I/tmp/blazing/blazingsql-files/cudf/cpp/install/include/ -I/tmp/blazing/blazingsql-files/cudf/thirdparty/dlpack/include/dlpack/" LD_FLASG="-L$PATH_USR/lib -lcudf" $PIP install $blazingsql_files/cudf/python/
if [ $? != 0 ]; then
  exit 1
fi

echo "### test cudf ###"
export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/
$PYTHON -c "import cudf"
if [ $? != 0 ]; then
  exit 1
fi

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
$PYTHON -c "import pyblazing"
if [ $? != 0 ]; then
  exit 1
fi

echo "### binaries ###"
cp -f $blazingsql_files/BlazingCalcite.jar $PATH_USR/bin/
cp -f $blazingsql_files/blazingdb_orchestator_service $PATH_USR/bin/
cp -f $blazingsql_files/testing-libgdf $PATH_USR/bin/

$SUDO mkdir -p /blazingsql/data/ && chmod 777 -R /blazingsql

echo "### downloading demo files ###"
wget -q -O /blazingsql/data/nation.psv https://s3.amazonaws.com/blazingsql-colab/demo/data/nation.psv
wget -q -O /blazingsql/data/gpu.arrow https://s3.amazonaws.com/blazingsql-colab/demo/data/gpu.arrow
wget -q -O /blazingsql/demo1.py https://s3.amazonaws.com/blazingsql-colab/demo/demo1.py
wget -q -O /blazingsql/demo2.py https://s3.amazonaws.com/blazingsql-colab/demo/demo2.py
wget -q -O /blazingsql/demo3.py https://s3.amazonaws.com/blazingsql-colab/demo/demo3.py
wget -q -O /blazingsql/demo4.py https://s3.amazonaws.com/blazingsql-colab/demo/demo4.py


echo "### supervisor ###"
wget -q -O /etc/supervisor/conf.d/blazing-calcite.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-calcite.conf
wget -q -O /etc/supervisor/conf.d/blazing-orchestrator.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-orchestrator.conf
wget -q -O /etc/supervisor/conf.d/blazing-ral.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-ral.conf
service supervisor start
service supervisor status
wget -q -O /usr/bin/blazingsql https://s3.amazonaws.com/blazingsql-colab/blazingsql && chmod +x /usr/bin/blazingsql
$blazingsql status

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
