#!/bin/bash

echo "Waiting for apache drill on port 8047"
while ! nc -z localhost 8047; do sleep 3; done

workdir_home=$1
module_test=$2

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
echo "Activating cudf"
source activate cudf
echo "Executing tests"

echo "python allE2ETest.py $workdir_home/configurationFile.json"

echo "PRINT configurationFile.json"
#python allE2ETest.py $workdir_home/configurationFile.json

#First execution
echo "================================ First execution ================================"
#python -m EndToEndTests.parquetFromLocalTest  $workdir_home/configurationFile.json
python -m EndToEndTests.$module_test  $workdir_home/configurationFileFalse.json

echo "================================ Second execution ================================"
python -m EndToEndTests.$module_test  $workdir_home/configurationFileTrue.json