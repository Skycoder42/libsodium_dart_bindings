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
@protected
JSUint8Array internalDec(JSUint8Array ciphertext, JSUint8Array privateKey);
```

Write **no doc comments** in this file: `@internal` already keeps the class and
everything in it out of the generated docs, so neither the class, its members,
nor the `@protected` methods need a `/// @nodoc`. Older files in the repo still
carry them — do not copy that.

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

**Never assume the JS parameter order matches the C/FFI one — read the actual
signature.** libsodium.js reorders and drops parameters, e.g.
`crypto_xof_shake128(int out_length, JSUint8Array message)` puts the output length
*first*, whereas the FFI signature takes the output pointer and its length last. Type
the `@protected` hook after the JS signature, not the FFI one.

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

## Step 7 — Multi-part / consumer APIs

The three patterns in Step 6 describe stateless one-shot operations. Multi-part APIs
(`_init` / `_update` / `_final`, or an interface returning a `{ClassName}Consumer`)
need their own file at
`lib/src/js/api/helpers/{base}/{base}_consumer_js.dart`.

**The state is a `JSNumber`.** libsodium.js allocates the state inside its emscripten
heap and hands back the *address*, typed via a top-level alias in `sodium.js.dart`:

```dart
typedef XofShake128State = JSNumber;   // not an extension type — no static distinction
```

So the consumer is generic over `T extends JSNumber`, and the algorithm-specific
functions are injected as constructor arguments typed by `@internal` typedefs — one
per native call:

```dart
@internal
typedef {Class}InitJsFn<T extends JSNumber> = T Function();

@internal
typedef {Class}UpdateJsFn<T extends JSNumber> =
    void Function(T state, JSUint8Array messageChunk);

@internal
typedef {Class}FinalJsFn<T extends JSNumber> = JSUint8Array Function(T state);

@internal
class {Class}ConsumerJS<T extends JSNumber>
    with {Class}ConsumerValidations
    implements {Class}Consumer {
  final {Class}UpdateJsFn<T> update;
  final {Class}FinalJsFn<T> finalize;

  late final T _state;

  {Class}ConsumerJS({
    required {Class}InitJsFn<T> init,
    required this.update,
    required this.finalize,
  }) {
    _state = jsErrorWrap(() => init());
  }
}
```

Because the state alias is not an extension type, the type parameter buys no static
safety — it is documentation only. Carry it anyway for symmetry with the FFI
implementation and with `KdfHkdfExtractConsumerJS<T>`.

**If the API has several init variants** (e.g. `_init` and `_init_with_domain`),
expose one `factory` per variant that funnels into a single private constructor
which picks the right init function — do not make the caller pass a nullable
discriminator.

**The `StreamConsumer` idiom:**

```dart
@override
void add(Uint8List data) {
  _ensureNotCompleted();
  jsErrorWrap(() => update(_state, data.toJS));
}

@override
Future<void> addStream(Stream<Uint8List> stream) {
  _ensureNotCompleted();
  return stream.map(add).drain<void>();
}
```

`close()` has two shapes — pick the one the Phase 2 interface implies:
- **Completing consumer** (`close()` produces the result, e.g. a hash or a
  `SecureKey`): hold a `Completer<R>`, complete it in `close()`, and use
  `_completer.isCompleted` as the guard. Reference:
  `helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart`.
- **Non-completing consumer** (`close()` only ends the absorbing phase and the
  result is pulled separately): use plain `bool` flags instead — a Completer
  cannot model a consumer that stays usable after `close()`.

**Disposal — the important asymmetry with FFI.** libsodium.js exposes **no** free or
memzero for a `*_state_address`; the only related binding is
`memzero(JSUint8Array)`. States are freed inside the generated `*_final` call. So:
- If the API has a `_final`, the state is released when `close()` runs — nothing else
  to do.
- If the API has **no** `_final` (pull-style APIs such as xof's `squeeze`), there is
  nothing `dispose()` can release. Implement it as a flag flip that invalidates the
  consumer, so its observable behavior stays identical to the FFI version, and leave
  a `//` comment stating that the heap allocation cannot be reclaimed from Dart.
  Mention this in your `designDecisions` — it is a real platform limitation, not an
  oversight.

Mirror the FFI consumer's guard semantics and **reuse its exact `StateError`
messages** so both platforms are indistinguishable to callers and to the Phase 9
integration tests.

> Reference: `packages/sodium/lib/src/js/api/helpers/generic_hash/generic_hash_consumer_js.dart`
> (Completer-based, `_final` frees the state),
> `packages/sodium/lib/src/js/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart`
> (generic over the state, functions injected) and
> `packages/sodium/lib/src/js/api/helpers/xof/xof_consumer_js.dart`
> (flag-based, no `_final`, nothing to free).

Note that the consumer file usually needs **no** `// ignore_for_file:
unnecessary_lambdas` header — it calls no sodium member directly, and the
`unnecessary_ignore` rule flags the header as unneeded there. The same applies to
an abstract base class that only delegates to `@protected` hooks.

## Step 8 — Standard imports summary

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
  operation, any `hide` names added to the `sodium.js.dart` import, whether a
  base class was used, any place the JS parameter order differs from the FFI one,
  and — for consumer APIs — the `close()`/`dispose()` mechanics and whether the
  state can be freed at all.
- `reviewQuestion`: *"Does the JS implementation look correct? Check especially:
  correct UPPERCASE vs lowercase for constants, correct `.toDart` / `SecureKeyJS`
  usage on outputs, and correct `hide` names on the `sodium.js.dart` import.
  Describe any issues and I'll adjust before we move on."*
- No tests run in this phase (`testResults.ran: false`); format/lint only.
