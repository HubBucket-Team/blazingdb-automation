#!/bin/bash

echo "Waiting for apache drill on port 8047"
while ! nc -z localhost 8047; do sleep 3; done

workdir_home=$1

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
echo "Activating cudf"
source activate cudf
echo "Executing tests"
echo "python allE2ETest.py $workdir_home/configurationFile.json"
#python allE2ETest.py $workdir_home/configurationFile.json
python -m EndToEndTests.allE2ETest  $workdir_home/configurationFile.json