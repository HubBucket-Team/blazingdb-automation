#!/bin/bash

echo "### Building from build.sh ###"

#DIR=$PWD
echo "CURRENT LOCATION ==> " $PWD
WORKDIR=/tmp/blazingsql

rm -rf $WORKDIR/

mkdir -p $WORKDIR/
tar -xvf blazingsql.tar.gz -C $WORKDIR/

cd $WORKDIR/blazingsql/
pip install .

#python3.7 setup.py install --single-version-externally-managed --record=record.txt
