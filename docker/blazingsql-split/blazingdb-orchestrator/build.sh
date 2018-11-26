#!/bin/bash
 
echo "#### Creando build/ ####"
rm -rf build/ && mkdir build/ && cd build/ && \
 
echo "#### Cmake ####"  && \
cmake ..  && \
 
echo "#### Make ####" && \
make && \
 
echo "#### Ctest ####" && \
ctest
