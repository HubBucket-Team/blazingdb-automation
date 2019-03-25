#!/bin/bash

echo "Waiting for apache drill on port 8047"
while ! nc -z localhost 8047; do sleep 3; done

workdir_home=$1

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
echo "Activating cudf"
source activate cudf
echo "Executing tests"
echo "python allE2ETest.py $workdir_home/configurationFile.json"

echo "PRINT configurationFile.json"
#python allE2ETest.py $workdir_home/configurationFile.json

#First execution
echo "================================ First execution ================================"
python -m EndToEndTests.allE2ETest  $workdir_home/configurationFileTrue.json

echo "================================ First execution ================================"
python -m EndToEndTests.allE2ETest  $workdir_home/configurationFileFalse.json