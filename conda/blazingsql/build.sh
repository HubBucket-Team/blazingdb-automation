#!/bin/bash

echo "### Building from build.sh ###"

DIR=$PWD
WORKDIR=/tmp/blazingsql

#tar -xvf $DIR/blazingsql.tar.gz -C $DIR/
#cp mypackapage.tar.gz /tmp/

mkdir -p $WORKDIR
cp $DIR/BlazingCalcite.jar $WORKDIR/
cp $DIR/blazingdb_orchestator_service $WORKDIR/
cp $DIR/testing-libgdf $WORKDIR/

#cd $DIR/blazingdb-protocol/python/ && python setup.py install
#cd $DIR/pyBlazing/ && python setup.py install
