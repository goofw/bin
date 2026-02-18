#!/bin/sh

apk add \
    curl \
    build-base \
    clang \
    openssl-dev \
    openssl-libs-static \
    nghttp2-dev \
    nghttp2-static \
    libssh2-dev \
    libssh2-static \
    zlib-dev \
    zlib-static

URL=$(curl -fsSL -o /dev/null -w %{url_effective} https://github.com/curl/curl/releases/latest)
VERSION=$(echo ${URL} | cut -d- -f2 | tr _ .)
rm -rf curl-${VERSION}
curl -fsSL https://github.com/curl/curl/releases/latest/download/curl-${VERSION}.tar.xz | tar -xJ
cd curl-${VERSION}

export CC=clang
LDFLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure \
    --disable-shared \
    --enable-static \
    --disable-docs \
    --disable-manual \
    --disable-ldap \
    --enable-ipv6 \
    --enable-unix-sockets \
    --without-libpsl \
    --with-ssl \
    --with-libssh2

make -j4 V=1 LDFLAGS="-static -all-static"

mv src/curl ..
cd ..
rm -rf curl-${VERSION}

strip curl
file curl
ls -lh curl
./curl -V
ldd curl && { rm -rf curl; exit 255; } || mv curl curl-static
