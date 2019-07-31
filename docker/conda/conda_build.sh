#!/bin/bash

#nvidia-docker build --build-arg CUDA_VERSION=10.0 -t blazingdb/conda:latest .
nvidia-docker build -t blazingdb/conda:latest .
