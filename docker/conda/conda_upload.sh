#!/bin/bash
# Usage: file_to_upload label

source activate builder
anaconda login --username mario21ic --password blazingdb2018123
anaconda upload --user BlazingDB $1 --label $2
