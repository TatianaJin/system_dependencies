#!/usr/bin/env bash

. $(dirname $0)/utils.sh $@

PV_VERSION=1.6.6

function install_pv {
  green_echo ========== install pv $PV_VERSION ==========
  cd $src_dir
  [ -e pv-${PV_VERSION}.tar.gz ] || wget http://www.ivarch.com/programs/sources/pv-${PV_VERSION}.tar.gz || exit $?
  [ -e pv-${PV_VERSION} ] || tar -zxf pv-${PV_VERSION}.tar.gz || exit $?

  cd pv-${PV_VERSION}
  ./configure --prefix=$app_dir && make -j $make_threads && make install || exit $?
}

if hash pv > /dev/null 2> /dev/null; then
  blue_echo ========== pv is already installed ==========
  pv --version
else
  install_pv
fi
hash pv > /dev/null 2> /dev/null || echo Error installing pv, please see log
