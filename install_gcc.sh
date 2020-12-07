#!/usr/bin/env bash

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

function install_lzip {
  cd $src_dir
  wget http://download.savannah.gnu.org/releases/lzip/lzip-1.22-rc1.tar.gz && tar -zxf lzip-1.22-rc1.tar.gz && cd lzip-1.22-rc1 || exit $?
  ./configure --prefix=$app_dir && make -j $make_threads && make install || exit $?
  cd -
}

function install_gmp {
  cd $src_dir
  blue_echo '========= installing gmp 6.2.0 ========='
  if [ ! -e gmp-6.2.0.tar.lz ]; then wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.lz || wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.lz || exit $?; fi
  if [ ! -e gmp-6.2.0 ]; then
    hash lzip 2>/dev/null || install_lzip
    tar -xf gmp-6.2.0.tar.lz || exit $?
  fi
  cd gmp-6.2.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install || exit $?
}

function install_mpfr {
  cd $src_dir
  blue_echo '======== installing mpfr 4.1.0 ========='
  if [ ! -e mpfr-4.1.0.tar.gz ]; then wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz || exit $?; fi
  if [ ! -e mpfr-4.1.0 ]; then tar -xf mpfr-4.1.0.tar.gz || exit $?; fi
  cd mpfr-4.1.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install || exit $?
}

function install_mpc {
  cd $src_dir
  blue_echo '========= installing mpc 1.2.0 ========='
  if [ ! -e mpc-1.2.0.tar.gz ]; then wget https://ftp.gnu.org/gnu/mpc/mpc-1.2.0.tar.gz || exit; fi
  if [ ! -e mpc-1.2.0 ]; then tar -xf mpc-1.2.0.tar.gz || exit; fi
  cd mpc-1.2.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install || exit $?
}

function install_gcc {
  if [ "X$GCC_VERSION" == "X" ]; then
    GCC_VERSION=10.2.0
  fi

  export GCC_HOME=$app_dir/gcc-${GCC_VERSION}
  export PATH=$GCC_HOME/bin:$PATH
  export CC=$GCC_HOME/bin/gcc
  export CXX=$GCC_HOME/bin/g++
  export LD_LIBRARY_PATH=$GCC_HOME/lib:$GCC_HOME/lib64:$LD_LIBRARY_PATH

  cd $src_dir
  blue_echo ======== installing gcc $GCC_VERSION  =========
  if [ ! -e gcc-$GCC_VERSION.tar.gz ]; then wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz || exit 1; fi
  if [ ! -e gcc-${GCC_VERSION} ]; then tar -xf gcc-${GCC_VERSION}.tar.gz || exit 1; fi
  cd gcc-${GCC_VERSION} && CC=/usr/bin/gcc CXX=/usr/bin/g++ ./configure --disable-multilib --prefix=$app_dir/gcc-${GCC_VERSION} && make -j $make_threads && make install || exit 1

  echo export GCC_HOME=$GCC_HOME >> $bashrc
  echo export PATH=\$GCC_HOME/bin:\$PATH >> $bashrc
  echo export CC=\$GCC_HOME/bin/gcc >> $bashrc
  echo export CXX=\$GCC_HOME/bin/g++ >> $bashrc
  echo export LD_LIBRARY_PATH=\$GCC_HOME/lib:\$GCC_HOME/lib64:\$LD_LIBRARY_PATH >> $bashrc
}

if hash dpkg 2>/dev/null; then
  echo
  dpkg -l | grep libgmp || install_gmp

  echo
  dpkg -l | grep libmpfr || install_mpfr

  echo
  dpkg -l | grep libmpc || install_mpc
else
  bold_echo This script requires dpkg, but not found. Now skipping checking libgmp, libmpfr and libmpc dependency.
fi

echo

if hash gcc 2> /dev/null; then
  CURRENT_GCC_VERSION=`gcc --version | grep [0-9]*[.][0-9]*[.][0-9]* -o`
  if [ "X$GCC_VERSION" == "X" ]; then return; fi
  echo Detected GCC version ${CURRENT_GCC_VERSION}, required ${GCC_VERSION}
  version_no=(${CURRENT_GCC_VERSION//./ })  
  required_version_no=(${GCC_VERSION//./ })  
  if [[ ${version_no[0]} -eq ${required_version_no[0]} ]] && [[ ${version_no[1]} -eq ${required_version_no[1]} ]]; then return; fi
fi
install_gcc || echo Failed to install GCC
