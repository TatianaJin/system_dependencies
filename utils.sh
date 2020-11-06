#!/usr/bin/env bash

##### functions

function blue_echo { echo -e "\e[34m$@\e[0m"; }
function bold_echo { echo -e "\e[1m$@\e[0m"; }
function green_echo { echo -e "\e[32m$@\e[0m"; }

function untar {
  if hash pv 2> /dev/null; then
    pv $@ | tar -zxf -
  else
    tar -zxf $@
  fi
}

function usage {
  echo "$0 -p <install_prefix> [-j <threads> -b <bashrc_output>]"
}

### default

if [ "X$make_threads" == "X" ]; then
  make_threads=`lscpu | grep '^CPU(s)' | awk '{print $2}'`
fi
if [ "X$APP_DIR" != "X" ]; then
  app_dir=$APP_DIR
fi
dir=$(dirname $(realpath $0))
user_dir=`pwd`

### argparse

POSITIONAL=()
while [[ $# -gt 0 ]]; do
key="$1"

case $key in
    -h|--help)
    usage
    exit 0
    ;;
    -p|--prefix)
    app_dir="$2"
    shift # past argument
    shift # past value
    ;;
    -j)
    make_threads="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--bashrc)
    bashrc="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "X$app_dir" == "X" ]; then usage; exit 0; fi

if [ "X$bashrc" == "X" ]; then
  bashrc=$app_dir/graxy.bashrc
fi
src_dir=$app_dir/src
mkdir -p $src_dir

export app_dir
export src_dir
export make_threads
export bashrc

green_echo "INSTALL PREFIX = ${app_dir}"
green_echo "THREADS        = ${make_threads}"
green_echo "BASHRC         = ${bashrc}"
