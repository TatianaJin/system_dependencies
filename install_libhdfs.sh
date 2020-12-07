#!/usr/bin/bash

############################################
#                                          #
# This script builds libhdfs               #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh
fi

function gsasl {
  GSASL_HOME=$app_dir/libgsasl-1.8.1
  if [ ! -e $GSASL_HOME ]; then
    green_echo '================================ gsasl ================================'
    cd $src_dir
    [ -e libgsasl-1.8.1.tar.gz ] || wget ftp://ftp.gnu.org/gnu/gsasl/libgsasl-1.8.1.tar.gz || exit 1
    [ -e libgsasl-1.8.1 ] || untar libgsasl-1.8.1.tar.gz || exit 1

    cd libgsasl-1.8.1
    ./configure --prefix=$app_dir/libgsasl-1.8.1 && make -j $make_threads && make install || exit 1
    echo export LD_LIBRARY_PATH=$app_dir/libgsasl-1.8.1/lib:\$LD_LIBRARY_PATH >> $bashrc
  fi
  export CMAKE_PREFIX_PATH=$app_dir/libgsasl-1.8.1:$CMAKE_PREFIX_PATH
}

function uuid {
  LIBUUID_HOME=$app_dir/libuuid-1.0.3
  if [ ! -e $LIBUUID_HOME ]; then
    green_echo '================================ uuid ================================'
    cd $src_dir
    [ -e libuuid-1.0.3.tar.gz ] || wget "https://udomain.dl.sourceforge.net/project/libuuid/libuuid-1.0.3.tar.gz" || exit 1
    [ -e libuuid-1.0.3 ] || untar libuuid-1.0.3.tar.gz || exit 1

    cd libuuid-1.0.3
    ./configure --prefix=${LIBUUID_HOME} && make -j $make_threads install || exit 1
    echo export LD_LIBRARY_PATH=$LIBUUID_HOME/lib:\$LD_LIBRARY_PATH >> $bashrc
  fi
  export CMAKE_PREFIX_PATH=$LIBUUID_HOME:$CMAKE_PREFIX_PATH
}

function build {
  green_echo '================================ libhdfs3 ================================'
  LIBHDFS3_HOME=$app_dir/libhdfs
  cd $src_dir
  [ -e libhdfs ] || git clone https://github.com/TatianaJin/libhdfs3_fork.git libhdfs || exit 1

  cd libhdfs
  mkdir -p build && cd build || exit 1
  cmake .. -DCMAKE_INSTALL_PREFIX=${LIBHDFS3_HOME} && make -j $make_threads install || exit 1

  export LIBHDFS3_HOME
  echo export LIBHDFS3_HOME=$LIBHDFS3_HOME >> $bashrc
  echo export LD_LIBRARY_PATH=$LIBHDFS3_HOME/lib:\$LD_LIBRARY_PATH >> $bashrc
}

if [ "X" == "X$LIBHDFS3_HOME" ]; then
  if hash dpkg 2>/dev/null; then
    echo
    dpkg -l | grep libgsasl || gsasl
    dpkg -l | grep libuuid || uuid
  else
    if [ $# -ge 1 ]; then
      for cmd in $@; do $cmd; done
    else
      bold_echo This script needs dpkg, but not found. If dependencies need to be installed, please run \`install_libhdfs.sh '<install_prefix>' '<dependencies>'\`.
    fi
  fi

  build
else
  green_echo "libhdfs3 home $LIBHDFS3_HOME"
fi
