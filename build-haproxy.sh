#!/bin/bash

# The script for building HAProxy with open-quantum-safe algorithms.
# Arguments: build-path openssl-install-path haproxy-install-path make-args
#            (open-quantum-safe openssl must be installed in openssl-install-path)

# Copyright (c) Institute of Mathematics and Computer Science, University of Latvia
# Licence: MIT
# Contributors:
#   Sergejs Kozlovics, 2022

export BUILD_PATH=build
export OPENSSL_INSTALL_PATH=/usr
export HAPROXY_INSTALL_PATH=/usr/local
export MAKE_ARGS="TARGET=cygwin"

# define the haproxy version to download and build
#export HAPROXY_MAJOR_VERSION=2.8
#export HAPROXY_VERSION=2.8.1
#export HAPROXY_DEVEL=""

export HAPROXY_MAJOR_VERSION=3.0
export HAPROXY_VERSION="3.0-dev12"
export HAPROXY_DEVEL="/devel"


mkdir -p $HAPROXY_INSTALL_PATH
if [ -f "$HAPROXY_INSTALL_PATH/sbin/haproxy" ]; then
    echo oqs-haproxy has already been installed, skipping the build process
    exit
fi

mkdir -p $BUILD_PATH
if [ ! -d "${BUILD_PATH}/haproxy" ]; then
  # /usr/bin/curl -o haproxy-${HAPROXY_VERSION}.tar.gz http://www.haproxy.org/download/${HAPROXY_MAJOR_VERSION}/src/haproxy-${HAPROXY_VERSION}.tar.gz
  wget http://www.haproxy.org/download/${HAPROXY_MAJOR_VERSION}/src${HAPROXY_DEVEL}/haproxy-${HAPROXY_VERSION}.tar.gz
  tar xzvf haproxy-${HAPROXY_VERSION}.tar.gz
  mv haproxy-${HAPROXY_VERSION} ${BUILD_PATH}/haproxy
  rm haproxy-${HAPROXY_VERSION}.tar.gz
  #variant (if git and some other libs already installed):
  #git clone http://git.haproxy.org/git/haproxy-${HAPROXY_MAJOR_VERSION}.git ${BUILD_PATH}/haproxy
fi

cd ${BUILD_PATH}/haproxy

if [[ $OSTYPE == 'darwin'* ]]; then
  OQS_OPT=" -loqs"
  # ^^^ -loqs specifies liboqs as dependency, needed on macOS
else
  OQS_OPT=""
fi

if [[ -z "$MAKE_DEFINES" ]] ; then nproc=$(getconf _NPROCESSORS_ONLN) && MAKE_DEFINES="-j $nproc"; fi \
  && make $MAKE_DEFINES \
    USE_THREAD=1 \
    USE_OPENSSL=1 \
    SSL_INC=$OPENSSL_INSTALL_PATH/include SSL_LIB=$OPENSSL_INSTALL_PATH/lib \
    LDFLAGS="-Wl,-L$OPENSSL_INSTALL_PATH/lib,-L$HAPROXY_INSTALL_PATH/lib,-rpath,$OPENSSL_INSTALL_PATH/lib,-rpath,$HAPROXY_INSTALL_PATH/lib $OQS_OPT" \
    ${MAKE_ARGS}


SUDO=`which sudo 2>/dev/null`
$SUDO mkdir -p $HAPROXY_INSTALL_PATH
$SUDO make PREFIX=$HAPROXY_INSTALL_PATH install

cp $HAPROXY_INSTALL_PATH/sbin/haproxy.exe $HAPROXY_INSTALL_PATH/bin/
cp /usr/local/bin/cygoqs-*.dll $HAPROXY_INSTALL_PATH/sbin/
cp /usr/local/bin/oqsprovider*.dll $HAPROXY_INSTALL_PATH/sbin/
cp /usr/bin/cygcrypto-3.dll $HAPROXY_INSTALL_PATH/sbin/
cp /usr/bin/cygssl-3.dll $HAPROXY_INSTALL_PATH/sbin/
cp /usr/bin/cygz.dll $HAPROXY_INSTALL_PATH/sbin/
cp /cygdrive/c/cygwin64/bin/cygwin1.dll $HAPROXY_INSTALL_PATH/sbin/
cp /cygdrive/c/cygwin64/bin/cyggcc_s-seh-1.dll $HAPROXY_INSTALL_PATH/sbin/
