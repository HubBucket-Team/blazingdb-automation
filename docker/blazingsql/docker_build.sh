#!/bin/bash

echo "### Copy *.db ###"
cp /blazingsql/*.db .

echo "### Copy output ###"
cp ../blazingsql-build/output/* .

echo "### Build ###"
nvidia-docker build -t blazingdb/deploy:$1 .
