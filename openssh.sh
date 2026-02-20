#!/bin/sh

# this script should be run in a bare alpine image

# https://github.com/openssh/openssh-portable#building-portable-openssh
# https://gist.github.com/fumiyas/b4aaee83e113e061d1ee8ab95b35608b
apk add \
    clang \
    git \
    build-base \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static

git clone https://github.com/openssh/openssh-portable
cd openssh-portable
git checkout $(git tag --sort=-creatordate | grep -E "^V_\d+_\d+_P\d+$" | head -1)

# https://stackoverflow.com/a/59473090
# export CC=clang
# export CC="cc -no-pie"
#export CFLAGS="-no-pie"
#export LDFLAGS="-L. -Lopenbsd-compat/ -static"
export LDFLAGS="-static -no-pie"
./configure --with-pie=no #LDFLAGS="-static"
make -j$(nproc)


find . -maxdepth 1 -type f -executable

file ssh
ldd ssh
file sshd
ldd sshd
