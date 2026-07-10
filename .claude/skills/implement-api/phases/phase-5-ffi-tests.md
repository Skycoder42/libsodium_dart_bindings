# Phase 5 — FFI Unit Tests

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- `packages/sodium/lib/src/ffi/api/{base}*_ffi.dart` — the Phase 4
  implementation (see `phaseOutputs["4"].files`).

Goal: write and pass unit tests for the FFI implementation from Phase 4. These tests
mock `LibSodiumFFI`, never touch real native memory, and run **only on the Dart VM**.

## Step 1 — Decide file structure

**One FFI class → one test file:**
`packages/sodium/test/unit/ffi/api/{base}_ffi_test.dart`

**Base class + multiple variant classes → one test file per variant:**
`packages/sodium/test/unit/ffi/api/{base}_{variant}_ffi_test.dart`

Each variant test exercises ALL methods (constants, keygen, and every operation) using
that variant's concrete class. This verifies that each variant's function pointers are
wired to the right C symbols.

## Step 2 — Write the file skeleton

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

## Step 3 — Test size constants

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

## Step 4 — Test key generation

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

## Step 5 — Test crypto operations

For each crypto operation, write a `group('{methodName}', () { ... })` with four kinds
of tests.

**Establish test-data sizes upfront** — pick sizes that match the value stubs in the
`methods` setUp, e.g. if `publickeybytes` is stubbed to `5`, use `Uint8List(5)`.

### Test 1 — Input validation (one per validated parameter)

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

### Test 2 — Correct native call arguments

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

### Test 3 — Correct return value

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

### Test 4 — Failure path

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

## Step 6 — Pointer count reference

To get the `sodium_free` counts right, refer to the Phase 4 implementation:

| Pointer type | Success path | Failure path |
|---|---|---|
| Input (`toSodiumPointer`, disposed in `finally`) | freed | freed |
| Output Uint8List (`SodiumPointer.alloc`, transferred via `asListView(owned: true)`) | **not freed** | freed |
| Output SecureKey (`SecureKeyFFI.alloc`, returned directly) | **not freed** | freed |
| Optional input that was `null` | not allocated → 0 | not allocated → 0 |

## Step 7 — Run tests

From `packages/sodium/`:
```
dart test test/unit/ffi/api/{base}_ffi_test.dart
```

Do **not** add `-p chrome` — these are VM-only.

Both success and failure tests must pass with zero failures. If a test fails, diagnose
and fix the Phase 4 FFI implementation — do not weaken the test.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON, put the VM test command/result in `testResults`, and set:
- `reviewQuestion`: *"Do the FFI tests look correct? Check especially: correct
  pointer counts in `sodium_free` assertions, correct positional indices in
  `fillPointer`, and whether any operation tests are missing. Describe any issues
  and I'll adjust before we move on."*
