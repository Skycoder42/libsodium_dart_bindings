#!/bin/bash
set -ex

tmpDir=$(mktemp -d)
archiveName=libsodium-1.0.20-darwin.tar.xz
shaFileName="$archiveName.sha512"
archivePath="$tmpDir/$archiveName"
shaFilePath="$tmpDir/$shaFileName"
libShaFilePath=Libraries/$shaFileName

rm -rf Libraries/libsodium.xcframework
cp "$libShaFilePath" "$shaFilePath"

curl -Lfo "$archivePath" "https://github.com/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries%2Fv1.0.20/$archiveName"
pushd "$tmpDir"
shasum -a512 -c "$shaFileName"
popd
tar -xvf "$archivePath" -C Libraries/

