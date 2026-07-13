# implement-api — shared conventions

These rules apply to **every** phase playbook. Each playbook references this file
instead of repeating them.

## Placeholder notation

In code examples throughout the playbooks, `{placeholder}` denotes a value you
must substitute (e.g. `{base}`, `{ClassName}`, `{prefix}`, `{variant}`). Do not
emit literal curly braces in generated code.

## Running unit tests

There is no dart MCP test-runner tool, so tests run via the Bash tool. **Every**
`dart test` invocation MUST set `NIX_SKIP_SODIUM_BUILD_HOOKS=1` — the native
assets are prebuilt, and without this variable the build hooks re-run and fail
under the sandbox.

The two platforms are invoked **very differently** — read both rows carefully:

| Platform | How to run |
|---|---|
| **Dart VM** | From `packages/sodium/`: `NIX_SKIP_SODIUM_BUILD_HOOKS=1 dart test <relative-path>` |
| **Chrome (JS)** | Via the wrapper — see "Chrome / browser tests" below. **Never** `dart test -p chrome …` directly. |

VM example for a file at `test/unit/api/kem_test.dart`:
```
NIX_SKIP_SODIUM_BUILD_HOOKS=1 dart test test/unit/api/kem_test.dart
```

When a phase requires running tests, run the platform(s) that phase specifies and
capture the full output. If tests fail, fix the **code** (not the tests) before
reporting the phase as complete. Individual playbooks state which platform(s)
apply (some are VM-only, some Chrome-only).

### Chrome / browser tests — use the wrapper, never `-p chrome` directly

Chrome **cannot start inside the Claude Code sandbox** (its multiprocess core
must register the `com.google.Chrome.MachPortRendezvousServer` Mach service,
which the macOS seatbelt sandbox denies with no override; `package:test` also
needs a loopback socket the sandbox denies). Running `dart test -p chrome …`
directly therefore fails with `Operation not permitted`.

Instead, run Chrome tests through **`packages/sodium/tool/chrome_test.sh`**, which
is registered in `.claude/settings.json` → `sandbox.excludedCommands` (as
`bash packages/sodium/tool/chrome_test.sh *`) so it runs **outside** the sandbox.
Pass the test path(s) as arguments, from the **repo root**:

```
bash packages/sodium/tool/chrome_test.sh test/unit/api/{base}_test.dart
```

Paths may be given relative to `packages/sodium` or to the repo root (a leading
`packages/sodium/` is stripped automatically). With no arguments the whole
`test/` suite runs.

**The invocation is fragile — matching uses Claude Code's command-prefix parser,
so the sandbox exclusion SILENTLY breaks (dropping you back into the sandbox,
where Chrome fails with `Operation not permitted`) if you:**
- add **any prefix** — `timeout 300 bash …`, `cd packages/sodium && bash …`,
  `NIX_… bash …`;
- **chain, pipe, or redirect** — `bash … | tail`, `bash … > log 2>&1`, `… ; bash …`.

Passing the test path as an **argument is fine** (the trailing `*` allows it) —
just keep it a plain, standalone command from the repo root: no prefix, no pipe,
no redirect, no chaining. If the wrapper detects it is still sandboxed it aborts
immediately (exit 3) with a message explaining which of the above went wrong;
read that message and re-invoke it correctly.

## Formatting and linting

All generated code must be properly formatted and lint-free before assembling
your return JSON:

- **Format:** run `dart format <relative-path(s)-to-modified-files>` from the
  `packages/sodium/` directory.
- **Analyze:** use the **dart MCP server** — call the
  `mcp__dart-mcp-server__analyze_files` tool. **Do NOT** run `dart analyze` (or
  `flutter analyze`) via the Bash/shell tool. If the MCP tool is unavailable,
  report that in your return JSON rather than falling back to the CLI.

Fix any issues reported by the analyzer before finishing. Do not suppress
warnings with `// ignore` comments unless the warning is a known false positive.

## build_runner (freezed / generated code)

`dart run build_runner build` is **always running in the background** — do **not**
invoke it. If a phase emits a `part '{base}.freezed.dart';` directive, wait a
short time for the background runner to pick up the new file and regenerate the
output. If the generated file does not exist yet when you need it, wait a few
seconds and check again before proceeding.

## Phase-close protocol (adapted for subagent execution)

You run inside a spawned subagent and **never address the user directly**. After
completing your phase's steps:

1. Write all generated/modified files to disk.
2. Run tests (as your playbook specifies) and `dart format` / `dart analyze`.
   Fix code until tests pass and analysis is clean.
3. Assemble and emit **only** the return JSON described in
   `reference/io-contract.md`:
   - Put every created/modified path in `filesWritten`.
   - Put the test command, pass/fail, and a short summary in `testResults`.
   - Put non-obvious design decisions in `designDecisions`.
   - Put your playbook's completion question in `reviewQuestion` — the
     orchestrator asks the user; you do not.
   - If you are blocked and genuinely need a user decision, set
     `status: "blocked"` and list the questions in `blockingQuestions`.

The orchestrator owns `state.json` and the user-approval loop. If the user
requests changes, the orchestrator re-engages you with the feedback; apply it,
re-run tests/format/lint, and emit an updated return JSON.
