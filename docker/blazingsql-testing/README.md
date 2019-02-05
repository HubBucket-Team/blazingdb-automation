
## Run BlazingSQL End to End test

## Developer mode

## Pre Requirements

**1. Clone the repository:**
```shell-script
git clone https://github.com/BlazingDB/blazingdb-automation.git
cd blazingdb-automation/
git checkout feature/sprint16-e2e-automation
cd docker/blazingsql-testing
```

-  You need the imagen **demo** and the **demobuid** are created, follow this README.md : https://github.com/BlazingDB/blazingdb-automation/blob/develop/README.md
-  Change the HEAD in Dockerfile to FROM {your_image_deploy_blazingsql}:latest on: blazingdb-automation/docker/blazingsql-testing/Dockerfile
-  You need a workspace  for end to end tes in your local machinet Example: **workspace-testing**
-  Into workspace-testing you need this  two components: **DataSet1Mb, configurationFile.json**
-  The configuration file similar like this, where  **"edith"**, is your local machine user. (change it!)
```shell-script
{
    "TestSettings": {
     "dataDirectory": "/home/edith/blazingdb/DataSet1Mb",
     "logDirectory": "/home/edith/blazingdb/logtest"
    }
}
```

**2.  Change the follow parameters:**
In the file: **run_complete_test.sh** change the parameters like this:
```shell-script
cd  ...blazingdb-automation/docker/blazingsql-testing
# Your local machine user
user=edith

# The volumen do you want to mount (DataSet1MB, configurationFile.json)
workdir=$whereis_workspace-testing

# Where the blazingdb-automation/docker/blazingsql-testing is
local_workdir=$whereis_blazingsql-testing 

# Asign the values to blazingsql image deploy and its tag
image=demo
tag=latest

```
**3. Launch the script to run end to end test**
```shell-script
cd $local_workdir
./run_complete_test.sh
```

## Jenkins Mode

## IN PROGRESS

## Pre Requirements

1.  Apache Drill
```shell-script
wget http://apache.mirrors.hoobly.com/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
tar -xvzf apache-drill-1.12.0.tar.gz
```

2. Data pruebas: 
tar -xvf DataSet1Mb.tar.gz

3. Archivo de configuracion
```shell-script
configurationFile.json

{
    "TestSettings": {
     "dataDirectory": "/home/edith/blazingdb/repositories/blazingsql/data-pruebas/DataSet1Mb",
     "logDirectory": "/home/edith/blazingdb/repositories/blazingsql/data-pruebas/logtest"
    }
}
```


## Changes in dockerfile blazingsql-testing

1. Change name in dockerfile: edith
2. Change the source in dockerfile: FROM demo:latest


## How build the e2e test

## 1. Build image to build blazingsql
```shell-script
cd docker/blazingsql-build
nvidia-docker build -t demobuild .
cp blazingsql-build.properties /home/edithbz/blazingdb/repositories/volumenes/worspace-docker
nvidia-docker run --rm -v /home/edithbz/blazingdb/repositories/volumenes/worspace-docker/:/home/builder/workspace/ -v /home/edithbz/blazingdb/repositories/volumenes/worspace-output/:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ demobuild
```

## 2. Buils image to deploy blazingsql

cd docker/blazingsql
```shell-script
cp /home/edithbz/blazingdb/repositories/volumenes/worspace-output/blazingsql-files.tar.gz  .
nvidia-docker build -t demo .
```

## 3. Build image to e2e test

cd /home/edithbz/blazingdb/repositories/volumenes/worspace-testing
```shell-script
nvidia-docker build -t blazingsqltest .
```

# 4. Enter shell terminal in the image blazingsqltest, also mapping you volumen
```shell-script
nvidia-docker run --name bzsqlcontainer --rm -p 8888:8888 -p 8887:8787 -p 8886:8786 -p 9002:9001 -v /home/edith/blazingdb/workspace-testing:/home/edith/blazingdb -ti blazingsqltest bash
cd /home/edith/blazing/blazingdb-testing/BlazingSQLTest
source activate cudf
```

## 5. Change the permissions
```shell-script
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /blazingsql/
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /home/edith/blazingdb/apache-drill-1.12.0/
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /home/edith/blazingdb/blazingdb-testing/
nvidia-docker exec -u root bzsqlcontainer chown -R edith:edith /home/edith/blazingdb/logTest/
```

## 6. In other terminal: Start the services
```shell-script
nvidia-docker exec bzsqlcontainer /home/jupyter/testing-libgdf
nvidia-docker exec bzsqlcontainer /home/jupyter/blazingdb_orchestator_service
nvidia-docker exec bzsqlcontainer java -jar /home/jupyter/BlazingCalcite.jar
```

## 7. Start up drill
```shell-script
nvidia-docker exec -ti bzsqlcontainer /bin/bash
cd blazingdb/apache-drill-1.12.0/bin/
./drill-embedded
```

## 8. Install dependencies into bzsqlcontainer , to start running test, in the terminal where cudf is activated
```shell-script
python allE2ETest.py configurationFile.json
```


