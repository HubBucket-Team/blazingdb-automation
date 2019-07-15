#!/bin/sh
# Author: BlazingDB
# This script use cli from google cloud to create testa 4 instances based in an image

# Creating New Agent
###################################
instance_name=slave-01-jenkins-gpu
image_project=blazingdb-jenkins
zone=us-east1-c
machine_type=n1-standard-4
boot_disk_type=pd-standard
boot_disk_size=50
gpu_type=nvidia-tesla-t4
image_name="blazingsql-slave-gpu-image"

echo  "Creating instance from an image nvidia410 and  cuda10  to Testa 4" 
gcloud compute instances create $instance_name  --image-project ${image_project} --zone ${zone} --machine-type ${machine_type} --boot-disk-type ${boot_disk_type} --boot-disk-size ${boot_disk_size}  --accelerator type=${gpu_type} --image  ${image_name} --maintenance-policy TERMINATE --restart-on-failure


