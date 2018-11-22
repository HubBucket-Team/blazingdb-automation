#!/bin/bash
nvidia-docker build -t blazingdb/deploy:$1 .
