#!/bin/sh

# this script should be run in a bare alpine image

# https://github.com/openssh/openssh-portable#building-portable-openssh
# https://gist.github.com/fumiyas/b4aaee83e113e061d1ee8ab95b35608b
apk add \
    git \
    build-base \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static

git clone https://github.com/openssh/openssh-portable
cd openssh-portable
# newest tag with name like "V_10_2_P1"
git checkout $(git tag --sort=-creatordate | grep -E "^V_\d+_\d+_P\d+$" | head -1)

# https://stackoverflow.com/a/59473090
# for gcc to compile a statically linked binary, it needs two flags: -static and -no-pie
# these flags can be added to: CC, CFLAGS or LDFLAGS
# somehow, CFLAGS doesn't work when building the actual binaries
# so both flags got added to LDFLAGS
export LDFLAGS="-static -no-pie"

# without setting --with-pie=no explicitly, it will add a -pie at the end of the building command
# override any -no-pie settings from CC, CFLAGS or LDFLAGS
./configure --with-pie=no

# two extra libraries are being built in the process
# ./libssh.a and ./openbsd-compat/libopenbsd-compat.a
# somewhere -L. -Lopenbsd-compat/ got added to LDFLAGS so they can be used
# BUT setting LDFLAGS here like 'make -j4 LDFLAGS="-static -no-pie"'
# will override "-L. -Lopenbsd-compat/" somehow
# overall, very confusing CFLAGS and LDFLAGS behavior
make -j$(nproc)

find . -maxdepth 1 -type f -executable

FILES="sshd ssh scp sftp ssh-add ssh-agent ssh-keygen"
mkdir -p ../openssh-static
mv  $FILES ../openssh-static
cd ..
rm -rf openssh-portable

cd openssh-static
for FILE in $FILES; do
    strip $FILE
    file $FILE
    ls -lh $FILE
    ./$FILE -V || true
    ldd $FILE || true
done
