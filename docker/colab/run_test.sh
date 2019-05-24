#!/bin/bash
# TODO: agregar parametros para module and dataset

export NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
export NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/

cd /tmp/blazingdb/ && python3 -m EndToEndTests.allE2ETest configFileFalse.json
