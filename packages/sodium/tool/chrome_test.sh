#!/bin/bash
# Runs the `dart test` Chrome (browser) suite OUTSIDE the Claude Code sandbox.
#
# Why: Chrome cannot start under the macOS seatbelt sandbox — its multiprocess
# core must register the com.google.Chrome.MachPortRendezvousServer Mach service
# (bootstrap_check_in), which the sandbox denies with no override; and
# package:test must bind a loopback server socket, which the sandbox also denies.
# This wrapper is listed in .claude/settings.json -> sandbox.excludedCommands
# (as "bash packages/sodium/tool/chrome_test.sh *") so invoking it runs
# UNSANDBOXED while every other command stays sandboxed.
#
# Usage — from the repo ROOT, pass the test path(s) as arguments. Paths may be
# given relative to packages/sodium or to the repo root (a leading
# "packages/sodium/" is stripped automatically):
#     bash packages/sodium/tool/chrome_test.sh test/unit/api/kdf_hkdf_test.dart
# With no arguments, the whole test/ suite runs.
#
# CRITICAL — the sandbox exclusion is fragile. Matching uses Claude Code's
# command-prefix parser, so the exclusion breaks SILENTLY (dropping you back into
# the sandbox, where Chrome fails with "Operation not permitted") if you:
#   * add a prefix            — timeout 300 bash ... , cd packages/sodium && bash ...
#   * chain / pipe / redirect — bash ... | tail , bash ... > log 2>&1 , ... ; bash ...
# Passing the test path as an ARGUMENT is fine (the trailing "*" in the
# excludedCommands entry allows it). Just invoke the plain, standalone command
# from the repo root — no prefix, no pipe, no redirect, no chaining.
set -euo pipefail
cd "$(dirname "$0")/.."   # -> packages/sodium

# Fail fast if we are (still) sandboxed: a loopback bind is denied inside the
# sandbox, so continuing would only produce a confusing downstream failure.
if ! /usr/bin/python3 -c 'import socket; socket.socket().bind(("127.0.0.1", 0))' 2>/dev/null; then
  {
    echo "ERROR: chrome_test.sh is running INSIDE the Claude Code sandbox."
    echo "       (Proof: binding a 127.0.0.1 socket was denied with EPERM. Chrome"
    echo "       and package:test both need it, so the run would fail anyway.)"
    echo
    echo "  WHY: this script only escapes the sandbox when the command matches the"
    echo "  sandbox.excludedCommands entry in .claude/settings.json:"
    echo "      bash packages/sodium/tool/chrome_test.sh *"
    echo "  Matching uses Claude Code's command-prefix parser, so the match breaks"
    echo "  SILENTLY (and you fall back into the sandbox) if you:"
    echo "    - add a prefix            e.g.  timeout 300 bash ...   /   cd x && bash ..."
    echo "    - chain / pipe / redirect e.g.  bash ... | tail   /   bash ... > log   /   ...; bash ..."
    echo "  (Passing the test path as an ARGUMENT is fine — that is expected.)"
    echo
    echo "  FIX: run it as the plain, standalone command from the repo ROOT, e.g.:"
    echo "      bash packages/sodium/tool/chrome_test.sh test/unit/api/foo_test.dart"
    echo "  No prefix, no pipe, no redirect, no chaining."
  } >&2
  exit 3
fi

# Accept paths relative to either the repo root or packages/sodium.
targets=()
for arg in "$@"; do
  targets+=("${arg#packages/sodium/}")
done
[ "${#targets[@]}" -eq 0 ] && targets=(test/)

echo "Running Chrome tests (unsandboxed): ${targets[*]}"
exec timeout 300 env NIX_SKIP_SODIUM_BUILD_HOOKS=1 dart test -p chrome "${targets[@]}"
