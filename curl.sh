#!/bin/sh

# this script should be run in a bare alpine image

# https://curl.se/docs/install.html
apk add \
    curl \
    build-base \
    nghttp2-dev \
    nghttp2-static \
    nghttp3-dev \
    nghttp3-static \
    openssl-dev \
    openssl-libs-static \
    brotli-dev \
    brotli-static \
    zlib-dev \
    zlib-static \
    zstd-dev \
    zstd-static

URL=$(curl -fsSL -o /dev/null -w %{url_effective} https://github.com/curl/curl/releases/latest)
VERSION=$(echo $URL | cut -d- -f2 | tr _ .)
curl -fsSL https://github.com/curl/curl/releases/latest/download/curl-${VERSION}.tar.xz | tar -xJ
cd curl-${VERSION}

# https://stackoverflow.com/a/59473090
export CFLAGS="-no-pie"

# https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/curl/APKBUILD
./configure \
    --disable-shared \
    --enable-static \
    --enable-ipv6 \
    --enable-websockets \
    --enable-unix-sockets \
    --with-nghttp2 \
    --with-nghttp3 \
    --with-openssl \
    --with-openssl-quic \
    --with-brotli \
    --with-zlib \
    --with-zstd \
    --without-libpsl
make -j$(nproc) LDFLAGS="-static -all-static"

mv src/curl ..
cd ..
rm -rf curl-${VERSION}

strip curl
file curl
ls -lh curl
./curl -V
ldd curl && { rm -rf curl; exit 1; } || mv curl curl-static
