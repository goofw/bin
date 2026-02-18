FILE=$(curl -fsSL https://ftp.debian.org/debian/pool/main/b/bash | grep -oP "(?<=href=\")bash-static.*amd64.deb(?=\")" | tail -1)
curl -fsSL https://ftp.debian.org/debian/pool/main/b/bash/$FILE > bash-static.deb
ar p bash-static.deb data.tar.xz | tar -xJ --strip-components=3 ./usr/bin/bash-static
rm -rf bash-static.deb
