#!/bin/bash
set -e
./build3.sh
./build2.sh
echo "rm /usr/local/zhuowei/vztool
rm /usr/local/zhuowei/libinterpose_xpc.dylib
put vztool /usr/local/zhuowei/
put libinterpose_xpc.dylib /usr/local/zhuowei/" | sftp -P 2223 root@localhost
