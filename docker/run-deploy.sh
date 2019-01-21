#!/bin/bash
# Usage: tag_deploy

image_deploy="blazingdb/blazingsql:$1"

echo "### Run de Image Deploy ###"
nvidia-docker rm -f myjupyter
echo "nvidia-docker run --name myjupyter --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy"
nvidia-docker run --name myjupyter --rm -d -p 8884:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 $image_deploy

echo "### Open with browser ###"
echo "http://35.185.48.245:8884"
