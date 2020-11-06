#!/usr/bin/env bash

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

function check_return {
  if [ ! $? -eq 0 ]; then
    echo Encountered error. Please check log.
    exit
  fi
}

function install_lzip {
  cd $src_dir
  wget http://download.savannah.gnu.org/releases/lzip/lzip-1.22-rc1.tar.gz && tar -zxf lzip-1.22-rc1.tar.gz && cd lzip-1.22-rc1 || exit
  ./configure --prefix=$app_dir && make -j $make_threads && make install
  check_return
  cd -
}

function install_gmp {
  cd $src_dir
  blue_echo '========= installing gmp 6.2.0 ========='
  if [ ! -e gmp-6.2.0.tar.lz ]; then wget https://gmplib.org/download/gmp/gmp-6.2.0.tar.lz || wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.lz || exit; fi
  if [ ! -e gmp-6.2.0 ]; then
    hash lzip || install_lzip
    tar -xf gmp-6.2.0.tar.lz || exit
  fi
  cd gmp-6.2.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install
  check_return
}

function install_mpfr {
  cd $src_dir
  blue_echo '======== installing mpfr 4.1.0 ========='
  if [ ! -e mpfr-4.1.0.tar.gz ]; then wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz || exit; fi
  if [ ! -e mpfr-4.1.0 ]; then tar -xf mpfr-4.1.0.tar.gz || exit; fi
  cd mpfr-4.1.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install
  check_return
}

function install_mpc {
  cd $src_dir
  blue_echo '========= installing mpc 1.2.0 ========='
  if [ ! -e mpc-1.2.0.tar.gz ]; then wget https://ftp.gnu.org/gnu/mpc/mpc-1.2.0.tar.gz || exit; fi
  if [ ! -e mpc-1.2.0 ]; then tar -xf mpc-1.2.0.tar.gz || exit; fi
  cd mpc-1.2.0 && ./configure --prefix=$app_dir && make -j $make_threads && make install
  check_return
}

function install_gcc {
  if [ "X$GCC_VERSION" == "X" ]; then
    GCC_VERSION=10.2.0
  fi

  cd $src_dir
  blue_echo ======== installing gcc $GCC_VERSION  =========
  if [ ! -e gcc-$GCC_VERSION.tar.gz ]; then wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz || exit 1; fi
  if [ ! -e gcc-${GCC_VERSION} ]; then tar -xf gcc-${GCC_VERSION}.tar.gz || exit 1; fi
  cd gcc-${GCC_VERSION} && CC=/usr/bin/gcc CXX=/usr/bin/g++ ./configure --disable-multilib --prefix=$app_dir/gcc-${GCC_VERSION} && make -j $make_threads && make install || exit 1
}


green_echo '========================================'
echo
green_echo "install prefix $app_dir"
echo
green_echo '========================================'
echo

if hash dpkg; then
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
  CURRENT_GCC_VERSION=`gcc --version | grep [0-9][.][0-9]*[.][0-9]* -o`
  if [ "X$GCC_VERSION" == "X" ]; then exit 0; fi
  echo Detected GCC version ${CURRENT_GCC_VERSION}, required ${GCC_VERSION}
  version_no=(${CURRENT_GCC_VERSION//./ })  
  required_version_no=(${GCC_VERSION//./ })  
  if [[ ${version_no[0]} -eq ${required_version_no[0]} ]] && [[ ${version_no[1]} -eq ${required_version_no[1]} ]]; then return ; fi
fi
install_gcc || echo Failed to install GCC
