#!/usr/bin/bash

##################################################################################
#                                                                                #
# This script builds all dependencies                                            #
#                                                                                #
# It is assumed that m4, wget, openssl development package, libgcrypt            #
# development package, and libxml2 and its developement package are              #
# already installed.                                                             #
#                                                                                #
##################################################################################

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


[ -e $bashrc ] && source $bashrc

# add to paths
entry_found=0
entries=(${PATH//:/ })
for i in ${entries[@]}; do if [ "$i" == "$app_dir/bin" ]; then entry_found=1; break; fi; done
if [ $entry_found -ne 1 ]; then echo export PATH=$app_dir/bin:\$PATH >> $bashrc; fi
entry_found=0
entries=(${CMAKE_PREFIX_PATH//:/ })
for i in ${entries[@]}; do if [ "$i" == "$app_dir" ]; then entry_found=1; break; fi; done
if [ $entry_found -ne 1 ]; then echo export CMAKE_PREFIX_PATH=$app_dir:\$CMAKE_PREFIX_PATH >> $bashrc; fi
entry_found=0
entries=(${LD_LIBRARY_PATH//:/ })
for i in ${entries[@]}; do if [ "$i" == "$app_dir/lib" ]; then entry_found=1; break; fi; done
if [ $entry_found -ne 1 ]; then echo export LD_LIBRARY_PATH=$app_dir/lib:\$LD_LIBRARY_PATH >> $bashrc; fi

export PATH=$app_dir/bin:$PATH
export CMAKE_PREFIX_PATH=$app_dir:$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=$app_dir/lib:$LD_LIBRARY_PATH


. $dir/install_gcc.sh || exit 1
. $dir/install_cmake.sh || exit 1

. $dir/install_protobuf.sh || exit 1
. $dir/install_libhdfs.sh gsasl uuid || exit 1
. $dir/install_zmq.sh || exit 1
. $dir/install_orc.sh || exit 1
. $dir/install_gflags.sh || exit 1
. $dir/install_glog.sh || exit 1

echo >> $bashrc
