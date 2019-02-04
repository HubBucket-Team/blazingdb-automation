#!/bin/bash

workdir_home=$1

cd $workdir_home/blazingdb-testing/BlazingSQLTest/
source activate cudf
python allE2ETest.py $workdir_home/configurationFile.json