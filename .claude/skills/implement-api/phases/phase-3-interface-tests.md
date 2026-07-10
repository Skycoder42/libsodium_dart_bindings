# Phase 3 — Validation Mixin Tests

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, and `selectedGroups`.
- `packages/sodium/lib/src/api/{base}.dart` — the interface and validation mixin
  from Phase 2 (see `phaseOutputs["2"].files`).

Goal: write and pass the `test/unit/api/` test file that verifies the
validation mixin created in Phase 2.

## Step 1 — Write the test file

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

## Step 2 — Run on both platforms

Run on both the Dart VM and Chrome (see `reference/conventions.md`):
```
dart test test/unit/api/{base}_test.dart
dart test -p chrome test/unit/api/{base}_test.dart
```

Both must pass with zero failures and zero errors before finishing.

If a test fails, diagnose and fix the mixin implementation (in the
`lib/src/api/{base}.dart` file) — do not weaken the test.

## Output

Follow the phase-close protocol in `reference/conventions.md`. In your return
JSON, put both test commands/results in `testResults`, and set:
- `reviewQuestion`: *"Do the validation tests look correct? If anything is
  missing or wrong, describe it and I'll adjust before we move on."*
