#!/bin/sh

# this script should be run in bare alpine image

# https://github.com/tmux/tmux/wiki/Installing#from-source-tarball
apk add \
    build-base \
    bison \
    libevent-dev \
    libevent-static \
    ncurses-dev \
    ncurses-static \
    ncurses-terminfo-base

VERSION=$(basename $(curl -fsSL -o /dev/null -w %{url_effective} https://github.com/tmux/tmux/releases/latest))
wget -q "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
tar -xzf "tmux-${VERSION}.tar.gz"
cd "tmux-${VERSION}"

# https://stackoverflow.com/a/59473090
export CFLAGS="-no-pie"
./configure --enable-static
make -j$(nproc)
mv tmux ..
cd ..

strip tmux
file tmux
ls -lh tmux
./tmux -V
ldd tmux && { rm -rf tmux; exit 1; } || mv tmux tmux-static

# terminfo is not embeded in ncurses
# package terminfo instead of compiling ncurses --with-fallbacks="xterm xterm-256color"
# export TERM=xterm-256color TERMINFO=/path/to/terminfo; tmux should work
cd /etc
tar -zcf terminfo.tar.gz terminfo
cd -
mv terminfo.tar.gz .
