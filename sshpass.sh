#!/bin/sh

# this script should be run in a bare alpine image

# https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/sshpass/APKBUILD
apk add curl build-base

VERSION=1.10
curl -fsSL "https://downloads.sourceforge.net/sshpass/sshpass-${VERSION}.tar.gz" | tar -xz
cd "sshpass-${VERSION}"

# https://stackoverflow.com/a/59473090
export CC="cc -static -no-pie"
./configure
make -j$(nproc)

mv sshpass ..
cd ..
rm -rf "sshpass-${VERSION}"

strip sshpass
file sshpass
ls -lh sshpass
./sshpass -V
ldd sshpass && { rm -rf sshpass; exit 1; } || mv sshpass sshpass-static
