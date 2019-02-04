#!/bin/bash
#Build image e2etest
workdir=/home/edith/blazingdb/workspace-testing
workdir_testing=$workdir/blazingdb-testing

# Repository  blazingdb-testing
cd $workdir
blazingdb_testing_name=blazingdb-testing

if [ ! -d $blazingdb_testing_name ]; then
echo " Clonning blazingdb-testing"
    git clone git@github.com:BlazingDB/blazingdb-testing.git
    cd $workdir_testing
    git checkout develop
fi 

cd $workdir_testing
git checkout develop
git pull

# Install apache drill
echo " Install apache drill"
cd $workdir
apache_drill_name=apache-drill-1.12.0

if [ ! -d $apache_drill_name ]; then
    wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
    tar -xvzf apache-drill-1.12.0.tar.gz
fi   
# Copy Data MB

# Create LogData
logTest_name=logTest

if [ ! -d $logTest_name ]; then
    mkdir logTest
fi   

# Build e2e image
echo "Building e2e test image"
#./e2e_build.sh
nvidia-docker build -t blazingsqltest .

# Executing container e2e
echo "Run e2e test image"
#./e2e_run.sh
nvidia-docker run --name bzsqlcontainer -d -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v /home/edith/blazingdb/workspace-testing/:/home/edith/blazingdb  -ti blazingsqltest  bash


# Change permissions
echo "Changing permission"
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /blazingsql/
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /home/edith/blazingdb/

# Init services
echo "Init services"
nvidia-docker exec -d bzsqlcontainer /home/jupyter/testing-libgdf
nvidia-docker exec -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
nvidia-docker exec -d bzsqlcontainer java -jar  /home/jupyter/BlazingCalcite.jar

# Init apache Drill
echo "Init apache Drill"
nvidia-docker exec -d bzsqlcontainer   /home/edith/blazingdb/apache-drill-1.12.0/bin/drill-embedded

# Init e2e test
echo "Init e2e test"
nvidia-docker exec -ti bzsqlcontainer /bin/bash
cd /home/edith/blazingdb/blazingdb-testing/BlazingSQLTest/
source activate cudf
python allE2ETest.py /home/edith/blazingdb/configurationFile.json
