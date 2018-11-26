#!/bin/bash
# Usage: ./docker-build.sh number_version

nvidia-docker build -t blazingdb/ral:build$1 .
