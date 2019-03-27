# blazingdb-automation
blazingdb-automation for blazingdb > 3.0

# Build docker

This process will build and zip all the artifacts and binaries into a single file called blazingsql.tar.gz

```shell-script
mkdir -p /path/blazingsql/your/local/workspace/
cp blazingsql-build/blazingsql-build.properties /path/blazingsql/your/local/workspace/
cd docker/blazingsql-build
nvidia-docker build -t demobuild .
nvidia-docker run -e NEW_UID=$(id -u) -e NEW_GID=$(id -g) --rm -v /path/blazingsql/your/local/workspace/:/home/builder/workspace/ -v /path/output/:/home/builder/output -v /home/user/.ssh/:/home/builder/.ssh/ demobuild
```

then check /path/output/ there will be the file blazingsql.tar.gz
 

# Demo
```shell-script
cd docker/blazingsql
cp /path/output/blazingsql.tar.gz .
nvidia-docker build -t demo .
nvidia-docker run --rm -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 demo

# inside the container
cd /rapids && source activate gdf
# untar mortgage.tar.gz is optional 
tar -xzvf data/mortgage.tar.gz
bash utils/start_jupyter.sh
```

# Run Build and Deploy 
```shell-script
# Create the  belong folders
mkdir /home/$USER/blazingsql
mkdir /home/$USER/blazingsql/output
mkdir /home/$USER/blazingsql/workspace
mkdir /home/$USER/blazingsql/workspace-testing

# Execute the script to build and deploy into docker folder
cd docker
./build-deploy.sh latest cudf_branch blazingdb_protocol_branch  blazingdb_io_branch blazingdb_ral_branch blazingdb_orchestrator_branch blazingdb_calcite_branch  pyblazing_branch
./build-deploy.sh latest develop develop develop develop develop develop develop
```
# Run end to end test
```shell-script
# You need configurationFile.json and  DataSet1Mb into /home/$USER/blazingsql

#  Exeute the script to end to end in blazingdb-testing directory
cd blazingdb-testing
# Script
./run_complete_test.sh $USER $WORKDIR $IMAGE_TAG $DATA_SET $BLAZINGDB_TESTING_BRANCH
# Example
./run_complete_test.sh $USER  /home/$USER/blazingsql/ latest DataSet1Mb develop
```

Notes:
- You can mount your /tmp folder into the container  with -v /tmp:/tmp so this way you can use the from your host BlazingSQL and PyBlazing from the container.
- All the BlazingSQL stack is under supervisord, once the thing is running check: http://localhost:9001
- This docker container will run the JupyterLab service, try to connect there with (the default token is 'rapids'): http://localhost:8884/lab
