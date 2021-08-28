#!/bin/bash

EXECUTABLE_FILE=gpfdist
if [ ! -f "$EXECUTABLE_FILE" ]; then
    echo "Executable file $EXECUTABLE_FILE does not exist. Build it with 'make -f Makefile.static' first."
    exit 1
fi

version=$(../../../getversion | awk '{print $1;}')
package=gpfdist-$version

echo "Create (and clear if needed) folders for $package"
mkdir -p "$package"
rm -rf "$package"/*

mkdir -p "$package/DEBIAN"

echo "Create control file $package/DEBIAN/control"
cat <<EOT > "$package"/DEBIAN/control
Package: gpfdist
Version: $version
Section: base
Priority: optional
Architecture: all
Maintainer: $USERNAME
Description: gpfdist
 Greenplum Database parallel file distribution program. It is used by readable external tables and gpload to serve
 external table files to all Greenplum Database segments in parallel. It is used by writable external tables to accept
 output streams from Greenplum Database segments in parallel and write them out to a file.
EOT

echo "Copy executable gpfdist file"
mkdir -p "$package"/usr/local/bin
cp gpfdist "$package"/usr/local/bin

echo "Build package"
dpkg-deb --build "$package"

echo "OK"