#!/bin/bash

#nvidia-docker build --build-arg CUDA_VERSION=10.0 -t blazingdb/conda .
nvidia-docker build -t blazingdb/conda .
