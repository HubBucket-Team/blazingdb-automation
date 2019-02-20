
## Run BlazingSQL End to End test

## Developer mode

**1. Requirements**
-  You need the imagen **demo** and the **demobuid** are created, follow this : https://github.com/BlazingDB/blazingdb-automation/blob/develop/README.md
-  You need a workspace  for end to end tes in your local machinet, example: **workspace-testing**
-  Into **workspace-testing** you need this  two components: 
        * DataSet1Mb
        * configurationFile.json
-  The configuration file similar like this, where  **"edith"**, is your local machine user. (change it!)
```shell-script
{
    "TestSettings": {
     "dataDirectory": "/home/edith/blazingdb/DataSet1Mb/",
     "logDirectory": "/home/edith/blazingdb/logtest/"
    }
}
```
- Clone this repo and use: feature/sprint16-e2e-automation  branch

**2. Launch the script to run end to end test**
```shell-script
cd blazingdb-automation/docker/blazingsql-testing

#  Comment JENKINS MODE and descoment DEVELOP MODE, line 68 and 70 in run_complete_test.sh
nvidia-docker run --name bzsqlcontainer -d -p ....

# Run the script to end to end test
./run_complete_test.sh $USUARIO $WORKDIR $IMAGE_TAG $DATA_SET $BLAZINGDB_TESTING_BRANCH

# Example:
./run_complete_test.sh  edith  /home/edith/blazingdb/workspace-testing  demo:latest  DataSet1Mb develop
```

## Jenkins Mode

## IN PROGRESS

## Pre Requirements

1.  Go to jenkins:  http://35.211.56.200:8080/view/BLAZINGSQL/job/04.ENDTOEND_TEST_BLAZINGSQL/

