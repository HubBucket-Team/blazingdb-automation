#!/bin/bash
# Project https://github.com/GoogleContainerTools/container-structure-test
# Usage: ./test-image.sh docker_image

container-structure-test test --image $1 --config container-structure-test.yaml
