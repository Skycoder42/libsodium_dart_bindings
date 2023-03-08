#!/bin/bash
# $1 libsodium version
# $2 (optional) stable suffix
set -eo pipefail

version=${1:?First argument must be the libsodium version to build}
version_suffix=${2:-"-stable"}

full_version="$version$version_suffix"
download_url=https://download.libsodium.org/libsodium/releases/libsodium-$full_version-msvc.zip
cache_dir=${CACHE_DIR:-$GITHUB_WORKSPACE/.cache/libsodium}
lib_dir="$PWD/windows/lib"

# shellcheck disable=SC1091
source "$PWD/tool/libsodium/env.sh"

echo ::group::Validating and restoring cache
curl -sSfLI "$download_url" | grep 'last-modified' > "$RUNNER_TEMP/last-modified.txt"
if [ "$CACHE_HIT" = "true" ]; then
  echo "Cache hit!"
  if cmp -s "$RUNNER_TEMP/last-modified.txt" "$cache_dir/last-modified.txt"; then
    echo "Stable has not changed! Restoring cache."
    cp -a "$cache_dir/" "$lib_dir/"
    echo ::endgroup::
    exit 0
  else
    echo "Stable has changed! Discarding cache."
    rm -rf "$cache_dir"
  fi
else
  echo "No cache hit!"
fi
echo ::endgroup::

echo ::group::Install minisign
choco install minisign -y
echo ::endgroup::

echo ::group::Download and extract libsodium
curl -fLo "$RUNNER_TEMP/libsodium.zip" "$download_url"
curl -fLo "$RUNNER_TEMP/libsodium.zip.minisig" "$download_url.minisig"

minisign -VP "$LIBSODIUM_SIGNING_KEY" -m "$RUNNER_TEMP/libsodium.zip"
unzip "$RUNNER_TEMP/libsodium.zip" -d "$RUNNER_TEMP"
echo ::endgroup::

echo ::group::Cache libsodium binaries
mkdir -p "$cache_dir/Debug/v142"
mkdir -p "$cache_dir/Debug/v143"
mkdir -p "$cache_dir/Release/v142"
mkdir -p "$cache_dir/Release/v143"
mv "$RUNNER_TEMP/libsodium/x64/Debug/v142/dynamic/libsodium.dll" "$cache_dir/Debug/v142/libsodium.dll"
mv "$RUNNER_TEMP/libsodium/x64/Debug/v142/dynamic/libsodium.dll" "$cache_dir/Debug/v142/libsodium.pdb"
mv "$RUNNER_TEMP/libsodium/x64/Debug/v143/dynamic/libsodium.dll" "$cache_dir/Debug/v143/libsodium.dll"
mv "$RUNNER_TEMP/libsodium/x64/Debug/v143/dynamic/libsodium.dll" "$cache_dir/Debug/v143/libsodium.pdb"
mv "$RUNNER_TEMP/libsodium/x64/Release/v142/dynamic/libsodium.dll" "$cache_dir/Release/v142/libsodium.dll"
mv "$RUNNER_TEMP/libsodium/x64/Release/v143/dynamic/libsodium.dll" "$cache_dir/Release/v143/libsodium.dll"
mv "$RUNNER_TEMP/last-modified.txt" "$cache_dir/last-modified.txt"
echo ::endgroup::

echo ::group::Install libsodium into flutter package
cp -a "$cache_dir/" "$lib_dir/"
echo ::endgroup::
