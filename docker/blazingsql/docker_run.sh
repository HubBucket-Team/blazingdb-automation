#!/bin/bash

nvidia-docker run --rm -p 8888:8888 -p 8787:8787 -p 8786:8786 -p 9001:9001 blazingdb/deploy:$1


