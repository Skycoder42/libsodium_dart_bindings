# Phase 6 — JS Implementation

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- `packages/sodium/lib/src/ffi/api/{base}*_ffi.dart` — the Phase 4 implementation
  (structural reference).
- `packages/sodium/lib/src/js/bindings/sodium.js.dart` — return types, UPPERCASE
  constants, method signatures for the selected groups.

Goal: create `lib/src/js/api/{base}_js.dart` — the web/JS platform implementation.
This is significantly simpler than the FFI implementation: there is no manual memory
management, no pointer arithmetic, and no unlock nesting for outputs. The JS library
handles allocation internally.

## Step 1 — Decide class structure

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

## Step 2 — Write the file header

```dart
// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/{base}.dart';
import '../../api/key_pair.dart';          // if KeyPair is returned
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;  // see Step 3
import 'secure_key_js.dart';
```

Add `../../api/{result_type}.dart` for any `freezed` result type from Phase 2.
The `// ignore_for_file` comment is required on every file that calls sodium functions
directly — without it the analyser flags the lambdas used to defer member access.

## Step 3 — Resolve `hide` conflicts

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

## Step 4 — Implement size constants

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

## Step 5 — Implement key generation

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

## Step 6 — Implement crypto operations

There are three output patterns. For each operation, read the JS binding's **return
type** from `sodium.js.dart` to decide which pattern applies.

### Pattern A — Single `JSUint8Array` output → `Uint8List`

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

### Pattern B — Single `JSUint8Array` output → `SecureKey`

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

### Pattern C — Extension type output (multi-field result)

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

## Step 7 — Standard imports summary

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

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON:
- `designDecisions`: note which output pattern (A/B/C) was used for each
  operation, any `hide` names added to the `sodium.js.dart` import, and whether a
  base class was used.
- `reviewQuestion`: *"Does the JS implementation look correct? Check especially:
  correct UPPERCASE vs lowercase for constants, correct `.toDart` / `SecureKeyJS`
  usage on outputs, and correct `hide` names on the `sodium.js.dart` import.
  Describe any issues and I'll adjust before we move on."*
- No tests run in this phase (`testResults.ran: false`); format/lint only.
