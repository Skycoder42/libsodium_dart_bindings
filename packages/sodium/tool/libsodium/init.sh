#!/bin/bash
set -euo pipefail

export GITHUB_ENV=/dev/null

echo ">>> Downloading source archives"
dart run tool/libsodium/download.dart

echo ">>> Exporting headers for generators"
dart run test -h > /dev/null

echo ">>> preparing web integrations tests"
dart run tool/integration/setup_web.dart
