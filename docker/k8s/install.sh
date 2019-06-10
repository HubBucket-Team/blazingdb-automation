#!/bin/bash
# Syntax: ./create_cluster.sh project_name cluster_name zone number_nodes number_gpus_per_node
# Example: ./create_cluster.sh myproject-bigdata cluster-2-2gpu us-west1-a 2 2

project=$1
name=$2
zone=$3
num_nodes=$4
num_gpus=$5
region="${zone::-2}"


echo "### creating cluster ###"
gcloud beta container --project "$project" clusters create "$name" --zone "$zone" --username "admin" --cluster-version "1.12.7-gke.10" --machine-type "n1-standard-4" --accelerator "type=nvidia-tesla-t4,count=$num_gpus" --image-type "COS" --disk-type "pd-standard" --disk-size "50" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "$num_nodes" --enable-cloud-logging --enable-cloud-monitoring --no-enable-ip-alias --network "projects/$project/global/networks/default" --subnetwork "projects/$project/regions/$region/subnetworks/default" --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair


echo "### credentials ###"
gcloud container clusters get-credentials $name --zone $zone --project $project


echo "### install nvidia driver ###"
cmd="kubectl"
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  echo 'Downloading kubectl'
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl
  chmod +x kubectl
  cmd="./kubectl"
fi
$cmd apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/stable/nvidia-driver-installer/cos/daemonset-preloaded.yaml


echo "### install blazingsql ###"
#$cmd apply -f pv.yaml
#$cmd apply -f pvc.yaml
#$cmd apply -f tcp/blazingdb_calcite_dep.yaml
#$cmd apply -f blazingdb_orch_dep.yaml
#$cmd apply -f tcp/blazingdb_ral_orchestrator_dep.yaml
#$cmd apply -f tcp/blazingdb_jupyter_dep.yaml

#$cmd apply -f tcp/blazingdb_orch_svc.yaml
#$cmd apply -f tcp/blazingdb_jupyter_svc.yaml

$cmd apply -f tcp/  .

echo "### command to connect ###"
echo "gcloud container clusters get-credentials $name --zone $zone --project $project"
