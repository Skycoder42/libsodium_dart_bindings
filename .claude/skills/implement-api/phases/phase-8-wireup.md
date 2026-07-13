# Phase 8 — Wire-Up

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- The Phase 4 and Phase 6 implementation classes (see `phaseOutputs["4"]` and
  `phaseOutputs["6"]`).

Goal: Register the new implementations in the three `Crypto` classes, export the
new API types from `sodium.dart`, and extend the two `crypto_*_test.dart` files
with one test per new getter. Run all affected tests before finishing.

## Step 1 — Determine getter name(s)

For each implementation class generated in Phases 4 and 6 (e.g. `KemFFI` /
`KemJS`), derive:

| Piece | Rule | Example |
|-------|------|---------|
| Getter name | camelCase of feature prefix, or prefix + variant | `kem`, `aeadChaCha20Poly1305` |
| API type | Abstract class from `api/{feature}.dart` | `Kem`, `Aead` |
| FFI class | `{FeaturePascal}FFI` (or variant-specific) | `KemFFI` |
| JS class | `{FeaturePascal}JS` | `KemJS` |

If Phase 1 identified multiple variants, each variant produces its own getter.

## Step 2 — `lib/src/api/crypto.dart`

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

## Step 3 — `lib/src/ffi/api/crypto_ffi.dart`

1. Add API import: `import '../../api/{feature}.dart';` (alphabetical).
2. Add implementation import: `import '{feature}_ffi.dart';` (alphabetical).
3. Add one `@override late final` property per variant:

```dart
@override
late final {ApiType} {getterName} = {ImplClassFFI}(sodium);
```

## Step 4 — `lib/src/js/api/crypto_js.dart`

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

## Step 5 — `lib/sodium.dart`

Add an export for the new API file. Follow the existing `hide {Foo}Validations`
pattern:

```dart
export 'src/api/{feature}.dart' hide {Feature}Validations;
```

If the API file defines no validation mixin, omit the `hide` clause. Insert the
line in alphabetical order with the existing exports.

## Step 6 — `test/unit/ffi/api/crypto_ffi_test.dart`

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

## Step 7 — `test/unit/js/api/crypto_js_test.dart`

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

## Step 8 — Run tests

Run both crypto wire-up test files (plus re-run the individual unit tests for
the new feature to catch any regressions). See `reference/conventions.md` →
"Running unit tests"; the VM and Chrome invocations differ:

- **VM** — from `packages/sodium/`:
  ```
  NIX_SKIP_SODIUM_BUILD_HOOKS=1 dart test test/unit/ffi/api/crypto_ffi_test.dart
  ```
- **Chrome** — from the repo root, run the wrapper with the test path as an
  argument (plain standalone command — no prefix, no pipe, no chaining; see the
  Chrome-wrapper rules in `reference/conventions.md`):
  ```
  bash packages/sodium/tool/chrome_test.sh test/unit/js/api/crypto_js_test.dart
  ```

Fix any failures before finishing.

## Step 9 — Update README

In the README.md under `### API Status`, add a new row to the table for the new
feature, with "✔️" in the "VM" and "JS" columns. The "Sumo" column must be
filled only when the feature was added to `CryptoSumo` instead of `Crypto`. The
Documentation should reference the same documentation as the generated API
interface.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON, list every modified file in `filesWritten`, put both test results in
`testResults`, and set:
- `reviewQuestion`: *"Does this look correct? If anything needs to be changed,
  describe it and I will adjust before we move on."*
