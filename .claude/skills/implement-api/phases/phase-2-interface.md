# Phase 2 — Abstract API Interface

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `prefix`, `base`, `className`, and `selectedGroups`.
- `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart` — C signatures
  for the selected groups.

Goal: create (or extend) the Dart abstract interface and validation mixin in
`packages/sodium/lib/src/api/`.

## Step 1 — Derive naming

From the prefix (e.g. `crypto_kem`):

1. Strip the leading `crypto_` → base name (e.g. `kem`)
2. The base name in **snake_case** is the file name: `{base}.dart`
   (e.g. `crypto_secret_stream` → `secret_stream.dart`)
3. The base name in **PascalCase** is the Dart class name: `{Base}`
   (e.g. `secret_stream` → `SecretStream`)

The file lives at `packages/sodium/lib/src/api/{base}.dart`.

**Check first:** if this file already exists, read it. If the interface it
contains already covers all operations in the selected groups, this phase is
a no-op — report that in your return JSON (`status: completed`, empty
`filesWritten`) and set the `reviewQuestion` to confirm skipping. If the file
exists but is missing some operations, extend it rather than recreating it.

## Step 2 — Map FFI signatures to a Dart API shape

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

## Step 3 — Write the file

Structure the file in this order:

1. Dart imports (`dart:typed_data`, `package:meta/meta.dart`, relative imports
   for `key_pair.dart`, `secure_key.dart`, `helpers/validations.dart`, etc.)
2. `part` directive if any `freezed` class is needed
3. Any `typedef` record aliases or `freezed` sealed class definitions
4. Validate documentation links. They are not identical for every API. Scan the
   documentation website to find the correct page(s)
5. The interface:

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

## Step 4 — Generate `freezed` code (conditional)

If the file written in Step 3 includes a `part '{base}.freezed.dart';`
directive, the generated `.freezed.dart` file is needed for all subsequent
phases to compile. Follow the build_runner note in `reference/conventions.md`:
do not invoke it; wait for the background runner to regenerate the output and
verify the `.freezed.dart` file exists before finishing.

If no `part` directive was emitted, skip this step.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON:
- `filesWritten`: the interface file (and any generated `.freezed.dart`).
- `designDecisions`: note any non-obvious choices (e.g. why a parameter is
  `SecureKey` vs `Uint8List`, why a `freezed` class was chosen over a record
  typedef).
- `reviewQuestion`: *"Does this interface look correct? If anything needs to
  change — method signatures, naming, result types, missing or extra members,
  validation rules — describe it and I'll adjust before we move on."*
- No tests run in this phase (`testResults.ran: false`).
