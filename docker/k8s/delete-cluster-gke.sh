#!/bin/bash
# Syntax: ./create_cluster.sh project_name cluster_name zone number_nodes number_gpus_per_node
# Example: ./create_cluster.sh myproject-bigdata cluster-2-2gpu us-west1-a 2 2

project_id=$1
cluster_name=$2
zone=$3
region="${zone::-3}"



#yes | gcloud container clusters delete  $name



echo " *************  Params to Remove Google Kubernetes Engine in GCP  ************* "

echo "project_id :"  $project_id
echo "cluster_name :"  $cluster_name
echo "zone :"  $zone
echo "region :"  $region

gcloud config set project $project_id
gcloud config set compute/zone $zone
gcloud config set compute/region $region
#gcloud components update

echo " *************  Removing Cluster from "  $cluster_name    "from " +    $project_id   " ************* " 

yes | gcloud container clusters delete $cluster_name


