#!/usr/bin/bash

############################################
#                                          #
# This script builds glog                  #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

if [ "X$GLOG_VERSION" == "X" ]; then
  GLOG_VERSION=0.4.0
fi

if [ "X${GLOG_HOME}" != "X" ]; then return; fi
export GLOG_HOME=$app_dir/glog-${GLOG_VERSION}
cd $src_dir
[ -e glog-${GLOG_VERSION}.tar.gz ] || wget "https://github.com/google/glog/archive/v${GLOG_VERSION}.tar.gz" -O glog-${GLOG_VERSION}.tar.gz || exit 1
[ -e glog-${GLOG_VERSION} ] || tar -zxf glog-${GLOG_VERSION}.tar.gz || exit 1

cd glog-${GLOG_VERSION}
mkdir -p build && cd build || exit 1
cmake .. -DCMAKE_INSTALL_PREFIX=${GLOG_HOME} && make -j $make_threads install || exit 1
echo export GLOG_HOME=$GLOG_HOME >> $bashrc
echo "export CMAKE_PREFIX_PATH=$GLOG_HOME:\$CMAKE_PREFIX_PATH" >> $bashrc
