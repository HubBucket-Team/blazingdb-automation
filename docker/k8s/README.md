# Using Google Cli
## Requirements
- Ubuntu update  that is still valid
- A project in Cloud Platform (It is recommended to create a new project from the interface of GCP if you have a specific project you can set it)
- Remember to be admin allow you to create resources in GCP and enabled APIs (Fundamental Roles should you  have)
    - Kubernetes Engine Admine
    - Service Account user
- Then, perform the steps below in the local machine to start to use Google CLI


## Install  SDK de Google Cloud (In local machine)

```shell-script
# Open terminal in local machine
 
# Create environment variable for correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
 
# Add the Cloud SDK distribution URI as a package source
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
 
# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
 
# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

## Initialize the SDK (In local machine)

```shell-script
# Open terminal in local machine
 
# We need to init gcloud
gcloud init
 
**To continue, you must log in. Would you like to log in (Y / n)? Y
Pick cloud project to use:
 [1] [my-project-1]
 [2] [my-project-2]
 ...
Please enter your numeric choice:
** Which compute zone would you like to use as project default?
 [1] [asia-east1-a]
 [2] [asia-east1-b]
 ...
 [14] Do not use default zone
 Please enter your numeric choice:
 
** gcloud init confirm that you completed the configuration steps correctly:
gcloud has now been configured!
You can use [gcloud config] to change more gcloud settings.
 
Your active configuration is: [default]
```

## Add Kuberntes API (Through the Google Cloud Interface)

```shell-script
- In Google Cloud Platform, search APIs & Services section
- After select "Dashboard" go to "ENABLE APIS AND SERVICES"
- Search "KUBERNETES"
- To finish,  enable the API
```

## Install kubectl (local machine)

```shell-script
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

## Build the cluster in GKE

```shell-script
# Execute this command to create the infrastructure a node in GKE (Enter the folder k8s) and for intall the yaml blazingsql.yaml (blazingdb/blazingsql:v0.3.5)
./install.sh $project_name $name_cluster $zone $num_nodes $num_gpus $num_nodes $gpu_type $recipe

# Example:
./install.sh blazingdb-system-automation tmp-1-1-gpu us-west1-a 1 1 p100 blazingsql.yaml

# Then wait until the script finishes ant type the JUPYTER IP
# Example:
01:37:55   ************** Go to JUPYTER :  **********************************
01:37:55      - ip: 35.230.40.49
 
# Copy the ip into the browser ( the port is 80 by default and it is not necesary type)
35.230.40.49
 
# It takes approximately 8 minutes to set the deployment and and that the ip is enabled

**Note: Jupyter password is: rapids
```