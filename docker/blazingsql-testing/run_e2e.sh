#!/bin/bash

workdir_home=$1

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
echo "Activating cudf"
source activate cudf
echo "Executing tes"
python allE2ETest.py $workdir_home/configurationFile.json