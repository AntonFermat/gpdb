#!/bin/bash

EXECUTABLE_FILE=gpfdist
if [ ! -f "$EXECUTABLE_FILE" ]; then
  echo "Executable file $EXECUTABLE_FILE does not exist. Build it with 'make -f Makefile.static' first."
  exit 1
fi

version=$(../../../getversion | awk '{print $1;}' | sed "s/-/_/g")
package=gpfdist-$version

echo "Create (and clear if needed) skeleton folders for $package"
mkdir -p "$package"
rm -rf "$package"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$package"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

echo "Copy executable gpfdist file"
mkdir -p "$package"/usr/local/bin
cp gpfdist "$package"/usr/local/bin
tar -czvf "$package"/SOURCES/"$package".tar.gz "$package"/usr/local/bin/gpfdist

echo "Create spec file $package/SPECS/gpfdist.spec"
cat <<EOT >"$package"/SPECS/gpfdist.spec

Name:       gpfdist
Version:    $version
Release:    0
Summary:    Greenplum Database parallel file distribution program
Group:      System Environment/Base
License:    Apache 2
Source0:    $package.tar.gz

%description
Greenplum Database parallel file distribution program. It is used by readable external tables and gpload to serve
external table files to all Greenplum Database segments in parallel. It is used by writable external tables to accept
output streams from Greenplum Database segments in parallel and write them out to a file.

%prep
%setup -q

%build

%install
cp -rfa * %{buildroot}

%files
/*
EOT

echo "Build package"
rpmbuild --define "_topdir $(pwd)/$package" -ba "$package"/SPECS/gpfdist.spec
find "$package"/RPMS/. -name '*.rpm' -exec cp {} . \;

echo "OK"
