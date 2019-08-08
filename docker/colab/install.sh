#!/bin/bash
# Usage: path_tar verbose sudo path_usr non_strict_mode
# Usage: /tmp/blazingsql-files.tar.gz true true $PYENV_VIRTUAL_ENV/|/usr true

GPU_TYPE=$(nvidia-smi --query-gpu=gpu_name --format=csv|awk 'FNR==2 {print $1}')

STRICT_MODE=0
if [ ! -z $5 ]; then
  STRICT_MODE=1
fi

VERBOSE="/dev/null"
#VERBOSE="/dev/stdout"
if [ ! -z $2 ]; then
  VERBOSE="/dev/stdout"
fi

SUDO=""
if [ ! -z $3 ]; then
  SUDO="sudo"
fi

BUCKET="blazingsql-colab"
BUCKET_DEMO=$BUCKET"/demo"
BUCKET_DATA=$BUCKET_DEMO"/data"

PYTHON="python"
PIP="python -m pip"

PATH_USR="/usr/local/"
if [ ! -z $4 ]; then
  PATH_USR=$4
fi

echo "GPU_TYPE: "$GPU_TYPE
echo "Strict mode: "$STRICT_MODE
if [ $STRICT_MODE == 1 ] && [ "$GPU_TYPE" != "Tesla T4" ]; then
  echo "GPU model must be Tesla T4"
  exit 1
fi

echo "### update ###"
$SUDO apt-get update -qq > $VERBOSE

echo "### wget ###"
$SUDO apt-get install -y wget > $VERBOSE
if [ $? != 0 ]; then
    exit 1
fi

echo "### dependencies ###"
$SUDO apt-get install -y --no-install-recommends libprotobuf-dev libgsasl7 libgsasl7-dev libxml2-dev libicu-dev libcurl3 libssl1.0.0 zlib1g libuuid1 > $VERBOSE
if [ $? != 0 ]; then
    exit 1
fi


if [ -z $1 ]; then
  wget -O /tmp/blazingsql-files.tar.gz -q https://s3.amazonaws.com/$BUCKET/blazingsql-files.tar.gz
  if [ $? != 0 ]; then
    exit 1
  fi
fi

mkdir -p /tmp/blazing/ && cd /tmp/blazing/ && tar -xf /tmp/blazingsql-files.tar.gz
if [ $? != 0 ]; then
  exit 1
fi


source /etc/lsb-release
#echo "DISTRIB_ID: "$DISTRIB_ID
#echo "DISTRIB_RELEASE: "$DISTRIB_RELEASE
echo "DISTRIB_DESCRIPTION: "$DISTRIB_DESCRIPTION
echo "PYTHON: "$PYTHON
#echo "VERSION: "$($PYTHON --version)
echo "PIP: "$PIP
echo "VERBOSE: "$VERBOSE
echo "SUDO: "$SUDO
echo "PATH_USR: "$PATH_USR

echo "### java ###"
echo "CMD: $SUDO apt-get install -y openjdk-8-jre"
$SUDO apt-get install -y openjdk-8-jre > $VERBOSE
if [ $? != 0 ]; then
    exit 1
fi

echo "### Conda ###"
if ! [ -x "$(command -v conda)" ]; then
  echo "conda is not installed"
  wget -q -O /tmp/miniconda.sh -nv https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash /tmp/miniconda.sh -b -f -p /usr/local
  if [ $? != 0 ]; then
    exit 1
  fi
  rm -f /tmp/miniconda.sh
fi
echo "conda version: "$(conda --version)
if [ $? != 0 ]; then
  exit 1
fi

echo "### conda dependencies ###"
conda install -y --prefix $PATH_USR -c numba -c conda-forge -c defaults dask xgboost numba=0.43.0 pandas=0.24.2 pyarrow=0.12.1 cmake=3.14
#conda install -y --prefix /usr/local \
#    -c rapidsai-nightly/label/xgboost -c nvidia -c conda-forge -c rapidsai-nightly/label/cuda10.0 \
#    python=3.6 cudatoolkit=10.0 \
#    rmm=0.9.0a1 nvstrings=0.9.0a cudf=0.9 dask-cudf=0.9.0a \
#    dask dask-cudf rapidsai/label/xgboost::xgboost=>0.9 \
#    numba=0.43.0 pandas=0.24.2 pyarrow=0.12.1 cmake=3.14
if [ $? != 0 ]; then
  exit 1
fi

echo "### conda nightly ###"
conda install -y --prefix $PATH_USR -c rapidsai-nightly/label/cuda10.0 rmm=0.9.0a1 nvstrings=0.9.0a cudf=0.9 dask-cudf=0.9.0a
if [ $? != 0 ]; then
  exit 1
fi


blazingsql_files=/tmp/blazing/blazingsql-files

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
#echo "### test pyblazing ###"
#$PYTHON -c "import pyblazing"
#if [ $? != 0 ]; then
#  exit 1
#fi

echo "### binaries ###"
cp -f $blazingsql_files/BlazingCalcite.jar $PATH_USR/bin/
cp -f $blazingsql_files/blazingdb_orchestator_service $PATH_USR/bin/
cp -f $blazingsql_files/testing-libgdf $PATH_USR/bin/

$SUDO mkdir -p /blazingsql/data/ && chmod 777 -R /blazingsql

echo "### downloading demo files ###"
wget -q -O /blazingsql/data/nation.psv https://s3.amazonaws.com/$BUCKET_DATA/nation.psv
wget -q -O /blazingsql/data/gpu.arrow https://s3.amazonaws.com/$BUCKET_DATA/gpu.arrow
wget -q -O /blazingsql/data/Music.csv https://s3.amazonaws.com/$BUCKET_DATA/Music.csv
wget -q -O /blazingsql/data/cancer_data_00.csv https://s3.amazonaws.com/$BUCKET_DATA/cancer_data_00.csv
wget -q -O /blazingsql/data/cancer_data_01.parquet https://s3.amazonaws.com/$BUCKET_DATA/cancer_data_01.parquet
wget -q -O /blazingsql/data/cancer_data_02.csv .csv https://s3.amazonaws.com/$BUCKET_DATA/cancer_data_02.csv

wget -q -O /blazingsql/demo1.py https://s3.amazonaws.com/$BUCKET_DEMO/demo1.py
wget -q -O /blazingsql/demo2.py https://s3.amazonaws.com/$BUCKET_DEMO/demo2.py
wget -q -O /blazingsql/demo3.py https://s3.amazonaws.com/$BUCKET_DEMO/demo3.py
wget -q -O /blazingsql/demo4.py https://s3.amazonaws.com/$BUCKET_DEMO/demo4.py
wget -q -O /blazingsql/demo5.py https://s3.amazonaws.com/$BUCKET_DEMO/demo5.py


echo "### supervisor ###"
$SUDO apt-get install -y supervisor > $VERBOSE
wget -q -O /etc/supervisor/conf.d/blazing-calcite.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-calcite.conf
wget -q -O /etc/supervisor/conf.d/blazing-orchestrator.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-orchestrator.conf
wget -q -O /etc/supervisor/conf.d/blazing-ral.conf https://s3.amazonaws.com/blazingsql-colab/supervisor/blazing-ral.conf
service supervisor start
service supervisor status
wget -q -O /usr/bin/blazingsql https://s3.amazonaws.com/blazingsql-colab/blazingsql && chmod +x /usr/bin/blazingsql
blazingsql status

# Clean
apt-get clean
rm -rf /tmp/blazing*

echo "### BlazingSQL installation finished ###"
echo "You can run the command to view status:"
echo "!blazingsql status"
echo "Demo files are in /blazingsql/"
ls -la /blazingsql/

echo "Run these commands, copy its content and/or execute it:"
echo "!cat /blazingsql/demo1.py"
echo "!python /blazingsql/demo1.py"
