#!/bin/bash

# this function build the stack
nvidia-docker build -t blazingdb/build:1 .

cd  ${workspace}/blazingdb-calcite
mkdir $PWD/output
nvidia-docker run --rm -v $PWD:/home/builder/workspace/ -v $PWD/output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ -ti blazingdb/build:1 bash

cd  workspace/java
mvn clean install -Dmaven.test.skip=true