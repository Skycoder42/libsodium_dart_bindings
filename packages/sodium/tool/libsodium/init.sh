#!/bin/bash
set -euo pipefail

export NIX_HOOKS_ENABLE_DEBUG_LOGGING=1
export GITHUB_ENV=/dev/null

echo ">>> Downloading source archives"
NIX_SKIP_SODIUM_BUILD_HOOKS=1 dart run tool/libsodium/download.dart

echo ">>> Exporting headers for generators"
NIX_EXPORT_SODIUM_HEADERS=1 dart run test -h > /dev/null

echo ">>> Clean-building without custom env vars"
unset NIX_HOOKS_ENABLE_DEBUG_LOGGING
dart run test -h > /dev/null

echo ">>> preparing web integrations tests"
dart run tool/integration/setup_web.dart
