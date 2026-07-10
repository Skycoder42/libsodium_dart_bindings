# Phase 1 — API Selection

> **Runs in the orchestrator (interactive), not a subagent** — it needs the
> user's group-selection dialog. Its output is the initial `state.json`.
> Conventions: `reference/conventions.md`. Contract: `reference/io-contract.md`.

Goal: discover what is available in the bindings for the given prefix, present it
to the user grouped by algorithm variant, and record the selection for all later
phases.

## Step 1 — Determine if this is a sumo API

Ask the user: *"Is `{prefix}` a sumo-only API (one that lives under
`lib/src/api/sumo/` and is exposed via `SodiumSumo`/`CryptoSumo`), or a base
`Sodium` API?"*

- If **sumo**: this skill covers only base `Sodium` APIs. The sumo paths
  (`lib/src/api/sumo/`, `crypto_sumo.dart`, `ffi/api/crypto_sumo_ffi.dart`,
  `js/api/crypto_sumo_js.dart`) differ and are not handled here. Inform the
  user and do not continue.
- If **base**: proceed to Step 2.

## Step 2 — Scan the bindings

Search both binding files for every entry whose name starts with `{prefix}_`:

- **FFI wrapper** — `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart`
  Grep for method declarations matching `^\s+\S+ {prefix}_\w+\(` to extract all
  method names (return type + name line).

- **JS bindings** — `packages/sodium/lib/src/js/bindings/sodium.js.dart`
  Grep for both `external \S+ {prefix}_\w+\(` (methods) and
  `external \S+ get {prefix}_[A-Z_]+` (uppercase constants) to extract names.

Collect every distinct symbol name from both files.

## Step 3 — Group by algorithm variant

After stripping the prefix `{prefix}_` from each symbol name, the **first
`_`-delimited segment** is either:

- A **variant name** — if that same segment appears as the leading part of
  multiple symbol names (e.g. `xwing` in `xwing_keypair`, `xwing_enc`, …).
- An **operation name** — if it appears in only one symbol or is clearly an
  operation verb (`keypair`, `enc`, `dec`, `keybytes`, `primitive`, …).

Symbols that fall into the second category belong to the **"default" group**
(the primitive-wrapper functions that have no named variant).

Produce a list of groups. Each group entry contains:
- The variant name (or `default` for the primitive wrapper)
- All FFI method names belonging to it
- All JS method names belonging to it
- All JS constant names (UPPERCASE getters) belonging to it

## Step 4 — Display, select, and persist

Print an indexed table, for example:

```
Found N algorithm groups matching prefix `{prefix}`:

[1] default  (primitive/alias wrapper)
    FFI : crypto_kem_keypair, crypto_kem_seed_keypair, crypto_kem_enc, crypto_kem_dec,
          crypto_kem_primitive, crypto_kem_publickeybytes, …
    JS  : crypto_kem_keypair(), crypto_kem_seed_keypair(), crypto_kem_enc(),
          crypto_kem_dec(), crypto_kem_primitive()
    JS constants: crypto_kem_PUBLICKEYBYTES, crypto_kem_SECRETKEYBYTES, …

[2] mlkem768
    FFI : crypto_kem_mlkem768_keypair, crypto_kem_mlkem768_enc, …
    JS  : crypto_kem_mlkem768_keypair(), …
    JS constants: crypto_kem_mlkem768_PUBLICKEYBYTES, …

[3] xwing
    FFI : crypto_kem_xwing_keypair, crypto_kem_xwing_enc, …
    …
```

Then ask:

> Which groups should be implemented?
> Enter indices using commas, ranges, or `!N` to exclude:
> examples — `1,3`  |  `1-3`  |  `!2`  |  `all`

Parse the user's input against the displayed index:

- `all` → every group
- `1,3` → groups at those indices
- `2-4` → inclusive range
- `!2` → all groups except index 2
- Combinations: `1-4,!3` → groups 1, 2, 4

If the input is unambiguous, **immediately write `state.json`** (see below) and
confirm by reporting what was saved: *"Saved selection: xwing, mlkem768.
Proceeding to Phase 2."* Only ask a follow-up question if the input contains an
unrecognized token.

## Step 5 — Write `state.json`

Write the selection to `.claude/skills/implement-api/state.json` following the
schema in `reference/io-contract.md`. Populate `prefix`, `base` (prefix minus the
leading `crypto_`), `className` (PascalCase of `base`), `isSumo: false`,
`lastCompletedPhase: 1`, and `selectedGroups` (one entry per chosen group with
its FFI/JS method and constant names). Leave `phaseOutputs` as `{}`.

This file is the single source of truth for all later phases.
