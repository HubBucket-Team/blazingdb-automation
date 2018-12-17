#!/bin/bash

echo "### Building from build.sh ###"

#DIR=$PWD
echo $pwd
echo "CURRENT LOCATION ==> " $PWD
WORKDIR=/tmp/blazingsql

tar -xvf blazingsql.tar.gz -C $WORKDIR/
python $WOKDIR/setup.py install
#cp mypackapage.tar.gz /tmp/

#mkdir -p $WORKDIR
#cp BlazingCalcite.jar $WORKDIR/
#cp blazingdb_orchestator_service $WORKDIR/
#cp testing-libgdf $WORKDIR/

#cd $DIR/blazingdb-protocol/python/ && python setup.py install
#cd $DIR/pyBlazing/ && python setup.py install
