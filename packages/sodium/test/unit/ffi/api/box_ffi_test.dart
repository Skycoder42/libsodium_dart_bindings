import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/box_ffi.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();
  late BoxFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);
    sut = BoxFFI(mockSodium);
  });

  group('BoxFFI', () {
    testConstantsMapping([
      Tuple3(
        () => mockSodium.crypto_box_publickeybytes(),
        () => sut.publicKeyBytes,
        'publicKeyBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_box_secretkeybytes(),
        () => sut.secretKeyBytes,
        'secretKeyBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_box_macbytes(),
        () => sut.macBytes,
        'macBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_box_noncebytes(),
        () => sut.nonceBytes,
        'nonceBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_box_seedbytes(),
        () => sut.seedBytes,
        'seedBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_box_sealbytes(),
        () => sut.sealBytes,
        'sealBytes',
      ),
    ]);

    group('methods', () {
      setUp(() {
        when(() => mockSodium.crypto_box_publickeybytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_secretkeybytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_macbytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_noncebytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_seedbytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_sealbytes()).thenReturn(5);
        when(() => mockSodium.crypto_box_beforenmbytes()).thenReturn(15);
      });

      testKeypair(
        mockSodium: mockSodium,
        runKeypair: () => sut.keyPair(),
        secretKeyBytesNative: mockSodium.crypto_box_secretkeybytes,
        publicKeyBytesNative: mockSodium.crypto_box_publickeybytes,
        keypairNative: mockSodium.crypto_box_keypair,
      );

      testSeedKeypair(
        mockSodium: mockSodium,
        runSeedKeypair: (SecureKey seed) => sut.seedKeyPair(seed),
        seedBytesNative: mockSodium.crypto_box_seedbytes,
        secretKeyBytesNative: mockSodium.crypto_box_secretkeybytes,
        publicKeyBytesNative: mockSodium.crypto_box_publickeybytes,
        seedKeypairNative: mockSodium.crypto_box_seed_keypair,
      );

      group('easy', () {
        test('asserts if nonce is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(10),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_noncebytes());
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_box_easy with correct arguments', () {
          when(
            () => mockSodium.crypto_box_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final message = List.generate(20, (index) => index * 2);
          final nonce = List.generate(5, (index) => 10 + index);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);
          final mac = List.filled(5, 0);

          sut.easy(
            message: Uint8List.fromList(message),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(nonce)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_easy(
                  any(that: hasRawData<Uint8>(mac + message)),
                  any(that: hasRawData<Uint8>(message)),
                  message.length,
                  any(that: hasRawData<Uint8>(nonce)),
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
          ]);
        });

        test('returns encrypted data', () {
          final cipher = List.generate(25, (index) => 100 - index);
          when(
            () => mockSodium.crypto_box_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer<Uint8>, cipher);
            return 0;
          });

          final result = sut.easy(
            message: Uint8List(20),
            nonce: Uint8List(5),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(result, cipher);

          verify(() => mockSodium.sodium_free(any())).called(4);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.easy(
              message: Uint8List(10),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(4);
        });
      });

      group('openEasy', () {
        test('asserts if cipherText is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(3),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_macbytes());
        });

        test('asserts if nonce is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(20),
              nonce: Uint8List(10),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_noncebytes());
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_box_open_easy with correct arguments', () {
          when(
            () => mockSodium.crypto_box_open_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final cipherText = List.generate(20, (index) => index * 2);
          final nonce = List.generate(5, (index) => 10 + index);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.openEasy(
            cipherText: Uint8List.fromList(cipherText),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(nonce)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_open_easy(
                  any(that: hasRawData<Uint8>(cipherText.sublist(5))),
                  any(that: hasRawData<Uint8>(cipherText)),
                  cipherText.length,
                  any(that: hasRawData<Uint8>(nonce)),
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
          ]);
        });

        test('returns decrypted data', () {
          final message = List.generate(8, (index) => index * 5);
          when(
            () => mockSodium.crypto_box_open_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer<Uint8>, message);
            return 0;
          });

          final result = sut.openEasy(
            cipherText: Uint8List(13),
            nonce: Uint8List(5),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(result, message);

          verify(() => mockSodium.sodium_free(any())).called(4);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_open_easy(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.openEasy(
              cipherText: Uint8List(10),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(4);
        });
      });

      group('detached', () {
        test('asserts if nonce is invalid', () {
          expect(
            () => sut.detached(
              message: Uint8List(20),
              nonce: Uint8List(10),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_noncebytes());
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.detached(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.detached(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_box_detached with correct arguments', () {
          when(
            () => mockSodium.crypto_box_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final message = List.generate(20, (index) => index * 2);
          final nonce = List.generate(5, (index) => 10 + index);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.detached(
            message: Uint8List.fromList(message),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(nonce)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_detached(
                  any(that: hasRawData<Uint8>(message)),
                  any(that: isNot(nullptr)),
                  any(that: hasRawData<Uint8>(message)),
                  message.length,
                  any(that: hasRawData<Uint8>(nonce)),
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
          ]);
        });

        test('returns encrypted data and mac', () {
          final cipherText = List.generate(10, (index) => index);
          final mac = List.generate(5, (index) => index * 3);
          when(
            () => mockSodium.crypto_box_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments[0] as Pointer<Uint8>, cipherText);
            fillPointer(i.positionalArguments[1] as Pointer<Uint8>, mac);
            return 0;
          });

          final result = sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(
            result,
            DetachedCipherResult(
              cipherText: Uint8List.fromList(cipherText),
              mac: Uint8List.fromList(mac),
            ),
          );

          verify(() => mockSodium.sodium_free(any())).called(5);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.detached(
              message: Uint8List(10),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(5);
        });
      });

      group('openDetached', () {
        test('asserts if mac is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(10),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_macbytes());
        });

        test('asserts if nonce is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(10),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_noncebytes());
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_secretbox_open_detached with correct arguments', () {
          when(
            () => mockSodium.crypto_box_open_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final cipherText = List.generate(15, (index) => index * 2);
          final mac = List.generate(5, (index) => 20 - index);
          final nonce = List.generate(5, (index) => 10 + index);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.openDetached(
            cipherText: Uint8List.fromList(cipherText),
            mac: Uint8List.fromList(mac),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(mac)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(nonce)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_open_detached(
                  any(that: hasRawData<Uint8>(cipherText)),
                  any(that: hasRawData<Uint8>(cipherText)),
                  any(that: hasRawData<Uint8>(mac)),
                  cipherText.length,
                  any(that: hasRawData<Uint8>(nonce)),
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
          ]);
        });

        test('returns decrypted data', () {
          final message = List.generate(25, (index) => index);
          when(
            () => mockSodium.crypto_box_open_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer<Uint8>, message);
            return 0;
          });

          final result = sut.openDetached(
            cipherText: Uint8List(25),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(result, message);

          verify(() => mockSodium.sodium_free(any())).called(5);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_open_detached(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(5);
        });
      });

      group('precalculate', () {
        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.precalculate(
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.precalculate(
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_box_beforenm with correct arguments', () {
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.precalculate(
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readwrite(
                  any(that: isNot(nullptr)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_beforenm(
                  any(that: isNot(nullptr)),
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
            () => mockSodium.sodium_mprotect_noaccess(
                  any(that: isNot(nullptr)),
                ),
          ]);
        });

        test('returns precompiled box with shared key', () {
          final sharedKey = List.generate(15, (index) => 44 - index);
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer, sharedKey);
            return 0;
          });

          final result = sut.precalculate(
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(
            result,
            isA<PrecalculatedBoxFFI>()
                .having(
                  (b) => b.box,
                  'box',
                  sut,
                )
                .having(
                  (b) => b.sharedKey.extractBytes(),
                  'sharedKey',
                  Uint8List.fromList(sharedKey),
                ),
          );

          verify(() => mockSodium.sodium_free(any())).called(2);
        });

        test('throws error if crypto_box_beforenm fails', () {
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.precalculate(
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(3);
        });
      });

      group('seal', () {
        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.seal(
              message: Uint8List(20),
              publicKey: Uint8List(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('calls crypto_box_seal with correct arguments', () {
          when(
            () => mockSodium.crypto_box_seal(
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final message = List.generate(20, (index) => index * 2);
          final publicKey = List.generate(5, (index) => 20 + index);
          final seal = List.filled(5, 0);

          sut.seal(
            message: Uint8List.fromList(message),
            publicKey: Uint8List.fromList(publicKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.crypto_box_seal(
                  any(that: hasRawData<Uint8>(seal + message)),
                  any(that: hasRawData<Uint8>(message)),
                  message.length,
                  any(that: hasRawData<Uint8>(publicKey)),
                ),
          ]);
        });

        test('returns sealed data', () {
          final cipher = List.generate(25, (index) => 100 - index);
          when(
            () => mockSodium.crypto_box_seal(
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer<Uint8>, cipher);
            return 0;
          });

          final result = sut.seal(
            message: Uint8List(20),
            publicKey: Uint8List(5),
          );

          expect(result, cipher);

          verify(() => mockSodium.sodium_free(any())).called(2);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_seal(
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.seal(
              message: Uint8List(10),
              publicKey: Uint8List(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(2);
        });
      });

      group('sealOpen', () {
        test('asserts if cipherText is invalid', () {
          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(3),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_sealbytes());
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(20),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_publickeybytes());
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(20),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_secretkeybytes());
        });

        test('calls crypto_box_seal_open with correct arguments', () {
          when(
            () => mockSodium.crypto_box_seal_open(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(0);

          final cipherText = List.generate(20, (index) => index * 2);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.sealOpen(
            cipherText: Uint8List.fromList(cipherText),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verifyInOrder([
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(publicKey)),
                ),
            () => mockSodium.sodium_mprotect_readonly(
                  any(that: hasRawData(secretKey)),
                ),
            () => mockSodium.crypto_box_seal_open(
                  any(that: hasRawData<Uint8>(cipherText.sublist(5))),
                  any(that: hasRawData<Uint8>(cipherText)),
                  cipherText.length,
                  any(that: hasRawData<Uint8>(publicKey)),
                  any(that: hasRawData<Uint8>(secretKey)),
                ),
          ]);
        });

        test('returns decrypted data', () {
          final message = List.generate(8, (index) => index * 5);
          when(
            () => mockSodium.crypto_box_seal_open(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenAnswer((i) {
            fillPointer(i.positionalArguments.first as Pointer<Uint8>, message);
            return 0;
          });

          final result = sut.sealOpen(
            cipherText: Uint8List(13),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(result, message);

          verify(() => mockSodium.sodium_free(any())).called(3);
        });

        test('throws exception on failure', () {
          when(
            () => mockSodium.crypto_box_seal_open(
              any(),
              any(),
              any(),
              any(),
              any(),
            ),
          ).thenReturn(1);

          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(13),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );

          verify(() => mockSodium.sodium_free(any())).called(3);
        });
      });
    });
  });

  group('PrecalculatedBoxFFI', () {
    final sharedKey = Uint8List.fromList(List.generate(20, (index) => index));

    late PrecalculatedBoxFFI preSut;

    setUp(() {
      preSut = PrecalculatedBoxFFI(
        sut,
        SecureKeyFFI(
          SodiumPointer.raw(
            mockSodium,
            sharedKey.toPointer(),
            sharedKey.length,
          ),
        ),
      );

      when(() => mockSodium.crypto_box_macbytes()).thenReturn(5);
      when(() => mockSodium.crypto_box_noncebytes()).thenReturn(5);
    });

    group('easy', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.easy(
            message: Uint8List(20),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('calls crypto_box_easy_afternm with correct arguments', () {
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final mac = List.filled(5, 0);

        preSut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(sharedKey)),
              ),
          () => mockSodium.crypto_box_easy_afternm(
                any(that: hasRawData<Uint8>(mac + message)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(sharedKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: hasRawData(sharedKey)),
              ),
        ]);
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, cipher);
          return 0;
        });

        final result = preSut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
        );

        expect(result, cipher);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => preSut.easy(
            message: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('openEasy', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(3),
            nonce: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('calls crypto_box_open_easy_afternm with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final cipherText = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.openEasy(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(sharedKey)),
              ),
          () => mockSodium.crypto_box_open_easy_afternm(
                any(that: hasRawData<Uint8>(cipherText.sublist(5))),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(sharedKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: hasRawData(sharedKey)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = preSut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('detached', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.detached(
            message: Uint8List(20),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('calls crypto_box_detached_afternm with correct arguments', () {
        when(
          () => mockSodium.crypto_box_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(sharedKey)),
              ),
          () => mockSodium.crypto_box_detached_afternm(
                any(that: hasRawData<Uint8>(message)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(sharedKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: hasRawData(sharedKey)),
              ),
        ]);
      });

      test('returns encrypted data and mac', () {
        final cipherText = List.generate(10, (index) => index);
        final mac = List.generate(5, (index) => index * 3);
        when(
          () => mockSodium.crypto_box_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, cipherText);
          fillPointer(i.positionalArguments[1] as Pointer, mac);
          return 0;
        });

        final result = preSut.detached(
          message: Uint8List(10),
          nonce: Uint8List(5),
        );

        expect(
          result,
          DetachedCipherResult(
            cipherText: Uint8List.fromList(cipherText),
            mac: Uint8List.fromList(mac),
          ),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => preSut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('openDetached', () {
      test('asserts if mac is invalid', () {
        expect(
          () => preSut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test(
          'calls crypto_secretbox_open_detached_afternm with correct arguments',
          () {
        when(
          () => mockSodium.crypto_box_open_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final cipherText = List.generate(15, (index) => index * 2);
        final mac = List.generate(5, (index) => 20 - index);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.openDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(mac)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(sharedKey)),
              ),
          () => mockSodium.crypto_box_open_detached_afternm(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: hasRawData<Uint8>(mac)),
                cipherText.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(sharedKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: hasRawData(sharedKey)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(25, (index) => index);
        when(
          () => mockSodium.crypto_box_open_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = preSut.openDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_detached_afternm(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => preSut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    test('dispose frees shared key', () {
      preSut.dispose();

      verify(() => mockSodium.sodium_free(any(that: hasRawData(sharedKey))));
    });
  });
}
