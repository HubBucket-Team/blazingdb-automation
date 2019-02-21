#!/bin/bash
# Usage: ./build.sh workspace_path

workspace_dir=/home/builder/workspace/
if [ ! -z $1 ]; then
  workspace_dir=$1
fi
echo "workspace_dir: $workspace_dir"

BUILD_TYPE='Release'
if [ $# -eq 3 ]; then
    BUILD_TYPE=$3
fi

working_directory=$PWD

cd $workspace_dir

#BEGIN main

#BEGIN dependencies

if [ ! -d dependencies ]; then
    mkdir dependencies
fi

echo "workspace_dir: $workspace_dir"

#BEGIN zeromq

zeromq_install_dir=$workspace_dir/dependencies/zeromq_install_dir

if [ ! -d $zeromq_install_dir ]; then
    echo "### Zeromq - Star ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/zeromq/libzmq.git
    cd $workspace_dir/dependencies/libzmq
    git checkout master

    zeromq_build_dir=$workspace_dir/dependencies/libzmq/build/
    echo "zeromq_build_dir: $zeromq_build_dir"

    mkdir -p $zeromq_build_dir
    if [ $? != 0 ]; then
      exit 1
    fi

    cd $zeromq_build_dir
    echo "### Zeromq - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$zeromq_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DENABLE_CURVE=OFF \
          -DZMQ_BUILD_TESTS=OFF \
          ..  
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Zeromq - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

fi

# Package zeromq
cd $workspace_dir
#mkdir -p ${output}/zeromq/
#if [ $? != 0 ]; then
#  exit 1
#fi
#cp -r $zeromq_install_dir/lib/* ${output}/zeromq/

echo "### Zeromq - end ###"
#END zeromq

#BEGIN jzmq

jzmq_install_dir=$workspace_dir/dependencies/jzmq_install_dir

if [ ! -d $jzmq_install_dir ]; then
    echo "### Jzmq - Start ###"
    rm -rf $jzmq_install_dir
    cd $workspace_dir/dependencies/
    git clone https://github.com/zeromq/jzmq.git
    cd jzmq
    git checkout master

    cd jzmq-jni
    LDFLAGS="-L$zeromq_install_dir/lib" CFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" ./autogen.sh
    LDFLAGS="-L$zeromq_install_dir/lib" CFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" ./configure --prefix=$jzmq_install_dir
    LDFLAGS="-L$zeromq_install_dir/lib" CFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-I$zeromq_install_dir/include -D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi
    cd ..

    echo "### Jzmq - mvn ###"
    mvn clean install -Dgpg.skip=true -DskipTests=true
    if [ $? != 0 ]; then
      exit 1
    fi
fi

# Package jzmq
#cd $workspace_dir
#mkdir -p ${output}/jzmq/
#cp -r $jzmq_install_dir/lib/* ${output}/jzmq/

echo "### Jzmq - end ###"
#END jzmq

#BEGIN boost

boost_install_dir=$workspace_dir/dependencies/boost_install_dir

if [ ! -d $boost_install_dir ]; then
    echo "### Boost - start ###"
    cd $workspace_dir/dependencies/

    boost_dir=$workspace_dir/dependencies/boost/
    mkdir -p $boost_dir

    wget http://archive.ubuntu.com/ubuntu/pool/main/b/boost1.58/boost1.58_1.58.0+dfsg.orig.tar.gz
    echo "Decompressing boost1.58_1.58.0+dfsg.orig.tar.gz ..."
    tar xf boost1.58_1.58.0+dfsg.orig.tar.gz -C $boost_dir
    echo "Boost package boost1.58_1.58.0+dfsg.orig.tar.gz was decompressed at $boost_dir"

    boost_build_dir=$boost_dir/boost_1_58_0

    # NOTE build Boost with old C++ ABI _GLIBCXX_USE_CXX11_ABI=0 and with -fPIC
    cd $boost_build_dir
    ./bootstrap.sh --with-libraries=system,filesystem,regex,atomic,chrono,container,context,thread --with-icu --prefix=$boost_install_dir
    ./b2 install variant=release define=_GLIBCXX_USE_CXX11_ABI=0 stage cxxflags=-fPIC cflags=-fPIC link=static runtime-link=static threading=multi --exec-prefix=$boost_install_dir --prefix=$boost_install_dir -a
    if [ $? != 0 ]; then
      exit 1
    fi
    echo "### Boost - end ###"
fi

#END boost

#BEGIN nvstrings

nvstrings_package=nvstrings
nvstrings_install_dir=$workspace_dir/dependencies/$nvstrings_package

if [ ! -d $nvstrings_install_dir ]; then
    echo "### Nvstring - start ###"
    cd $workspace_dir/dependencies/
    nvstrings_file=nvstrings-0.2.0-cuda9.2_py36_0.tar.bz2
    nvstrings_url=https://anaconda.org/nvidia/nvstrings/0.2.0/download/linux-64/$nvstrings_file
    wget $nvstrings_url
    mkdir $nvstrings_package

    #TODO percy remove this fix once nvstrings has pre compiler flags in its headers
    sed -i '1s/^/#define NVIDIA_NV_STRINGS_H_NVStrings\n/' $nvstrings_package/include/NVStrings.h
    sed -i '1s/^/#ifndef NVIDIA_NV_STRINGS_H_NVStrings\n/' $nvstrings_package/include/NVStrings.h
    echo "#endif" >> $nvstrings_package/include/NVStrings.h

    sed -i '1s/^/#define NVIDIA_NV_STRINGS_H_NVCategory\n/' $nvstrings_package/include/NVCategory.h
    sed -i '1s/^/#ifndef NVIDIA_NV_STRINGS_H_NVCategory\n/' $nvstrings_package/include/NVCategory.h
    echo "#endif" >> $nvstrings_package/include/NVCategory.h

    tar xvf $nvstrings_file -C $nvstrings_package

    if [ $? != 0 ]; then
      exit 1
    fi
fi

# Package nvstrings (always do this since this lib is needed by further deployment processes: conda, docker)
#cd $workspace_dir
#mkdir -p $output/nvstrings/
#cp -r $nvstrings_install_dir/* $output/nvstrings/

echo "### Nvstring - end ###"
#END nvstrings

#BEGIN libstd libhdfs3 

libhdfs3_package=libhdfs3
libhdfs3_install_dir=$workspace_dir/dependencies/$libhdfs3_package

if [ ! -d $libhdfs3_install_dir ]; then
    echo "### Libhdfs3 - start ###"
    cd $workspace_dir/dependencies/
    libhdfs3_url=https://s3-us-west-2.amazonaws.com/blazing-public-downloads/_libs_/libhdfs3/libhdfs3.tar.gz
    wget $libhdfs3_url
    mkdir $libhdfs3_package
    tar xvf "$libhdfs3_package".tar.gz -C $libhdfs3_package
    if [ $? != 0 ]; then
      exit 1
    fi
fi

#cd $workspace_dir
#mkdir -p $output/$libhdfs3_package/
#cp -r $libhdfs3_install_dir/* $output/$libhdfs3_package/
echo "### Libhdfs3 - end ###"

#END libhdfs3

#BEGIN googletest

googletest_install_dir=$workspace_dir/dependencies/googletest_install_dir

if [ ! -d $googletest_install_dir ]; then
    echo "### Googletest - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/googletest.git
    cd $workspace_dir/dependencies/googletest
    git checkout release-1.8.0

    googletest_build_dir=$workspace_dir/dependencies/googletest/build/
    mkdir -p $googletest_build_dir

    echo "### Googletest - cmake ###"
    cd $googletest_build_dir
    cmake -DCMAKE_BUILD_TYPE=Debug \
          -DCMAKE_INSTALL_PREFIX:PATH=$googletest_install_dir \
          -Dgtest_build_samples=ON \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Googletest - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi
    echo "### Googletest - End ###"
fi

#END googletest

#BEGIN flatbuffers

flatbuffers_install_dir=$workspace_dir/dependencies/flatbuffers_install_dir

if [ ! -d $flatbuffers_install_dir ]; then
    echo "### Flatbufferts - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/flatbuffers.git
    cd $workspace_dir/dependencies/flatbuffers
    git checkout 02a7807dd8d26f5668ffbbec0360dc107bbfabd5

    flatbuffers_build_dir=$workspace_dir/dependencies/flatbuffers/build/

    mkdir -p $flatbuffers_build_dir
    cd $flatbuffers_build_dir
    echo "### Flatbufferts - cmake ###"
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$flatbuffers_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Flatbufferts - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Flatbufferts - End ###"
fi

#END flatbuffers

#BEGIN lz4

lz4_install_dir=$workspace_dir/dependencies/lz4_install_dir

if [ ! -d $lz4_install_dir ]; then
    echo "### Lz4 - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/lz4/lz4.git
    cd $workspace_dir/dependencies/lz4
    git checkout v1.7.5

    lz4_build_dir=$workspace_dir/dependencies/lz4

    # NOTE build Boost with old C++ ABI _GLIBCXX_USE_CXX11_ABI=0 and with -fPIC
    echo "### Lz4 - make install ###"
    cd $lz4_build_dir
    CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC" PREFIX=$lz4_install_dir make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Lz4 - End ###"
fi

#END lz4

#BEGIN zstd

zstd_install_dir=$workspace_dir/dependencies/zstd_install_dir

if [ ! -d $zstd_install_dir ]; then
    echo "### Zstd - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/facebook/zstd.git
    cd $workspace_dir/dependencies/zstd
    git checkout v1.2.0

    zstd_build_dir=$workspace_dir/dependencies/zstd/build/cmake/build

    mkdir -p $zstd_build_dir

    echo "### Zstd - cmake ###"
    cd $zstd_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$zstd_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DZSTD_BUILD_STATIC=ON \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Zstd - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Zstd - End ###"
fi

#END zstd

#BEGIN brotli

brotli_install_dir=$workspace_dir/dependencies/brotli_install_dir

if [ ! -d $brotli_install_dir ]; then
    echo "### Brotli - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/brotli.git
    cd $workspace_dir/dependencies/brotli
    git checkout v0.6.0

    brotli_build_dir=$workspace_dir/dependencies/brotli/build/

    mkdir -p $brotli_build_dir

    echo "### Brotli - cmake ###"
    cd $brotli_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$brotli_install_dir \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DBUILD_SHARED_LIBS=OFF \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Brotli - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Brotli - End ###"
fi

#END brotli

#BEGIN snappy

snappy_install_dir=$workspace_dir/dependencies/snappy_install_dir

if [ ! -d $snappy_install_dir ]; then
    echo "### Snappy - Start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/google/snappy.git
    cd $workspace_dir/dependencies/snappy
    git checkout 1.1.3

    snappy_build_dir=$workspace_dir/dependencies/snappy

    # NOTE build Boost with old C++ ABI _GLIBCXX_USE_CXX11_ABI=0 and with -fPIC
    cd $snappy_build_dir
    CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" ./autogen.sh

    echo "### Snappy - Configure ###"
    CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" ./configure --prefix=$snappy_install_dir

    echo "### Snappy - make install ###"
    CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -O3 -fPIC -O2" make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Snappy - End ###"
fi

#END snappy

#BEGIN thrift

thrift_install_dir=$workspace_dir/dependencies/thrift_install_dir

if [ ! -d $thrift_install_dir ]; then
    echo "### Thrift - start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/apache/thrift.git
    cd $workspace_dir/dependencies/thrift
    git checkout 0.11.0

    thrift_build_dir=$workspace_dir/dependencies/thrift/build/

    mkdir -p $thrift_build_dir

    echo "### Thrift - cmake ###"
    cd $thrift_build_dir
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=$thrift_install_dir \
          -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_SHARED_LIBS=OFF \
          -DBUILD_TESTING=OFF \
          -DBUILD_EXAMPLES=OFF \
          -DBUILD_TUTORIALS=OFF \
          -DWITH_QT4=OFF \
          -DWITH_C_GLIB=OFF \
          -DWITH_JAVA=OFF \
          -DWITH_PYTHON=OFF \
          -DWITH_HASKELL=OFF \
          -DWITH_CPP=ON \
          -DWITH_STATIC_LIB=ON \
          -DWITH_LIBEVENT=OFF \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
          -DBOOST_ROOT=$boost_install_dir \
          ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Thrift - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Thrift - end ###"
fi

#END thrift

#BEGIN arrow

arrow_install_dir=$workspace_dir/dependencies/arrow_install_dir

if [ ! -d $arrow_install_dir ]; then
    echo "### Arrow - start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/apache/arrow.git
    cd $workspace_dir/dependencies/arrow
    git checkout apache-arrow-0.12.0

    arrow_build_dir=$workspace_dir/dependencies/arrow/cpp/build/
    
    mkdir -p $arrow_build_dir

    echo "### Arrow - cmake ###"
    cd $arrow_build_dir
    
    # NOTE for the arrow cmake arguments:
    # -DARROW_IPC=ON \ # need ipc for blazingdb-ral (because cudf)
    # -DARROW_HDFS=ON \ # blazingdb-io use arrow for hdfs
    # -DARROW_TENSORFLOW=ON \ # enable old ABI for C/C++
    
    BOOST_ROOT=$boost_install_dir \
    FLATBUFFERS_HOME=$flatbuffers_install_dir \
    LZ4_HOME=$lz4_install_dir \
    ZSTD_HOME=$zstd_install_dir \
    BROTLI_HOME=$brotli_install_dir \
    SNAPPY_HOME=$snappy_install_dir \
    THRIFT_HOME=$thrift_install_dir \
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX:PATH=$arrow_install_dir \
        -DARROW_WITH_LZ4=ON \
        -DARROW_WITH_ZSTD=ON \
        -DARROW_WITH_BROTLI=ON \
        -DARROW_WITH_SNAPPY=ON \
        -DARROW_WITH_ZLIB=ON \
        -DARROW_BUILD_STATIC=ON \
        -DARROW_BUILD_SHARED=ON \
        -DARROW_BOOST_USE_SHARED=OFF \
        -DARROW_BUILD_TESTS=OFF \
        -DARROW_TEST_MEMCHECK=OFF \
        -DARROW_BUILD_BENCHMARKS=OFF \
        -DARROW_IPC=ON \
        -DARROW_COMPUTE=ON \
        -DARROW_GPU=OFF \
        -DARROW_JEMALLOC=OFF \
        -DARROW_BOOST_VENDORED=OFF \
        -DARROW_PYTHON=OFF \
        -DARROW_HDFS=ON \
        -DARROW_TENSORFLOW=ON \
        -DARROW_PARQUET=ON \
        ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Arrow - make install ###"
    make -j4 install
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Arrow - end ###"
fi

#END arrow

#BEGIN aws-sdk-cpp

aws_sdk_cpp_build_dir=$workspace_dir/dependencies/aws-sdk-cpp/build

if [ ! -d $aws_sdk_cpp_build_dir ]; then
    echo "### Aws sdk - start ###"
    cd $workspace_dir/dependencies/
    git clone https://github.com/aws/aws-sdk-cpp.git
    cd $workspace_dir/dependencies/aws-sdk-cpp
    git checkout 864eb0bca8b48427f94850b7a8311ef0ae0f433b

    mkdir -p $aws_sdk_cpp_build_dir

    echo "### Aws sdk - cmake ###"
    cd $aws_sdk_cpp_build_dir
    
    # NOTE we only need core, s3 and s3-encryption, also we don't need to install this package
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_ONLY="core;s3;s3-encryption" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTING=OFF \
        -DENABLE_UNITY_BUILD=ON \
        -DCUSTOM_MEMORY_MANAGEMENT=0 \
        -DCPP_STANDARD=14 \
        -DCMAKE_C_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
        -DCMAKE_CXX_FLAGS=-D_GLIBCXX_USE_CXX11_ABI=0 \
        ..
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Aws sdk - make ###"
    make -j4
    if [ $? != 0 ]; then
      exit 1
    fi

    echo "### Arrow - end ###"
fi

#END aws-sdk-cpp
