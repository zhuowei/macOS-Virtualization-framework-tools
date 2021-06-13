#!/bin/sh
set -e
swiftc poke.swift -import-objc-header sandbox_header.h
/usr/bin/codesign --force \
	--sign 52F754C59CFAC59BC5794F5A3B523EFE0667D7EB \
	--timestamp=none \
	--entitlements real.entitlements \
	poke
