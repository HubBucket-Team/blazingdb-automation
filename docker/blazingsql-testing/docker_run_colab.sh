#!/bin/bash
# Usage image_name container_name directory_testing
# Example: blazingdb/blazingsql:colab-cuda10 blzsql_test_cuda10 blazingdb-testing/BlazingSQLTest

image_name=$1
container_name=$2
dir_testing=$3

docker run --rm --runtime=nvidia --name $container_name -d -ti -v $dir_testing/:/tmp/blazingdb/ $image_name bash

docker cp ./docker/colab/install_tests.sh $container_name:/tmp/
docker cp ./docker/colab/run_test.sh $container_name:/tmp/

docker exec $container_name service supervisor start
docker exec $container_name blazingsql status