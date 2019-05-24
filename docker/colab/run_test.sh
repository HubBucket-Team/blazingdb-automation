#!/bin/bash
# TODO: agregar parametros para module and dataset

echo "Waiting for apache drill on port 8047"
while ! nc -z localhost 8047; do sleep 3; done

export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/

cd /tmp/blazingdb/ && python3 -m EndToEndTests.allE2ETest configFileFalse.json
