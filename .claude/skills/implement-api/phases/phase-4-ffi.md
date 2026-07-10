# Phase 4 — FFI Implementation

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- `packages/sodium/lib/src/api/{base}.dart` — the Phase 2 interface.
- `packages/sodium/lib/src/ffi/bindings/libsodium.ffi.wrapper.dart` — C signatures
  for the selected groups.

Goal: create `lib/src/ffi/api/{base}_ffi.dart` — the native platform
implementation. This phase translates each Dart API method from Phase 2 into
precise C interop code using `SodiumPointer`, `SecureKeyFFI`, and the unlock
pattern.

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

## Step 2 — Write the class header

```dart
/// @nodoc
@internal
class {ClassName}FFI with {ClassName}Validations, KeygenMixin implements {ClassName} {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  {ClassName}FFI(this.sodium);
```

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

Every operation follows a five-zone pattern. Work through each C parameter from the
FFI wrapper signature and classify it before writing any code.

### Zone 0: Classify C parameters

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

### Zone 1: Validate

Call every relevant `validate*` mixin method before any allocation:

```dart
validatePublicKey(publicKey);
validateSecretKey(secretKey);
```

### Zone 2: Declare pointer variables

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

### Zone 3: Unlock and call

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

### Zone 4: Check result

Always check the return value immediately after the native call:

```dart
SodiumException.checkSucceededInt(result);
```

### Zone 5: Return and clean up

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

## Step 6 — Standard imports

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

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON:
- `designDecisions`: note which C parameters were classified as output
  `SecureKey` vs `Uint8List`, whether a base class was used, any `viewAt` /
  `Uint8List.sublistView` usage, and the nesting order of `runUnlockedNative`
  calls if more than one is present.
- `reviewQuestion`: *"Does the FFI implementation look correct? In particular,
  check: memory ownership in try/catch/finally, unlock nesting order (outputs
  outermost), correct `nullptr` for dropped parameters, and correct `.count`
  arguments. Describe any issues and I'll adjust before we move on."*
- No tests run in this phase (`testResults.ran: false`); format/lint only.
