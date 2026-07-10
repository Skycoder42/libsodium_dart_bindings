---
name: implement-api
description: >
  Implements a new libsodium API feature end-to-end: abstract interface,
  FFI implementation, JS implementation, wire-up, and tests. Orchestrates the
  work across per-phase subagents, presenting each phase's result for approval
  and looping on feedback before moving on.
argument-hint: <feature-name>
---

You are the **orchestrator** for implementing a new API feature in the
`packages/sodium` Dart library. The feature prefix is: **$ARGUMENTS**

Your job is to drive the run phase by phase, keeping your own context slim. You
do **not** hold the detailed phase instructions yourself — each phase's playbook
is loaded only into an ephemeral subagent you spawn to run it. You own the state
file and the user-approval loop.

All paths below are relative to the repository root
(`.claude/skills/implement-api/`).

## How this skill is structured

| File | Role |
|---|---|
| `reference/io-contract.md` | The `state.json` schema and the subagent return-JSON schema. **Read this before spawning any subagent.** |
| `reference/conventions.md` | Shared rules (test/format/lint commands, build_runner, phase-close). Subagents read it; you don't need to. |
| `phases/phase-N-*.md` | The detailed playbook for each phase. You pass the path to a subagent; you do not read the body yourself. |
| `state.json` | Durable cross-phase state. You create and update it. |

## Phase map

| Phase | Goal | Playbook | Output file(s) |
|-------|------|----------|----------------|
| 1 | API selection | `phases/phase-1-selection.md` | `state.json` |
| 2 | Abstract interface | `phases/phase-2-interface.md` | `lib/src/api/{base}.dart` |
| 3 | Validation tests | `phases/phase-3-interface-tests.md` | `test/unit/api/{base}_test.dart` |
| 4 | FFI implementation | `phases/phase-4-ffi.md` | `lib/src/ffi/api/{base}*_ffi.dart` |
| 5 | FFI unit tests | `phases/phase-5-ffi-tests.md` | `test/unit/ffi/api/{base}*_ffi_test.dart` |
| 6 | JS implementation | `phases/phase-6-js.md` | `lib/src/js/api/{base}*_js.dart` |
| 7 | JS unit tests | `phases/phase-7-js-tests.md` | `test/unit/js/api/{base}*_js_test.dart` |
| 8 | Wire-up | `phases/phase-8-wireup.md` | `crypto.dart`, `crypto_ffi.dart`, `crypto_js.dart`, `sodium.dart`, `crypto_*_test.dart`, `README.md` |
| 9 | Integration scaffolding | `phases/phase-9-integration.md` | `test/integration/cases/{base}_test_case.dart`, `test_runner.dart` |

## Start-up and resume

Before doing any work, check whether `state.json` exists.

- **If it exists** with a `lastCompletedPhase` field: read it, display the saved
  prefix, selected groups, and phase number, then ask: *"I found a previous
  session for `$ARGUMENTS` (last completed: Phase N). Resume from Phase N+1, or
  start over?"*
  - Resume → begin the run loop at Phase N+1.
  - Start over → delete `state.json` and begin at Phase 1.
- **If it does not exist**: begin at Phase 1.

## Phase 1 (runs in the orchestrator)

Phase 1 is interactive — it needs the user's group-selection dialog — so **you**
run it directly rather than spawning a subagent. Follow
`phases/phase-1-selection.md`, which ends by writing the initial `state.json`
(prefix, base, className, selected groups, `lastCompletedPhase: 1`). If the
feature turns out to be a sumo-only API, stop as that playbook instructs.

## Run loop (Phases 2–9)

For each phase `N` from the resume point onward, one at a time:

1. **Spawn** a subagent (`general-purpose`, run synchronously) with a prompt that
   follows the phase-input contract in `reference/io-contract.md`. State
   explicitly:
   - The phase number and the playbook path (`phases/phase-N-*.md`) to read and
     execute.
   - The conventions path (`reference/conventions.md`) and the contract path
     (`reference/io-contract.md`).
   - The `state.json` path to read for prefix, selected groups, and prior outputs.
   - That it must do all the work, run tests/format/lint per conventions, **not**
     address the user, and end its turn by emitting **only** the return JSON.
2. **Receive** the subagent's return JSON. If `status` is `blocked`, relay its
   `blockingQuestions` to the user, then re-engage the subagent (step 5) with the
   answers. If `failed`, surface the `notes` and decide with the user how to
   proceed.
3. **Merge** the result into `state.json`: append `phaseOutputs[N]` with
   `filesWritten` and a condensed note from `designDecisions`; set
   `lastCompletedPhase = N`.
4. **Present** to the user: a summary of files created/changed, the design
   decisions, and the test/format result; then ask the subagent-supplied
   `reviewQuestion`.
5. **Feedback loop:** if the user requests changes, re-engage the **same** phase
   subagent via `SendMessage` (its context is intact) with the feedback. When it
   returns an updated result, re-merge (step 3) and re-present (step 4). Repeat
   until the user approves.
6. **Approve:** only once the user explicitly approves do you spawn the **next**
   phase's subagent (a fresh `Agent`). Never move to the next phase without
   explicit approval of the current one.

## Rules

- **Subagents never talk to the user.** They do the work and return the
  `reviewQuestion`; you ask it. All approval interaction stays with you.
- **You own `state.json`.** Subagents read it but never write it — they report
  results in the return JSON and you persist them. This keeps the state
  consistent and is the durable memory that lets a run resume.
- **Keep your context slim.** Do not read phase playbook bodies yourself; pass
  their paths to subagents. Hold only the phase map, the compact return JSONs,
  and `state.json`.
- **Naming derivation** (used when composing prompts and reading state):
  strip the leading `crypto_` from the prefix to get `base` (snake_case file
  stem); the PascalCase of `base` is `className`. Both are stored in
  `state.json` by Phase 1.
