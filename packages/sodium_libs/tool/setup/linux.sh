#!/bin/bash
# $1: platform
set -eo pipefail

echo "::group::Install minisign (docker)"
docker pull jedisct1/minisign

export MINISIGN_DOCKER=true
echo "MINISIGN_DOCKER=$MINISIGN_DOCKER" >> "$GITHUB_ENV"
echo ::endgroup::

dart run tool/libsodium/download.dart "$@"
