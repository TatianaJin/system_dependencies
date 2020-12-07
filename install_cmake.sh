#!/usr/bin/bash

############################################
#                                          #
# This script builds CMake unless >= 3.13  #
#                                          #
############################################

if [ "X$app_dir" == "X" ]; then
  . $(dirname $0)/utils.sh $@
fi

if hash cmake 2>/dev/null; then
  # check version compatibility
  CURRENT_CMAKE_VERSION=`cmake --version | grep [0-9][.][0-9]*[.][0-9]* -o`
  echo Detected CMake version ${CURRENT_CMAKE_VERSION}, required 3.13 at minimum
  version_no=(${CURRENT_CMAKE_VERSION//./ })  
  if [[ ${version_no[0]} -eq 3 ]] && [[ ${version_no[1]} -gt 13 ]]; then skip=1; fi
fi

if [ ! $skip -eq 1 ] ; then
  export CMAKE_HOME=$app_dir/cmake-${CMAKE_VERSION}
  cd $src_dir
  [ -e cmake-${CMAKE_VERSION}.tar.gz ] || wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
  [ -e cmake-${CMAKE_VERSION} ] || tar -zxf cmake-${CMAKE_VERSION}.tar.gz

  cd cmake-${CMAKE_VERSION}
  ./configure --prefix=$app_dir
  make -j $make_threads install

  export PATH=$CMAKE_HOME/bin:$PATH
  echo export PATH=$CMAKE_HOME/bin:\$PATH >> $bashrc
fi
