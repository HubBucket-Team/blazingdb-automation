
## Run BlazingSQL End to End test

## Developer mode

**1. Requirements**
-  You need the imagen **demo** and the **demobuid** are created, follow this : https://github.com/BlazingDB/blazingdb-automation/blob/develop/README.md
-  You need a workspace  for end to end tes in your local machinet, example: **workspace-testing**
-  Into **workspace-testing** you need this  two components: 
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
**2. Launch the script to run end to end test**
```shell-script
cd blazingdb-automation/docker/blazingsql-testing

# Run the script to end to end test
./run_complete_test.sh $USUARIO $WORKDIR $IMAGE_TAG $DATA_SET $BLAZINGDB_TESTING_BRANCH
```

## Jenkins Mode

## IN PROGRESS

## Pre Requirements

1.  Go to jenkins:  http://35.211.56.200:8080/view/BLAZINGSQL/job/04.ENDTOEND_TEST_BLAZINGSQL/

