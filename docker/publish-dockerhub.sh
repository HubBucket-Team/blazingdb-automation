#!/bin/bash

#JOB PUBLISH

docker login

#nvidia-docker
docker tag demo blazingdb/blazingsql:version01


docker push
