
echo "### docker run with gpu"

nvidia-docker run --name bzsql_one --rm -e NVIDIA_VISIBLE_DEVICES=0 --cpuset-cpus="0-15" --cpuset-mems="0" -p 8880:8888 -p 9000:9001 -d blazingdb/blazingsql
nvidia-docker run --name bzsql_two --rm -e NVIDIA_VISIBLE_DEVICES=1 --cpuset-cpus="32-47" --cpuset-mems="0" -p 8881:8888 -p 9001:9001 -d blazingdb/blazingsql
nvidia-docker run --name bzsql_three --rm -e NVIDIA_VISIBLE_DEVICES=2 --cpuset-cpus="16-31" --cpuset-mems="1" -p 8882:8888 -p 9002:9001 -d blazingdb/blazingsql
nvidia-docker run --name bzsql_four --rm -e NVIDIA_VISIBLE_DEVICES=3 --cpuset-cpus="48-63" --cpuset-mems="1" -p 8883:8888 -p 9003:9001 -d blazingdb/blazingsql
