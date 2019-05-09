#!/bin/bash
# Usage: nro_workers

echo "### docker build scheduler ###"
cp ./start_conda_gpu.sh ./dask-scheduler/
cp ./gpu_workflow.py ./dask-scheduler/
nvidia-docker build -t blazingdb/dask:scheduler ./dask-scheduler/

echo "### docker build worker ###"
cp ./start_conda_gpu.sh ./dask-scheduler/
cp ./gpu_workflow.py ./dask-scheduler/
nvidia-docker build -t blazingdb/dask:worker ./dask-worker/

echo "### docker network ###"
docker network create --subnet=172.18.0.0/16 dask_net

echo "### docker scheduler ###"
nvidia-docker run --rm -d --name bzsql_scheduler -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-15" --cpuset-mems="0" --net dask_net --ip 172.18.0.20 -p 8880:8888 -p 9000:9001 -p 8786:8786 -p 8787:8787 -v $PWD/results/:/blazingdb/data/results -v $PWD/tpch/:/blazingdb/data/tpch blazingdb/dask:scheduler

echo "### docker workers ###"
NRO_WORKERS="1"
if [ ! -z $1 ]; then
  NRO_WORKERS=$1
fi

if [ $NRO_WORKERS -gt 10 ]; then
  echo "No se pueden crear mas de 9 workers"
  exit 1
fi


x="1"
echo "Workers: "$NRO_WORKERS
while [ $x -le $NRO_WORKERS ]; do
  #echo "index: "$x
  NAME="bzsql_worker$x"
  IP="172.18.0.2$x"
  JUPYTER="888$x:8888"
  SUPERVISOR="900$x:9001"
  CMD="nvidia-docker run --rm -d --name $NAME -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus='0-11' --cpuset-mems='0' --net dask_net --ip $IP -p $JUPYTER -p $SUPERVISOR -v $PWD/results/:/blazingdb/data/results -v $PWD/tpch/:/blazingdb/data/tpch blazingdb/dask:worker"
  echo "======================="
  eval "$CMD"
  if [ ! $? != 0 ]; then
    echo "CMD: "$CMD
    echo "IP: "$IP
    echo "JUPYTER: "$JUPYTER
  fi
  x=$[$x+1]
done

echo "Done"
