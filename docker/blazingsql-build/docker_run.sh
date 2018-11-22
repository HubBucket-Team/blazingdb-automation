#!/bin/bash
#nvidia-docker run --rm -v $src:/home/builder/src/ -v $output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$1
nvidia-docker run --rm -v /home/edithbz/blazingdb/repositories/blazingsql:/home/builder/src/ -v /home/edithbz/blazingdb/repositories/output:/home/builder/output -v $HOME/.ssh/:/home/builder/.ssh/ blazingdb/build:$1