#!/bin/bash
 
echo "#### Creando build/ ####"
rm -rf build/ && mkdir build/ && cd build/ && \
 
echo "#### Cmake ####"
cmake -DLIBGDF_HOME=/home/$USER/repo/libgdf ..
 
echo "#### Make ####"
make
 
echo "#### Ctest ####"
ctest
