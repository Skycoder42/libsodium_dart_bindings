#!/bin/sh
set -e

cd libsodium

output_dir=../Libraries
archive_file=libsodium-1.0.20-darwin.tar.xz
archive_hash_file=$archive_file.sha512
archive_url_file=$archive_file.url
archive_url=$(cat "$archive_url_file")

cleanup() {
  rm -f "$archive_file"
}

validate_checksum() {
  shasum -a512 -c "$archive_hash_file"
  return $?
}

if [ -f "$archive_file" ]; then
  if validate_checksum; then
    exit 0
  fi
  cleanup
fi

# add trap do delete the downloaded file if hash validation or extraction fail
trap cleanup EXIT

curl -sSLfo "$archive_file" "$archive_url"
validate_checksum

rm -rf "$output_dir"
mkdir -p "$output_dir"
tar -xf "$archive_file" -C "$output_dir"

trap '' EXIT
