# Phase 9 — Integration Tests

> **Runs in a spawned subagent.** Read `reference/conventions.md` and
> `reference/io-contract.md` first. End your turn by emitting only the return JSON.

## Inputs

- `state.json` — for `base`, `className`, `prefix`, and the getter name(s)
  registered in Phase 8.
- `packages/sodium/lib/src/api/{feature}.dart` — the Phase 2 interface.

Goal: Generate the integration test *scaffolding* — the test case class and its
registration in the test runner — with stubs for every constant and operation.
Leave the actual test bodies empty or commented out; a human will fill them in.

## Step 1 — Derive constants and operations from the API

Read `lib/src/api/{feature}.dart`. Collect two lists:

- **Constants** — every abstract getter that returns `int` or `String`
  (e.g. `publicKeyBytes`, `secretKeyBytes`, `primitive`).
- **Operations** — every abstract method
  (e.g. `keyPair`, `seedKeyPair`, `enc`, `dec`).

## Step 2 — Create `test/integration/cases/{feature}_test_case.dart`

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

## Step 3 — Register in `test/integration/test_runner.dart`

Two changes:

1. **Import** — add alphabetically with the existing case imports:
   ```dart
   import 'cases/{feature}_test_case.dart';
   ```

2. **`createTestCases()`** — add alphabetically in the returned list:
   ```dart
   {Feature}TestCase(this),
   ```

## Output

Follow the phase-close protocol in `reference/conventions.md`, but do **not**
run the integration tests (the stubs are empty; running them would produce
trivially-passing but meaningless results) — set `testResults.ran: false`.
Still run `dart format` / `dart analyze` on the generated files.

In your return JSON, list the generated test case file and the modified
`test_runner.dart` in `filesWritten`, and set:
- `reviewQuestion`: *"The integration test scaffolding is ready. The constants
  stubs show every constant that needs an expected value; the group stubs mark
  every operation that needs tests. Does this structure look correct, or would
  you like any adjustments?"*
