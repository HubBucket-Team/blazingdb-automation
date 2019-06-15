#!/bin/bash
# Syntax: ./create_cluster.sh project_name cluster_name zone number_nodes number_gpus_per_node
# Example: ./create_cluster.sh myproject-bigdata cluster-2-2gpu us-west1-a 2 2

project=$1
name=$2
zone=$3
num_nodes=$4
num_gpus=$5
region="${zone::-2}"

echo "### credentials ###"
gcloud container clusters get-credentials $name --zone $zone --project $project

echo "### deleting cluster google kuberntes engineer ###"

#yes | gcloud container clusters delete  $name