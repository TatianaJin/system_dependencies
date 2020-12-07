#!/usr/bin/bash

############################################
#                                          #
# This script builds all dependencies      #
#                                          #
############################################

### Version info
export CMAKE_VERSION=3.18.4
export GCC_VERSION=10.2.0

export ORC_VERSION=1.5.3
export PROTOBUF_VERSION=3.5
export ZMQ_VERSION=4.3.3
export CPPZMQ_VERSION=4.6.0
export GFLAGS_VERSION=2.2.2
export GLOG_VERSION=0.4.0


exec_name=$0
. $(dirname $0)/utils.sh $@


echo export PATH=$app_dir/bin:\$PATH >> $bashrc
echo export CMAKE_PREFIX_PATH=$app_dir:\$CMAKE_PREFIX_PATH >> $bashrc


. $dir/install_gcc.sh || exit 1
. $dir/install_cmake.sh || exit 1

. $dir/install_protobuf.sh || exit 1 
. $dir/install_libhdfs.sh gsasl uuid || exit 1
. $dir/install_zmq.sh || exit 1
. $dir/install_orc.sh || exit 1
. $dir/install_gflags.sh || exit 1
. $dir/install_glog.sh || exit 1

echo >> $bashrc
