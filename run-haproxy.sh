#!/bin/bash

export PATH=/usr/local/bin:$PATH
export OPENSSL_CONF=/etc/ssl/openssl.cnf
#openssl list -providers
/usr/local/bin/haproxy -vv
