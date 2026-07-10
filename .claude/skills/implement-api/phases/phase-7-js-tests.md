# Phase 7 — JS Unit Tests

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and `selectedGroups`.
- `packages/sodium/lib/src/js/api/{base}*_js.dart` — the Phase 6 implementation
  (see `phaseOutputs["6"].files`).

Goal: write and pass unit tests for the JS implementation from Phase 6. These tests use
the `MockLibSodiumJS` JS-interop mock and run **only on the JS platform**.

## Step 1 — Decide file structure

Same rule as Phase 5:

**One JS class → one test file:**
`packages/sodium/test/unit/js/api/{base}_js_test.dart`

**Base class + multiple variant classes → one test file per variant:**
`packages/sodium/test/unit/js/api/{base}_{variant}_js_test.dart`

Each variant test exercises ALL methods using that variant's concrete class.

## Step 2 — Write the file skeleton

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

## Step 3 — Test size constants

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

## Step 4 — Test key generation

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

## Step 5 — Test crypto operations

For each crypto operation, write a `group('{methodName}', () { ... })` with four tests.

**Determine the mock return type** by looking at the JS binding signature in
`sodium.js.dart`:

| JS return type | Mock `thenReturn` value | Assertion pattern |
|---|---|---|
| `JSUint8Array` (Uint8List result) | `Uint8List.fromList(data).toJS` | `expect(result, data)` |
| `JSUint8Array` (SecureKey result) | `Uint8List.fromList(data).toJS` | `expect(result.extractBytes(), data)` or `expect(result, SecureKeyFake(data))` |
| Extension type (e.g. `KemEncResult`) | `ExtType(field: data.toJS, ...)` | `expect(result.field, data)` / `expect(result.secureField, SecureKeyFake(data))` |
| `KeyPair` | `KeyPair(keyType: '', publicKey: ...)` | handled by `testKeypair` helper |

### Test 1 — Input validation (one per validated parameter)

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

### Test 2 — Correct native call arguments

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

### Test 3 — Correct return value

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

### Test 4 — Failure path

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

## Step 6 — For base class + variants

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

## Step 7 — Run tests

From `packages/sodium/`:
```
dart test -p chrome test/unit/js/api/{base}_js_test.dart
```

Do **not** run on the VM (`dart test` without `-p chrome`) — these are JS-only.

Both success and failure tests must pass with zero failures. If a test fails, fix the
Phase 6 JS implementation — do not weaken the test.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON, put the Chrome test command/result in `testResults`, and set:
- `reviewQuestion`: *"Do the JS tests look correct? Check especially: UPPERCASE
  constant names in `testConstantsMapping`, correct `.toJS` conversion on
  arguments in `verify`, correct extension type construction in mock `thenReturn`
  calls, and correct assertion pattern for each output type. Describe any issues
  and I'll adjust before we move on."*
