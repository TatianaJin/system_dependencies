#!/usr/bin/bash

############################################
#                                          #
# This script builds libhdfs               #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

function install_gsasl {
  cd $src_dir
  [ -e libgsasl-1.8.1.tar.gz ] || wget ftp://ftp.gnu.org/gnu/gsasl/libgsasl-1.8.1.tar.gz || exit 1
  [ -e libgsasl-1.8.1 ] || untar libgsasl-1.8.1.tar.gz || exit 1

  cd libgsasl-1.8.1
  ./configure --prefix=$app_dir/libgsasl-1.8.1 && make -j $make_threads && make install || exit 1
  # export LD_LIBRARY_PATH=$app_dir/libgsasl-1.8.1/lib:$LD_LIBRARY_PATH
  export CMAKE_PREFIX_PATH=$app_dir/libgsasl-1.8.1:$CMAKE_PREFIX_PATH

  echo export LD_LIBRARY_PATH=$app_dir/libgsasl-1.8.1/lib:\$LD_LIBRARY_PATH >> $bashrc
}

function build_libuuid {
  LIBUUID_HOME=$app_dir/libuuid-1.0.3
  cd $src_dir
  [ -e libuuid-1.0.3.tar.gz ] || wget "https://udomain.dl.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz" || exit 1
  [ -e libuuid-1.0.3 ] || untar libuuid-1.0.3.tar.gz || exit 1

  cd libuuid-1.0.3
  mkdir -p build && cd build || exit 1
  cmake .. -DCMAKE_INSTALL_PREFIX=${LIBUUID_HOME} && make -j $make_threads install || exit 1

  export CMAKE_PREFIX_PATH=$LIBUUID_HOME:$CMAKE_PREFIX_PATH
  echo export LD_LIBRARY_PATH=$LIBUUID_HOME/lib:\$LD_LIBRARY_PATH >> $bashrc
}

function build {
  LIBHDFS3_HOME=$app_dir/libhdfs
  cd $src_dir
  [ -e libhdfs ] || git clone https://github.com/TatianaJin/libhdfs3_fork.git libhdfs || exit 1

  cd libhdfs
  mkdir -p build && cd build || exit 1
  cmake .. -DCMAKE_INSTALL_PREFIX=${LIBHDFS3_HOME} && make -j $make_threads install || exit 1

  export LIBHDFS3_HOME
  echo export LIBHDFS3_HOME=$LIBHDFS3_HOME >> $bashrc
}

if hash dpkg; then
  echo
  dpkg -l | grep libgsasl || install_gsasl
else
  if [ $# -eq 2 ]; then
    $2
  else
    bold_echo This script needs dpkg, but not found. If gsasl need to be installed, please run \`install_libhdfs.sh '<install_prefix>' install_gsasl\`.
  fi
fi

build
