#!/bin/bash

# Remove old containers
echo "Removing old containers"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Set directories workspace
user=edith
home_user=/home/$user/blazingdb
workdir=$home_user/workspace-testing
workdir_testing=$workdir/blazingdb-testing
local_workdir=$home_user/repositories/blazingsql/blazingdb-automation/docker/blazingsql-testing
workdir_drill=$home_user/apache-drill-1.12.0

# Build end to end test image
echo "Building e2e test image"
nvidia-docker build -t blazingsqltest .

# Repository  blazingdb-testing
echo "Updading blazingdb-testing repository"
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
echo " Installig apache drill"
cd $workdir
apache_drill_directory=apache-drill-1.12.0

if [ ! -d $apache_drill_directory ]; then
    wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
    tar -xvzf apache-drill-1.12.0.tar.gz
fi 
# TODO: Set time zone apacje drill:  In the folder : /apache-drill-1.12.0/conf/ edit the file drill-env.sh and add the line: export DRILL_JAVA_OPTS="-Duser.timezone=UTC"

# TODO: Download DataSet1Mb

# Create logtest
echo "Updating creation logtest directory "
logTest_name=logtest

if [ ! -d $logTest_name ]; then
    mkdir $logTest_name
fi   

# Executing container e2e
echo "Run end to end  test container"
nvidia-docker run --name bzsqlcontainer -d -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user -ti blazingsqltest  bash


# Change permissions
echo "Changing permission"
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user /blazingsql/
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user $home_user
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user $workdir_drill


# Init services
echo "Init services"
nvidia-docker exec -d bzsqlcontainer /home/jupyter/testing-libgdf
nvidia-docker exec -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
nvidia-docker exec -d bzsqlcontainer java -jar  /home/jupyter/BlazingCalcite.jar

# Init apache Drill
echo "Init apache Drill"
#!quit
cd $local_workdir
./run_drill.sh  $workdir_drill/bin/drill-embedded
sleep 10

# Init e2e test
echo "Init e2e test"
nvidia-docker  exec -ti  bzsqlcontainer   /tmp/run_e2e.sh

