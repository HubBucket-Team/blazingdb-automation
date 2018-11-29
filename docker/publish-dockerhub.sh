#!/bin/bash

#JOB PUBLISH
# docker login

#nvidia-docker
nvidia-docker tag $1 mario21ic/nginx:latest

#docker push
