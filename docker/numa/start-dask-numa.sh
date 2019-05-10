#!/bin/bash

echo "### docker build scheduler ###"
nvidia-docker build -t blazingdb/dask:scheduler ./dask-scheduler/

echo "### docker build worker ###"
nvidia-docker build -t blazingdb/dask:worker ./dask-worker/

echo "### docker network ###"
docker network create --subnet=172.18.0.0/16 dask_net

echo "### docker scheduler ###"
nvidia-docker run --rm -d --name bzsql_scheduler -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-15" --cpuset-mems="0" --net dask_net --ip 172.18.0.20 -p 8880:8888 -p 9000:9001 -p 8786:8786 -p 8787:8787 -v $PWD/results/:/blazingdb/data/results -v /datasets/mortgage/:/blazingdb/data/tpch blazingdb/dask:scheduler

echo "### docker workers numa node 0 ###"
nvidia-docker run --rm -d --name bzsql_worker1 -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-15" --cpuset-mems="0" --net dask_net --ip 172.18.0.21 -p 8881:8888 -p 9001:9001 -v $PWD/results/:/blazingdb/data/results  -v /datasets/mortgage/:/blazingdb/data/tpch blazingdb/dask:worker
nvidia-docker run --rm -d --name bzsql_worker2 -e NVIDIA_VISIBLE_DEVICES=1 --cpuset-cpus="32-47" --cpuset-mems="0" --net dask_net --ip 172.18.0.22 -p 8882:8888 -p 9002:9001 -v $PWD/results/:/blazingdb/data/results -v /datasets/mortgage/:/blazingdb/data/tpch blazingdb/dask:worker

echo "### docker workers numa node 1 ###"
nvidia-docker run --rm -d --name bzsql_worker3 -e NVIDIA_VISIBLE_DEVICES=2 --cpuset-cpus="16-31" --cpuset-mems="1" --net dask_net --ip 172.18.0.23 -p 8883:8888 -p 9003:9001 -v $PWD/results/:/blazingdb/data/results -v /datasets/mortgage/:/blazingdb/data/tpch blazingdb/dask:worker
nvidia-docker run --rm -d --name bzsql_worker4 -e NVIDIA_VISIBLE_DEVICES=3 --cpuset-cpus="48-63" --cpuset-mems="1" --net dask_net --ip 172.18.0.24 -p 8884:8888 -p 9004:9001 -v $PWD/results/:/blazingdb/data/results -v /datasets/mortgage/:/blazingdb/data/tpch blazingdb/dask:worker
