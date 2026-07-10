# implement-api — I/O contract

The single source of truth for the data exchanged between the orchestrator
(`SKILL.md`) and the per-phase subagents. Both sides reference this file.

## `state.json` — durable cross-phase state

Lives at `.claude/skills/implement-api/state.json`. The **orchestrator owns it**:
it creates the file after Phase 1, merges each phase's results into it, and
updates `lastCompletedPhase`. Subagents **read** it (for prefix, base name, class
name, selected groups, and prior-phase outputs) but do **not** write it — they
report their results in the return JSON and let the orchestrator persist them.

```json
{
  "prefix": "crypto_kem",
  "base": "kem",
  "className": "Kem",
  "isSumo": false,
  "lastCompletedPhase": 4,
  "selectedGroups": [
    {
      "variant": "xwing",
      "ffiMethods": ["crypto_kem_xwing_keypair", "crypto_kem_xwing_enc", "..."],
      "ffiConstants": ["crypto_kem_xwing_publickeybytes", "..."],
      "jsMethods": ["crypto_kem_xwing_keypair", "crypto_kem_xwing_enc", "..."],
      "jsConstants": ["crypto_kem_xwing_PUBLICKEYBYTES", "..."]
    }
  ],
  "phaseOutputs": {
    "2": {
      "files": ["packages/sodium/lib/src/api/kem.dart"],
      "notes": "freezed result used because ss is a SecureKey"
    }
  }
}
```

Field notes:
- `base` — the prefix with the leading `crypto_` stripped (e.g. `kem`); the
  snake_case file-name stem.
- `className` — the PascalCase Dart class name derived from `base` (e.g. `Kem`).
- `isSumo` — always `false` for a run this skill handles (sumo APIs are out of
  scope; see Phase 1).
- `selectedGroups[].variant` — a named algorithm variant, or the literal
  `"default"` for the primitive/alias wrapper group.
- `phaseOutputs` — keyed by phase number (string); one entry appended per
  completed phase.

## Phase-input contract (orchestrator → subagent)

Every spawn prompt the orchestrator sends contains, uniformly:

- **Phase number** and the **playbook path** to read
  (`.claude/skills/implement-api/phases/phase-N-*.md`).
- The **conventions path** (`.claude/skills/implement-api/reference/conventions.md`)
  and **this contract path**.
- The **state.json path** (`.claude/skills/implement-api/state.json`) — read it
  for `prefix`, `base`, `className`, `selectedGroups`, and `phaseOutputs`.
- **Accumulated user feedback**, present only when the orchestrator re-engages
  the same subagent to revise its work.
- The standing rule: do all work, run tests/format/lint per conventions, do
  **not** address the user, and end your turn by emitting **only** the return
  JSON below.

## Return JSON (subagent → orchestrator)

The subagent's **final message must be exactly this JSON object and nothing
else** (no prose before or after):

```json
{
  "phase": 4,
  "status": "completed",
  "filesWritten": ["packages/sodium/lib/src/ffi/api/kem_ffi.dart"],
  "testResults": {
    "ran": true,
    "command": "dart test test/unit/ffi/api/kem_ffi_test.dart",
    "passed": true,
    "summary": "12/12 passed"
  },
  "formatLintClean": true,
  "designDecisions": [
    "classified ss as SecureKey output",
    "used base class + variant subclasses"
  ],
  "reviewQuestion": "Does the FFI implementation look correct? Check memory ownership in try/catch/finally, unlock nesting (outputs outermost), nullptr for dropped params, and .count args.",
  "blockingQuestions": []
}
```

Field rules:
- `status` — one of `"completed"`, `"blocked"`, `"failed"`.
  - `completed` — work done, tests/format/lint pass.
  - `blocked` — you need a user decision before you can finish; put the questions
    in `blockingQuestions`.
  - `failed` — you could not complete after genuine effort; explain in `notes`.
- `filesWritten` — every path you created or modified (repo-relative).
- `testResults` — `ran:false` for phases that do not run tests (e.g. the final
  integration-scaffolding phase); otherwise the command, `passed`, and a short
  `summary`. Include the full raw test output separately in `testOutput` if a
  phase requires the orchestrator to surface it.
- `formatLintClean` — `true` only after `dart format` + `dart analyze` pass.
- `designDecisions` — short bullet strings for anything non-obvious the
  orchestrator should surface to the user.
- `reviewQuestion` — the phase's completion question, verbatim from the
  playbook's "Output" section, for the orchestrator to ask the user.
- `blockingQuestions` — empty unless `status` is `"blocked"`.
- `notes` (optional) — free text for `failed`/`blocked` context.

## What the orchestrator does with the return

1. Merge `filesWritten` (+ a condensed note from `designDecisions`) into
   `phaseOutputs[N]` in `state.json` and set `lastCompletedPhase = N`.
2. Present to the user: a file summary, the design decisions, and the test/format
   result; then ask the `reviewQuestion`.
3. If the user requests changes, re-engage the **same** subagent (SendMessage)
   with the feedback and re-merge its new return.
4. Only on explicit user approval spawn the next phase's subagent.
