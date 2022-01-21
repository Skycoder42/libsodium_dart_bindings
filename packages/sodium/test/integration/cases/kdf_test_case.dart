// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';
import '../test_runner.dart';

class KdfTestCase extends TestCase {
  KdfTestCase(TestRunner runner) : super(runner);

  @override
  String get name => 'kdf';

  Kdf get sut => sodium.crypto.kdf;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytesMin, 16, reason: 'bytesMin');
      expect(sut.bytesMax, 64, reason: 'bytesMax');
      expect(sut.contextBytes, 8, reason: 'contextBytes');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
    });

    test('keygen generates different correct length keys', () {
      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(sut.keyBytes));
      expect(key2, hasLength(sut.keyBytes));

      expect(key1, isNot(key2));
    });

    group('deriveFromKey', () {
      test('same masterkey produces valid subkeys', () {
        final masterKey = sut.keygen();

        printOnFailure('masterKey: ${masterKey.extractBytes()}');

        const context1 = '__test__';
        const context2 = 'testmore';

        final key1 = sut.deriveFromKey(
          masterKey: masterKey,
          context: context1,
          subkeyId: 1,
          subkeyLen: 42,
        );
        final key2 = sut.deriveFromKey(
          masterKey: masterKey,
          context: context1,
          subkeyId: 2,
          subkeyLen: 42,
        );
        final key3 = sut.deriveFromKey(
          masterKey: masterKey,
          context: context2,
          subkeyId: 1,
          subkeyLen: 42,
        );
        final key4 = sut.deriveFromKey(
          masterKey: masterKey,
          context: context2,
          subkeyId: 1,
          subkeyLen: 42,
        );

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');
        printOnFailure('key3: ${key3.extractBytes()}');
        printOnFailure('key4: ${key4.extractBytes()}');

        expect(key1, hasLength(42));
        expect(key2, hasLength(42));
        expect(key3, hasLength(42));
        expect(key4, hasLength(42));

        expect(key1, isNot(key2));
        expect(key1, isNot(key3));
        expect(key1, isNot(key4));
        expect(key2, isNot(key3));
        expect(key2, isNot(key4));
        expect(key3, key4);
      });

      test('generates keys of correct lengts', () {
        final masterKey = sut.keygen();

        printOnFailure('masterKey: ${masterKey.extractBytes()}');

        for (var i = sut.bytesMin; i <= sut.bytesMax; ++i) {
          final subKey = sut.deriveFromKey(
            masterKey: masterKey,
            context: 'test_len',
            subkeyId: i - sut.bytesMin,
            subkeyLen: i,
          );

          printOnFailure('subKey${i - sut.bytesMin}: ${subKey.extractBytes()}');

          expect(subKey, hasLength(i));
        }
      });

      test('different masterkeys generate different subkeys', () {
        final masterKey1 = sut.keygen();
        final masterKey2 = sut.keygen();

        printOnFailure('masterKey1: ${masterKey1.extractBytes()}');
        printOnFailure('masterKey2: ${masterKey2.extractBytes()}');

        final subKey1 = sut.deriveFromKey(
          masterKey: masterKey1,
          context: 'master',
          subkeyId: 42,
          subkeyLen: sut.bytesMax,
        );
        final subKey2 = sut.deriveFromKey(
          masterKey: masterKey2,
          context: 'master',
          subkeyId: 42,
          subkeyLen: sut.bytesMax,
        );

        printOnFailure('subKey1: ${subKey1.extractBytes()}');
        printOnFailure('subKey2: ${subKey2.extractBytes()}');

        expect(subKey1, isNot(subKey2));
      });
    });
  }
}
