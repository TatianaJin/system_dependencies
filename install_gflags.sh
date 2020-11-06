#!/usr/bin/bash

############################################
#                                          #
# This script builds gflags                #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

if [ "X$GFLAGS_VERSION" == "X" ]; then
  GFLAGS_VERSION=2.2.2
fi

if [ "X${GFLAGS_HOME}" != "X" ]; then return; fi
export GFLAGS_HOME=$app_dir/gflags-${GFLAGS_VERSION}
cd $src_dir
[ -e gflags-${GFLAGS_VERSION}.tar.gz ] || wget "https://github.com/gflags/gflags/archive/v${GFLAGS_VERSION}.tar.gz" -O gflags-${GFLAGS_VERSION}.tar.gz || exit 1
[ -e gflags-${GFLAGS_VERSION} ] || tar -zxf gflags-${GFLAGS_VERSION}.tar.gz || exit 1

cd gflags-${GFLAGS_VERSION}
mkdir -p build && cd build || exit 1
cmake .. -DCMAKE_INSTALL_PREFIX=${GFLAGS_HOME} && make -j $make_threads install || exit 1
echo export GFLAGS_HOME=$GFLAGS_HOME >> $bashrc
echo "export CMAKE_PREFIX_PATH=$GFLAGS_HOME:\$CMAKE_PREFIX_PATH" >> $bashrc
