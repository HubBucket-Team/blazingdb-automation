# Dask and BlazingSql with Docker Compose
Run docker-compose twith dask and blazingsql stack

# Requirements
- To this demo we need install docker-compose : https://docs.docker.com/compose/install/
- Should exist the follow:
    - blazingsql-files.tar.gz into blazingdb-automation/docker/dask


# Build images easy way
Use docker_build_images.sh

```shell-script
cd  blazingdb-automation/docker/dask 
./docker_build_images.sh
```

# Build  docker compose

```shell-script
# To create containers with docker compose
cd blazingdb-automation/docker/dask
docker-compose -f docker-compose.yml  up
```

```shell-script
# To show  containers with docker compose
cd blazingdb-automation/docker/dask
docker-compose  ps
```

```shell-script
# To scale workers
cd blazingdb-automation/docker/dask
docker-compose scale worker=3
```

```shell-script
# To delete the  containers with docker compose
cd blazingdb-automation/docker/dask
docker-compose  down
```

# Test
```shell-script
# Enter the containers for dask scheduler and workers
docker exec -it dask_blazingdb-dask-scheduler-svc_1 bash
docker exec -it dask_worker1_1 bash
docker exec -it dask_worker2_1 bash
# Check the status in each nodos with:
supervisorctl status

# In any of workers, copy the demo.py, change the ip for the scheduler ip: client = Client('127.0.0.1:8786') 
docker exec -it dask_worker1_1 bash
source activate cudf
python demoral.py
go to: http://localhost:8787/status
```
