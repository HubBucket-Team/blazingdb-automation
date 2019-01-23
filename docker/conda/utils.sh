#!/bin/bash
# Usage: file_to_upload label

file_name=$1
version=$2
python_version=$3 
build_number=$4

sudo mv $file_name blazingsql-${version}-${python_version}_${build_number}

#1.0
#py35
#0