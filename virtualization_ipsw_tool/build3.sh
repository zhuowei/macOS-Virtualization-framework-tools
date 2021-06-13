#!/bin/sh
set -e
clang -fmodules -target arm64-apple-macos12 interpose_xpc.m -o libinterpose_xpc.dylib -shared -install_name /usr/local/zhuowei/libinterpose_xpc.dylib
/usr/bin/codesign --force \
	--sign 52F754C59CFAC59BC5794F5A3B523EFE0667D7EB \
	--timestamp=none \
	libinterpose_xpc.dylib
