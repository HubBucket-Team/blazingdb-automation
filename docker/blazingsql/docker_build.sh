#!/bin/bash

echo "### Copy *.db ###"
rm -rf ./bz3.*.db .
cp /blazingsql/bz3.*.db .

echo "### Copy output ###"
cp ../blazingsql-build/output/blazingsql-files.tar.gz .

echo "### Build ###"
nvidia-docker build -t blazingdb/deploy:$1 .
