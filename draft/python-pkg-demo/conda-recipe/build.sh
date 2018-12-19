#!/bin/bash

echo "### Building ###"
pwd
ls -la
tar -xvf pkg_mario21ic-0.0.1.tar.gz
cd pkg_mario21ic-0.0.1/
python setup.py install
