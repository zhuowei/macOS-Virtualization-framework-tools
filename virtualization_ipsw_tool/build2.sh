#!/bin/sh
set -e
clang -fmodules -target arm64-apple-macos12 virtualization_ipsw_tool.m -o vztool libinterpose_xpc.dylib
/usr/bin/codesign --force \
	--sign 52F754C59CFAC59BC5794F5A3B523EFE0667D7EB \
	--timestamp=none \
	--entitlements real.entitlements \
	vztool
