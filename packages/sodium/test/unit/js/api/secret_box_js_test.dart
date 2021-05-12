import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/secret_box_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SecretBoxJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SecretBoxJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_secretbox_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretbox_MACBYTES,
      () => sut.macBytes,
      'macBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretbox_NONCEBYTES,
      () => sut.nonceBytes,
      'nonceBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_secretbox_KEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_secretbox_MACBYTES).thenReturn(5);
      when(() => mockSodium.crypto_secretbox_NONCEBYTES).thenReturn(5);
    });

    group('keygen', () {
      test('calls crypto_secretbox_keygen on generated key', () {
        when(() => mockSodium.crypto_secretbox_keygen())
            .thenReturn(Uint8List(0));

        sut.keygen();

        verify(() => mockSodium.crypto_secretbox_keygen());
      });

      test('returns generated key', () {
        final testData = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_secretbox_keygen())
            .thenReturn(Uint8List.fromList(testData));

        final res = sut.keygen();

        expect(res.extractBytes(), testData);
      });

      test('throws SodiumException on JsError', () {
        when(() => mockSodium.crypto_secretbox_keygen()).thenThrow(JsError());

        expect(() => sut.keygen(), throwsA(isA<SodiumException>()));
      });
    });

    group('easy', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_NONCEBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_KEYBYTES);
      });

      test('calls crypto_secretbox_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_easy(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = Uint8List.fromList(
          List.generate(20, (index) => index * 2),
        );
        final nonce = Uint8List.fromList(
          List.generate(5, (index) => 10 + index),
        );
        final key = Uint8List.fromList(
          List.generate(5, (index) => index),
        );

        sut.easy(
          message: message,
          nonce: nonce,
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_secretbox_easy(message, nonce, key),
        );
      });

      test('returns encrypted data', () {
        final cipher = Uint8List.fromList(
          List.generate(25, (index) => 100 - index),
        );
        when(
          () => mockSodium.crypto_secretbox_easy(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(cipher);

        final result = sut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, cipher);
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_secretbox_easy(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.easy(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('openEasy', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_MACBYTES);
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_NONCEBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_KEYBYTES);
      });

      test('calls crypto_secretbox_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_open_easy(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final cipherText = Uint8List.fromList(
          List.generate(20, (index) => index * 2),
        );
        final nonce = Uint8List.fromList(
          List.generate(5, (index) => 10 + index),
        );
        final key = List.generate(5, (index) => index);

        sut.openEasy(
          cipherText: cipherText,
          nonce: nonce,
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_secretbox_open_easy(
            cipherText,
            nonce,
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns decrypted data', () {
        final message = Uint8List.fromList(
          List.generate(8, (index) => index * 5),
        );
        when(
          () => mockSodium.crypto_secretbox_open_easy(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(message);

        final result = sut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_open_easy(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('detached', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_NONCEBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_KEYBYTES);
      });

      test('calls crypto_secretbox_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_detached(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(SecretBox(cipher: Uint8List(0), mac: Uint8List(0)));

        final message = Uint8List.fromList(
          List.generate(20, (index) => index * 2),
        );
        final nonce = Uint8List.fromList(
          List.generate(5, (index) => 10 + index),
        );
        final key = List.generate(5, (index) => index);

        sut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_secretbox_detached(
            message,
            nonce,
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns encrypted data and mac', () {
        final cipherText = Uint8List.fromList(
          List.generate(10, (index) => index),
        );
        final mac = Uint8List.fromList(
          List.generate(5, (index) => index * 3),
        );
        when(
          () => mockSodium.crypto_secretbox_detached(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(SecretBox(cipher: cipherText, mac: mac));

        final result = sut.detached(
          message: Uint8List(10),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(
          result,
          DetachedCipherResult(
            cipherText: Uint8List.fromList(cipherText),
            mac: Uint8List.fromList(mac),
          ),
        );
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_detached(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('openDetached', () {
      test('asserts if mac is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_MACBYTES);
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_NONCEBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_KEYBYTES);
      });

      test('calls crypto_secretbox_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_open_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final cipherText = Uint8List.fromList(
          List.generate(15, (index) => index * 2),
        );
        final mac = Uint8List.fromList(
          List.generate(5, (index) => 20 - index),
        );
        final nonce = Uint8List.fromList(
          List.generate(5, (index) => 10 + index),
        );
        final key = List.generate(5, (index) => index);

        sut.openDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_secretbox_open_detached(
            cipherText,
            mac,
            nonce,
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns decrypted data', () {
        final message = Uint8List.fromList(List.generate(25, (index) => index));
        when(
          () => mockSodium.crypto_secretbox_open_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(message);

        final result = sut.openDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_open_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
