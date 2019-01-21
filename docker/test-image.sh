#!/bin/bash
# Project https://github.com/GoogleContainerTools/container-structure-test
# Usage: ./test-image.sh tag_deploy

container-structure-test test --image blazingdb/blazingsql:$1 --config container-structure-test.yaml
