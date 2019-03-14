#!/bin/bash

echo "### docker build scheduler ###"
nvidia-docker build -t blazingdb/dask:scheduler ./dask-scheduler/

echo "### docker build worker ###"
nvidia-docker build -t blazingdb/dask:worker ./dask-worker/

echo "### docker network ###"
nvidia-docker network create --subnet=172.18.0.0/16 dask_net

echo "### docker scheduler ###"
nvidia-docker run --rm -d --name bzsql_scheduler -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" --net dask_net --ip 172.18.0.22 -p 8880:8888 -p 9000:9001 -p 8786:8786 -p 8787:8787 blazingdb/dask:scheduler

echo "### docker workers ###"
nvidia-docker run --rm -d --name bzsql_worker1 -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" --net dask_net --ip 172.18.0.23 -p 8881:8888 -p 9001:9001 blazingdb/dask:worker
nvidia-docker run --rm -d --name bzsql_worker2 -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" --net dask_net --ip 172.18.0.24 -p 8882:8888 -p 9002:9001 blazingdb/dask:worker
nvidia-docker run --rm -d --name bzsql_worker3 -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" --net dask_net --ip 172.18.0.25 -p 8883:8888 -p 9003:9001 blazingdb/dask:worker
nvidia-docker run --rm -d --name bzsql_worker4 -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" --net dask_net --ip 172.18.0.26 -p 8884:8888 -p 9004:9001 blazingdb/dask:worker
