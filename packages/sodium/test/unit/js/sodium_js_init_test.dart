@TestOn('js')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/sodium_js_init.dart';
import 'package:test/test.dart';

import 'sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  test('init returns SodiumJS instance', () async {
    final libSodium = mockSodium.asLibSodiumJS;
    final sodium = await SodiumInit.init(() => libSodium);

    expect(
      sodium,
      isA<SodiumJS>().having((p) => p.sodium, 'sodium', libSodium),
    );
  });
}
