#!/bin/sh

#version=$(basename $(curl -fsSL -o /dev/null -w %{url_effective} https://github.com/tmux/tmux-builds/releases/latest))
#curl -fsSL https://github.com/tmux/tmux-builds/releases/latest/download/tmux-${version:1}-linux-x86_64.tar.gz | tar -xz tmux
#mv tmux tmux-static

command -v bash || apk add bash
[ "$BASH" ] || exec bash $(readlink -f "$0")

apk add \
    curl \
    build-base

TMUX_VERSION=3.6a
MUSL_VERSION=1.2.5
LIBEVENT_VERSION=2.1.12
NCURSES_VERSION=6.5

PREFIX=/build
mkdir -p "$PREFIX/src"
cd "$PREFIX/src"


### musl
wget "https://musl.libc.org/releases/musl-${MUSL_VERSION}.tar.gz"
tar xzf "musl-${MUSL_VERSION}.tar.gz"
cd "musl-${MUSL_VERSION}"

./configure \
    --enable-gcc-wrapper \
    --disable-shared \
    --prefix="${PREFIX}"

make -j$(nproc)
make install
cd -


export CC="${PREFIX}/bin/musl-gcc -static"


### libevent
wget "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz"
tar xzf "libevent-${LIBEVENT_VERSION}-stable.tar.gz"
cd "libevent-${LIBEVENT_VERSION}-stable"

./configure \
    --prefix="$PREFIX" \
    --includedir=${PREFIX}/include \
    --libdir=${PREFIX}/lib \
    --disable-shared \
    --disable-openssl \
    --disable-libevent-regress \
    --disable-samples

make -j$(nproc)
make install
cd -


### ncurses
wget "https://invisible-island.net/archives/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"
tar xzf "ncurses-${NCURSES_VERSION}.tar.gz"
cd "ncurses-${NCURSES_VERSION}"

./configure \
    --prefix=${PREFIX} \
    --includedir=${PREFIX}/include \
    --libdir=${PREFIX}/lib \
    --without-ada \
    --without-cxx \
    --without-cxx-binding \
    --without-tests \
    --without-manpages \
    --without-debug \
    --disable-lib-suffixes \
    --disable-db-install \
    --with-termlib \
    --with-default-terminfo-dir=/usr/share/terminfo \
    --with-terminfo-dirs=/etc/terminfo:/lib/terminfo:/usr/share/terminfo \
    --with-fallbacks="screen screen-256color tmux tmux-256color xterm xterm-256color"


make -j$(nproc)
make install
cd -


### tmux
wget "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
tar xzf "tmux-${TMUX_VERSION}.tar.gz"
cd "tmux-${TMUX_VERSION}"

./configure \
    --enable-static \
    --prefix=${PREFIX} \
    --includedir="${PREFIX}/include" \
    --libdir="${PREFIX}/lib" \
    LIBEVENT_LIBS="-L${PREFIX}/lib -levent" \
    LIBNCURSES_CFLAGS="-I${PREFIX}/include/ncurses" \
    LIBNCURSES_LIBS="-L${PREFIX}/lib -lncurses" \
    LIBTINFO_CFLAGS="-I${PREFIX}/include/ncurses" \
    LIBTINFO_LIBS="-L${PREFIX}/lib -ltinfo" \
    CFLAGS="-I${PREFIX}/include" \
    LDFLAGS="-L${PREFIX}/lib" \
    CPPFLAGS="-I${PREFIX}/include"

make -j$(nproc)
make install
cd -

cp ${PREFIX}/bin/tmux $(dirname $(readlink -f "$0"))/tmux-static
