# Phase 4 — FFI Implementation

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- `packages/sodium/lib/src/api/{base}.dart` — the Phase 2 interface.
- `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart` — C signatures
  for the selected groups.
- `packages/sodium/lib/src/ffi/bindings/sodium_scope.dart` — the allocation scope
  every operation is built on. **Read its doc comments before writing code.**

Goal: create `lib/src/ffi/api/{base}_ffi.dart` — the native platform
implementation. This phase translates each Dart API method from Phase 2 into
precise C interop code using `sodiumScope`, `SodiumPointer`, `SecureKeyFFI` and
the unlock pattern.

## Step 1 — Decide class structure

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
@protected
int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk) get internalKeyPair;

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

Repeating a long signature in every subclass is noisy — hoist it into an `@internal`
`typedef` in the base file and use that in both places.

> Reference: `packages/sodium/lib/src/ffi/api/aead_base_ffi.dart` and
> `packages/sodium/lib/src/ffi/api/aead_chacha20poly1305_ffi.dart` show this exact pattern.

**If the variants take a typed state struct** (the wrapper shows
`Pointer<crypto_{prefix}_{variant}_state>` rather than `Pointer<UnsignedChar>`), the
function types differ per variant and a plain base class cannot express them. Make the
base class generic over the struct instead:

```dart
@internal
typedef {ClassName}InitFn<T extends NativeType> = int Function(Pointer<T> state);

@internal
abstract class {ClassName}BaseFFI<T extends NativeType>
    with {ClassName}Validations
    implements {ClassName} {
  @protected
  {ClassName}InitFn<T> get internalInit;
}
```

and pin the type parameter in each subclass, importing the struct from the raw bindings:

```dart
import '../bindings/libsodium.ffi.dart' show crypto_{prefix}_{variant}_state;

class {ClassName}{Variant}FFI
    extends {ClassName}BaseFFI<crypto_{prefix}_{variant}_state> {
  @override
  {ClassName}InitFn<crypto_{prefix}_{variant}_state> get internalInit =>
      sodium.crypto_{prefix}_{variant}_init;
}
```

> Reference: `packages/sodium/lib/src/ffi/api/kdf_hkdf_base_ffi.dart` and
> `packages/sodium/lib/src/ffi/api/kdf_hkdf_sha256_ffi.dart`.

## Step 2 — Write the class header

```dart
@internal
class {ClassName}FFI with {ClassName}Validations, KeygenMixin implements {ClassName} {
  final LibSodiumFFI sodium;

  {ClassName}FFI(this.sodium);
```

Write **no doc comments** in this file: `@internal` already keeps the class and
everything in it out of the generated docs, so neither the class, its members,
nor the `@protected` getters need a `/// @nodoc`. Older files in the repo still
carry them — do not copy that.

## Step 3 — Implement size constants

FFI size constants call C functions — lowercase names with parentheses:

```dart
@override
int get publicKeyBytes => sodium.crypto_{prefix}_publickeybytes();

@override
String get primitive => sodium.crypto_{prefix}_primitive();
```

## Step 4 — Implement key generation methods

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

## Step 5 — Implement crypto operations

Every operation body is wrapped in a **`sodiumScope`**. The scope owns every allocation
made through it and frees them all, in reverse order, when the body returns **or**
throws — so operations contain no `try`/`catch`/`finally` and no `dispose()` calls of
their own. Results leave the scope through the `take*` methods, which transfer ownership
out and stop the scope from freeing them.

`SodiumScope` is **not** a `package:ffi` `Arena`: every allocation still goes through
`SodiumPointer`/`SecureKeyFFI` and therefore uses libsodium's guarded, secure memory
(`sodium_malloc`, `mlock`, `mprotect`, zero-on-free) — never `malloc`/`calloc`.

> Reference: `packages/sodium/lib/src/ffi/bindings/sodium_scope.dart` defines the scope;
> `packages/sodium/lib/src/ffi/api/kx_ffi.dart`,
> `packages/sodium/lib/src/ffi/api/secret_box_ffi.dart`,
> `packages/sodium/lib/src/ffi/api/aead_base_ffi.dart` and
> `packages/sodium/lib/src/ffi/api/ipcrypt_nd_base_ffi.dart` are the current
> implementations to copy from.

Work through each C parameter from the FFI wrapper signature and classify it before
writing any code.

### Zone 0: Classify C parameters

| C param role | How to recognise it | FFI handling |
|---|---|---|
| **Input `Uint8List`** | `Pointer<UnsignedChar>` — `m`, `c` (input), `pk` (input), `ct` (input), `ad`, `npub`, `nonce` | `scope.copyList<UnsignedChar>(data)` — defaults to `MemoryProtection.readOnly` |
| **Input `String`** | `Pointer<Char>` — `ctx`, `passwd`, `str` | `scope.copyString(str)`; pass `memoryWidth:` for a fixed-size buffer such as a kdf context |
| **Output `Uint8List`** | `Pointer<UnsignedChar>` — `c` (output), `ct` (output), `hash`, `mac` | `scope.alloc<UnsignedChar>(n)`, returned via `scope.takeBytes<Uint8List>(ptr)` |
| **Output `SecureKey`** | `Pointer<UnsignedChar>` — `ss` (shared secret), `k` (output key) | `scope.allocSecureKey(n)`, unlocked writably, returned via `scope.takeSecureKey(key)` |
| **Output `String`** | `Pointer<Char>` — encoded hash strings | `scope.alloc<Char>(n)`, returned via `scope.takeString(ptr)` |
| **Input `SecureKey`** | `Pointer<UnsignedChar>` — `sk` (input), `k` (input) | No allocation — unlock via `key.runUnlockedNative(sodium, ...)` extension |
| **Long-lived state pointer** | `Pointer<..._state>` kept across calls | `scope.takePointer(ptr)`, or allocate it outside any scope — see Step 6 |
| **Length input** | `int mlen`, `int clen`, `int adlen` | Pass `.count` of the corresponding pointer |
| **Length output ptr** | `Pointer<UnsignedLongLong>` / `Pointer<LongLong>` | Pass `nullptr` |
| **Always-null** | `Pointer<UnsignedChar> nsec` | Pass `nullptr` |
| **Optional input** | `Pointer<UnsignedChar> ad` with nullable Dart param | `additionalData != null ? scope.copyList<UnsignedChar>(additionalData) : null`, then pass `adPtr?.ptr ?? nullptr` and `adPtr?.count ?? 0` |

### Zone 1: Validate

Call every relevant `validate*` mixin method **before** opening the scope, so a bad
argument never allocates anything:

```dart
validatePublicKey(publicKey);
validateSecretKey(secretKey);
```

### Zone 2: Open the scope and allocate

Allocate everything through the scope, in one flat block — no nullable pre-declarations,
no `try` block. If any allocation throws part-way, the scope frees the ones that already
succeeded.

```dart
return sodiumScope(sodium, (scope) {
  final ctPtr = scope.alloc<UnsignedChar>(ciphertextBytes);
  final ssKey = scope.allocSecureKey(sharedSecretBytes);
  final pkPtr = scope.copyList<UnsignedChar>(publicKey);
```

`scope.alloc` defaults to `MemoryProtection.readWrite`; pass `zeroMemory: true` to zero
the buffer instead of filling it with the `0xdb` guard byte. `scope.copyList` and
`scope.copyString` default to `MemoryProtection.readOnly` — pass
`memoryProtection: .readWrite` when the C function writes back into an input buffer
(the in-place `open`/`decrypt` case).

### Zone 3: Unlock and call

Choose the unlock strategy based on which SecureKey roles are present.

**No SecureKey inputs or outputs:**
```dart
final result = sodium.crypto_{prefix}_{op}(outPtr.ptr, inPtr.ptr, inPtr.count);
```

**One SecureKey input only:**
```dart
final result = key.runUnlockedNative(
  sodium,
  (keyPtr) => sodium.crypto_{prefix}_{op}(outPtr.ptr, inPtr.ptr, inPtr.count, keyPtr.ptr),
);
```
> Use the extension method `key.runUnlockedNative(sodium, callback)` — it accepts any
> `SecureKey`, including non-FFI instances. For a nullable input key use
> `key.runMaybeUnlockedNative(sodium, (keyPtr) => … keyPtr?.ptr ?? nullptr …)`.

**One SecureKey output only** (e.g. writing the shared secret):
```dart
final result = ssKey.runUnlockedNative(
  (ssPtr) => sodium.crypto_{prefix}_{op}(ssPtr.ptr, ctPtr.ptr, pkPtr.ptr),
  writable: true,
);
```
> Call the direct method on the `SecureKeyFFI` returned by `scope.allocSecureKey` (not
> the extension), since this is a freshly allocated key being written to. Always pass
> `writable: true`.

**SecureKey input + SecureKey output (nested unlock):**
```dart
final result = ssKey.runUnlockedNative(
  (ssPtr) => secretKey.runUnlockedNative(
    sodium,
    (skPtr) => sodium.crypto_{prefix}_{op}(ssPtr.ptr, ctPtr.ptr, skPtr.ptr),
  ),
  writable: true,
);
```
> The outermost unlock is always the output key (`writable: true`).
> The inner unlock is the input key (read-only, extension method).

**Multiple SecureKey outputs (e.g. two session keys):**
```dart
final result = rxKey.runUnlockedNative(
  (rxKeyPtr) => txKey.runUnlockedNative(
    (txKeyPtr) => clientSecretKey.runUnlockedNative(
      sodium,
      (clientSecretKeyPtr) => sodium.crypto_{prefix}_{op}(
        rxKeyPtr.ptr, txKeyPtr.ptr,
        clientPublicKeyPtr.ptr, clientSecretKeyPtr.ptr, serverPublicKeyPtr.ptr,
      ),
    ),
    writable: true,
  ),
  writable: true,
);
```
> Reference: `packages/sodium/lib/src/ffi/api/kx_ffi.dart`.

### Zone 4: Check result

Always check the return value immediately after the native call:

```dart
SodiumException.checkSucceededInt(result);
```

### Zone 5: Hand results out of the scope

Every value that outlives the operation must leave through a `take*` method — that is
what stops the scope from freeing it. Anything **not** taken is freed automatically,
which is exactly what should happen to inputs and to outputs on the error path (the body
never reaches its `take*` calls when the native call throws).

```dart
  return (
    ciphertext: scope.takeBytes<Uint8List>(ctPtr),
    sharedSecret: scope.takeSecureKey(ssKey),
  );
});
```

| Method | Use for | Effect |
|---|---|---|
| `scope.takeBytes<Uint8List>(ptr)` | byte outputs | hands the memory to the returned list's finalizer |
| `scope.takeSecureKey(key)` | `SecureKey` outputs | returns the key live; the **caller** must dispose it |
| `scope.takeString(ptr)` | encoded-string outputs | copies to a Dart `String` and frees the buffer at once |
| `scope.takePointer(ptr)` | pointers that become long-lived state | returns the pointer as-is, keeping its finalizer and protection |

Each `take*` must be given the exact instance that `alloc*`/`copy*` returned — passing a
`viewAt()` view of it is a programming error and is asserted against.

**Stripping a prefix or MAC from an output buffer** — take the bytes, then view them:
```dart
return Uint8List.sublistView(
  scope.takeBytes<Uint8List>(dataPtr),
  macBytes,                     // e.g. skip the MAC prefix for openEasy
);
```
```dart
final messageLength = dataPtr.count - aBytes;
return Uint8List.sublistView(scope.takeBytes<Uint8List>(dataPtr), 0, messageLength);
```

**In-place operations where input and output share one buffer** — use `viewAt`:
```dart
final dataPtr = scope.alloc<UnsignedChar>(message.length + macBytes)
  ..fill(List<int>.filled(macBytes, 0))   // MAC prefix placeholder
  ..fill(message, offset: macBytes);      // message after the prefix

sodium.crypto_{prefix}_{op}(
  dataPtr.ptr,                   // output: full buffer (MAC + ciphertext)
  dataPtr.viewAt(macBytes).ptr,  // input: message sub-region at offset macBytes
  message.length,
  ...
)
```
> Reference: `packages/sodium/lib/src/ffi/api/secret_box_ffi.dart` (`easy` / `openEasy`).

## Step 6 — Multi-part / consumer APIs

Multi-part APIs (`_init` / `_update` / `_final`, or an interface returning a
`{ClassName}Consumer`) own a state buffer that must survive **between** calls, so it
cannot live in a `sodiumScope`. Put the consumer in
`lib/src/ffi/api/helpers/{base}/{base}_consumer_ffi.dart` and follow this shape:

- **Allocate the state in the constructor, outside any scope**, then init it. Use
  `SodiumPointer<UnsignedChar>.alloc(sodium, count: stateBytes, zeroMemory: true)` and
  pass it to C as `_state.ptr.cast()`. Wrap the init call in a `try`/`catch` that
  disposes the state and rethrows — this is the one place manual disposal remains,
  because there is no scope to fall back on.
- **Keep the state at `MemoryProtection.noAccess` between calls.** Set
  `_state.memoryProtection = .noAccess;` right after a successful init, then flip it to
  `.readWrite` for the duration of each `update`/`final` call and back in a `finally`.
- **Use a scope for the transient buffers inside each method** — the message copy in
  `add`, the output buffer in `close`/`squeeze`.
- **Free the state exactly once**, when the consumer completes or is disposed.

```dart
@override
void add(Uint8List data) {
  _ensureNotCompleted();

  sodiumScope(sodium, (scope) {
    final messagePtr = scope.copyList<UnsignedChar>(data);

    _state.memoryProtection = .readWrite;
    try {
      final result = sodium.crypto_{prefix}_update(
        _state.ptr.cast(),
        messagePtr.ptr,
        messagePtr.count,
      );
      SodiumException.checkSucceededInt(result);
    } finally {
      _state.memoryProtection = .noAccess;
    }
  });
}
```

If the state is a typed struct and the class is generic over it (Step 1), pass the
`init`/`update`/`final` functions into the consumer as constructor arguments typed by
the shared `typedef`s.

> Reference: `packages/sodium/lib/src/ffi/api/helpers/generic_hash/generic_hash_consumer_ffi.dart`
> (plain state), `packages/sodium/lib/src/ffi/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_ffi.dart`
> (generic over the state struct, functions injected) and
> `packages/sodium/lib/src/ffi/api/helpers/sign/sign_consumer_ffi_mixin.dart`.

## Step 7 — Standard imports

```dart
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/{base}.dart';
import '../../api/key_pair.dart';         // if KeyPair is used
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';  // for runUnlockedNative extension
import '../bindings/sodium_scope.dart';
import 'helpers/keygen_mixin.dart';
```

Add `../bindings/sodium_pointer.dart` only when a `SodiumPointer` is named explicitly
(a consumer's state field, or a `takePointer` result) — scope-allocated pointers do not
need it. Add `../../api/{result_type}.dart` for any `freezed` result type from Phase 2.
`../bindings/memory_protection.dart` is not needed when the enum is written with the
inferred-type shorthand `.readWrite` / `.noAccess`. Omit imports that are not used.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON:
- `designDecisions`: note which C parameters were classified as output
  `SecureKey` vs `Uint8List`, whether a base class was used (and whether it had to
  be generic over a state struct), any `viewAt` / `Uint8List.sublistView` usage, the
  nesting order of `runUnlockedNative` calls if more than one is present, and any
  allocation that deliberately lives outside a `sodiumScope`.
- `reviewQuestion`: *"Does the FFI implementation look correct? In particular,
  check: every allocation goes through the `sodiumScope` and every returned value
  leaves it via a `take*` call, unlock nesting order (output keys outermost, with
  `writable: true`), correct `nullptr` for dropped parameters, and correct `.count`
  arguments. Describe any issues and I'll adjust before we move on."*
- No tests run in this phase (`testResults.ran: false`); format/lint only.
