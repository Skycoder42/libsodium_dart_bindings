---
name: implement-api
description: >
  Implements a new libsodium API feature end-to-end: abstract interface,
  FFI implementation, JS implementation, wire-up, and tests. Runs through
  multiple phases, presenting generated files after each phase and looping
  on user feedback until the phase is approved before moving on.
argument-hint: <feature-name>
---

You are implementing a new API feature for the `packages/sodium` Dart library.
The feature prefix is: **$ARGUMENTS**

> In code examples throughout this skill, `{placeholder}` denotes a value you
> must substitute (e.g. `{base}`, `{ClassName}`, `{prefix}`). Do not emit
> literal curly braces in generated code.

---

## How This Skill Works

### Phase Map

| Phase | Goal | Output file(s) |
|-------|------|----------------|
| 1 | API selection | `state.md` |
| 2 | Abstract interface | `lib/src/api/{base}.dart` |
| 3 | Validation tests | `test/unit/api/{base}_test.dart` |
| 4 | FFI implementation | `lib/src/ffi/api/{base}*_ffi.dart` |
| 5 | FFI unit tests | `test/unit/ffi/api/{base}*_ffi_test.dart` |
| 6 | JS implementation | `lib/src/js/api/{base}*_js.dart` |
| 7 | JS unit tests | `test/unit/js/api/{base}*_js_test.dart` |
| 8 | Wire-up | `lib/src/api/crypto.dart`, `crypto_ffi.dart`, `crypto_js.dart`, `sodium.dart`, `crypto_*_test.dart` |
| 9 | Integration scaffolding | `test/integration/cases/{base}_test_case.dart`, `test_runner.dart` |

### Phase sequencing rules

- Proceed through phases **one at a time**.
- Never move to the next phase without explicit user approval of the current one.
- **Resuming:** At the very start, before doing any work, check whether
  `.claude/skills/implement-api/state.md` already exists. If it does, read it.
  If the file contains `## Last completed phase`, display the saved selection
  and phase number, then ask: *"I found a previous session for `$ARGUMENTS`
  (last completed: Phase N). Resume from Phase N+1, or start over?"*
  If the user says resume, jump directly to Phase N+1.
  If the user says start over, delete `state.md` and begin at Phase 1.

### Phase start rule

**At the start of every phase (2 onwards):** read
`.claude/skills/implement-api/state.md` and the primary output file(s) of the
preceding phase before doing any other work.

### Standard phase-close protocol

After completing every phase's steps:

1. Write all generated/modified files to disk.
2. Update `## Last completed phase` in `state.md` to the current phase number.
3. Show the user a summary of what was created or changed.
4. Ask the phase-specific question (stated at the end of each phase below).
5. If the user requests changes, apply them and repeat from step 1 of the
   current phase.
6. Only once the user explicitly approves do you move to the next phase.

### Running unit tests

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

When a phase requires running tests, run both platforms and show the full
output, unless the phase explicitly says otherwise. If tests fail, fix the
code (not the tests) before asking the user to approve the phase.

---

## Phase 1: API Selection

Goal: discover what is available in the bindings for the given prefix, present it
to the user grouped by algorithm variant, and record the selection for all later phases.

### Step 1 — Determine if this is a sumo API

Ask the user: *"Is `$ARGUMENTS` a sumo-only API (one that lives under
`lib/src/api/sumo/` and is exposed via `SodiumSumo`/`CryptoSumo`), or a base
`Sodium` API?"*

- If **sumo**: this skill covers only base `Sodium` APIs. The sumo paths
  (`lib/src/api/sumo/`, `crypto_sumo.dart`, `ffi/api/crypto_sumo_ffi.dart`,
  `js/api/crypto_sumo_js.dart`) differ and are not handled here. Inform the
  user and do not continue.
- If **base**: proceed to Step 2.

### Step 2 — Scan the bindings

Search both binding files for every entry whose name starts with `$ARGUMENTS_`:

- **FFI wrapper** — `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart`
  Grep for method declarations matching `^\s+\S+ $ARGUMENTS_\w+\(` to extract all
  method names (return type + name line).

- **JS bindings** — `packages/sodium/lib/src/js/bindings/sodium.js.dart`
  Grep for both `external \S+ $ARGUMENTS_\w+\(` (methods) and
  `external \S+ get $ARGUMENTS_[A-Z_]+` (uppercase constants) to extract names.

Collect every distinct symbol name from both files.

### Step 3 — Group by algorithm variant

After stripping the prefix `$ARGUMENTS_` from each symbol name, the **first
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

### Step 4 — Display, select, and persist

Print an indexed table, for example:

```
Found N algorithm groups matching prefix `$ARGUMENTS`:

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

If the input is unambiguous, **immediately write `state.md`** (see format below)
and confirm by reporting what was saved: *"Saved selection: xwing, mlkem768.
Proceeding to Phase 2."* Only ask a follow-up question if the input contains an
unrecognized token.

### Step 5 — `state.md` format

Write the selection to `.claude/skills/implement-api/state.md` in this exact
format so every subsequent phase can read it with a single `Read` call:

```markdown
# implement-api state

## Prefix
crypto_kem

## Last completed phase
1

## Selected groups

### xwing
FFI methods: crypto_kem_xwing_keypair, crypto_kem_xwing_seed_keypair, crypto_kem_xwing_enc, crypto_kem_xwing_enc_deterministic, crypto_kem_xwing_dec
FFI constants: crypto_kem_xwing_publickeybytes, crypto_kem_xwing_secretkeybytes, crypto_kem_xwing_ciphertextbytes, crypto_kem_xwing_sharedsecretbytes, crypto_kem_xwing_seedbytes
JS methods: crypto_kem_xwing_keypair, crypto_kem_xwing_seed_keypair, crypto_kem_xwing_enc, crypto_kem_xwing_enc_deterministic, crypto_kem_xwing_dec
JS constants: crypto_kem_xwing_PUBLICKEYBYTES, crypto_kem_xwing_SECRETKEYBYTES, crypto_kem_xwing_CIPHERTEXTBYTES, crypto_kem_xwing_SHAREDSECRETBYTES, crypto_kem_xwing_SEEDBYTES

### mlkem768
…
```

`## Last completed phase` is updated to the current phase number at the end of
every phase (part of the standard phase-close protocol). This file is the single
source of truth for all later phases.

---

## Phase 2: Abstract API Interface

Goal: create (or extend) the Dart abstract interface and validation mixin in
`packages/sodium/lib/src/api/`.

> Previous phase output: `.claude/skills/implement-api/state.md`

### Step 1 — Derive naming

From the prefix (e.g. `crypto_kem`):

1. Strip the leading `crypto_` → base name (e.g. `kem`)
2. The base name in **snake_case** is the file name: `{base}.dart`
   (e.g. `crypto_secret_stream` → `secret_stream.dart`)
3. The base name in **PascalCase** is the Dart class name: `{Base}`
   (e.g. `secret_stream` → `SecretStream`)

The file lives at `packages/sodium/lib/src/api/{base}.dart`.

**Check first:** if this file already exists, read it. If the interface it
contains already covers all operations in the selected groups, this phase is
a no-op — confirm with the user and skip to Phase 3. If the file exists but
is missing some operations, extend it rather than recreating it.

### Step 2 — Map FFI signatures to a Dart API shape

Read the full method signatures for every FFI method in the selected groups
from `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart`.

Apply these rules to translate each C-level signature into a Dart API member:

**Drop these without replacement:**
- All length input parameters: any `int` param whose name contains `len`
  (e.g. `int mlen`, `int adlen`, `int clen`).
- All output length pointers: `Pointer<UnsignedLongLong>` / `Pointer<LongLong>`
  params (e.g. `clen_p`, `mlen_p`).
- `Pointer<UnsignedChar> nsec` — libsodium always passes `null` here; omit
  entirely from the Dart API.

**Map parameter names to Dart parameter roles:**

| C parameter name(s) | Dart type | Dart name | Named? |
|---|---|---|---|
| `m` (input) | `Uint8List` | `message` | required named |
| `c` (output) | part of return value | — | — |
| `npub`, `nonce` | `Uint8List` | `nonce` | required named |
| `k` | `SecureKey` | `key` | required named |
| `pk` (output) | part of return value | — | — |
| `pk` (input, single param) | `Uint8List` | `publicKey` | positional |
| `pk` (input, among others) | `Uint8List` | `publicKey` | required named |
| `sk` (output) | part of return value | — | — |
| `sk` (input) | `SecureKey` | `secretKey` | required named |
| `seed` | `SecureKey` | `seed` | positional |
| `ct` (input) | `Uint8List` | `ciphertext` | required named |
| `ct` (output) | part of return value | — | — |
| `ss` (output) | `SecureKey` in return | — | — |
| `ad`, `adlen` | `Uint8List?` | `additionalData` | optional named |

**Determine the return type:**
- No outputs → `void`
- Single `Uint8List` output → `Uint8List`
- Single secret-key output (e.g. `ss` shared secret) → `SecureKey`
- `pk` + `sk` both output → `KeyPair` (existing class)
- Multiple outputs, none are `SecureKey` → Dart **record typedef**:
  `typedef {Class}{Op}Result = ({Uint8List a, Uint8List b, …});`
  Define it just above the interface class.
- Multiple outputs, at least one is `SecureKey` → **`freezed` sealed class**
  with a `dispose()` method if it holds a `SecureKey`. Declare it in the same
  file with `part '{base}.freezed.dart';`.
- `Pointer<Char>` return → `String`

**Naming methods (C snake_case → Dart camelCase):**
Strip the full prefix (including variant, e.g. `crypto_kem_xwing_`) then
convert the remainder to camelCase:
`keypair` → `keyPair()`, `seed_keypair` → `seedKeyPair()`,
`enc` → `enc()`, `dec` → `dec()`, `open_easy` → `openEasy()`, etc. If there is
no remainder, the method must be named `call()`.

**Naming size-constant getters:**
Strip the prefix and `_` suffix, convert to camelCase, append `Bytes`:
`crypto_kem_publickeybytes` → `int get publicKeyBytes`
`crypto_kem_ciphertextbytes` → `int get ciphertextBytes`

String-typed constants (e.g. `crypto_kem_PRIMITIVE`) → `String get primitive`

If the selected groups contain variants only (no `default` group), derive the
interface from the union of operations shared across all selected variants.
Members that exist in some variants but not others should be noted in a comment.

### Step 3 — Write the file

Structure the file in this order:

1. Dart imports (`dart:typed_data`, `package:meta/meta.dart`, relative imports
   for `key_pair.dart`, `secure_key.dart`, `helpers/validations.dart`, etc.)
2. `part` directive if any `freezed` class is needed
3. Any `typedef` record aliases or `freezed` sealed class definitions
4. The interface:

```dart
/// A meta class that provides access to all libsodium {base} APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/…
/// Please refer to that documentation for more details about these APIs.
abstract interface class {ClassName} {
  /// Provides {c_constant_name}.
  ///
  /// See https://libsodium.gitbook.io/doc/…#constants
  int get publicKeyBytes;

  // … further constants …

  /// Provides {c_function_name}.
  ///
  /// See https://libsodium.gitbook.io/doc/…#usage
  ReturnType methodName(…);
}
```

**Do not add a constructor** — no `const ClassName._()`, no `ClassName()`.
The `abstract interface class` keyword alone is sufficient.

5. The validation mixin immediately after the interface in the same file:

```dart
/// @nodoc
@internal
mixin {ClassName}Validations implements {ClassName} {
  /// @nodoc
  void validatePublicKey(Uint8List publicKey) =>
      Validations.checkIsSame(publicKey.length, publicKeyBytes, 'publicKey');

  // one validate* per Uint8List / SecureKey parameter that has a
  // corresponding size constant
}
```

Mixin rules:
- `/// @nodoc` on the mixin class and on every method inside it.
- One `validateX` method per `Uint8List` / `SecureKey` parameter that maps to
  a size constant.
  - Fixed-size inputs/keys → `Validations.checkIsSame(value.length, sizeGetter, 'name')`
  - Variable-length outputs with a minimum → `Validations.checkAtLeast(…)`
  - No validation for parameters with no corresponding constant.
- If the same parameter appears in multiple operations under the same name
  (e.g. every `publicKey`) → one shared `validatePublicKey` method covers all.

Use `packages/sodium/lib/src/api/kem.dart` as the primary style reference —
it is the closest existing file that already uses `abstract interface class`.

### Step 4 — Generate `freezed` code (conditional)

If the file written in Step 3 includes a `part '{base}.freezed.dart';`
directive, run from `packages/sodium/`:

```
dart run build_runner build --delete-conflicting-outputs
```

This generates the `.freezed.dart` file that all subsequent phases require for
compilation. If no `part` directive was emitted, skip this step.

**Phase completion**
Show: the complete generated file; note any non-obvious design decisions (e.g.
why a parameter is `SecureKey` vs `Uint8List`, why a `freezed` class was chosen
over a record typedef).
Ask: *"Does this interface look correct? If anything needs to change — method
signatures, naming, result types, missing or extra members, validation rules —
describe it and I'll adjust before we move on."*
Follow the standard phase-close protocol.

---

## Phase 3: Validation Mixin Tests

Goal: write and pass the `test/unit/api/` test file that verifies the
validation mixin created in Phase 2.

> Previous phase output: `packages/sodium/lib/src/api/{base}.dart`

### Step 1 — Write the test file

Create `packages/sodium/test/unit/api/{base}_test.dart`.

**File structure:**

```dart
// ignore_for_file: unnecessary_lambdas

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/{base}.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class Mock{ClassName} extends Mock
    with {ClassName}Validations
    implements {ClassName} {}

void main() {
  // --- disposal test for every freezed sealed class defined in Phase 2
  //     that contains a SecureKey field (e.g. a custom result class) ---
  // group('{ResultClass}', () { … });

  group('{ClassName}Validations', () {
    late Mock{ClassName} sutMock;

    setUp(() {
      sutMock = Mock{ClassName}();
    });

    // one test helper call per validate* method:
    testCheckIsSame(
      'validatePublicKey',
      source: () => sutMock.publicKeyBytes,
      sut: (value) => sutMock.validatePublicKey(Uint8List(value)),
    );
    // …
  });
}
```

**Mapping validate methods to test helpers:**

| Mixin uses | Test helper |
|---|---|
| `Validations.checkIsSame` | `testCheckIsSame` |
| `Validations.checkAtLeast` | `testCheckAtLeast` |
| `Validations.checkAtMost` | `testCheckAtMost` |
| `Validations.checkInRange` | `testCheckInRange` |

**Parameter types in the `sut:` lambda:**
- `Uint8List` parameter → `Uint8List(value)`
- `SecureKey` parameter → `SecureKeyFake.empty(value)`

**Disposal tests** — for every `freezed` sealed class defined in Phase 2
that holds a `SecureKey` (e.g. a custom result type), add a group that:
1. Creates `Mock` instances for each `SecureKey` field.
2. Calls `dispose()`.
3. Verifies `dispose()` was called on every `SecureKey` field.

Follow the `SessionKeys` disposal test in
`packages/sodium/test/unit/api/kx_test.dart` as the reference.

### Step 2 — Run on both platforms

```
dart test test/unit/api/{base}_test.dart
dart test -p chrome test/unit/api/{base}_test.dart
```

Both must pass with zero failures and zero errors before proceeding.

If a test fails, diagnose and fix the mixin implementation (in the
`lib/src/api/{base}.dart` file) — do not weaken the test.

**Phase completion**
Show: the test file and the output of both test runs.
Ask: *"Do the validation tests look correct? If anything is missing or wrong,
describe it and I'll adjust before we move on."*
Follow the standard phase-close protocol.

---

## Phase 4: FFI Implementation

Goal: create `lib/src/ffi/api/{base}_ffi.dart` — the native platform implementation.
This phase requires translating each Dart API method from Phase 2 into precise C interop
code using `SodiumPointer`, `SecureKeyFFI`, and the unlock pattern.

> Previous phase output: `packages/sodium/lib/src/api/{base}.dart`
> Also read: `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart` (C signatures for the selected groups)

### Step 1 — Decide class structure

**One group, or groups with structurally different method sets → one class per group:**

- `class {ClassName}FFI with {ClassName}Validations, KeygenMixin implements {ClassName}`
  in `lib/src/ffi/api/{base}_ffi.dart`
- `class {ClassName}{Variant}FFI with {ClassName}Validations, KeygenMixin implements {ClassName}`
  in `lib/src/ffi/api/{base}_{variant}_ffi.dart`

**Multiple groups with identical method shapes (same operation names and same parameter
structure) → abstract base class + concrete subclasses:**

- `abstract class {ClassName}BaseFFI with {ClassName}Validations, KeygenMixin implements {ClassName}`
  in `lib/src/ffi/api/{base}_base_ffi.dart`
- `class {ClassName}{Variant}FFI extends {ClassName}BaseFFI`
  in `lib/src/ffi/api/{base}_{variant}_ffi.dart`

In the base class, declare each algorithm-specific C function as a `@protected` abstract
getter whose type matches the FFI wrapper signature:

```dart
/// @nodoc
@protected
int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk) get internalKeyPair;

/// @nodoc
@protected
int Function(Pointer<UnsignedChar> ct, Pointer<UnsignedChar> ss, Pointer<UnsignedChar> pk)
    get internalEnc;
```

Each concrete subclass overrides the size constants and the function getters:

```dart
@override
int get publicKeyBytes => sodium.crypto_{prefix}_{variant}_publickeybytes();

@override
int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk)
    get internalKeyPair => sodium.crypto_{prefix}_{variant}_keypair;
```

> Reference: `packages/sodium/lib/src/ffi/api/aead_base_ffi.dart` and
> `packages/sodium/lib/src/ffi/api/aead_chacha20poly1305_ffi.dart` show this exact pattern.

### Step 2 — Write the class header

```dart
/// @nodoc
@internal
class {ClassName}FFI with {ClassName}Validations, KeygenMixin implements {ClassName} {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  {ClassName}FFI(this.sodium);
```

### Step 3 — Implement size constants

FFI size constants call C functions — lowercase names with parentheses:

```dart
@override
int get publicKeyBytes => sodium.crypto_{prefix}_publickeybytes();

@override
String get primitive => sodium.crypto_{prefix}_primitive();
```

### Step 4 — Implement key generation methods

**Simple key generation** (returns `SecureKey`):
```dart
@override
SecureKey keygen() => keygenImpl(
  sodium: sodium,
  keyBytes: keyBytes,
  implementation: sodium.crypto_{prefix}_keygen,
);
```

**Random key pair** (returns `KeyPair`, no arguments):
```dart
@override
KeyPair keyPair() => keyPairImpl(
  sodium: sodium,
  secretKeyBytes: secretKeyBytes,
  publicKeyBytes: publicKeyBytes,
  implementation: sodium.crypto_{prefix}_keypair,
);
```

**Seed-based key pair** (validate first, then delegate):
```dart
@override
KeyPair seedKeyPair(SecureKey seed) {
  validateSeed(seed);
  return seedKeyPairImpl(
    sodium: sodium,
    seed: seed,
    secretKeyBytes: secretKeyBytes,
    publicKeyBytes: publicKeyBytes,
    implementation: sodium.crypto_{prefix}_seed_keypair,
  );
}
```

### Step 5 — Implement crypto operations

Every operation follows a five-zone pattern. Work through each C parameter from the
FFI wrapper signature and classify it before writing any code.

#### Zone 0: Classify C parameters

| C param role | How to recognise it | FFI handling |
|---|---|---|
| **Input `Uint8List`** | `Pointer<UnsignedChar>` — `m`, `c` (input), `pk` (input), `ct` (input), `ad`, `npub`, `nonce` | `.toSodiumPointer(sodium, memoryProtection: MemoryProtection.readOnly)` — dispose in `finally` |
| **Output `Uint8List`** | `Pointer<UnsignedChar>` — `c` (output), `ct` (output), `hash`, `mac` | `SodiumPointer.alloc(sodium, count: N)` — dispose in `catch`, return via `.asListView(owned: true)` |
| **Output `SecureKey`** | `Pointer<UnsignedChar>` — `ss` (shared secret), `k` (output key) | `SecureKeyFFI.alloc(sodium, N)` — dispose in `catch`, unlock writably, return directly |
| **Input `SecureKey`** | `Pointer<UnsignedChar>` — `sk` (input), `k` (input) | No allocation — unlock via `key.runUnlockedNative(sodium, ...)` extension |
| **Length input** | `int mlen`, `int clen`, `int adlen` | Pass `.count` of the corresponding pointer |
| **Length output ptr** | `Pointer<UnsignedLongLong>` / `Pointer<LongLong>` | Pass `nullptr` |
| **Always-null** | `Pointer<UnsignedChar> nsec` | Pass `nullptr` |
| **Optional input** | `Pointer<UnsignedChar> ad` with nullable Dart param | `additionalData?.toSodiumPointer(...)` then pass `adPtr?.ptr ?? nullptr` and `adPtr?.count ?? 0` |

#### Zone 1: Validate

Call every relevant `validate*` mixin method before any allocation:

```dart
validatePublicKey(publicKey);
validateSecretKey(secretKey);
```

#### Zone 2: Declare pointer variables

Declare all pointer variables nullable **outside** the `try` block so `catch` can safely
dispose them even if allocation fails mid-way:

```dart
SodiumPointer<UnsignedChar>? ctPtr;
SecureKeyFFI? ssKey;
SodiumPointer<UnsignedChar>? pkPtr;
try {
  ctPtr = SodiumPointer.alloc(sodium, count: ciphertextBytes);
  ssKey = SecureKeyFFI.alloc(sodium, sharedSecretBytes);
  pkPtr = publicKey.toSodiumPointer(sodium, memoryProtection: MemoryProtection.readOnly);
```

#### Zone 3: Unlock and call

Choose the unlock strategy based on which SecureKey roles are present:

**No SecureKey inputs or outputs** (rare):
```dart
final result = sodium.crypto_{prefix}_{op}(outPtr.ptr, inPtr.ptr, inPtr.count);
```

**One SecureKey input only:**
```dart
final result = key.runUnlockedNative(
  sodium,
  (keyPtr) => sodium.crypto_{prefix}_{op}(outPtr!.ptr, inPtr!.ptr, inPtr.count, keyPtr.ptr),
);
```
> Use the extension method `key.runUnlockedNative(sodium, callback)` — it accepts any
> `SecureKey`, including non-FFI instances.

**One SecureKey output only** (e.g. writing the shared secret):
```dart
final result = ssKey.runUnlockedNative(
  (ssPtr) => sodium.crypto_{prefix}_{op}(ssPtr.ptr, ctPtr!.ptr, pkPtr!.ptr),
  writable: true,
);
```
> Call the direct method on `SecureKeyFFI` (not the extension), since this is a freshly
> allocated key being written to. Always pass `writable: true`.

**SecureKey input + SecureKey output (nested unlock):**
```dart
final result = ssKey.runUnlockedNative(
  (ssPtr) => secretKey.runUnlockedNative(
    sodium,
    (skPtr) => sodium.crypto_{prefix}_{op}(ssPtr.ptr, ctPtr!.ptr, skPtr.ptr),
  ),
  writable: true,
);
```
> The outermost unlock is always the output key (`writable: true`).
> The inner unlock is the input key (read-only, extension method).

**Multiple SecureKey outputs (e.g. two session keys):**
```dart
final result = rxKey.runUnlockedNative(
  (rxPtr) => txKey!.runUnlockedNative(
    (txPtr) => inputKey.runUnlockedNative(
      sodium,
      (inputPtr) => sodium.crypto_{prefix}_{op}(
        rxPtr.ptr, txPtr.ptr,
        pkPtr!.ptr, inputPtr.ptr, otherPkPtr!.ptr,
      ),
    ),
    writable: true,
  ),
  writable: true,
);
```

#### Zone 4: Check result

Always check the return value immediately after the native call:

```dart
SodiumException.checkSucceededInt(result);
```

#### Zone 5: Return and clean up

```dart
  // Ownership transfer — the returned object now owns the memory:
  return (
    ciphertext: ctPtr.asListView(owned: true),
    sharedSecret: ssKey,
  );

} catch (_) {
  // Dispose only OWNED outputs that have NOT yet been transferred
  ctPtr?.dispose();
  ssKey?.dispose();
  rethrow;
} finally {
  // Dispose every input/read-only pointer unconditionally
  pkPtr?.dispose();
  adPtr?.dispose();
}
```

**Ownership rule:**
- Input pointers (created via `.toSodiumPointer`) → always in `finally`
- Output pointers (`SodiumPointer.alloc` / `SecureKeyFFI.alloc`) → only in `catch`,
  because `asListView(owned: true)` detaches them from our ownership before the return

**Stripping a prefix or MAC from an output buffer** — use `Uint8List.sublistView`:
```dart
return Uint8List.sublistView(
  dataPtr.asListView<Uint8List>(owned: true),
  startOffset,   // e.g. macBytes for openEasy
  endOffset,     // e.g. dataPtr.count - aBytes for decrypt
);
```

**In-place operations where input and output share one buffer** — use `viewAt`:
```dart
dataPtr = SodiumPointer.alloc(sodium, count: message.length + macBytes)
  ..fill(List<int>.filled(macBytes, 0))   // MAC prefix placeholder
  ..fill(message, offset: macBytes);      // message after the prefix

sodium.crypto_{prefix}_{op}(
  dataPtr.ptr,                   // output: full buffer (MAC + ciphertext)
  dataPtr.viewAt(macBytes).ptr,  // input: message sub-region at offset macBytes
  message.length,
  ...
)
```

### Step 6 — Standard imports

```dart
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/{base}.dart';
import '../../api/key_pair.dart';         // if KeyPair is used
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';  // for runUnlockedNative extension
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';
import 'secure_key_ffi.dart';             // if SecureKeyFFI.alloc is called directly
```

Add `../../api/{result_type}.dart` for any `freezed` result type from Phase 2.
Omit imports that are not used.

**Phase completion**
Show: all generated file(s); note which C parameters were classified as output
`SecureKey` vs `Uint8List`, whether a base class was used, any `viewAt` /
`Uint8List.sublistView` usage, and the nesting order of `runUnlockedNative`
calls if more than one is present.
Ask: *"Does the FFI implementation look correct? In particular, check: memory
ownership in try/catch/finally, unlock nesting order (outputs outermost),
correct `nullptr` for dropped parameters, and correct `.count` arguments.
Describe any issues and I'll adjust before we move on."*
Follow the standard phase-close protocol.

---

## Phase 5: FFI Unit Tests

Goal: write and pass unit tests for the FFI implementation from Phase 4. These tests
mock `LibSodiumFFI`, never touch real native memory, and run **only on the Dart VM**.

> Previous phase output: `packages/sodium/lib/src/ffi/api/{base}*_ffi.dart`

### Step 1 — Decide file structure

**One FFI class → one test file:**
`packages/sodium/test/unit/ffi/api/{base}_ffi_test.dart`

**Base class + multiple variant classes → one test file per variant:**
`packages/sodium/test/unit/ffi/api/{base}_{variant}_ffi_test.dart`

Each variant test exercises ALL methods (constants, keygen, and every operation) using
that variant's concrete class. This verifies that each variant's function pointers are
wired to the right C symbols.

### Step 2 — Write the file skeleton

```dart
@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/{base}_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();
  late {ClassName}FFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
    mockAllocArray(mockSodium);
    sut = {ClassName}FFI(mockSodium);
  });

  // … test groups follow …
}
```

Add `import 'package:sodium/src/api/{base}.dart';` if any result types from Phase 2
are referenced in test assertions.

### Step 3 — Test size constants

Use `testConstantsMapping` outside the `methods` group, passing one triple per constant:

```dart
testConstantsMapping([
  (
    () => mockSodium.crypto_{prefix}_publickeybytes(),
    () => sut.publicKeyBytes,
    'publicKeyBytes',
  ),
  (
    () => mockSodium.crypto_{prefix}_secretkeybytes(),
    () => sut.secretKeyBytes,
    'secretKeyBytes',
  ),
  // … one entry per size constant and String constant
]);
```

### Step 4 — Test key generation

Wrap all method tests in a `group('methods', () { ... })` that stubs every byte constant
in its own `setUp` with a small, consistent value (e.g. `5`):

```dart
group('methods', () {
  setUp(() {
    when(() => mockSodium.crypto_{prefix}_publickeybytes()).thenReturn(5);
    when(() => mockSodium.crypto_{prefix}_secretkeybytes()).thenReturn(5);
    when(() => mockSodium.crypto_{prefix}_seedbytes()).thenReturn(5);
    // … all byte getters
  });
```

Then call the helpers (each creates its own nested `group`):

**Simple keygen:**
```dart
testKeygen(
  mockSodium: mockSodium,
  runKeygen: () => sut.keygen(),
  keyBytesNative: mockSodium.crypto_{prefix}_keybytes,
  keygenNative: mockSodium.crypto_{prefix}_keygen,
);
```

**Random keypair:**
```dart
testKeypair(
  mockSodium: mockSodium,
  runKeypair: () => sut.keyPair(),
  secretKeyBytesNative: mockSodium.crypto_{prefix}_secretkeybytes,
  publicKeyBytesNative: mockSodium.crypto_{prefix}_publickeybytes,
  keypairNative: mockSodium.crypto_{prefix}_keypair,
);
```

**Seed-based keypair:**
```dart
testSeedKeypair(
  mockSodium: mockSodium,
  runSeedKeypair: (seed) => sut.seedKeyPair(seed),
  seedBytesNative: mockSodium.crypto_{prefix}_seedbytes,
  secretKeyBytesNative: mockSodium.crypto_{prefix}_secretkeybytes,
  publicKeyBytesNative: mockSodium.crypto_{prefix}_publickeybytes,
  seedKeypairNative: mockSodium.crypto_{prefix}_seed_keypair,
);
```

Only include helpers that match methods the interface actually exposes.

### Step 5 — Test crypto operations

For each crypto operation, write a `group('{methodName}', () { ... })` with four kinds
of tests.

**Establish test-data sizes upfront** — pick sizes that match the value stubs in the
`methods` setUp, e.g. if `publickeybytes` is stubbed to `5`, use `Uint8List(5)`.

#### Test 1 — Input validation (one per validated parameter)

```dart
test('asserts if {paramName} is invalid', () {
  expect(
    () => sut.{methodName}(
      {paramName}: Uint8List(wrongSize),       // or SecureKeyFake.empty(wrongSize)
      otherParam: Uint8List(correctSize),
    ),
    throwsA(isA<RangeError>()),
  );
  verify(() => mockSodium.crypto_{prefix}_{constant}());
});
```

#### Test 2 — Correct native call arguments

Stub the native function to return `0`, call the method, then use `verifyInOrder` to
assert the call received the right data in each position:

```dart
test('calls {nativeFn} with correct arguments', () {
  when(
    () => mockSodium.{nativeFn}(any(), any(), any(), ...),
  ).thenReturn(0);

  final inputData = List.generate(5, (i) => i);

  sut.{methodName}(param: Uint8List.fromList(inputData), ...);

  verifyInOrder([
    () => mockSodium.{nativeFn}(
      any(that: hasRawData<UnsignedChar>(inputData)),
      ...
    ),
  ]);
});
```

Use `any()` for positions you are not checking in this test.
Use `any(that: hasRawData<UnsignedChar>(data))` for positions you want to verify.
Use the literal `nullptr` for parameters that Phase 4 passes as `nullptr`.

#### Test 3 — Correct return value

Use `fillPointer` inside `thenAnswer` to write known data into the output pointer(s),
then assert the returned value equals that data:

```dart
test('returns {outputName}', () {
  final outputData = List.generate(5, (i) => 100 - i);

  when(
    () => mockSodium.{nativeFn}(any(), any(), ...),
  ).thenAnswer((i) {
    fillPointer(
      i.positionalArguments[outputArgIndex] as Pointer<UnsignedChar>,
      outputData,
    );
    return 0;
  });

  final result = sut.{methodName}(...valid-sized inputs...);

  // For Uint8List return:
  expect(result, outputData);
  // For SecureKey return:
  expect(result.extractBytes(), outputData);
  // For record return with multiple fields:
  expect(result.fieldA, outputDataA);
  expect(result.fieldB.extractBytes(), outputDataB);

  // Verify exactly the expected number of sodium_free calls (success path):
  // Count one call per input pointer (disposed in `finally`).
  // Output pointers transferred via asListView(owned: true) or returned as
  // SecureKeyFFI are NOT freed in the success path (finalizer is mocked).
  verify(() => mockSodium.sodium_free(any())).called(N_input_pointers);
});
```

For operations with multiple output pointers, call `fillPointer` once per output
using the correct positional-argument index for each.

#### Test 4 — Failure path

```dart
test('throws if {nativeFn} fails', () {
  when(
    () => mockSodium.{nativeFn}(any(), any(), ...),
  ).thenReturn(1);

  expect(
    () => sut.{methodName}(...valid-sized inputs...),
    throwsA(isA<SodiumException>()),
  );

  // On failure ALL allocated pointers are freed (catch + finally paths):
  verify(() => mockSodium.sodium_free(any()))
      .called(N_input_pointers + N_output_pointers);
});
```

### Step 6 — Pointer count reference

To get the `sodium_free` counts right, refer to the Phase 4 implementation:

| Pointer type | Success path | Failure path |
|---|---|---|
| Input (`toSodiumPointer`, disposed in `finally`) | freed | freed |
| Output Uint8List (`SodiumPointer.alloc`, transferred via `asListView(owned: true)`) | **not freed** | freed |
| Output SecureKey (`SecureKeyFFI.alloc`, returned directly) | **not freed** | freed |
| Optional input that was `null` | not allocated → 0 | not allocated → 0 |

### Step 7 — Run tests

From `packages/sodium/`:
```
dart test test/unit/ffi/api/{base}_ffi_test.dart
```

Do **not** add `-p chrome` — these are VM-only.

Both success and failure tests must pass with zero failures. If a test fails, diagnose
and fix the Phase 4 FFI implementation — do not weaken the test.

**Phase completion**
Show: the test file(s) and full test run output.
Ask: *"Do the FFI tests look correct? Check especially: correct pointer counts
in `sodium_free` assertions, correct positional indices in `fillPointer`, and
whether any operation tests are missing. Describe any issues and I'll adjust
before we move on."*
Follow the standard phase-close protocol.

---

## Phase 6: JS Implementation

Goal: create `lib/src/js/api/{base}_js.dart` — the web/JS platform implementation.
This is significantly simpler than the FFI implementation: there is no manual memory
management, no pointer arithmetic, and no unlock nesting for outputs. The JS library
handles allocation internally.

> Previous phase output: `packages/sodium/lib/src/ffi/api/{base}*_ffi.dart`
> Also scan: `packages/sodium/lib/src/js/bindings/sodium.js.dart` (return types, UPPERCASE constants, method signatures for the selected groups)

### Step 1 — Decide class structure

Apply the same rule as Phase 4:

**One group or structurally different groups → one class per group:**
- `class {ClassName}JS with {ClassName}Validations implements {ClassName}`
  in `lib/src/js/api/{base}_js.dart`
- `class {ClassName}{Variant}JS with {ClassName}Validations implements {ClassName}`
  in `lib/src/js/api/{base}_{variant}_js.dart`

**Multiple groups with identical method shapes → abstract base class:**
- `abstract class {ClassName}BaseJS with {ClassName}Validations implements {ClassName}`
  in `lib/src/js/api/{base}_base_js.dart`
- `class {ClassName}{Variant}JS extends {ClassName}BaseJS`
  in `lib/src/js/api/{base}_{variant}_js.dart`

In the base class, declare each algorithm-specific JS call as a `@protected` abstract
method whose parameters and return type are **JS types** (`JSUint8Array`, an extension
type from `sodium.js.dart`, etc.):

```dart
/// @nodoc
@protected
JSUint8Array internalDec(JSUint8Array ciphertext, JSUint8Array privateKey);
```

The base class implements all Dart-facing methods, handles `jsErrorWrap` and
`runUnlockedSync`, and converts to/from Dart types. The concrete subclass only
overrides size constants and delegates to the right sodium function:

```dart
@override
JSUint8Array internalDec(JSUint8Array ciphertext, JSUint8Array privateKey) =>
    sodium.crypto_{prefix}_{variant}_dec(ciphertext, privateKey);
```

> Reference: `packages/sodium/lib/src/js/api/aead_base_js.dart` and
> `packages/sodium/lib/src/js/api/aead_chacha20poly1305_js.dart`.

### Step 2 — Write the file header

```dart
// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/{base}.dart';
import '../../api/key_pair.dart';          // if KeyPair is returned
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;  // see Step 4
import 'secure_key_js.dart';
```

Add `../../api/{result_type}.dart` for any `freezed` result type from Phase 2.
The `// ignore_for_file` comment is required on every file that calls sodium functions
directly — without it the analyser flags the lambdas used to defer member access.

### Step 3 — Resolve `hide` conflicts

`sodium.js.dart` defines extension types for its own JS result objects. Some share names
with Dart API types. If you import a Dart API type whose name also exists as an extension
type in `sodium.js.dart`, add that name to the `hide` clause:

```dart
import '../bindings/sodium.js.dart' hide KeyPair, KemEncResult;
//                                       ^^^^^^^^  ^^^^^^^^^^^^
//  from api/key_pair.dart              from api/kem.dart (the record typedef)
```

Rule: for each `import '../../api/...dart'` that brings in a named type, grep
`sodium.js.dart` for `extension type {TypeName}`. If found, hide it.

Common names that need hiding: `KeyPair`, `SecretBox`, `KemEncResult`.

### Step 4 — Implement size constants

UPPERCASE getters — **no parentheses**:

```dart
@override
int get publicKeyBytes => sodium.crypto_{prefix}_PUBLICKEYBYTES;

@override
String get primitive => sodium.crypto_{prefix}_PRIMITIVE;
```

Note: String constants follow the same UPPERCASE property pattern as integer constants.
Do **not** call `crypto_{prefix}_primitive()` (the lowercase method alias) — use the
uppercase getter.

### Step 5 — Implement key generation

**Simple keygen** (no `KeygenMixin` — construct `SecureKeyJS` directly):
```dart
@override
SecureKey keygen() =>
    SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_{prefix}_keygen()));
```

**Random keypair** — JS returns a `KeyPair` extension type with `.privateKey` and
`.publicKey` fields:
```dart
@override
KeyPair keyPair() {
  final keyPair = jsErrorWrap(() => sodium.crypto_{prefix}_keypair());

  return KeyPair(
    publicKey: keyPair.publicKey.toDart,
    secretKey: SecureKeyJS(sodium, keyPair.privateKey),
  );
}
```

**Seed-based keypair** — unlock the seed inside `jsErrorWrap`:
```dart
@override
KeyPair seedKeyPair(SecureKey seed) {
  validateSeed(seed);

  final keyPair = jsErrorWrap(
    () => seed.runUnlockedSync(
      (seedData) => sodium.crypto_{prefix}_seed_keypair(seedData.toJS),
    ),
  );

  return KeyPair(
    publicKey: keyPair.publicKey.toDart,
    secretKey: SecureKeyJS(sodium, keyPair.privateKey),
  );
}
```

### Step 6 — Implement crypto operations

There are three output patterns. For each operation, read the JS binding's **return
type** from `sodium.js.dart` to decide which pattern applies.

#### Pattern A — Single `JSUint8Array` output → `Uint8List`

The JS function returns `JSUint8Array`. Call `.toDart` inline at the end of the chain:

```dart
@override
Uint8List {methodName}({required Uint8List param, required SecureKey key}) {
  validate...(param);
  validateKey(key);

  return jsErrorWrap(
    () => key.runUnlockedSync(
      (keyData) => sodium.crypto_{prefix}_{op}(param.toJS, keyData.toJS).toDart,
    ),
  );
}
```

If there is **no SecureKey input**, omit `runUnlockedSync`:
```dart
return jsErrorWrap(() => sodium.crypto_{prefix}_{op}(param.toJS).toDart);
```

For **optional parameters** (`Uint8List? additionalData`), pass `additionalData?.toJS`
— this evaluates to a nullable `JSUint8Array?` which the JS function accepts.

#### Pattern B — Single `JSUint8Array` output → `SecureKey`

When the JS function returns raw bytes that should be kept secret, wrap in `SecureKeyJS`
instead of calling `.toDart`. Put `jsErrorWrap` *outside* `runUnlockedSync` so the
returned `JSUint8Array` is available for construction:

```dart
@override
SecureKey {methodName}({required Uint8List ciphertext, required SecureKey secretKey}) {
  validate...(ciphertext);
  validateSecretKey(secretKey);

  return SecureKeyJS(
    sodium,
    jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) =>
            sodium.crypto_{prefix}_{op}(ciphertext.toJS, secretKeyData.toJS),
      ),
    ),
  );
}
```

If there is **no SecureKey input**, omit `runUnlockedSync`:
```dart
return SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_{prefix}_{op}(param.toJS)));
```

#### Pattern C — Extension type output (multi-field result)

When the JS function returns an extension type (`KemEncResult`, `CryptoKX`, `CryptoBox`,
etc.), store the whole result first, then extract and convert each field:

```dart
@override
{DartResultType} {methodName}({required Uint8List publicKey}) {
  validatePublicKey(publicKey);

  final result = jsErrorWrap(
    () => sodium.crypto_{prefix}_{op}(publicKey.toJS),
    // or, if a SecureKey input is needed:
    // () => secretKey.runUnlockedSync((sk) => sodium.crypto_{prefix}_{op}(..., sk.toJS))
  );

  // Convert each field:
  return {DartResultType}(
    fieldA: result.fieldA.toDart,                   // JSUint8Array → Uint8List
    fieldB: SecureKeyJS(sodium, result.fieldB),     // JSUint8Array → SecureKey
  );
  // or for a record typedef:
  // return (fieldA: result.fieldA.toDart, fieldB: SecureKeyJS(sodium, result.fieldB));
}
```

To find the field names: read the extension type definition at the top of `sodium.js.dart`.

### Step 7 — Standard imports summary

```dart
// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/{base}.dart';
import '../../api/key_pair.dart';       // if KeyPair is used
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;   // add names as needed
import 'secure_key_js.dart';
```

Omit unused imports. Never import `dart:ffi` or anything from `ffi/`.

**Phase completion**
Show: all generated file(s); note which output pattern (A/B/C) was used for
each operation, any `hide` names added to the `sodium.js.dart` import, and
whether a base class was used.
Ask: *"Does the JS implementation look correct? Check especially: correct
UPPERCASE vs lowercase for constants, correct `.toDart` / `SecureKeyJS` usage
on outputs, and correct `hide` names on the `sodium.js.dart` import. Describe
any issues and I'll adjust before we move on."*
Follow the standard phase-close protocol.

---

## Phase 7: JS Unit Tests

Goal: write and pass unit tests for the JS implementation from Phase 6. These tests use
the `MockLibSodiumJS` JS-interop mock and run **only on the JS platform**.

> Previous phase output: `packages/sodium/lib/src/js/api/{base}*_js.dart`

### Step 1 — Decide file structure

Same rule as Phase 5:

**One JS class → one test file:**
`packages/sodium/test/unit/js/api/{base}_js_test.dart`

**Base class + multiple variant classes → one test file per variant:**
`packages/sodium/test/unit/js/api/{base}_{variant}_js_test.dart`

Each variant test exercises ALL methods using that variant's concrete class.

### Step 2 — Write the file skeleton

```dart
@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/{base}_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late {ClassName}JS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
    sut = {ClassName}JS(mockSodium.asLibSodiumJS);
  });

  // … test groups follow …
}
```

Add `import 'package:sodium/src/api/{base}.dart';` if any result types from Phase 2
are referenced in test assertions (e.g. a `freezed` result class).

### Step 3 — Test size constants

Use `testConstantsMapping` with UPPERCASE getter names — no parentheses:

```dart
testConstantsMapping([
  (
    () => mockSodium.crypto_{prefix}_PUBLICKEYBYTES,
    () => sut.publicKeyBytes,
    'publicKeyBytes',
  ),
  (
    () => mockSodium.crypto_{prefix}_SECRETKEYBYTES,
    () => sut.secretKeyBytes,
    'secretKeyBytes',
  ),
  // … one entry per size constant
]);
```

For a `String` constant (`primitive`), the same pattern applies — the UPPERCASE
getter returns a `String` and the triple's first element is its thunk.

> Contrast with Phase 5 (FFI): there the native side used lowercase function calls
> `mockSodium.crypto_{prefix}_publickeybytes()`. Here it is a bare property access
> `mockSodium.crypto_{prefix}_PUBLICKEYBYTES` with no call syntax.

### Step 4 — Test key generation

Wrap all method tests in a `group('methods', () { ... })` with a `setUp` that stubs
every constant using UPPERCASE names:

```dart
group('methods', () {
  setUp(() {
    when(() => mockSodium.crypto_{prefix}_PUBLICKEYBYTES).thenReturn(5);
    when(() => mockSodium.crypto_{prefix}_SECRETKEYBYTES).thenReturn(5);
    when(() => mockSodium.crypto_{prefix}_SEEDBYTES).thenReturn(5);
    // … all byte and string constants
  });
```

Then use the helpers (each creates its own nested `group`):

**Simple keygen** — note: no `keyBytesNative` argument (JS helpers are simpler):
```dart
testKeygen(
  mockSodium: mockSodium,
  runKeygen: () => sut.keygen(),
  keygenNative: mockSodium.crypto_{prefix}_keygen,
);
```

**Random keypair:**
```dart
testKeypair(
  mockSodium: mockSodium,
  runKeypair: () => sut.keyPair(),
  keypairNative: mockSodium.crypto_{prefix}_keypair,
);
```

**Seed-based keypair** — `seedBytesNative` is a thunk for the UPPERCASE getter:
```dart
testSeedKeypair(
  mockSodium: mockSodium,
  runSeedKeypair: (seed) => sut.seedKeyPair(seed),
  seedBytesNative: () => mockSodium.crypto_{prefix}_SEEDBYTES,
  seedKeypairNative: mockSodium.crypto_{prefix}_seed_keypair,
);
```

Only include helpers that match methods the interface actually exposes.

### Step 5 — Test crypto operations

For each crypto operation, write a `group('{methodName}', () { ... })` with four tests.

**Determine the mock return type** by looking at the JS binding signature in
`sodium.js.dart`:

| JS return type | Mock `thenReturn` value | Assertion pattern |
|---|---|---|
| `JSUint8Array` (Uint8List result) | `Uint8List.fromList(data).toJS` | `expect(result, data)` |
| `JSUint8Array` (SecureKey result) | `Uint8List.fromList(data).toJS` | `expect(result.extractBytes(), data)` or `expect(result, SecureKeyFake(data))` |
| Extension type (e.g. `KemEncResult`) | `ExtType(field: data.toJS, ...)` | `expect(result.field, data)` / `expect(result.secureField, SecureKeyFake(data))` |
| `KeyPair` | `KeyPair(keyType: '', publicKey: ...)` | handled by `testKeypair` helper |

#### Test 1 — Input validation (one per validated parameter)

```dart
test('asserts if {paramName} is invalid', () {
  expect(
    () => sut.{methodName}(
      {paramName}: Uint8List(wrongSize),    // or SecureKeyFake.empty(wrongSize)
      otherParam: Uint8List(correctSize),
    ),
    throwsA(isA<RangeError>()),
  );
  verify(() => mockSodium.crypto_{prefix}_{CONSTANT});  // UPPERCASE, no ()
});
```

#### Test 2 — Correct native call arguments

Stub the mock, call the method, then verify the exact JS-converted arguments:

```dart
test('calls {nativeFn} with correct arguments', () {
  when(
    () => mockSodium.{nativeFn}(any(), any(), ...),
  ).thenReturn(Uint8List(0).toJS);  // or the appropriate extension type

  final inputData = List.generate(5, (i) => i);

  sut.{methodName}(param: Uint8List.fromList(inputData), ...);

  verify(
    () => mockSodium.{nativeFn}(
      Uint8List.fromList(inputData).toJS,
      ...
    ),
  );
});
```

> Use `any()` for arguments you are not verifying. When verifying a specific value,
> pass `Uint8List.fromList(data).toJS` — mocktail compares JS typed arrays by value.

#### Test 3 — Correct return value

```dart
test('returns {outputName}', () {
  final outputData = List.generate(5, (i) => 100 - i);

  when(
    () => mockSodium.{nativeFn}(any(), any(), ...),
  ).thenReturn(Uint8List.fromList(outputData).toJS);  // for JSUint8Array return

  final result = sut.{methodName}(...valid-sized inputs...);

  // Uint8List return (Pattern A):
  expect(result, outputData);

  // SecureKey return (Pattern B):
  expect(result.extractBytes(), outputData);

  // Extension type with multiple fields (Pattern C):
  // Mock returns the extension type:
  // .thenReturn(ExtType(fieldA: dataA.toJS, fieldB: dataB.toJS));
  // Then assert each field:
  // expect(result.fieldA, dataA);                   // Uint8List field
  // expect(result.fieldB, SecureKeyFake(dataB));    // SecureKey field
});
```

#### Test 4 — Failure path

```dart
test('throws exception on failure', () {
  when(
    () => mockSodium.{nativeFn}(any(), any(), ...),
  ).thenThrow(JSError());

  expect(
    () => sut.{methodName}(...valid-sized inputs...),
    throwsA(isA<SodiumException>()),
  );
});
```

No pointer count assertions needed — JS has no manual memory management.

### Step 6 — For base class + variants

For each variant, create a separate test file that wires the helpers and verifies to
that variant's function names:

```dart
sut = {ClassName}XwingJS(mockSodium.asLibSodiumJS);

// In testConstantsMapping:
() => mockSodium.crypto_{prefix}_xwing_PUBLICKEYBYTES

// In testKeypair:
keypairNative: mockSodium.crypto_{prefix}_xwing_keypair

// In operation tests:
when(() => mockSodium.crypto_{prefix}_xwing_enc(any())).thenReturn(...);
```

### Step 7 — Run tests

From `packages/sodium/`:
```
dart test -p chrome test/unit/js/api/{base}_js_test.dart
```

Do **not** run on the VM (`dart test` without `-p chrome`) — these are JS-only.

Both success and failure tests must pass with zero failures. If a test fails, fix the
Phase 6 JS implementation — do not weaken the test.

**Phase completion**
Show: the test file(s) and full test run output.
Ask: *"Do the JS tests look correct? Check especially: UPPERCASE constant names
in `testConstantsMapping`, correct `.toJS` conversion on arguments in `verify`,
correct extension type construction in mock `thenReturn` calls, and correct
assertion pattern for each output type. Describe any issues and I'll adjust
before we move on."*
Follow the standard phase-close protocol.

---

## Phase 8: Wire-Up

Goal: Register the new implementations in the three `Crypto` classes, export the
new API types from `sodium.dart`, and extend the two `crypto_*_test.dart` files
with one test per new getter. Run all affected tests before asking the user to
approve.

---

### Step 1 — Determine getter name(s)

For each implementation class generated in Phases 4 and 6 (e.g. `KemFFI` /
`KemJS`), derive:

| Piece | Rule | Example |
|-------|------|---------|
| Getter name | camelCase of feature prefix, or prefix + variant | `kem`, `aeadChaCha20Poly1305` |
| API type | Abstract class from `api/{feature}.dart` | `Kem`, `Aead` |
| FFI class | `{FeaturePascal}FFI` (or variant-specific) | `KemFFI` |
| JS class | `{FeaturePascal}JS` | `KemJS` |

If Phase 1 identified multiple variants, each variant produces its own getter.

### Step 2 — `lib/src/api/crypto.dart`

1. Insert `import '{feature}.dart';` in alphabetical order with the other imports.
2. Add one abstract getter per variant, following the doc-comment style of
   existing getters:

```dart
/// An instance of [{ApiType}].
///
/// This provides all APIs that start with `crypto_{prefix}`.
{ApiType} get {getterName};
```

Insert the getter alphabetically among the existing getters (e.g. `kem` goes
between `kdf` and `kx`).

### Step 3 — `lib/src/ffi/api/crypto_ffi.dart`

1. Add API import: `import '../../api/{feature}.dart';` (alphabetical).
2. Add implementation import: `import '{feature}_ffi.dart';` (alphabetical).
3. Add one `@override late final` property per variant:

```dart
@override
late final {ApiType} {getterName} = {ImplClassFFI}(sodium);
```

### Step 4 — `lib/src/js/api/crypto_js.dart`

**Check for extension-type name conflicts first.**

The `sodium.js.dart` binding defines extension types whose names can clash with
Dart API types. For each type exported from `api/{feature}.dart` (beyond the
main interface), check whether `sodium.js.dart` also defines an extension type
with the same name:

```
grep "extension type {TypeName}" packages/sodium/lib/src/js/bindings/sodium.js.dart
```

If a match exists, add that name to the `hide` list on the existing
`sodium.js.dart` import line, e.g.:

```dart
// Before (only SecretBox was conflicting):
import '../bindings/sodium.js.dart' hide SecretBox;

// After (KemEncResult also conflicts):
import '../bindings/sodium.js.dart' hide KemEncResult, SecretBox;  // keep alphabetical
```

Then:

1. Add API import: `import '../../api/{feature}.dart';` (alphabetical).
2. Add implementation import: `import '{feature}_js.dart';` (alphabetical).
3. Add one `@override late final` property per variant:

```dart
@override
late final {ApiType} {getterName} = {ImplClassJS}(sodium);
```

### Step 5 — `lib/sodium.dart`

Add an export for the new API file. Follow the existing `hide {Foo}Validations`
pattern:

```dart
export 'src/api/{feature}.dart' hide {Feature}Validations;
```

If the API file defines no validation mixin, omit the `hide` clause. Insert the
line in alphabetical order with the existing exports.

### Step 6 — `test/unit/ffi/api/crypto_ffi_test.dart`

1. Add one import per variant implementation class:
   ```dart
   import 'package:sodium/src/ffi/api/{feature}_ffi.dart';
   ```
2. Add one test per getter:
   ```dart
   test('{getterName} returns {ImplClassFFI} instance', () {
     expect(
       sut.{getterName},
       isA<{ImplClassFFI}>().having((p) => p.sodium, 'sodium', mockSodium),
     );
   });
   ```

### Step 7 — `test/unit/js/api/crypto_js_test.dart`

1. Add one import per variant implementation class:
   ```dart
   import 'package:sodium/src/js/api/{feature}_js.dart';
   ```
2. Add one test per getter:
   ```dart
   test('{getterName} returns {ImplClassJS} instance', () {
     expect(
       sut.{getterName},
       isA<{ImplClassJS}>().having((p) => p.sodium, 'sodium', sut.sodium),
     );
   });
   ```

### Step 8 — Run tests

Run both crypto wire-up test files (plus re-run the individual unit tests for
the new feature to catch any regressions):

```
# From packages/sodium/
dart test test/unit/ffi/api/crypto_ffi_test.dart
dart test -p chrome test/unit/js/api/crypto_js_test.dart
```

Fix any failures before proceeding.

### Step 9 - Update README

In the README.md under `### API Status`, add a new row to the table for the new
feature, with "✔️" in the "VM" and "JS" columns. The "Sumo" column must be
filled only when the feature was added to `CryptoSumo` instead of `Crypto`. The
Documentation should reference the same documentation as the generate API
interface.

**Phase completion**
Show: a summary of every file modified.
Ask: *"Does this look correct? If anything needs to be changed, describe it and
I will adjust before we move on."*
Follow the standard phase-close protocol.

---

## Phase 9: Integration Tests

Goal: Generate the integration test *scaffolding* — the test case class and its
registration in the test runner — with stubs for every constant and operation.
Leave the actual test bodies empty or commented out; a human will fill them in.

---

### Step 1 — Derive constants and operations from the API

Read `lib/src/api/{feature}.dart`. Collect two lists:

- **Constants** — every abstract getter that returns `int` or `String`
  (e.g. `publicKeyBytes`, `secretKeyBytes`, `primitive`).
- **Operations** — every abstract method
  (e.g. `keyPair`, `seedKeyPair`, `enc`, `dec`).

---

### Step 2 — Create `test/integration/cases/{feature}_test_case.dart`

The file structure mirrors every existing test case. Generate it with:

```dart
import '../test_case.dart';

class {Feature}TestCase extends TestCase {
  {Feature}TestCase(super._runner);

  @override
  String get name => '{prefix}';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.{getterName};

      // TODO: replace ??? with expected values from the libsodium documentation
      // expect(sut.{constant1}, ???, reason: '{constant1}');
      // expect(sut.{constant2}, ???, reason: '{constant2}');
      // ... one commented-out expect per constant
    });

    // One group stub per operation:
    group('{operation1}', () {
      // TODO: implement tests
    });

    group('{operation2}', () {
      // TODO: implement tests
    });

    // ... one group per operation
  }
}
```

Rules:
- `name` should be the short human-readable feature name as used in the existing
  test group names (e.g. `'kx'`, `'kdf'`).
- Add `import 'dart:typed_data';` only if the test file will need it (e.g. if
  any operation takes or returns `Uint8List`). Since all bodies are empty stubs,
  omit this import — a human will add it when implementing the tests.
- Keep the commented-out `expect` lines for constants because they communicate
  what values need to be looked up. Do not add `expect` lines for operations.
- The `group` bodies must be syntactically valid Dart (empty body `{}` with a
  `// TODO` comment is fine).

---

### Step 3 — Register in `test/integration/test_runner.dart`

Two changes:

1. **Import** — add alphabetically with the existing case imports:
   ```dart
   import 'cases/{feature}_test_case.dart';
   ```

2. **`createTestCases()`** — add alphabetically in the returned list:
   ```dart
   {Feature}TestCase(this),
   ```

---

**Phase completion**
Show: the generated test case file and the modified `test_runner.dart`. Do
**not** run the integration tests (the stubs are empty; running them would
produce trivially-passing but meaningless results).
Ask: *"The integration test scaffolding is ready. The constants stubs show
every constant that needs an expected value; the group stubs mark every
operation that needs tests. Does this structure look correct, or would you like
any adjustments?"*
Follow the standard phase-close protocol.
