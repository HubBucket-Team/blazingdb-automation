#!/bin/bash
# Usage: ./run_complete_test.sh user path_workspace_testing docker_image path_data_set branch
# Example: ./run_complete.test.sh mario21ic /home/mario21ic/workspace/workspace-testing blazingdb/blazingsql:latest DataSet1Mb develop

# Remove old containers
#TODO : We need to map all scenarios to know what container live in this jenkins-slave. Not remove all the container to start the end to end.
echo "Removing old containers"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Set directories workspace
# Parameters
user=$1
workdir=$2
image_tag="blazingdb/blazingsql:"$3
data_set=$4
branch_blazingdb_testing=$5
# Variables
home_user=/home/$user/blazingdb
workdir_drill=$home_user/apache-drill-1.12.0
local_workdir=$PWD
docker_image="blazingsql/test"
echo "PWD===>" $PWD
ssh_key=$HOME/.ssh/


echo "Using Blazingsql deploy image"
image_tag=`echo "$image_tag"| sed "s/\//\\\\\\\\\//g"`
sed -ie "s/FROM.*/FROM $image_tag/g" $local_workdir/Dockerfile

echo "Building e2e test image"
nvidia-docker build -t $docker_image .

echo "Updading blazingdb-testing repository"
cd $workdir
blazingdb_testing_name=blazingdb-testing

if [ ! -d $blazingdb_testing_name ]; then
echo " Clonning blazingdb-testing"
    git clone git@github.com:BlazingDB/blazingdb-testing.git
    cd $workdir/blazingdb-testing
    git checkout $branch_blazingdb_testing
fi 
cd $workdir/blazingdb-testing
git checkout $branch_blazingdb_testing
git pull

#We use DataSet1Mb from  blazigndb google storage
cd  $workdir
if [ ! -d $workdir/$data_set ]; then
  gsutil cp -R gs://blazingdbstorage/$data_set .
fi

#TO DO: Replace file configurationfile
if [ ! -f $workdir/configurationFile.json ]; then
    #gsutil cp gs://blazingdbstorage/configurationFileTrue.json  .
    #gsutil cp gs://blazingdbstorage/configurationFileFalse.json  .
    echo "hola"
fi

echo "Updating creation logtest directory"
logTest_name=logtest

if [ ! -d $logTest_name ]; then
    mkdir $logTest_name
fi

echo "Run end to end  test container"
nvidia-docker run --name bzsqlcontainer -d -ti -e DEV_UID=$(id -u) -e DEV_GID=$(id -g) -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $ssh_key/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user $docker_image bash

#echo "Changing permission"
echo "USERRRRRRRRR" $user
nvidia-docker exec --user root bzsqlcontainer chown -R tester:tester /blazingsql/

echo "Init services"
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer java -jar /home/jupyter/BlazingCalcite.jar
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer /home/jupyter/testing-libgdf

echo "Init apache Drill"
nvidia-docker exec -ti -d bzsqlcontainer /etc/apache-drill-1.12.0/bin/drill-embedded
#sleep 15

echo "Init e2e test"

echo "============================First execution==============================================="
nvidia-docker  exec  bzsqlcontainer   /tmp/run_e2e.sh  $home_user

#echo "=========================== Second execution ==========================================="
#nvidia-docker  exec  bzsqlcontainer   /tmp/run_e2e.sh  $home_user
