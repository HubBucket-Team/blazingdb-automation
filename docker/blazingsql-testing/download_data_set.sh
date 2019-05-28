#!/bin/bash
# Usage data_set directory

data_set=$1
directory=$2

if [ ! -d $directory/$data_set ]; then
  gsutil cp -R gs://blazingdbstorage/$data_set $directory
fi
