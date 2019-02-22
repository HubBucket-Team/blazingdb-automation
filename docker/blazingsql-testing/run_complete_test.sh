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
nvidia-docker build --build-arg USER=$user -t $docker_image .

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

#echo " Installig apache drill"
#cd $workdir
#apache_drill_directory=apache-drill-1.12.0

#if [ ! -d $apache_drill_directory ]; then
#    wget http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
#    tar -xvzf apache-drill-1.12.0.tar.gz
    # Set time zone apache drill:  In the folder : /apache-drill-1.12.0/conf/ edit the file drill-env.sh and add the line: export DRILL_JAVA_OPTS="-Duser.timezone=UTC"
#    DRILL_JAVA_OPTS_VAR='export DRILL_JAVA_OPTS="-Duser.timezone=UTC" '
#    echo $DRILL_JAVA_OPTS_VAR >> apache-drill-1.12.0/conf/drill-env.sh
#fi 

#We use DataSet1Mb from  blazigndb google storage
cd  $workdir
if [ ! -d $workdir/$data_set ]; then
gsutil cp -R gs://blazingdbstorage/$data_set .
fi
#TO DO: Replace file configurationfile
if [ ! -f $workdir/configurationFile.json ]; then
    gsutil cp gs://blazingdbstorage/configurationFile.json  .
fi

echo "Updating creation logtest directory "
logTest_name=logtest

if [ ! -d $logTest_name ]; then
    mkdir $logTest_name
fi   

echo "Run end to end  test container"
#DEVELOP MODE
#nvidia-docker run --name bzsqlcontainer -d -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $HOME/.ssh/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user -ti blazingsql/test  bash
nvidia-docker run --name bzsqlcontainer -d -ti -e DEV_UID=$(id -u) -e DEV_GID=$(id -g) -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $ssh_key/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user $docker_image bash

#JENKINS MODE
#nvidia-docker run --name bzsqlcontainer -d -p 8884:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001  -v $ssh_key/.ssh/:/home/$user/.ssh/ -v $local_workdir/run_e2e.sh:/tmp/run_e2e.sh -v $workdir/:$home_user -ti blazingsqltest  bash


#echo "Changing permission"
#echo "USERRRRRRRRR" $user
#nvidia-docker exec --user root bzsqlcontainer chown -R 1001:1001 /blazingsql/
#nvidia-docker exec --user root bzsqlcontainer chown -R 1001:1001 $home_user
#nvidia-docker exec --user root bzsqlcontainer chown -R 1001:1001 $workdir_drill

#echo "Init services"
#nvidia-docker exec -d bzsqlcontainer /home/jupyter/testing-libgdf
#nvidia-docker exec -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
#nvidia-docker exec -d bzsqlcontainer java -jar  /home/jupyter/BlazingCalcite.jar
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer java -jar /home/jupyter/BlazingCalcite.jar
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer /home/jupyter/blazingdb_orchestator_service 8890 127.0.0.1 8891 127.0.0.1 8892
nvidia-docker exec --user $(id -u):$(id -g) -d bzsqlcontainer /home/jupyter/testing-libgdf 127.0.0.1 8892

echo "Init apache Drill"
#!quit
#cd $local_workdir
#./run_drill.sh  $workdir_drill/bin/drill-embedded
nvidia-docker exec --user $(id -u):$(id -g) -ti -d bzsqlcontainer /etc/apache-drill-1.12.0/bin/drill-embedded
sleep 15

echo "Init e2e test"
#DEVELOPER MODE ( -it showing the process)
#nvidia-docker  exec  -it bzsqlcontainer   /tmp/run_e2e.sh  $home_user
# JENKINS MODE
echo "============================First execution==============================================="
nvidia-docker  exec  bzsqlcontainer   /tmp/run_e2e.sh  $home_user
echo "=========================== Second execution ==========================================="
nvidia-docker  exec  bzsqlcontainer   /tmp/run_e2e.sh  $home_user
