#!/usr/bin/bash

############################################
#                                          #
# This script builds protobuf              #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh
fi

if [ "X$PROTOBUF_HOME" == "X" ] ; then
  green_echo "================================ install protobuf to $PROTOBUF_HOME ================================"
  [ "X$PROTOBUF_VERSION" == "X" ] && [ $# -eq 1 ] && export PROTOBUF_VERSION=$1
  PROTOBUF_HOME=$app_dir/protobuf-${PROTOBUF_VERSION}

  cd $src_dir
  [ -e protobuf-cpp-3.5.0.tar.gz ] || wget https://github.com/protocolbuffers/protobuf/releases/download/v3.5.0/protobuf-cpp-3.5.0.tar.gz
  [ -e protobuf-3.5.0 ] || untar protobuf-cpp-3.5.0.tar.gz
  cd protobuf-3.5.0
  ./configure CXXFLAGS=-fPIC --prefix=${PROTOBUF_HOME} && make -j $make_threads install || exit 1

  export PROTOBUF_HOME
  echo export PROTOBUF_HOME=$PROTOBUF_HOME >> $bashrc
  echo export LD_LIBRARY_PATH=$PROTOBUF_HOME/lib:\$LD_LIBRARY_PATH >> $bashrc
else
  green_echo "================================ protobuf home $PROTOBUF_HOME ================================"
fi
export CMAKE_PREFIX_PATH=$PROTOBUF_HOME:$CMAKE_PREFIX_PATH
