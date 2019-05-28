#!/bin/bash
# Usage branch_name

branch_name=$1
blazingdb_testing_name=blazingdb-testing

if [ ! -d $blazingdb_testing_name ]; then
  echo " Clonning blazingdb-testing"
  git clone -b $branch_name git@github.com:BlazingDB/blazingdb-testing.git
fi

cd $blazingdb_testing_name/ && git reset --hard && git checkout $branch_name && git pull origin $branch_name && mkdir -p ./BlazingSQLTest/logtest/
