#!/bin/bash

echo "Waiting for apache drill on port 8047"
while ! nc -z localhost 8047; do sleep 3; done

workdir_home=$1
module_test=$2
data_set=$3

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
echo "Activating cudf"
source activate cudf
echo "Executing tests"

#echo "python allE2ETest.py $workdir_home/configurationFile$data_set.json"
#python allE2ETest.py $workdir_home/configurationFile$data_set.json

#First execution
#python -m EndToEndTests.parquetFromLocalTest  $workdir_home/configurationFile.json

flag="False"

echo "================================ First execution ================================"
echo "PRINT configurationFile$flag$data_set.json"
python -m EndToEndTests.$module_test  $workdir_home/configurationFile$flag$data_set.json

if [ $module_test == 'performanceTest' ]
then
    flag="True"
fi

echo "================================ Second execution ================================"
echo "PRINT configurationFile$flag$data_set.json"
python -m EndToEndTests.$module_test  $workdir_home/configurationFile$flag$data_set.json