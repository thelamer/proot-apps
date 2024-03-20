#!/bin/bash

ARCH=$(uname -m| sed 's/x86_64/amd64/g'| sed 's/aarch64/arm64/')

# Add jq and our binary
rm -Rf dist/
mkdir -p dist
cp proot-apps dist/
JQ_RELEASE=$(curl -sX GET "https://api.github.com/repos/jqlang/jq/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]');
curl -L \
  -o dist/jq \
  https://github.com/jqlang/jq/releases/download/${JQ_RELEASE}/jq-linux-${ARCH}

# Compile proot
rm -Rf proot/
mkdir -p proot
PROOT_RELEASE=$(curl -sX GET "https://api.github.com/repos/proot-me/proot/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]');
  curl -L \
    "https://github.com/proot-me/proot/archive/${PROOT_RELEASE}.tar.gz" \
    | tar -xzf - -C "proot/" --strip-components=1
  cd proot/
  make -C src loader.elf loader-m32.elf build.h
  make -C src proot
  cp src/proot ../dist/
  cd ..

# Create dist tarball
cd dist/
tar -czf proot-apps.tar.gz *
mv proot-apps.tar.gz /tmp
cd ..

# Cleanup
rm -Rf proot/ dist/
