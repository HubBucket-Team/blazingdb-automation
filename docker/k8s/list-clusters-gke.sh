#!/bin/bash
# Syntax: ./create_cluster.sh project_name cluster_name zone number_nodes number_gpus_per_node
# Example: ./create_cluster.sh myproject-bigdata cluster-2-2gpu us-west1-a 2 2


#gcloud projects list --sort-by=projectId

#gcloud config set project my-project

 #gcloud container clusters list


echo  " ****************** List Clusters Google Kubernetes Engine in all BlazingDB Projects******************"
for project in  $(gcloud projects list --sort-by=projectId --format="value(projectId)")
do
  #echo 
  gcloud config set project  $project > /dev/null 2>&1 &  
  gcloud container clusters list
  #echo $project
    if  [ -z  "$(gcloud container clusters list)" ] 
    then 
    var=""
    else 
    echo " ************** ProjectID  ************* "  $project
    fi
done


#gcloud projects list --sort-by=projectId --filter=name