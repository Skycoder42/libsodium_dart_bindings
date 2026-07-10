# implement-api — shared conventions

These rules apply to **every** phase playbook. Each playbook references this file
instead of repeating them.

## Placeholder notation

In code examples throughout the playbooks, `{placeholder}` denotes a value you
must substitute (e.g. `{base}`, `{ClassName}`, `{prefix}`, `{variant}`). Do not
emit literal curly braces in generated code.

## Running unit tests

All `dart test` commands must be run from the `packages/sodium/` directory.

| Platform | Command |
|---|---|
| Dart VM | `dart test <relative-path-to-test-file>` |
| Chrome (JS) | `dart test -p chrome <relative-path-to-test-file>` |

Example for a file at `test/unit/api/kem_test.dart`:
```
dart test test/unit/api/kem_test.dart
dart test -p chrome test/unit/api/kem_test.dart
```

When a phase requires running tests, run the platform(s) that phase specifies and
capture the full output. If tests fail, fix the **code** (not the tests) before
reporting the phase as complete. Individual playbooks state which platform(s)
apply (some are VM-only, some Chrome-only).

## Formatting and linting

All generated code must be properly formatted and lint-free. Run both commands
from the `packages/sodium/` directory before assembling your return JSON:

- **Format:** `dart format <relative-path(s)-to-modified-files>`
- **Analyze:** `dart analyze <relative-path(s)-to-modified-files>`

Fix any issues reported by `dart analyze` before finishing. Do not suppress
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
