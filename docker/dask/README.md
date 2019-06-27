# Dask and BlazingSql with Docker Compose
Run docker-compose twith dask and blazingsql stack

# Requirements
- Should exist the follow:
- BlazingCalcite.jar and blazingdb_orchestator_service into  docker/dask/calcite_orchestrator directory
- blazingsql-files.tar.gz into docker/dask/ral_pyblazing
- data and notebooks docker/dask/ral_pyblazing


# Build docker compose

```shell-script
# Create the images to use in docker compose

# Into : cd docker/dask/calcite_orchestrator
docker build -t blazingdb/blazingsql:dask_calcite_orchestrator .

# Into : cd docker/dask/ral_pyblazing
docker build -t blazingdb/blazingsql:dask_ral_pyblazing .
```

```shell-script
# To create containers with docker compose
cd docker/dask
docker-compose -f docker-compose.yml  up
```

```shell-script
# To show  containers with docker compose
cd docker/dask
docker-compose  ps
```

```shell-script
# To delete the  containers with docker compose
cd docker/dask
docker-compose  down
```
