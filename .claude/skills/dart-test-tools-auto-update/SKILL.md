---
name: dart-test-tools-auto-update
description: >-
  Use when the user wants to run or repair the automatic dependency update of a dart or
  flutter package — either starting a fresh update from the default branch, or working on
  the update that is already open on the 'automatic-dependency-updates' branch. Resolves
  which of the two it is, puts the worktree on the right branch, reproduces the shared
  auto-update CI workflow locally, and then validates the package the way CI would.
license: BSD-3-Clause
user-invocable: true
argument-hint: "[new|existing] [force]"
allowed-tools:
  - Bash(bash ${CLAUDE_SKILL_DIR}/scripts/prepare-update.sh:*)
  - Bash(dart analyze:*)
  - Bash(flutter analyze:*)
  - Bash(dart format -onone --set-exit-if-changed:*)
  - Bash(dart test:*)
  - Bash(flutter test:*)
  - Bash(dart pub publish --dry-run)
  - mcp__dart__analyze_files
---

# Automatic dependency updates

`dart_test_tools` ships a reusable workflow,
`Skycoder42/dart_test_tools/.github/workflows/auto-update.yml`, that updates a package's
dependencies and opens a pull request from the `automatic-dependency-updates` branch.
This skill drives the same thing locally. There are exactly two situations:

| Situation | Branch | Mode |
| --- | --- | --- |
| Start a **new** dependency update | the default branch (`main`) | `new` |
| Work on the update that is **already open** | `automatic-dependency-updates` | `existing` |

The skill runs in phases. **Phase 1** resolves the branch and, for a new update, runs the
update. **Phase 2** validates the package state against the checks CI performs. Both
phases always run — phase 2 applies whether or not an update was just executed, because
in `existing` mode the point is precisely to fix what CI is unhappy about.

Throughout: **never commit, never push, never publish for real.** Working-tree changes
plus a summary are the whole output.

---

## Phase 1 — resolve the branch and run the update

```sh
bash ${CLAUDE_SKILL_DIR}/scripts/prepare-update.sh [<mode>] [ignore-branch]
```

Translate the skill's argument into the script's arguments:

| Skill invoked as | Run |
| --- | --- |
| *(no argument)* | `prepare-update.sh` |
| `new` | `prepare-update.sh new` |
| `existing` | `prepare-update.sh existing` |
| `new force` | `prepare-update.sh new ignore-branch` |
| `existing force` | `prepare-update.sh existing ignore-branch` |

- With **no mode**, the script derives the mode from the branch that is checked out and
  fails if it is neither of the two. Prefer this when the user did not say which it is.
- With **a mode**, the script switches to the matching branch — but only if the worktree
  is clean. On a dirty worktree it refuses and tells you so.
- `ignore-branch` is the escape hatch the user asks for with "force": it skips every git
  check and takes the given mode at face value. Only pass it when the user explicitly
  asked to force it, and never on its own — it always needs a mode.

Run the script exactly once. Do not reach for `git`, `yq` or `auto_update` yourself.

### The record

The script prints a machine readable record on stdout; everything else it writes goes to
stderr and is progress noise.

```
>>> auto-update-prepare
status: ok
mode: new
...
<<< auto-update-prepare
```

One `key: value` per line. Keys are lowercase and may be dotted and indexed
(`package.1.name`); values are single-line; everything after the first `: ` belongs to
the value. `warning` may appear any number of times, every other key at most once.

Always present:

| Key | Meaning |
| --- | --- |
| `status` | `ok`, or `error` when the script itself failed |
| `mode` | `new` or `existing` — the situation that was resolved |
| `branch` | the branch the worktree is on now |
| `branch_check` | `derived` (read off the branch), `matched` (already correct), `switched` (checked out for you) or `ignored` (`ignore-branch` was passed) |
| `repo_root` | absolute path of the repository |
| `workflow_file` / `workflow_job` | the job calling the shared auto-update workflow, or `none` |
| `target` | the package directory the update applies to |
| `analyze_root` | **run analyze and format from here** — the workspace root |
| `workspace` | `yes` when `target` is a pub workspace with members |
| `package_count` | how many `package.<n>.*` groups follow |

One group per package, `<n>` from 1 to `package_count`:

| Key | Meaning |
| --- | --- |
| `package.<n>.name` | package name from its pubspec |
| `package.<n>.path` | absolute directory — **run publish and tests from here** |
| `package.<n>.tool` | `dart` or `flutter`; use it for `analyze` and `test` |
| `package.<n>.publishable` | `yes` unless the pubspec says `publish_to: none` |
| `package.<n>.build_runner` | `yes` when codegen has to run before anything else compiles |
| `package.<n>.unit_tests` | paths to pass to `test`, or `none` |
| `package.<n>.integration_tests` | paths CI runs separately — **never run these** |
| `package.<n>.test_source` | `workflow` (read off the CI caller — authoritative) or `heuristic` (guessed from the directory layout) |

Only when `mode: new`:

| Key | Meaning |
| --- | --- |
| `update_command` | the exact `auto_update` invocation |
| `update_exit_code` | its exit code — **`0` does not always mean there is nothing to report** |
| `update_log` | absolute path to its combined stdout/stderr |
| `update_report` | absolute path to the markdown report, or `none` |

Only when `status: error`, an `error` key says why the script could not continue.

A non-zero `update_exit_code` is **not** a script failure — the script still exits `0` and
reports it. It only exits non-zero when it could not do its own job at all (dirty worktree
blocking a switch, neither branch checked out, a missing tool).

### Before moving on

- **`status: error`** — relay the `error` value and what the user has to do about it
  (commit or stash their changes, check out one of the two branches, install the missing
  tool). Stop here; do not work around it on your own.
- **Non-zero `update_exit_code`** — read `update_log`, say what failed, and treat it as
  the first problem to solve in phase 2 rather than a reason to stop.
- **Always surface every `warning`.** They change what the run actually did: a missing
  caller workflow means the update ran with defaults instead of the package's real
  settings, and a stale branch means you may be looking at the wrong code.

Then continue to phase 2.

---

## Phase 2 — validate the package state

Reproduce the checks the CI runs, in this order, and **keep going until they all pass**.
Where each one runs depends on the record:

| # | Check | Where | Command |
| --- | --- | --- | --- |
| 1 | Static analysis | once, at `analyze_root` | `mcp__dart__analyze_files` if that tool is available, else `dart analyze --fatal-infos` (`flutter analyze` for a flutter package) |
| 2 | Formatting | once, at `analyze_root` | `dart format -onone --set-exit-if-changed $(git ls-files '*.dart')` |
| 3 | Publishing | per package with `publishable: yes`, at its `path` | `dart pub publish --dry-run` |
| 4 | Unit tests | per package with `unit_tests` other than `none`, at its `path` | `<tool> test <unit_tests>` |

Notes that matter:

- **`--dry-run` is not optional.** Never run `dart pub publish` without it, under any
  circumstance, for any reason. This skill never publishes.
- **Never run the `integration_tests` paths.** They routinely need setup — emulators,
  credentials, an installed Flutter SDK — that is out of scope here. A package whose
  `unit_tests` is `none` simply has no tests to run in this phase; that is a normal,
  passing outcome, not something to work around by running the integration paths instead.
- **`test_source: heuristic`** means no CI caller workflow covered that package, so the
  unit/integration split was guessed from the layout. Glance at what is actually in those
  paths before running them, and say so if they look like integration tests.
- **`build_runner: yes`** means generated sources (`*.g.dart`, `*.freezed.dart`) are
  required. If analysis fails with missing parts or unresolved generated identifiers, run
  `dart run build_runner build --delete-conflicting-outputs` at the package and retry —
  that is a missing build step, not a code defect.
- `--fatal-infos` matches CI. Plain `dart analyze` lets info-level lints through and would
  "pass" locally against a red CI.
- If you use the MCP analyzer, it reports the same diagnostics but does not apply the
  `--fatal-infos` threshold for you — treat info-level findings as failures too.

### The loop

1. Run the next check.
2. If it passes, move to the next one.
3. If it fails, **stop and diagnose before running anything else.** Read the actual error.
   Work out whether it is a consequence of the dependency update (a breaking change, a
   new lint, a changed API) or something unrelated that was already broken.
4. Resolve it — fix it yourself or ask the user, per the rules below.
5. After any change, **restart from check 1.** Fixes interact: applying analyzer fixes
   reformats code, regenerating sources changes what analysis sees, and a dependency bump
   can turn a passing test red.

Stop looping when all four pass, or when you are blocked on a decision that is the user's
to make. Do not loop on the same failure twice without changing something.

### Fix it yourself, or ask?

Decide honestly. The cost of a wrong autonomous "fix" here is a dependency update that
silently changes behaviour, so bias towards asking whenever the *intent* is unclear.

**Fix without asking** — mechanical, intent-preserving, verifiable:

- Formatting (`dart format` over the offending files).
- Missing or stale generated sources (`dart run build_runner build --delete-conflicting-outputs`).
- Lints with a single obvious mechanical fix, including what `dart fix --apply` resolves.
  Re-analyze afterwards; `dart fix` occasionally rewrites more than expected.
- Imports that moved within an updated dependency, where the replacement is unambiguous.

**Ask the user** — anything where more than one answer is defensible:

- A dependency's breaking change where the choice is *adapt the code* vs *hold the
  dependency back*. Say what each would cost.
- A deprecation with several valid migrations, or one that changes public API.
- A failing test where it is not obvious whether the test or the code is now wrong.
- `dart pub publish --dry-run` complaining about package metadata — description, homepage,
  license, oversized files. These are author decisions.
- Anything that would change behaviour the tests do not pin down.

**Never do these**, even if they would make a check pass:

- Delete, skip or weaken a test.
- Relax `analysis_options.yaml`, or add ignore comments to silence a real finding.
- Pin a dependency backwards to dodge a failure without saying so explicitly.
- Edit `.github/workflows/*.yml` directly — in these repositories they are generated from
  `tool/ci_gen/` and regenerated with `dart run tool/ci_gen.dart`.
- Commit, push, or drop `--dry-run`.

### Reporting

When the loop ends, tell the user:

- Which checks pass now, and which package each result belongs to when there are several.
- Every change you made and why, grouped by cause — separate what the dependency update
  forced from what was already broken.
- Anything you deliberately left alone, and the decision you need from them.
- For a new update, what `update_report` says was actually updated.

Then stop. The user commits.
