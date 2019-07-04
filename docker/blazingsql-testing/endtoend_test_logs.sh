#!/bin/sh

# Set variables
build_number=$1
logs_path=s3://blazingsql-colab/blazingsql-logs/endtoend_test_blazingsql

# Copy from docker container to tmp directory
sudo mkdir /tmp/$build_number

echo "Copying logs into local machine jenkins"
sudo docker cp bzsqlcontainer:/var/log/supervisor  /tmp/$build_number
sudo chmod  777  -R /tmp/$build_number
#  Uploading logs to s3 public bucket
echo "Copying logs to s3"
aws s3 cp  /tmp/$build_number/ $logs_path/$build_number --recursive
#aws s3 cp /tmp/supervisor/* $logs_path

# Print logs
echo "The generated logs are:"
aws s3 ls $logs_path/$build_number

echo "check  the logs in your local machine"
echo "wget https://blazingsql-colab.s3.amazonaws.com/blazingsql-logs/endtoend_test_blazingsql/200/$output_log"

#bzsqlcontainer