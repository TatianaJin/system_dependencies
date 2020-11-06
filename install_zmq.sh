#!/usr/bin/bash

############################################
#                                          #
# This script builds c++ ZeroMQ            #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi


if [ "X${ZMQ_HOME}" != "X" ]; then return; fi
export ZMQ_HOME=$app_dir/zeromq-${ZMQ_VERSION}
cd $src_dir
[ -e zeromq-${ZMQ_VERSION}.tar.gz ] || wget "https://github.com/zeromq/libzmq/releases/download/v${ZMQ_VERSION}/zeromq-${ZMQ_VERSION}.tar.gz" || exit 1
[ -e zeromq-${ZMQ_VERSION} ] || tar -zxf zeromq-${ZMQ_VERSION}.tar.gz || exit 1

cd zeromq-${ZMQ_VERSION}
mkdir -p build && cd build || exit 1
cmake .. -DCMAKE_INSTALL_PREFIX=${ZMQ_HOME} && make -j $make_threads install || exit 1

cd $src_dir
git clone https://github.com/zeromq/cppzmq.git || exit 1
cd cppzmq && git checkout tags/v${ZMQ_VERSION} && cp zmq.hpp $ZMQ_HOME/include

echo export ZMQ_HOME=$ZMQ_HOME >> $bashrc
echo "export CMAKE_PREFIX_PATH=$ZMQ_HOME:\$CMAKE_PREFIX_PATH" >> $bashrc
