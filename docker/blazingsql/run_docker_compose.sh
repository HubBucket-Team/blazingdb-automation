#!/bin/bash

./docker_build_components.sh

echo "### Up ###"
docker-compose -d up

echo "### Logs ###"
docker-compose logs -f
