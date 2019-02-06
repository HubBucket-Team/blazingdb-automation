#!/bin/bash

# Remove old containers
echo "Removing old containers"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Set directories workspace
# Parameters
user=$1
workdir=$2
image_tag=$3
data_set=$4
# Variables
home_user=/home/$user/blazingdb
workdir_drill=$home_user/apache-drill-1.12.0
local_workdir=$PWD
echo "PWD===" $PWD
ssh_key=$HOME/.ssh_jenkins/


echo "Using Blazingsql deploy image"
image_tag=`echo "$image_tag"| sed "s/\//\\\\\\\\\//g"`
sed -ie "s/FROM.*/FROM $image_tag/g" $local_workdir/Dockerfile

echo "Building e2e test image"
nvidia-docker build --build-arg USER=$user -t blazingsqltest .

echo "Updading blazingdb-testing repository"
cd $workdir
blazingdb_testing_name=blazingdb-testing

if [ ! -d $blazingdb_testing_name ]; then
echo " Clonning blazingdb-testing"
    git clone git@github.com:BlazingDB/blazingdb-testing.git
    cd $workdir/blazingdb-testing
    git checkout fix/read_tpch_files_for_strings
fi 
cd $workdir/blazingdb-testing
git checkout fix/read_tpch_files_for_strings
git pull

echo " Installig apache drill"
cd $workdir
apache_drill_directory=apache-drill-1.12.0

if [ ! -d $apache_drill_directory ]; then
    wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
    tar -xvzf apache-drill-1.12.0.tar.gz
    # Set time zone apache drill:  In the folder : /apache-drill-1.12.0/conf/ edit the file drill-env.sh and add the line: export DRILL_JAVA_OPTS="-Duser.timezone=UTC"
    DRILL_JAVA_OPTS_VAR='export DRILL_JAVA_OPTS="-Duser.timezone=UTC" '
    echo $DRILL_JAVA_OPTS_VAR >> apache-drill-1.12.0/conf/drill-env.sh

fi 

#We use DataSet1Mb from  blazigndb google storage
cd  $workdir
gsutil cp -R gs://blazingdbstorage/$data_set .

#TO DO: Replace file configurationfile
#cp  $local_workdir/configurationFile.json  $workdir



echo "Updating creation logtest directory "
logTest_name=logtest

if [ ! -d $logTest_name ]; then
    mkdir $logTest_name
fi   

echo "Run end to end  test container"
#DEVELOP MODE
#nvidia-docker run --name bzsqlcontainer -d -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $HOME/.ssh/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user -ti blazingsqltest  bash
#JENKINS MODE
nvidia-docker run --name bzsqlcontainer -d -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $ssh_key/.ssh/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user -ti blazingsqltest  bash


echo "Changing permission"
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user /blazingsql/
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user $home_user
nvidia-docker exec -u root bzsqlcontainer chown -R $user:$user $workdir_drill

echo "Init services"
nvidia-docker exec -d bzsqlcontainer /home/jupyter/testing-libgdf
nvidia-docker exec -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
nvidia-docker exec -d bzsqlcontainer java -jar  /home/jupyter/BlazingCalcite.jar

echo "Init apache Drill"
#!quit
cd $local_workdir
./run_drill.sh  $workdir_drill/bin/drill-embedded
sleep 10

echo "Init e2e test"
#DEVELOPER MODE ( -it showing the process)
#nvidia-docker  exec  -it bzsqlcontainer   /tmp/run_e2e.sh  $home_user
# JENKINS MODE
nvidia-docker  exec  bzsqlcontainer   /tmp/run_e2e.sh  $home_user