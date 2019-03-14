#!/bin/bash

docker build -t blazingdb/dask:scheduler ./dask-scheduler/
docker build -t blazingdb/dask:worker ./dask-worker/

docker network create --subnet=172.18.0.0/16 dask_net
docker run --net dask_net --ip 172.18.0.22 -p 8787 -d blazingdb/dask:scheduler
docker run --net dask_net --ip 172.18.0.23 -d blazingdb/dask:worker
docker run --net dask_net --ip 172.18.0.23 -d blazingdb/dask:worker
