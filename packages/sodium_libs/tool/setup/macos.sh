#!/bin/bash
# $1: platform
set -eo pipefail

echo "::group::Install minisign (homebrew)"
brew install minisign
echo ::endgroup::

dart run tool/libsodium/download.dart "$@"
