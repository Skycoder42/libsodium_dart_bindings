#!/bin/bash
# $1: platform
set -eo pipefail

echo "::group::Install minisign (chocolatey)"
choco install minisign
echo ::endgroup::

dart run tool/libsodium/download.dart "$@"

echo "::group::Build example"
cd example
flutter build windows --debug --verbose
echo ::endgroup::
