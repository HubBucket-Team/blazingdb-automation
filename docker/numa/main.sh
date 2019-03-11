#!/bin/bash

#lscpu
#numactl --hardware
#grep Cpus_allowed_list /proc/18220/status
#grep Mems_allowed_list /proc/18220/status
#nvidia-smi topo -m
#nvidia-docker run --rm -p 8888:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 -d  blazingdb/blazingsql
# run on cpus and mems
#nvidia-docker run --rm --cpuset-cpus="0-3" --cpuset-mems="0" -v $PWD/tmp/:/tmp -ti blazingdb/blazingsql nano /tmp/holas.txt
#nvidia-smi
#nvidia-smi -q -g 0 -d UTILIZATION -l

#nvidia-docker run --name bzsql_one --rm -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-15" --cpuset-mems="0" -p 8880:8888 -p 9000:9001 -d blazingdb/blazingsql
#nvidia-docker run --name bzsql_two --rm -e NVIDIA_VISIBLE_DEVICES=1 --cpuset-cpus="32-47" --cpuset-mems="0" -p 8881:8888 -p 9001:9001 -d blazingdb/blazingsql
#nvidia-docker run --name bzsql_three --rm -e NVIDIA_VISIBLE_DEVICES=2 --cpuset-cpus="16-31" --cpuset-mems="1" -p 8882:8888 -p 9002:9001 -d blazingdb/blazingsql
#nvidia-docker run --name bzsql_four --rm -e NVIDIA_VISIBLE_DEVICES=3 --cpuset-cpus="48-63" --cpuset-mems="1" -p 8883:8888 -p 9003:9001 -d blazingdb/blazingsql

echo "### docker build ###"
nvidia-docker build blazingdb/numa:latest .

echo "### docker run ###"
nvidia-docker run --rm -d --name bzsql_single -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-11" --cpuset-mems="0" -p 8888:8888 -p 9001:9001 -p 9090:9090 -p 9091:9091 -p 9092:9092 blazingdb/numa:latest
