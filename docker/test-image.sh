#!/bin/bash
# Usage: tag_deploy

container-structure-test test --image blazingdb/blazingsql:$1 --config container-structure-test.yaml
