#!/usr/bin/bash

############################################
#                                          #
# This script builds Apache ORC With fPIC #
#                                          #
############################################

# dependencies
SNAPPY_VERSION=1.1.7
ZLIB_VERSION=1.2.11
LZ4_VERSION=1.7.5


function build_snappy {
  SNAPPY_HOME=$app_dir/snappy-${SNAPPY_VERSION}
  if [ ! -e $SNAPPY_HOME ]; then
    cd $src_dir
    [ -e snappy-${SNAPPY_VERSION}.tar.gz ] || wget "https://github.com/google/snappy/archive/${SNAPPY_VERSION}.tar.gz" -O snappy-${SNAPPY_VERSION}.tar.gz || exit 1
    [ -e snappy-${SNAPPY_VERSION} ] || tar -zxf snappy-${SNAPPY_VERSION}.tar.gz || exit 1

    cd snappy-${SNAPPY_VERSION}
    mkdir -p build && cd build || exit 1
    cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DSNAPPY_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${SNAPPY_HOME} -DBUILD_SHARED_LIBS=OFF && make -j $make_threads install || exit 1
  fi
  export SNAPPY_HOME
  #export LD_LIBRARY_PATH=$SNAPPY_HOME/lib:$LD_LIBRARY_PATH
  #export LIBRARY_PATH=$SNAPPY_HOME/lib:$LIBRARY_PATH
  echo export SNAPPY_HOME=$SNAPPY_HOME >> $bashrc
}

function build_zlib {
  ZLIB_HOME=$app_dir/zlib-${ZLIB_VERSION}
  if [ ! -e $ZLIB_HOME ]; then
    cd $src_dir
    [ -e zlib-${ZLIB_VERSION}.tar.gz ] || wget "http://zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz" || exit 1
    [ -e zlib-${ZLIB_VERSION} ] || tar -zxf zlib-${ZLIB_VERSION}.tar.gz || exit 1

    cd zlib-${ZLIB_VERSION}
    mkdir -p build && cd build || exit 1
    cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=${ZLIB_HOME} -DBUILD_SHARED_LIBS=OFF && make -j $make_threads install || exit 1
  fi
  export ZLIB_HOME
  export LD_LIBRARY_PATH=$ZLIB_HOME/lib:$LD_LIBRARY_PATH
  export LIBRARY_PATH=$ZLIB_HOME/lib:$LIBRARY_PATH
  echo export ZLIB_HOME=$ZLIB_HOME >> $bashrc
}

function build_lz4 {
  LZ4_HOME=$app_dir/lz4-${LZ4_VERSION}
  if [ ! -e $LZ4_HOME ]; then
    cd $src_dir
    [ -e lz4-${LZ4_VERSION}.tar.gz ] || wget "https://github.com/lz4/lz4/archive/v${LZ4_VERSION}.tar.gz" -O lz4-${LZ4_VERSION}.tar.gz || exit 1
    [ -e lz4-${LZ4_VERSION} ] || tar -zxf lz4-${LZ4_VERSION}.tar.gz || exit 1

    cd lz4-${LZ4_VERSION}
    mkdir -p build && cd build || exit 1
    cmake ../contrib/cmake_unofficial -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=${LZ4_HOME} -DBUILD_SHARED_LIBS=OFF && make -j $make_threads install || exit 1
  fi
  export LZ4_HOME
  export LD_LIBRARY_PATH=$LZ4_HOME/lib:$LD_LIBRARY_PATH
  export LIBRARY_PATH=$LZ4_HOME/lib:$LIBRARY_PATH
  echo export LZ4_HOME=$LZ4_HOME >> $bashrc
}

 
function install_dependencies {
  build_snappy
  build_zlib
  build_lz4
}

function build_orc {
  ORC_HOME=${app_dir}/orc-${ORC_VERSION}
  cd $src_dir
  [ -e orc ] || git clone https://github.com/apache/orc.git && cd orc || exit 1
  git checkout rel/release-${ORC_VERSION}

  mkdir -p build && cd build
  rm -f CMakeCache.txt
  export CMAKE_PREFIX_PATH=$SNAPPY_HOME:$ZLIB_HOME:$CMAKE_PREFIX_PATH
  echo CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
  cmake .. -DBUILD_JAVA=OFF -DBUILD_LIBHDFSPP=OFF -DBUILD_CPP_TESTS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=$ORC_HOME -DBUILD_TOOLS=OFF
  make -j10 install
  # make test-out
  export ORC_HOME
  echo export ORC_HOME=$ORC_HOME >> $bashrc
}

[ "X$ORC_HOME" != "X" ] && [ -e $ORC_HOME ] && return
install_dependencies || exit 1
build_orc
